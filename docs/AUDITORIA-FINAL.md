# Auditoria da finalizacao — 09/09/2026

Base funcional auditada: `1e1f0d5584661200dd679ada17b40ea590a5cd58` (PR #20).
As entregas existentes foram preservadas; esta manutencao corrige a automacao
de retomada, a codificacao de documentos e adiciona testes de regressao.

| Verificacao | Evidencia observada |
|---|---|
| Entrega 1 | 10/10 testes, Node v22.23.2 |
| Entrega 2 | 10/10 testes, Node v22.23.2 |
| Entrega 3 | 10/10 testes, Node v22.23.2 |
| Cobertura E1 | finance.mjs: linhas 97,01%; branches 92,59%; funcoes 100% |
| Cobertura E2 | finance.mjs: linhas 89,83%; branches 84,21%; funcoes 100%; export.mjs 100% |
| Cobertura E3 | finance.mjs: linhas 94,95%; branches 80,77%; funcoes 100%; audit.mjs: linhas 94,44%; branches 66,67%; export.mjs 100% |
| PRs historicos | #14, #15, #19, #20 MERGED, checks SUCCESS |
| CI funcional | Run 34354131984 SUCCESS no commit auditado |
| Release | v1.0.0-bootcamp3 criada em main; tag preservada nas retomadas |
| Protecao main | PR + uma aprovacao; force push e exclusao desabilitados; administradores nao obrigados |
| Pages | Habilitado por workflow; deploy concluido com sucesso |
| PDF | Tres documentos Letter 612 x 792 pt, metadados, paginacao e evidencias |

Site: https://danielbdedeus.github.io/bootcamp3/

Release: https://github.com/DanielBDeDeus/bootcamp3/releases/tag/v1.0.0-bootcamp3

## Evidencias reproduziveis

Executar o [script canonico](../tools/README.md) gera `artifacts/submission`:
`FINAL-AUDIT.json`, `FINAL-TEST-ENTREGA*.txt`, snapshots de PRs/Issues/Actions,
configuracao Pages/protecao, referencia da tag, PDFs, HTMLs e SHA256SUMS.json.
Esses arquivos indicam o SHA e a data efetivamente consultados, sem alterar
evidencias historicas das entregas. Relatorios sao locais para submissao.

## Limites de evidencia

ProcyonOps pertence ao mesmo autor e nao e revisao humana independente.
Nao ha experimento comparativo documentado na matriz da Entrega 2; ela nao deve
ser interpretada como experimento realizado. Issues historicas ainda abertas
nao sao PRs de integracao pendentes. Falha historica de Pages foi preservada
no historico; o deploy posterior confirmou a correcao da configuracao.

Testes de dominio e cobertura nao comprovam homologacao humana da interface.
Se a rubrica exigir outra pessoa ou varias IAs efetivamente testadas, esses
pontos dependem de evidencias adicionais reais.
