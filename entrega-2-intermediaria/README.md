# DividimOS Lite - Bootcamp III

AplicaÃ§Ã£o web simples para registrar despesas compartilhadas entre duas pessoas e calcular automaticamente o saldo de cada participante.

## Problema

Em despesas compartilhadas, Ã© comum perder o controle de quem pagou cada conta e quanto cada pessoa deve ao final. O projeto registra despesas e calcula o acerto automaticamente.

## Funcionalidades

- Cadastro de dois participantes.
- Registro de descriÃ§Ã£o, valor e pagador.
- Rateio automÃ¡tico.
- Saldo individual.
- PersistÃªncia no navegador.
- Testes automatizados.
- CI com GitHub Actions.
- ADRs e fluxo de governanÃ§a.

## Arquitetura

```mermaid
flowchart LR
    UI[index.html + app.mjs]
    RULES[finance.mjs]
    STORE[(LocalStorage)]
    TESTS[Testes Node.js]
    CI[GitHub Actions]

    UI --> RULES
    UI --> STORE
    TESTS --> RULES
    CI --> TESTS
```

## Executar localmente

Se houver Python disponÃ­vel:

```bash
python -m http.server 8000 -d web
```

Depois abra:

`http://localhost:8000`

TambÃ©m Ã© possÃ­vel abrir os arquivos com uma extensÃ£o/servidor local de sua preferÃªncia.

## Testes

O CI usa Node.js 22 e executa:

```bash
cd entrega-2-intermediaria

npm test
```

NÃ£o Ã© necessÃ¡rio instalar Node.js no computador da sala para que o GitHub Actions execute os testes.

## GovernanÃ§a

Veja:

- `CONTRIBUTING.md`
- `.github/PULL_REQUEST_TEMPLATE.md`
- `.github/ISSUE_TEMPLATE/tarefa.md`

## DecisÃµes arquiteturais

- `docs/adr/0001-frontend-estatico.md`
- `docs/adr/0002-persistencia-local.md`
- `docs/adr/0003-ci.md`

## Documentos da entrega

- `docs/ERROS-E-REESPECIFICACAO.md`
- `docs/ANALISE-IA.md`
- `docs/PROMPT-PADRAO-AGENTES.md`
- `docs/CHECKLIST-ENTREGA.md`
- `docs/RELATORIO-FINAL.md`

## SeguranÃ§a

NÃ£o inserir segredos, tokens, senhas ou dados pessoais reais neste repositÃ³rio.