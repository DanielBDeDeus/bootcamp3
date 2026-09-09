# Finalizacao canonica

`bootcamp3-super.ps1` substitui a retomada do script Desktop V13 RESUME.
Os builders historicos foram aposentados: as tres entregas devem existir em main.
O helper de invocacao segura foi preservado e ajustado para extrair mensagens
de ErrorRecord sem a formatacao de stack trace do PowerShell 5.1.

Requisitos: Windows PowerShell 5.1, Git, sessoes gh existentes, Edge e ferramentas
portateis em `%LOCALAPPDATA%/Bootcamp3PortableTools` (Node v22.23.2 e gh).
Nao instala ferramentas nem inicia login. Reutiliza a configuracao gh da sessao.

Na raiz, atualizar `origin/main` com `git fetch --all --prune`, validar o parser e executar:

```powershell
$tokens = $null; $errors = $null
[System.Management.Automation.Language.Parser]::ParseFile(
    (Join-Path $PWD 'tools/bootcamp3-super.ps1'), [ref]$tokens, [ref]$errors
) | Out-Null
if ($errors.Count) { throw ($errors | Out-String) }
& ./tools/bootcamp3-super.ps1
```

Testes: `tools/tests/release.tests.ps1` (validar parser antes) e
`node --test tools/tests/text.test.mjs` com Node 22. CI Windows executa as
regressoes sem autenticacao nem mutacoes GitHub.

Efeitos autorizados: criar release ausente em main, habilitar/deployar Pages,
configurar protecao somente se ausente. Nao recria PRs ou Issues, nao muda
historico Git e nao remove sessoes. Erros reais de release falham; recursos
opcionais recusados ficam nos JSONs de evidencia.

Saidas locais ignoradas pelo Git: `artifacts/submission`. Incluem tres PDFs
Letter, HTMLs, testes com cobertura, snapshots GitHub, auditoria e hashes.
Cada reexecucao substitui esses relatorios. Preservar UTF-8 com BOM nos `.ps1`
para que o PowerShell 5.1 interprete corretamente caracteres nao ASCII.

Verificacao de PDFs e texto: Python com PyMuPDF, instalado localmente em
`artifacts/python-tools` (`python -m pip install --target artifacts/python-tools pymupdf`).
A execucao final verifica texto extraido, Letter, paginacao e metadados dos PDFs,
e varre textos atuais do projeto e artefatos. Historico `.git`, bibliotecas
instaladas e perfis de navegador sao excluidos; conteudo binario nao e tratado
como texto. Referencias conceituais da disciplina sao distintas de afirmacoes
sobre a producao destes materiais. A auditoria nao declara autoria sem auxilio.
