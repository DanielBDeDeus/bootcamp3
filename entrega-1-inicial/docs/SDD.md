# SDD - DividimOS Lite

## Problema
Pessoas que dividem despesas precisam registrar quem pagou cada conta e calcular o saldo final sem perder centavos ou depender de planilhas manuais.

## Objetivo
Criar uma camada de dominio deterministica, testavel e independente de interface.

## Requisitos funcionais
- RF-01: aceitar valores monetarios positivos com ponto ou virgula decimal.
- RF-02: dividir uma despesa entre N participantes preservando o total em centavos.
- RF-03: aceitar apenas quantidade inteira de participantes maior que zero.
- RF-04: calcular saldo individual a partir das despesas.
- RF-05: rejeitar pagador que nao esteja na lista de participantes.
- RF-06: rejeitar nomes vazios e duplicados.

## Requisitos nao funcionais
- RNF-01: Node.js 22.
- RNF-02: test harness sem bibliotecas externas.
- RNF-03: um unico comando executa toda a suite.
- RNF-04: nenhuma senha/token/dado pessoal real no repositorio.
- RNF-05: alteracoes por branch e Pull Request.

## Regras de negocio
- RN-01: valor deve ser finito e maior que zero.
- RN-02: participantCount deve ser inteiro > 0.
- RN-03: sobras de centavos sao distribuidas uma a uma.
- RN-04: soma das parcelas = valor original.
- RN-05: soma de todos os saldos finais = zero.
- RN-06: pagador precisa existir na lista.

## Contratos

### parseAmount(value)
Entrada: numero/string monetaria.
Saida: numero positivo arredondado para 2 casas.
Erro: RangeError para entrada invalida.

### splitExpense(amount, participantCount)
Entrada: valor valido + inteiro > 0.
Saida: array de parcelas cuja soma e exatamente igual ao valor.
Erro: RangeError para quantidade invalida.

### calculateBalances(people, expenses)
Entrada: nomes unicos + despesas {description, amount, payer}.
Saida: objeto {nome: saldo}.
Erro: lista vazia, nome invalido/duplicado, pagador inexistente ou valor invalido.

## Decomposicao
parseAmount -> splitExpense -> calculateBalances

Cada funcao e isolada e exportada para permitir SDD, teste unitario e iteracao.

## Criterios de aceite
- suite 100% verde;
- centavos preservados;
- zero participantes rejeitado;
- quantidade fracionaria rejeitada;
- pagador inexistente rejeitado;
- soma de saldos igual a zero.
