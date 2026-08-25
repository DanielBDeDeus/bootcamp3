# ADR 0002 - Persistência em LocalStorage

## Status

Aceito para a entrega intermediária.

## Contexto

O protótipo precisa conservar dados entre recargas sem depender de infraestrutura externa.

## Decisão

Usar LocalStorage apenas com dados fictícios/de demonstração.

## Consequências

- Setup mínimo.
- Sem sincronização entre dispositivos.
- Não adequado para dados pessoais ou sensíveis.
- Uma versão futura pode migrar para backend autenticado.