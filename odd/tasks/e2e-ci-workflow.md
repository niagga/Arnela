# Feature: workflow E2E en CI (cierre 2.9–2.10)

Change OpenSpec: `mvp-roadmap-2026`, Fase 2. Alcance: cerrar las tareas **2.9** y **2.10** y alinear la documentación E2E.

## Specs

**S1** — El workflow E2E cierra las tareas 2.9 (`workflow con services Postgres 16 + Redis 7`, migraciones, API en background, `pnpm build` + `pnpm start`, `playwright install --with-deps`) y 2.10 (`pnpm exec playwright test`, en fallo subir artefactos `playwright-report/` y `test-results/`).

**S2** — Trigger exacto decidido por el usuario: «En cada PR a main + dispatch manual».
```yaml
on:
  pull_request:
    branches: [main]
  workflow_dispatch:
```
Además `concurrency` con cancelación para no acumular runs del mismo PR.

**S3** — Los services se alinean a `docker-compose.yml`: `postgres:16-alpine` con `POSTGRES_DB=arnela_db`, `POSTGRES_USER=arnela_user`, healthcheck `pg_isready`; `redis:7-alpine` con healthcheck `redis-cli ping`. Redis de CI **sin** `requirepass` (efímero, en runner), y `REDIS_PASSWORD` vacío en la API.

**S4** — Las migraciones **no** llevan paso propio: la API las aplica al arrancar (`backend/cmd/api/main.go:66-70`).

**S5** — `NEXT_PUBLIC_API_URL` se hornea en `pnpm build` (`frontend/src/lib/api.ts:58`), así que el build corre con `http://127.0.0.1:8080/api/v1` y `E2E_BASE_URL` queda en `http://127.0.0.1:3000` (ambos orígenes ya están en el default de `CORS_ORIGINS`, `backend/config/config.go:58-62`).

**S6** — El usuario admin de CI **no** se siembra con `POST /api/v1/auth/register` enviando `role=admin`. Ese endpoint es público y acepta el rol del cliente (`backend/internal/service/auth_service.go:35-41,78-81`), lo que permite autoelevación a admin a cualquiera. El seed registra como `client` (rol por defecto) y luego asciende con `UPDATE users SET role='admin'` vía `psql`. La vulnerabilidad de autoelevación queda **fuera de alcance**, como hallazgo reportado.

**S7** — `docs/E2E.md` deja de decir «Plantilla pendiente en `.github/workflows/e2e.yml`» y documenta trigger, secrets requeridos y cómo reproducir el job en local. `Tasks` de OpenSpec marca 2.9 y 2.10 como cumplidas y `apply-progress.md` refleja el ciclo TDD del batch.

**S8** — Sin artefactos versionados: `playwright-report/` y `test-results/` se suben como artefactos de Actions, no se commitean. En fallo también se sube el log de la API para diagnóstico.

**S9** — El job **no** depende de secrets de repo: genera su propio admin efímero (email fijo `e2e-admin@arnela.test`, password aleatoria por corrida exportada a `GITHUB_ENV`). Motivo: los specs hacen `test.skip` cuando faltan `E2E_ADMIN_*` (`frontend/e2e/*.spec.ts:8`), así que un repo sin secrets configurados pasaría el job en falso. Con seed propio, los 3 specs corren siempre.

**S10** — Si la API no queda sana o el seed falla, el job falla con el log de la API impreso, nunca en verde silencioso.

## Tasks

| ID | Spec | Qué | Ruta | Commit |
|----|------|-----|------|--------|
| T1 | — | Feature doc + rama `feat/e2e-ci-workflow` + mirror Engram | `odd/tasks/e2e-ci-workflow.md` | — |
| T2 | S2, S3, S4, S5, S6 | Workflow E2E completo | `.github/workflows/e2e.yml` | WU1 |
| T3 | S7 | Doc E2E actualizada | `docs/E2E.md` | WU1 |
| T4 | S7 | Cierre 2.9–2.10 | `openspec/changes/mvp-roadmap-2026/tasks.md`, `apply-progress.md` | WU1 |
| T5 | S1, S9, S10 | Validación YAML + cruce de referencias | — | WU1 |

Riesgo: ítem 5 (CI/delivery) y ítem 6 (ningún test atrapa una regresión en un archivo de workflow). Verificación: validación estática de YAML, cruce de cada env/path/comando contra el repo, y corrida local acotada si el entorno lo permite. La prueba definitiva es el primer run real de Actions, que requiere push (decisión del usuario).

## Log

**L1** (pedido original, verbatim): «Analiza el proyecto, dime de que va, cual es el estado de el, y como deberiamos continuar»

**L2** (decisión de hilo, verbatim): «Cerrar 2.9–2.10: workflow E2E en CI»

**L3** (decisión de trigger, verbatim): «En cada PR a main + dispatch manual»

**L4** (hallazgo, este turno): `POST /api/v1/auth/register` acepta `role` arbitrario de un cliente anónimo; se reporta y queda fuera de alcance (S6).

**L5** (decisión de diseño, este turno): CI se autosiembra el admin en vez de depender de `secrets.E2E_ADMIN_*`. Razón verificada en el código: los specs saltan sin credenciales, así que con secrets vacíos el job sería verde falso (S9).
