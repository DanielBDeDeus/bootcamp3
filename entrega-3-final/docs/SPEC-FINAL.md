# Especificacao Final - DividimOS Lite

## Objetivo
Entregar uma aplicacao funcional e verificavel para rateio de despesas entre duas pessoas.

## Funcionalidades
- cadastro dos participantes;
- inclusao/remocao de despesas;
- calculo de saldos;
- sugestao de acerto;
- persistencia local;
- exportacao JSON;
- reset local;
- trilha de eventos em memoria para observabilidade da sessao.

## Qualidade
- regras de dominio isoladas da UI;
- testes unitarios automatizados;
- CI para as tres entregas;
- ambiente executavel por Docker;
- ausencia de dependencias de runtime externas.

## Criterios de aceite
- todos os testes passam;
- soma dos saldos e zero em cenarios validos;
- centavos nao desaparecem;
- dados invalidos sao rejeitados;
- exportacao e deterministica;
- nenhuma credencial e necessaria para executar a aplicacao.
