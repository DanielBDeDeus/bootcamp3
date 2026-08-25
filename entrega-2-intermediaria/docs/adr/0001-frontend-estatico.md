# ADR 0001 - Front-end estático sem framework

## Status

Aceito.

## Contexto

A entrega precisa ser simples de executar, publicar, revisar e testar.

## Decisão

Usar HTML, CSS e JavaScript ES Modules, com regra de negócio separada da interface.

## Consequências

### Benefícios

- Poucas dependências.
- Execução simples.
- Testes da regra de negócio independentes da interface.
- Menor superfície de manutenção.

### Trade-offs

- Menos abstrações prontas que frameworks.
- Estado e renderização precisam ser controlados pela própria aplicação.