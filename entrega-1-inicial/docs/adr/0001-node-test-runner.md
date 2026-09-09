# ADR 0001 - Node.js 22 e test runner nativo

Status: aceito.

Decisao:
Usar ES Modules e node --test.

Motivos:
- zero dependencias de teste;
- funciona localmente e no GitHub Actions;
- pode ser usado com Node portatil sem admin.

Trade-off:
menos recursos de framework, mas menor complexidade operacional.
