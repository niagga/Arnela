# Apply progress — mvp-roadmap-2026

**Change**: mvp-roadmap-2026  
**Mode**: Strict TDD  

## TDD cycle evidence (acumulado)

| Task | RED | GREEN | REFACTOR |
|------|-----|-------|----------|
| 0.1 `ExpenseDetailView` | Import inexistente tras tests RTL. | Componente + 3 tests. | `Readonly` props; `aria-live` en carga. |
| 0.2 `expenses/[id]` | — | Página con `getById` y errores. | `id` sin ternario anidado. |
| 1.1 `GET /tasks/:id` | Tests handler/servicio. | Handler + ruta tras `/me`; servicio `ErrTaskNotFound`. | — |
| 1.2 Tests backend GET | Suite nueva. | `task_handler_test` + `task_service_test` GetTask. | — |
| 1.3 Tipos `Task` | **Triangulation skipped** (solo tipos). | `types/task.ts`. | — |
| 1.4 `api.tasks` | `taskList.test` / `api.test` sin impl. | `taskList.ts`, `api.tasks`. | Cast `buildQueryParams`. |
| 1.5–1.10 Tasks UI | Varios (ver commits previos). | Sidebar, páginas, `taskLabels`, `TaskDetailView`, tests. | Sonar / formato fechas. |
| 2.1–2.3 Playwright tooling | **Triangulation skipped** (deps + config + `.env.example`). | `@playwright/test`, scripts, `playwright.config.ts`, `e2e/.env.example`, carga opcional `e2e/.env`. | `PLAYWRIGHT_SKIP_WEBSERVER`; `vitest` exclude `e2e/`; eslint ignore `e2e/`. |
| 2.4 `loginBackoffice` | — | Helper con Navbar + `LoginModal` (labels Email/Contraseña, botón Ingresar). | — |
| 2.5–2.7 E2E specs | Sin credenciales → `test.skip` (3 skipped, exit 0). | Specs auth, facturas, citas con `loginBackoffice` + headings reales. | — |
| 2.8 + 2.11 + 2.12 Docs | — | `docs/E2E.md`, enlace en `frontend/README.md`. | — |
| 2.9–2.10 CI workflow | Estático: `actionlint` no existía en el entorno → instalado vía `go install` en GOBIN temporal. | `.github/workflows/e2e.yml` (services Postgres 16 / Redis 7, build+arranque API, espera `/health`, seed admin, build+start front, Playwright, artefactos). | `pnpm start` por `PORT=3000` en vez de flag; JSON del seed a mano en vez de `jq`; Playwright con `PLAYWRIGHT_SKIP_WEBSERVER=1`. |

**Verificación de 2.9–2.10** (no hay Docker ni jq en el entorno local, así que la corrida real del stack queda para el primer run de Actions):

- `actionlint` v1.7.12 sobre `.github/workflows/e2e.yml` y sobre todo el repo: **0 hallazgos**. Sin `shellcheck` instalado, actionlint no analizó los scripts bash.
- Los 5 bloques `run:` extraídos: `bash -n` **OK** en todos.
- `go build -o <tmp>/arnela-api ./cmd/api` (comando exacto del workflow): **OK**.
- Cruce estático: 6/6 paths referenciados existen; 14/14 env vars presentes en `backend/config/config.go`; `/health` y `POST /auth/register` existen en `cmd/api/main.go`.

## Archivos tocados (batch Fase 2 parcial 2.1–2.8, 2.11–2.12)

- `frontend/package.json`, `frontend/pnpm-lock.yaml`
- `frontend/playwright.config.ts`
- `frontend/e2e/.env.example`, `frontend/e2e/helpers/loginBackoffice.ts`
- `frontend/e2e/auth-backoffice.spec.ts`, `frontend/e2e/billing-invoice.spec.ts`, `frontend/e2e/appointment.spec.ts`
- `frontend/vitest.config.ts`, `frontend/eslint.config.mjs`, `frontend/.gitignore`
- `docs/E2E.md`, `frontend/README.md`
- `openspec/changes/mvp-roadmap-2026/tasks.md`

## Archivos tocados (batch Fase 2 cierre 2.9–2.10)

- `.github/workflows/e2e.yml` (nuevo)
- `docs/E2E.md`
- `openspec/changes/mvp-roadmap-2026/tasks.md`, `apply-progress.md`
- `odd/tasks/e2e-ci-workflow.md`

## Desviaciones

Specs usan `test.skip` si faltan `E2E_ADMIN_*` para que CI/Vitest no fallen sin secrets; ejecución real requiere `e2e/.env`. Workflow `e2e.yml` (2.9–2.10) no incluido en este batch.

## Issues

Ninguno bloqueante.

## Estado

**Fase 1** completa. **Fase 2** completa (2.1–2.12).

**Siguiente**: Fase 3 (rate limits, matriz de permisos, métricas) requiere change dedicado.

**Hallazgo abierto (fuera de alcance)**: `POST /api/v1/auth/register` es público y acepta `role` arbitrario (`backend/internal/service/auth_service.go:35-41,78-81`), lo que permite autoelevación a `admin`. Detectado al diseñar el seed de CI; el workflow evita ese camino (registra como `client` + `UPDATE` por SQL) pero el endpoint sigue expuesto. Requiere decisión y change propio.
