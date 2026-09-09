# Testes e Qualidade

Camadas:
1. unitarios do dominio;
2. unitarios de exportacao;
3. unitarios de auditoria;
4. CI em push/PR;
5. verificacao sintatica de arquivos .mjs.

Casos de borda:
- valor zero;
- participantes invalidos;
- quantidade invalida;
- sobra de centavos;
- estado invalido na exportacao;
- evento de auditoria invalido.

Criterio de aceite:
suite completa verde antes da integracao.
