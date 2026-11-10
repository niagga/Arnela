# Pruebas E2E (Playwright)

Smoke end-to-end del front contra una API real. Los specs viven en `frontend/e2e/`.

## Prerrequisitos

1. API Go y Postgres/Redis según `docker-compose.yml` o entorno local habitual.
2. Un usuario **admin** válido (misma base que usa el backoffice).
3. Node 22+ y pnpm en `frontend/`.

## Configuración

```powershell
cd frontend
Copy-Item e2e/.env.example e2e/.env
# Editar e2e/.env: E2E_ADMIN_EMAIL, E2E_ADMIN_PASSWORD, y opcionalmente E2E_BASE_URL / E2E_API_URL
```

`playwright.config.ts` carga automáticamente `e2e/.env` si existe (sin publicar secretos en git).

Alinear el front con la API:

- En `.env` del front, `NEXT_PUBLIC_API_URL` debe apuntar a la misma API que usará el navegador (p. ej. `http://127.0.0.1:8080/api/v1`).

## Instalar navegadores Playwright

```powershell
cd frontend
pnpm exec playwright install chromium
```

## Ejecutar E2E local

Con el **dev server** ya levantado (`pnpm dev` en otra terminal), evita que Playwright intente otro `pnpm dev`:

```powershell
cd frontend
$env:PLAYWRIGHT_SKIP_WEBSERVER="1"
pnpm test:e2e
```

Si preferís que Playwright arranque solo el front:

```powershell
cd frontend
pnpm test:e2e
```

## CI / GitHub Actions

Workflow: [`.github/workflows/e2e.yml`](../.github/workflows/e2e.yml).

**Cuándo corre**

- En cada `pull_request` a `main` (run bloqueante).
- Manualmente: pestaña *Actions* → **E2E** → *Run workflow* (`workflow_dispatch`).

Agrupa por ref con `concurrency`, así que un push nuevo cancela el run anterior del mismo PR.

**Qué hace**

| Paso | Detalle |
|------|---------|
| Services | `postgres:16-alpine` + `redis:7-alpine` (alineados a `docker-compose.yml`) |
| API | `go build` y arranque en background; **aplica las migraciones al arrancar**, no hay paso de migrate aparte |
| Health | espera `GET /health` hasta 120 s; si no responde, falla e imprime el log de la API |
| Seed | registra `e2e-admin@arnela.test` con rol por defecto y lo asciende a `admin` por SQL |
| Front | `pnpm install --frozen-lockfile` + `pnpm build` (con `NEXT_PUBLIC_API_URL` ya seteada) + `pnpm start` |
| E2E | `playwright install --with-deps chromium` + `playwright test` con `PLAYWRIGHT_SKIP_WEBSERVER=1` |
| Fallo | sube `playwright-report/`, `test-results/` y los logs de API/front como artefactos |

**No requiere secrets del repositorio.** El job se autosiembra un admin efímero: email fijo
`e2e-admin@arnela.test` y password aleatoria por corrida (`openssl rand -hex 16`, enmascarada en los logs).
El seed **no** envía `role` al endpoint de registro: registra como `client` y asciende con un `UPDATE`.
Definí `E2E_ADMIN_EMAIL` / `E2E_ADMIN_PASSWORD` como variables solo si corrés los E2E contra un entorno externo.

**Reproducir el job en local**

1. Levantá el stack como siempre (`docker-compose up -d`, `go run cmd/api/main.go`, `pnpm dev`).
2. Sembrá un admin y copiá sus credenciales a `frontend/e2e/.env`.
3. `PLAYWRIGHT_SKIP_WEBSERVER=1 pnpm test:e2e`.

Las suites de Vitest **no** incluyen `e2e/` (excluido en `vitest.config.ts`), así que `pnpm test` sigue siendo rápido.

## Alcance actual (smoke)

| Spec | Qué valida |
|------|-------------|
| `auth-backoffice.spec.ts` | Login desde home → URL bajo `/dashboard/backoffice`. |
| `billing-invoice.spec.ts` | Listado facturas, heading **Facturas**. |
| `appointment.spec.ts` | Agenda, heading **Citas** / **Mis Citas**. |

## Problemas frecuentes

- **Timeouts**: subir `timeout` en `playwright.config.ts` o comprobar red/API.
- **Login falla**: revisar credenciales y que el modal esté visible (viewport desktop para el botón *Iniciar sesión* del Navbar).
