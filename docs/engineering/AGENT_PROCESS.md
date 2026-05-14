# Arov Agent Process Document

## Purpose

This document defines how a future coding agent should work on Arov.

Arov is a calm personal command center for reducing mental load across daily responsibilities, future-building goals, stability work, and restoration.

The first version is intentionally small and centers on this loop:

check in → capture actions → choose one next step → complete → reflect

The agent's job is not to expand Arov into a broad life-management platform. The agent's job is to implement small, well-scoped issues that advance the first usable product loop.

## Current Product Direction

Arov is not primarily:

- a generic task manager
- a calendar optimizer
- a finance app
- an AI agent
- a household management platform
- a productivity scoring system

Arov is a private, single-user full-stack app that helps the user decide what to do next based on current capacity, effort, impact, urgency, and mode.

The current product model is:

- Stabilize: what keeps life functioning
- Build: what moves future goals forward
- Restore: what protects capacity and well-being
- Supports Stability: optional marker for actions that support financial, career, household, or risk-reduction stability

## Current Technical Stack

Arov currently uses:

- Frontend: React + TypeScript + Vite
- Backend: Node.js + Express + TypeScript
- Database: PostgreSQL
- ORM: Prisma

Current repository shape:

```text
apps/web      # React frontend
apps/api      # Express API
docs          # Product and engineering documentation
```

The backend currently has a working `/health` endpoint.

The Prisma schema currently defines:

- ActionItem
- CapacityCheckIn
- Reflection

## Development Methodology

Arov uses a lightweight solo-developer Agile/Kanban workflow inspired by the SellThrough and EchoFinder projects.

The process is:

1. GitHub Issues define work.
2. GitHub Projects organizes work.
3. Each issue should have clear acceptance criteria.
4. Work should be small enough to review.
5. Code should be committed in meaningful checkpoints.
6. Documentation should change when behavior or architecture changes.
7. Scope creep should be actively resisted.

## Board Statuses

Use these statuses (matches the GitHub project Status field):

```text
Todo
In Progress
Blocked
Review
Done
```

Definitions:

| Status      | Meaning                                                           |
| ----------- | ----------------------------------------------------------------- |
| Todo        | Captured and scoped, not yet started                              |
| In Progress | Actively being worked                                             |
| Blocked     | Waiting on a decision, dependency, setup, or design clarification |
| Review      | Needs testing, code review, or manual validation                  |
| Done        | Acceptance criteria met, committed, pushed, and verified          |

## Priority Model

Use P0-P3.

| Priority | Meaning                                  |
| -------- | ---------------------------------------- |
| P0       | Required for the first usable app loop   |
| P1       | Important for MVP usefulness             |
| P2       | Useful after MVP works                   |
| P3       | Later enhancement, polish, or experiment |

## Workstreams

Use these Arov workstreams:

```text
Product Docs
Frontend
Backend
Database
UX Flow
Validation
DevOps
```

Later workstreams may include:

```text
AI Assistance
Calendar
Privacy
```

Do not activate later workstreams until the basic loop works.

## Current MVP Scope

The MVP includes:

1. Daily capacity check-in
2. Action item capture
3. Stabilize / Build / Restore classification
4. Rule-based next-small-step recommendation
5. Completion reflection
6. Basic dashboard

The MVP explicitly defers:

- AI planning
- Authentication
- Calendar integration
- Financial integration
- Household sharing
- Mobile app
- Notifications
- Streaks
- Productivity scoring

## Product Red Lines

Do not build the following in V1:

- AI auto-scheduling
- calendar write access
- financial integrations
- bank sync
- multi-user household sharing
- location tracking
- streaks
- leaderboards
- productivity scores
- shame-based reminders
- lost productivity metrics
- rest-cost-you-money logic
- public/social accountability features

If an issue requests one of these, mark it as blocked or out of scope unless the user explicitly changes the roadmap.

## Branching Standard

Current early-stage branch model:

```text
develop = active integration branch
```

Preferred issue work pattern:

```text
feature/<issue-number>-short-name -> develop
```

Examples:

```text
feature/002-prisma-client-helper
feature/003-actionitem-crud-api
feature/004-capacity-checkin-api
```

For very small documentation or setup fixes, direct commits to `develop` are acceptable while the project is still early.

Later, once the first app loop works, move to:

```text
feature/* -> develop -> release PR -> main
```

Do not introduce a heavier release train until the app has a working vertical slice.

## Definition of Done

An issue is done only when:

- Acceptance criteria are met
- Code runs locally
- Relevant endpoint or UI behavior is manually tested
- Git status is clean after commit
- No secrets are committed
- `node_modules` is not tracked
- Documentation is updated if behavior or architecture changed
- The commit message clearly describes the change
- Work is pushed to GitHub

## Git Hygiene Rules

Never commit:

```text
node_modules/
.env
dist/
build/
coverage/
*.log
```

Before committing, always run:

```bash
git status
```

Before pushing major setup changes, check for accidental dependency commits:

```bash
git ls-files | grep node_modules
```

Expected result: no output.

If `node_modules` appears, stop and fix before pushing.

## Recommended Next Issues

Use this sequence:

```text
#1 Add initial database migration
#2 Add Prisma client helper
#3 Add ActionItem CRUD API
#4 Add CapacityCheckIn API
#5 Add Reflection API
#6 Connect frontend to API health endpoint
#7 Build action capture form
#8 Build action list view
#9 Build daily capacity check-in screen
#10 Build next-small-step rule
#11 Build completion reflection flow
#12 Build basic dashboard
```

## Technical Implementation Standards

### Backend

Backend code lives in:

```text
apps/api
```

Recommended structure:

```text
apps/api/src/
  server.ts
  lib/
    prisma.ts
  routes/
    actionItems.ts
    capacityCheckIns.ts
    reflections.ts
  services/
    recommendationService.ts
```

Rules:

- Keep routes thin.
- Put reusable logic in services.
- Validate request bodies before database writes.
- Return consistent JSON.
- Use clear HTTP status codes.
- Do not add authentication yet.
- Do not add AI yet.

### Frontend

Frontend code lives in:

```text
apps/web
```

Recommended structure:

```text
apps/web/src/
  components/
  pages/
  lib/
  types/
```

Rules:

- Build simple screens before abstractions.
- Prefer readable components over clever patterns.
- Keep copy calm and non-shaming.
- Do not introduce global state libraries unless needed.
- Do not build dashboards before the capture/check-in loop works.

### Database

Database schema is managed through Prisma.

Rules:

- Schema changes require migration files.
- Do not edit generated Prisma client files manually.
- Commit migrations.
- Do not commit `.env`.
- Keep `.env.example` updated when required variables change.

## API Route Standards

Use REST-style routes for V1.

Recommended routes:

```text
GET    /health

GET    /action-items
POST   /action-items
GET    /action-items/:id
PATCH  /action-items/:id
DELETE /action-items/:id

GET    /capacity-check-ins
POST   /capacity-check-ins

GET    /reflections
POST   /reflections
```

For V1, deletion may be either hard delete or status-based archive. Prefer archive if the user wants history preserved.

## Product Language Standards

Use calm, neutral language.

Preferred:

```text
Still open
Paused
Available when ready
Restore
Protect capacity
Next small step
Today's mode
```

Avoid:

```text
Overdue
Failed
Behind
Productivity score
Lost time
Streak broken
You missed this
```

## Recommendation Logic Standard

The first next-small-step engine should be rule-based, not AI-based.

Initial recommendation factors:

- current capacity
- action category
- effort
- impact
- urgency
- status
- supportsStability

Example logic:

- Low capacity favors LOW effort tasks
- Recovery mode allows RESTORE tasks to be recommended
- High impact + low effort tasks are strong candidates
- DONE and ARCHIVED tasks are excluded
- PAUSED tasks are excluded unless explicitly resumed
- Build tasks should not dominate low-capacity days

Do not build machine learning or LLM planning for V1.

## Validation Commands

Common checks:

```bash
# Repo root
git status
git ls-files | grep node_modules

# API
cd apps/api
npm run dev
curl http://localhost:4000/health

# Prisma
npx prisma validate
npx prisma migrate status

# Web
cd apps/web
npm run dev
```

## Documentation Update Rules

Update docs when:

- MVP scope changes
- data model changes
- routes are added or changed
- setup steps change
- deferred features move into scope
- product red lines change

Primary docs:

```text
README.md
docs/product/vision.md
docs/product/mvp-spec.md
docs/engineering/architecture.md
docs/engineering/AGENT_PROCESS.md
docs/engineering/PROJECT_BOARD_SETUP.md
```

## Scope Control Rule

Before implementing any change, answer:

```text
Does this help the user complete the first loop?
check in → capture actions → choose one next step → complete → reflect
```

If yes, proceed.

If no, defer unless the user explicitly approves scope expansion.

## Project Board Views

The GitHub project board has seven configured views. See `docs/engineering/PROJECT_BOARD_SETUP.md` for:
- View names, layouts, filters, and grouping
- Step-by-step manual setup instructions
- Board maintenance rules
- Status field options

All visual view creation must be done through the GitHub web UI — the `gh` CLI does not support creating or editing project views.

## Scripted Board Views

Arov does not require manual GitHub Project view setup. Use `scripts/board-view.sh` to inspect work from the terminal. See `docs/engineering/BOARD_COMMANDS.md` for full usage.

```bash
./scripts/board-view.sh all       # all items with fields
./scripts/board-view.sh kanban    # grouped by Status
./scripts/board-view.sh mvp       # P0/P1 items only
./scripts/board-view.sh workstreams  # grouped by Workstream
./scripts/board-view.sh blocked   # blocked items only
./scripts/board-view.sh review    # review items only
./scripts/board-view.sh priority  # grouped by Priority
./scripts/board-view.sh deployment  # DevOps/Support items
```

## Future Agent Startup Checklist

When starting work on Arov, do this first:

```bash
cd /home/robert/dev/arov
git status
git pull
```

Then read:

```text
README.md
docs/product/vision.md
docs/product/mvp-spec.md
docs/engineering/architecture.md
docs/engineering/AGENT_PROCESS.md
```

Then inspect the active GitHub Issue.

Do not begin coding until:

- the issue goal is clear
- acceptance criteria are clear
- out-of-scope items are clear
- validation steps are known

## Future Agent Completion Checklist

Before ending work:

```bash
git status
```

Then provide the user:

```text
Summary:
Files changed:
Validation performed:
Known risks:
Recommended next issue:
```

If code was changed, commit using a clear message:

```bash
git add .
git commit -m "<clear action-oriented message>"
git push
```

Do not leave the repo in an unclear partially modified state unless explicitly instructed.

## Final Guiding Principle

Arov should become useful through small, calm, validated steps.

The agent should optimize for:

- clarity
- small scope
- working software
- honest documentation
- low cognitive load
- no shame mechanics
- no premature automation

The first goal is not to build the whole product.

The first goal is to make the basic loop work.
