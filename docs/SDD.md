# Especificacao da automacao de finalizacao

A especificacao funcional da Entrega 1 permanece em
`entrega-1-inicial/docs/SDD.md`; o As-Built esta em
`entrega-3-final/docs/SPEC-FINAL.md`.

## Requisitos afetados nesta retomada

- AUT-01: manter `tools/bootcamp3-super.ps1` como unica copia mantida, derivada
  do script V13 RESUME. Nao reconstruir entregas ja integradas.
- AUT-02: consultar release por captura explicita de exit code/stdout/stderr.
  Sucesso reutiliza; `release not found` cria em main; outros erros preservam
  a mensagem e falham. Executar essa etapa mesmo com checkpoint da Entrega 3.
- AUT-03: reutilizar sessoes existentes, Node 22 e Windows PowerShell 5.1.
- AUT-04: falhas opcionais de Pages/protecao ficam registradas sem interromper
  testes, auditoria e relatorios. Nao reduzir protecao existente.
- AUT-05: gerar tres PDFs Letter com identificacao academica, evidencias reais,
  paginacao e verificacao de existencia/tamanho. Nao alegar revisao independente
  de ProcyonOps nem testes de ferramentas de IA nao executadas.

## Re-especificacao de 2026-09-09

A retomada separa finalizacao dos builders historicos: o checkpoint integrado
nao implica que release, Pages ou relatorios estejam concluidos. Saidas locais
ficam em `artifacts/submission`, sem modificar evidencias historicas das entregas.
Testes de regressao: `tools/tests/release.tests.ps1` cobre release existente,
ausente, erro de permissao, rede e criacao recusada.

AUT-06: a descricao e os READMEs devem preservar portugues em UTF-8 sem
mojibake. A regressao `tools/tests/text.test.mjs` verifica os tres documentos
onde a corrupcao foi observada; `.ps1` usa BOM para PowerShell 5.1.

AUT-07: revisar textos atuais e PDFs quanto a mencoes de assistencia na producao,
preservando discussoes conceituais da disciplina. Registrar a abrangencia da
varredura em TEXT-AUDIT.json; nao reescrever historico publicado nem formular
declaracoes de autoria sem auxilio. Validar texto extraido e paginacao dos PDFs.
