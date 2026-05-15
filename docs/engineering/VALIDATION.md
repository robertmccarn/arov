# Arov Validation Methodology

## Overview

Arov uses three tiers of validation to balance speed, reliability, and coverage.

## Tier 1: Automated Route Tests (Fast)

Run against the actual Express app (no server needed) using Vitest and Supertest.

```bash
cd apps/api && npm run test
```

- Tests import the Express app directly from `app.ts`
- No server start/stop needed
- Uses the local development database
- Writes real test rows (identifiable by content)
- Run these on every code change

## Tier 2: Prisma Schema Validation

```bash
cd apps/api && npx prisma validate
```

Ensures the Prisma schema is syntactically valid. Run after any schema changes.

## Tier 3: Manual Server Smoke Test (Checkpoints Only)

```bash
cd apps/api && npm run dev
# In another terminal:
curl http://localhost:4000/health
```

Use only for:
- Final smoke test before committing
- Debugging a test failure
- Milestone or deployment verification

## Combined Validation

```bash
cd apps/api && npm run validate
```

This runs `npm run test` followed by `npx prisma validate`.

## Notes

- Tests use the local development database defined in `.env`.
- Test rows may persist after test runs. This is acceptable for local development.
- The database is PostgreSQL running locally on port 5432.
- No separate test database or Docker is required.
- OpenCode should prefer `npm run validate` instead of repeatedly starting and killing the dev server.
