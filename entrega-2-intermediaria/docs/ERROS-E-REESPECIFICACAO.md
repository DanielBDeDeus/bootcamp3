# Erros lÃ³gicos e loop de re-especificaÃ§Ã£o

## Caso de borda: quantidade invÃ¡lida de participantes

### EspecificaÃ§Ã£o inicial

A funÃ§Ã£o de rateio recebia um valor e uma quantidade de participantes.

### Falha identificada

O caso `participantCount = 0` nÃ£o possuÃ­a comportamento explicitamente definido.

### Teste automatizado

Foi criado primeiro um teste exigindo erro explÃ­cito para quantidade zero ou fracionÃ¡ria de participantes.

### Re-especificaÃ§Ã£o

A regra passou a exigir:

> A quantidade de participantes deve ser um nÃºmero inteiro maior que zero.

### CorreÃ§Ã£o

A funÃ§Ã£o `splitExpense` passou a validar a prÃ©-condiÃ§Ã£o e lanÃ§ar `RangeError` quando ela nÃ£o Ã© satisfeita.

### EvidÃªncia no GitHub

A branch `entrega2/validacao-borda` registra:

1. commit adicionando o teste;
2. primeiro push com CI vermelho;
3. commit posterior corrigindo a regra;
4. segundo push com CI verde;
5. Pull Request para revisÃ£o por outro integrante.

Isso demonstra o ciclo:

**teste -> falha -> re-especificaÃ§Ã£o -> correÃ§Ã£o -> novo teste**