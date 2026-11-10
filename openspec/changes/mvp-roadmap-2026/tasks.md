# Tasks — mvp-roadmap-2026

## Fases completadas (referencia)

- [x] **F0** Gasto detalle: `ExpenseDetailView`, tests Vitest, `billing/expenses/[id]/page.tsx`.
- [x] **F1** Tasks: `GET /tasks/:id`, `api.tasks` + tipos, `taskLabels` + `TaskDetailView` + tests, sidebar, `tasks/page.tsx` | `new` | `[id]`, cierre Vitest/tsc.

## Fase 2: E2E críticos + CI (2 jun–27 jun) — COMPLETA

- [x] 2.1 `frontend/package.json`: devDependency `@playwright/test`; scripts `test:e2e` (`playwright test`) y `test:e2e:ui` (`playwright test --ui`).
- [x] 2.2 `frontend/playwright.config.ts`: `testDir: 'e2e'`, `baseURL` desde `process.env.E2E_BASE_URL` (fallback `http://127.0.0.1:3000`), `forbidOnly: !!process.env.CI`, `retries`/`timeout` razonables, reporter `html`+`list`.
- [x] 2.3 `frontend/e2e/.env.example`: `E2E_BASE_URL`, `E2E_API_URL` (coherente con `NEXT_PUBLIC_API_URL`), `E2E_ADMIN_EMAIL` / `E2E_ADMIN_PASSWORD` como placeholders; aviso de no versionar secretos.
- [x] 2.4 `frontend/e2e/helpers/loginBackoffice.ts` (o `fixtures/`): helper que complete el flujo de login real del proyecto y espere URL bajo `/dashboard/backoffice`.
- [x] 2.5 `frontend/e2e/auth-backoffice.spec.ts`: smoke login → aserción `URL` contiene `backoffice` (o ruta acordada post-login).
- [x] 2.6 `frontend/e2e/billing-invoice.spec.ts`: con sesión admin, visitar listado facturas y aserción mínima (heading o tabla).
- [x] 2.7 `frontend/e2e/appointment.spec.ts`: visitar agenda backoffice y aserción mínima (rol admin/employee según seed).
- [x] 2.8 **Datos CI**: documentar en `docs/E2E.md` o script bajo `scripts/` cómo obtener usuario/contraseña conocidos (GitHub Secrets `E2E_*`, sin valores reales en git).
- [x] 2.9 `.github/workflows/e2e.yml` (nuevo, recomendado): job con `services` Postgres 16 + Redis 7 (alineado a `docker-compose.yml`), env DB/Redis, migraciones + arranque API Go en background, `pnpm build` + `pnpm start` en `frontend`, `playwright install --with-deps` (Chromium only opcional).
- [x] 2.10 Mismo workflow: paso `pnpm exec playwright test`; en fallo subir artefacto `playwright-report/` y `test-results/` (`upload-artifact`).
- [x] 2.11 `docs/E2E.md`: prerequisitos, copia de `.env.example`, comando local, apuntar API Docker vs host, timeouts y alcance smoke vs suite amplia.
- [x] 2.12 `frontend/README.md`: enlace a `docs/E2E.md` y variables necesarias para E2E local/CI.

## Fase 3: Hardening (30 jun–25 jul)

- [ ] 3.1–3.3 Rate limits, matriz permisos, métricas — desglosar en change dedicado según `proposal.md`.

## Fase 4: Buffer UX (28 jul–22 ago)

- [ ] 4.1 Backlog deuda menor con negocio (`MVP_ROADMAP.md`).
