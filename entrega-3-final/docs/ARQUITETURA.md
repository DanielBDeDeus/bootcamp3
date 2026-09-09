# Arquitetura Final

```text
index.html
   |
app.mjs ------------------- localStorage
   |
   +--> finance.mjs
   +--> export.mjs
   +--> audit.mjs

tests/
   +--> finance.test.mjs
   +--> export.test.mjs
   +--> audit.test.mjs

GitHub Actions
   +--> testes Entrega 1
   +--> testes Entrega 2
   +--> testes Entrega 3
   +--> verificacao de sintaxe
```

Decisao central:
manter a regra de negocio em modulos puros para que a interface seja substituivel sem alterar os contratos do dominio.
