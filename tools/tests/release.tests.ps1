#requires -version 5.1
$ErrorActionPreference = 'Stop'
$tokens = $null; $errors = $null
$ast = [System.Management.Automation.Language.Parser]::ParseFile((Join-Path $PSScriptRoot '../bootcamp3-super.ps1'), [ref]$tokens, [ref]$errors)
if ($errors.Count) { throw ($errors | Out-String) }
$probe = $ast.Find({param($n) $n -is [System.Management.Automation.Language.FunctionDefinitionAst] -and $n.Name -eq 'Invoke-GhProbe'}, $true)
Invoke-Expression $probe.Extent.Text
$script:GhExe = $env:ComSpec
$native = Invoke-GhProbe -Arguments @('/d','/c','echo release not found 1>&2 & exit /b 1')
if ($native.ExitCode -ne 1 -or $native.StdErr.Trim() -ne 'release not found' -or $native.StdOut.Trim()) { throw 'Native stderr/exit capture failed' }
if ($ErrorActionPreference -ne 'Stop') { throw 'Caller preference was not restored' }
Write-Output 'PASS: native stderr under ErrorActionPreference Stop'
$fn = $ast.Find({param($n) $n -is [System.Management.Automation.Language.FunctionDefinitionAst] -and $n.Name -eq 'Ensure-Release'}, $true)
if (-not $fn) { throw 'Ensure-Release missing' }
Invoke-Expression $fn.Extent.Text
$RepoSlug = 'example/repo'
function Ok($Text) {}
function Info($Text) {}
function Invoke-GhProbe($Arguments) {
    $script:Calls.Add(($Arguments -join '|'))
    if ($Arguments[1] -eq 'create') { return $script:CreateResult }
    return $script:ViewResult
}
function Result($Code, $Out, $Err) { [pscustomobject]@{ExitCode=$Code;StdOut=$Out;StdErr=$Err} }
foreach ($case in 'exists','missing','forbidden','network','create-fails') {
    $script:Calls = New-Object 'System.Collections.Generic.List[string]'
    $script:CreateResult = Result 0 'created' ''
    $script:ViewResult = switch ($case) {
        exists { Result 0 '{}' '' }
        missing { Result 1 '' 'release not found' }
        forbidden { Result 1 '' 'HTTP 403: Forbidden' }
        network { Result 1 '' 'connection reset' }
        create-fails { Result 1 '' 'release not found'; $script:CreateResult = Result 1 '' 'HTTP 403: Forbidden' }
    }
    $caught = $null
    try { Ensure-Release } catch { $caught = $_ }
    $shouldFail = $case -in @('forbidden','network','create-fails')
    if ([bool]$caught -ne $shouldFail) { throw "Unexpected outcome: $case / $caught" }
    $expectedCalls = if ($case -in @('missing','create-fails')) { 2 } else { 1 }
    if ($script:Calls.Count -ne $expectedCalls) { throw "Unexpected mutations: $case" }
    if ($expectedCalls -eq 2 -and $script:Calls[1] -notmatch '--target\|main') { throw 'Wrong release target' }
    if ($caught -and $caught.ToString() -notmatch 'Forbidden|connection reset') { throw 'Original error lost' }
    Write-Output "PASS: $case"
}
$global:LASTEXITCODE = 0
