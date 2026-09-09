# Refinamento por feedback

## Falha identificada
A especificacao inicial nao dizia explicitamente o que acontecia com quantidade zero ou fracionaria de participantes.

## Teste primeiro
Foram definidos testes para participantCount = 0 e participantCount = 1.5.

## Re-especificacao
A quantidade de participantes deve ser um numero inteiro maior que zero.

## Correcao
A validacao passou a ser responsabilidade da funcao splitExpense.

## Ciclo documentado
especificacao -> teste -> falha esperada -> refinamento -> implementacao -> regressao completa
