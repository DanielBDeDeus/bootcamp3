# Erros lógicos e loop de re-especificação

## Caso de borda: quantidade inválida de participantes

### Especificação inicial

A função de rateio recebia um valor e uma quantidade de participantes.

### Falha identificada

O caso `participantCount = 0` não possuía comportamento explicitamente definido.

### Teste automatizado

Foi criado primeiro um teste exigindo erro explícito para quantidade zero ou fracionária de participantes.

### Re-especificação

A regra passou a exigir:

> A quantidade de participantes deve ser um número inteiro maior que zero.

### Correção

A função `splitExpense` passou a validar a pré-condição e lançar `RangeError` quando ela não é satisfeita.

### Evidência no GitHub

A branch `entrega2/validacao-borda` registra:

1. commit adicionando o teste;
2. primeiro push com CI vermelho;
3. commit posterior corrigindo a regra;
4. segundo push com CI verde;
5. Pull Request para revisão técnica. ProcyonOps é uma conta do mesmo autor;
   esse registro não comprova revisão independente por outra pessoa.

Isso demonstra o ciclo:

**teste -> falha -> re-especificação -> correção -> novo teste**
