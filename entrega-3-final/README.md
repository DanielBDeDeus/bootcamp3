# Entrega 3 - Entrega Final

## DividimOS Lite
Aplicacao web para rateio de despesas entre duas pessoas.

## Executar a aplicacao
Abra `web/index.html` por um servidor local.

Com Python:
```powershell
python -m http.server 8000 -d entrega-3-final/web
```

Ou com Docker:
```powershell
cd entrega-3-final
docker compose up --build
```

## Testes
```powershell
cd entrega-3-final
node --test
```

## Estrutura
- web/: aplicacao
- tests/: suite automatizada
- docs/: especificacao, arquitetura, seguranca, CI/CD, observabilidade, retrospectiva e evidencias
- Dockerfile / docker-compose.yml

## Evidencias
docs/evidencias/
