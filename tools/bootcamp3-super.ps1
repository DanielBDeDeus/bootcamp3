#requires -version 5.1
# Canonical resume automation. Safe invocation retained from V13 RESUME.
# Completed builders intentionally retired: main is verified before finalization.
function Invoke-GhProbe {
    param(
        [Parameter(Mandatory=$true)]
        [string[]]$Arguments
    )

    $Id = [Guid]::NewGuid().ToString("N")
    $OutFile = Join-Path $env:TEMP ("bootcamp3-gh-" + $Id + ".out")
    $ErrFile = Join-Path $env:TEMP ("bootcamp3-gh-" + $Id + ".err")

    $OldPreference = $ErrorActionPreference

    try {
        # IMPORTANT:
        # Do NOT use Start-Process -ArgumentList here.
        # Windows PowerShell 5.1 re-quotes/reconstructs that command line and
        # breaks arguments containing spaces, e.g.:
        #
        #   --title "Integrar Entrega 1 em main"
        #
        # becoming several separate gh arguments.
        #
        # `& executable @Arguments` preserves the argument-array boundaries.
        $ErrorActionPreference = "Continue"

        $records = @(& $script:GhExe @Arguments 2>&1)
        $ExitCode = $LASTEXITCODE

        # PS 5.1 wraps native stderr in ErrorRecord; extract the message instead
        # of persisting its formatted PowerShell stack trace.
        $records | Where-Object { $_ -isnot [System.Management.Automation.ErrorRecord] } |
            ForEach-Object { [string]$_ } | Set-Content -LiteralPath $OutFile -Encoding UTF8
        $records | Where-Object { $_ -is [System.Management.Automation.ErrorRecord] } |
            ForEach-Object { $_.Exception.Message } | Set-Content -LiteralPath $ErrFile -Encoding UTF8

        $StdOut = if (Test-Path -LiteralPath $OutFile) {
            Get-Content -LiteralPath $OutFile -Raw -ErrorAction SilentlyContinue
        }
        else {
            ""
        }

        $StdErr = if (Test-Path -LiteralPath $ErrFile) {
            Get-Content -LiteralPath $ErrFile -Raw -ErrorAction SilentlyContinue
        }
        else {
            ""
        }

        return [pscustomobject]@{
            ExitCode = [int]$ExitCode
            StdOut   = [string]$StdOut
            StdErr   = [string]$StdErr
        }
    }
    finally {
        $ErrorActionPreference = $OldPreference
        Remove-Item -LiteralPath $OutFile,$ErrFile -Force -ErrorAction SilentlyContinue
    }
}



function Ensure-Release {
    $tag = 'v1.0.0-bootcamp3'
    $view = Invoke-GhProbe -Arguments @('release','view',$tag,'--repo',$RepoSlug,'--json','tagName,url,targetCommitish')
    if ($view.ExitCode -eq 0) { Info "Release $tag ja existe."; return }
    if (($view.StdErr + $view.StdOut) -notmatch '(?im)^\s*release not found\s*$') {
        throw "Falha ao consultar release (exit $($view.ExitCode)): $($view.StdErr) $($view.StdOut)"
    }
    $created = Invoke-GhProbe -Arguments @('release','create',$tag,'--repo',$RepoSlug,'--target','main','--title','Bootcamp III - Entrega Final','--notes','Release academica consolidando Entregas 1, 2 e 3 do DividimOS Lite. ProcyonOps e conta tecnica do mesmo autor, sem revisao independente.')
    if ($created.ExitCode -ne 0) { throw "Falha ao criar release: $($created.StdErr) $($created.StdOut)" }
    Ok "Release $tag criada em main."
}

function Info([string]$Message) { Write-Host $Message; Add-Content $MasterLog $Message }
function Ok([string]$Message) { Info $Message }
function GhJson([string[]]$Arguments) {
    $r = Invoke-GhProbe -Arguments $Arguments
    if ($r.ExitCode -ne 0) { throw "gh $($Arguments -join ' '): $($r.StdErr) $($r.StdOut)" }
    return ($r.StdOut | ConvertFrom-Json)
}
function SaveJson($Value, [string]$Name) {
    ConvertTo-Json -InputObject $Value -Depth 30 | Set-Content (Join-Path $OutputDir $Name) -Encoding UTF8
}
function Configure-OptionalFeatures {
    $protection = Invoke-GhProbe -Arguments @('api',"repos/$RepoSlug/branches/main/protection")
    if ($protection.ExitCode -ne 0 -and ($protection.StdOut + $protection.StdErr) -match '404') {
        $body = Join-Path $OutputDir 'protection-request.json'
        '{"required_status_checks":null,"enforce_admins":false,"required_pull_request_reviews":{"required_approving_review_count":1},"restrictions":null,"allow_force_pushes":false,"allow_deletions":false}' | Set-Content $body -Encoding ASCII
        $protection = Invoke-GhProbe -Arguments @('api','--method','PUT',"repos/$RepoSlug/branches/main/protection",'--input',$body)
    }
    SaveJson $protection 'MAIN-PROTECTION.json'
    $script:ProtectionStatus = if ($protection.ExitCode -eq 0) { 'PASS' } else { 'BLOCKED' }
    Info "main protection: $ProtectionStatus"

    $pages = Invoke-GhProbe -Arguments @('api',"repos/$RepoSlug/pages")
    if ($pages.ExitCode -ne 0 -and ($pages.StdOut + $pages.StdErr) -match '404') {
        $pages = Invoke-GhProbe -Arguments @('api','--method','POST',"repos/$RepoSlug/pages",'-f','build_type=workflow')
    }
    SaveJson $pages 'PAGES-CONFIG.json'
    $script:PagesStatus = 'BLOCKED'
    if ($pages.ExitCode -eq 0) {
        $existing = @(GhJson @('run','list','--repo',$RepoSlug,'--workflow','pages.yml','--limit','1','--json','databaseId,status,conclusion,headSha,url'))
        if ($existing.Count -and $existing[0].conclusion -eq 'success' -and $existing[0].headSha -eq $MainSha) {
            $script:PagesStatus = 'PASS'
        } else {
            $dispatch = Invoke-GhProbe -Arguments @('workflow','run','pages.yml','--repo',$RepoSlug,'--ref','main')
            SaveJson $dispatch 'PAGES-DISPATCH.json'
            if ($dispatch.ExitCode -eq 0) {
                for ($attempt=0; $attempt -lt 36; $attempt++) {
                    Start-Sleep -Seconds 5
                    $runs = @(GhJson @('run','list','--repo',$RepoSlug,'--workflow','pages.yml','--limit','1','--json','databaseId,status,conclusion,headSha,url'))
                    if ($runs.Count -and $runs[0].headSha -eq $MainSha -and $runs[0].status -eq 'completed' -and
                        (-not $existing.Count -or $runs[0].databaseId -ne $existing[0].databaseId)) {
                        if ($runs[0].conclusion -eq 'success') { $script:PagesStatus = 'PASS' }
                        SaveJson $runs 'PAGES-RUN.json'; break
                    }
                    if ($attempt % 6 -eq 0) { Info 'Aguardando deploy Pages...' }
                }
            }
        }
    }
    Info "GitHub Pages: $PagesStatus; detalhes em PAGES-*.json"
}

function Html([object]$Value) { [System.Net.WebUtility]::HtmlEncode([string]$Value) }
function New-SubmissionReport([int]$Number, [string]$Folder, [string]$TestLog) {
    $prRows = (@($script:PRs) | ForEach-Object { '<tr><td>#'+$_.number+'</td><td>'+(Html $_.title)+'</td><td>'+(Html $_.state)+'</td></tr>' }) -join "`n"
    $issueRows = (@($script:Issues) | ForEach-Object { '<tr><td>#'+$_.number+'</td><td>'+(Html $_.title)+'</td><td>'+(Html $_.state)+'</td></tr>' }) -join "`n"
    $runRows = (@($script:Runs) | Select-Object -First 8 | ForEach-Object { '<tr><td>'+ $_.databaseId+'</td><td>'+(Html $_.name)+'</td><td>'+(Html $_.conclusion)+'</td></tr>' }) -join "`n"
    $specPath = switch ($Number) { 1 {'docs/SDD.md'} 2 {'docs/RELATORIO-FINAL.md'} 3 {'docs/SPEC-FINAL.md'} }
    $spec = Get-Content (Join-Path (Join-Path $WorkDir $Folder) $specPath) -Raw -Encoding UTF8
    $log = Get-Content $TestLog -Raw -Encoding UTF8
    $summary = ($log -split "`r?`n" | Where-Object { $_ -match '^# (tests|suites|pass|fail|cancelled|skipped|duration_ms|all files)|^\s*#.*\|' }) -join "`n"
    $path = Join-Path $OutputDir "BOOTCAMP3-ENTREGA$Number-DANIEL-BARROS-DE-DEUS"
    $report = @"
<!doctype html><html lang="pt-BR"><head><meta charset="utf-8"><title>Bootcamp III - Entrega $Number</title>
<style>
@page { size: Letter; margin: 17mm 16mm 19mm; @bottom-center { content: 'CEUB | Bootcamp III - Daniel Barros de Deus | Pagina ' counter(page) ' de ' counter(pages); font: 8pt Arial; color: #54246f; } }
body{font:10pt Arial,sans-serif;color:#251c2d;line-height:1.45;margin:0}header{border-top:8px solid #552377;border-bottom:3px solid #b82685;padding:12px 0}header small{color:#ae227c;letter-spacing:2px}h1{font-size:23pt;color:#512071;margin:8px 0}h2{font-size:14pt;color:#652780;border-bottom:1px solid #e2d5ed;margin-top:22px;break-after:avoid}table{width:100%;border-collapse:collapse;font-size:8.5pt;margin:14px 0}td,th{border:1px solid #ddd1e6;padding:6px;text-align:left}th,.metadata{background:#f0e8f7}tr{break-inside:avoid}pre{white-space:pre-wrap;overflow-wrap:anywhere;background:#f6f3f8;border-left:3px solid #ac3288;padding:12px;font:8pt Consolas,monospace}.pagebreak{break-before:page}a{color:#652780}.note{background:#f4eef8;padding:12px}
</style></head><body><header><small>CEUB / ESPACO ALUNO</small><h1>Bootcamp III Â· Entrega $Number</h1><p>Relatorio academico de submissao e evidencias tecnicas</p></header>
<table class="metadata"><tr><th>Disciplina</th><td>Bootcamp III</td><th>Atividade</th><td>Entrega $Number</td></tr><tr><th>Aluno</th><td>Daniel Barros de Deus</td><th>RA</th><td>22600468</td></tr><tr><th>Data</th><td>$(Get-Date -Format 'dd/MM/yyyy')</td><th>Repositorio</th><td>github.com/$RepoSlug</td></tr></table>
<h2>1. Resultado verificado</h2><p>Entrega presente em main, commit <b>$MainSha</b>. Suite executada com Node $NodeVersion e PowerShell $($PSVersionTable.PSVersion). Resultados desta execucao:</p><pre>$(Html $summary)</pre>
<p>Release: v1.0.0-bootcamp3. Protecao main: $ProtectionStatus. GitHub Pages: $PagesStatus.</p>
<h2>2. Escopo tecnico / especificacao existente</h2><pre>$(Html $spec)</pre>
<h2>3. Responsabilidade e limites</h2><p class="note">Trabalho de Daniel Barros de Deus. ProcyonOps e conta tecnica do mesmo autor; aprovacoes dessa conta nao constituem revisao humana independente. A matriz comparativa pendente nao representa testes realizados.</p>
<p>Dados da aplicacao ficam no armazenamento local do navegador. Nao publicar tokens ou dados pessoais de despesas. Testes automatizados nao substituem homologacao humana de usabilidade, seguranca ou propriedade intelectual.</p>
<h2>4. Reproducao e demonstracao</h2><pre>cd $Folder
node --test
node --test --experimental-test-coverage</pre><p>Usar Node 22. Consultar README, documentacao e roteiro de demonstracao da entrega. Artefatos JSON e logs completos acompanham este PDF.</p>
<div class="pagebreak"></div><h2>5. Governanca â€” Pull Requests</h2><table><thead><tr><th>PR</th><th>Descricao</th><th>Estado</th></tr></thead><tbody>$prRows</tbody></table>
<h2>6. Issues â€” estado real</h2><table><thead><tr><th>Issue</th><th>Descricao</th><th>Estado</th></tr></thead><tbody>$issueRows</tbody></table>
<h2>7. GitHub Actions â€” execucoes recentes</h2><table><thead><tr><th>Run</th><th>Workflow</th><th>Conclusao</th></tr></thead><tbody>$runRows</tbody></table><p>Falhas historicas permanecem registradas. Consultar GITHUB-ACTIONS.json para URLs e estados completos.</p>
<h2>8. Fontes e limitacoes</h2><p><a href="https://github.com/$RepoSlug/tree/main/$Folder">Repositorio / $Folder</a><br><a href="https://github.com/$RepoSlug/releases/tag/v1.0.0-bootcamp3">Release oficial</a></p><p>Configuracao de Pages e protecao: PAGES-CONFIG.json e MAIN-PROTECTION.json. Cobertura mede exercicio do codigo, nao ausencia de defeitos. Eventuais requisitos de revisao por outra pessoa ou comparacao experimental de varias IAs permanecem dependentes de evidencia real.</p></body></html>
"@
    $report | Set-Content "$path.html" -Encoding UTF8
    $edge = @("${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe", "$env:ProgramFiles\Microsoft\Edge\Application\msedge.exe") | Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1
    if (-not $edge) { throw 'Microsoft Edge nao encontrado para PDF.' }
    $profile = Join-Path $OutputDir ('edge-profile-' + $Number)
    $pdf = "$path.pdf"
    if (Test-Path -LiteralPath $pdf) { Remove-Item -LiteralPath $pdf -Force }
    $args = @('--headless=new','--disable-gpu','--no-first-run','--no-pdf-header-footer', ('--user-data-dir="'+$profile+'"'), ('--print-to-pdf="'+$pdf+'"'), ('"'+([uri]"$path.html").AbsoluteUri+'"'))
    $process = Start-Process -FilePath $edge -ArgumentList $args -PassThru -WindowStyle Hidden
    if (-not $process.WaitForExit(60000)) { throw 'Edge excedeu 60s; verificar processo e PDF.' }
    if (-not (Test-Path -LiteralPath $pdf) -or (Get-Item $pdf).Length -lt 10000) { throw "PDF ausente/invalido: $pdf" }
    Info "PDF verificado: $pdf ($((Get-Item $pdf).Length) bytes)"
}

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
$WorkDir = Split-Path -Parent $PSScriptRoot
$OutputDir = Join-Path $WorkDir 'artifacts/submission'
$RepoSlug = 'DanielBDeDeus/bootcamp3'
$script:GhExe = Join-Path $env:LOCALAPPDATA 'Bootcamp3PortableTools/gh/bin/gh.exe'
$script:NodeExe = Join-Path $env:LOCALAPPDATA 'Bootcamp3PortableTools/node22/node-v22.23.2-win-x64/node.exe'
New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null
$MasterLog = Join-Path $OutputDir 'SUPER-SCRIPT-LOG.txt'
Set-Content $MasterLog "Retomada $(Get-Date -Format o)" -Encoding UTF8
Push-Location $WorkDir
try {
    $NodeVersion = (& $script:NodeExe --version | Out-String).Trim()
    if ($NodeVersion -notmatch '^v22\.') { throw "Node 22 obrigatorio: $NodeVersion" }
    $account = Invoke-GhProbe -Arguments @('auth','switch','--hostname','github.com','--user','DanielBDeDeus')
    if ($account.ExitCode -ne 0) { throw "Sessao principal indisponivel: $($account.StdErr)" }
    $user = GhJson @('api','user')
    if ($user.login -ne 'DanielBDeDeus') { throw 'Conta ativa incorreta' }
    $main = GhJson @('api',"repos/$RepoSlug/commits/main")
    $MainSha = $main.sha
    $localMain = (& git rev-parse origin/main | Out-String).Trim()
    if ($localMain -ne $MainSha) { throw 'origin/main desatualizado: executar git fetch antes de retomar.' }
    $folders = @('entrega-1-inicial','entrega-2-intermediaria','entrega-3-final')
    foreach ($folder in $folders) {
        $null = GhJson @('api',"repos/$RepoSlug/contents/${folder}?ref=main")
        $delta = & git diff $MainSha -- $folder
        if ($LASTEXITCODE -ne 0 -or $delta) { throw "Entrega local difere de main: $folder" }
        Info "CHECKPOINT: $folder confirmado em main; builder nao executado."
    }
    foreach ($number in 14,15,19,20) {
        $pr = GhJson @('pr','view',"$number",'--repo',$RepoSlug,'--json','number,state,mergedAt,statusCheckRollup,url')
        SaveJson $pr "PR-$number.json"
        if ($pr.state -ne 'MERGED') { throw "PR #$number nao integrado" }
    }
    Ensure-Release
    SaveJson (GhJson @('release','view','v1.0.0-bootcamp3','--repo',$RepoSlug,'--json','tagName,url,targetCommitish,publishedAt')) 'RELEASE.json'
    SaveJson (GhJson @('api',"repos/$RepoSlug/git/ref/tags/v1.0.0-bootcamp3")) 'TAG.json'
    try { Configure-OptionalFeatures } catch {
        if (-not $script:ProtectionStatus) { $script:ProtectionStatus = 'BLOCKED' }
        $script:PagesStatus = 'BLOCKED'
        $_.ToString() | Set-Content (Join-Path $OutputDir 'OPTIONAL-FEATURE-ERROR.txt') -Encoding UTF8
        Info "Recurso opcional indisponivel: $_"
    }
    $script:PRs = @(GhJson @('pr','list','--repo',$RepoSlug,'--state','all','--limit','200','--json','number,title,state,url,headRefName,baseRefName,reviews'))
    $script:Issues = @(GhJson @('issue','list','--repo',$RepoSlug,'--state','all','--limit','200','--json','number,title,state,url'))
    $script:Runs = @(GhJson @('run','list','--repo',$RepoSlug,'--limit','50','--json','databaseId,name,status,conclusion,url,headSha,headBranch'))
    SaveJson $script:PRs 'GITHUB-PRS.json'; SaveJson $script:Issues 'GITHUB-ISSUES.json'; SaveJson $script:Runs 'GITHUB-ACTIONS.json'
    $ci = @($script:Runs | Where-Object { $_.headSha -eq $MainSha -and $_.name -eq 'Bootcamp III - CI Completo' })
    $ciStatus = if ($ci.Count -and $ci[0].conclusion -eq 'success') { 'PASS' } else { 'FAIL' }
    $openPRs = @($script:PRs | Where-Object { $_.state -eq 'OPEN' -and $_.headRefName -match '^(develop|feature/entrega)' })
    $testResults = @()
    for ($i=0; $i -lt $folders.Count; $i++) {
        $testLog = Join-Path $OutputDir "FINAL-TEST-ENTREGA$($i+1).txt"
        Push-Location (Join-Path $WorkDir $folders[$i])
        try {
            $old = $ErrorActionPreference
            $ErrorActionPreference = 'Continue'
            $output = & $script:NodeExe --test --experimental-test-coverage 2>&1
            $exitCode = $LASTEXITCODE
        } finally { $ErrorActionPreference = $old; Pop-Location }
        $output | Set-Content $testLog -Encoding UTF8
        $testResults += ($exitCode -eq 0)
        Info "Entrega $($i+1): exit $exitCode; $testLog"
        New-SubmissionReport ($i+1) $folders[$i] $testLog
    }
    & git status --short --branch | Set-Content (Join-Path $OutputDir 'GIT-STATUS.txt') -Encoding UTF8
    & git log --graph --decorate --oneline --all -60 | Set-Content (Join-Path $OutputDir 'GIT-HISTORY.txt') -Encoding UTF8
    & git ls-tree -r --name-only $MainSha | Set-Content (Join-Path $OutputDir 'REPO-FINAL-TREE.txt') -Encoding UTF8
    "Node: $NodeVersion`nPowerShell: $($PSVersionTable.PSVersion)`nMain: $MainSha`nGit: $(& git --version)" | Set-Content (Join-Path $OutputDir 'AMBIENTE.txt') -Encoding UTF8
    $audit = [ordered]@{date=(Get-Date -Format o);main=$MainSha;node=$NodeVersion;tests=$testResults;actions=$ciStatus;pendingIntegrationPRs=$openPRs.Count;release='v1.0.0-bootcamp3';protection=$ProtectionStatus;pages=$PagesStatus;independentHumanReview=$false;otherAIToolsTested=$false}
    SaveJson $audit 'FINAL-AUDIT.json'
    if ($testResults -contains $false -or $ciStatus -eq 'FAIL' -or $openPRs.Count) { throw 'Auditoria encontrou falha obrigatoria; consultar FINAL-AUDIT.json.' }
    & python (Join-Path $PSScriptRoot 'verify-pdfs.py')
    if ($LASTEXITCODE -ne 0) { throw 'Validacao de PDF falhou.' }
    & python (Join-Path $PSScriptRoot 'audit-submission-text.py')
    if ($LASTEXITCODE -ne 0) { throw 'Auditoria de texto encontrou mencoes a revisar.' }
    Get-ChildItem $OutputDir -File | Where-Object { $_.Extension -in '.pdf','.html','.json','.txt' -and $_.Name -notin @('SHA256SUMS.json','SUPER-SCRIPT-LOG.txt') } | Get-FileHash -Algorithm SHA256 | Select-Object @{Name='file';Expression={Split-Path $_.Path -Leaf}},Hash | ConvertTo-Json | Set-Content (Join-Path $OutputDir 'SHA256SUMS.json') -Encoding UTF8
    Info 'Finalizacao concluida. PDFs, auditoria de texto e evidencias em artifacts/submission.'
} finally { Pop-Location }

