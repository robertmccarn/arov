# Initial GitHub Issues for Arov

*Generated as fallback because `gh` CLI was not available at setup time.*

---

## Issue 1: Add initial database migration

**Labels:** `database`, `P0`

**Goal:** Commit the initial Prisma migration created from the ActionItem, CapacityCheckIn, and Reflection schema.

**Acceptance Criteria:**
- Migration file exists under apps/api/prisma/migrations
- npx prisma migrate status succeeds
- .env is not committed
- .env.example is committed
- git status is clean after commit

**Validation:**
- cd apps/api && npx prisma validate
- cd apps/api && npx prisma migrate status

---

## Issue 2: Add Prisma client helper

**Labels:** `backend`, `database`, `P0`

**Goal:** Add a reusable Prisma client helper for backend routes.

**Acceptance Criteria:**
- apps/api/src/lib/prisma.ts exists
- PrismaClient is exported from one shared location
- No generated Prisma files are manually edited
- API still starts successfully

**Validation:**
- cd apps/api && npm run dev
- curl http://localhost:4000/health

---

## Issue 3: Add ActionItem CRUD API

**Labels:** `backend`, `P0`

**Goal:** Add REST endpoints for ActionItem.

**Acceptance Criteria:**
- GET /action-items returns action items
- POST /action-items creates an item
- GET /action-items/:id returns one item
- PATCH /action-items/:id updates one item
- DELETE /action-items/:id archives or deletes one item
- Routes use the shared Prisma client
- Request bodies are minimally validated

**Validation:**
- curl tests for each endpoint
- cd apps/api && npx prisma validate

---

## Issue 4: Add CapacityCheckIn API

**Labels:** `backend`, `P0`

**Goal:** Add endpoints for daily capacity check-ins.

**Acceptance Criteria:**
- GET /capacity-check-ins returns recent check-ins
- POST /capacity-check-ins creates a check-in
- Supports energy, stress, availableTime, mode, and notes
- Uses calm product language and avoids productivity scoring

**Validation:**
- curl tests for GET and POST
- API still passes /health

---

## Issue 5: Add Reflection API

**Labels:** `backend`, `P1`

**Goal:** Add endpoints for completion reflections.

**Acceptance Criteria:**
- GET /reflections returns reflections
- POST /reflections creates a reflection
- Reflection can optionally link to an ActionItem
- Supports stressReduced, momentumCreated, actualEffort, and notes

**Validation:**
- curl tests for GET and POST
- Create reflection linked to an existing ActionItem

---

## Issue 6: Connect frontend to API health endpoint

**Labels:** `frontend`, `backend`, `P1`

**Goal:** Confirm the frontend can call the backend.

**Acceptance Criteria:**
- apps/web calls GET /health
- UI shows API status
- API URL is configurable
- Frontend still runs with npm run dev

**Validation:**
- cd apps/api && npm run dev
- cd apps/web && npm run dev
- Confirm health status renders in browser

---

## Issue 7: Build action capture form

**Labels:** `frontend`, `P0`

**Goal:** Build the first UI for creating ActionItems.

**Acceptance Criteria:**
- User can enter title
- User can optionally enter description
- User can choose Stabilize, Build, or Restore
- User can mark Supports Stability
- Form submits to API

**Validation:**
- Create item from UI
- Confirm item appears in database or API response

---

## Issue 8: Build action list view

**Labels:** `frontend`, `P0`

**Goal:** Display ActionItems in the frontend.

**Acceptance Criteria:**
- Shows active/inbox action items
- Displays category, effort, impact, urgency, and status
- Uses calm non-shaming language
- Does not use overdue/failure wording

**Validation:**
- Create items via API or UI
- Confirm list renders correctly

---

## Issue 9: Build daily capacity check-in screen

**Labels:** `frontend`, `P0`

**Goal:** Build UI for daily capacity check-in.

**Acceptance Criteria:**
- User can select energy level
- User can select stress level
- User can enter available time
- User can select day mode
- User can add optional notes

**Validation:**
- Submit check-in from UI
- Confirm API stores the check-in

---

## Issue 10: Build next-small-step rule

**Labels:** `backend`, `ux-flow`, `P0`

**Goal:** Add the first rule-based next-step recommendation.

**Acceptance Criteria:**
- Recommends from ActionItems only
- Excludes DONE and ARCHIVED
- Low capacity favors LOW effort
- Recovery mode allows RESTORE recommendations
- High impact + low effort ranks highly
- No AI or ML is used

**Validation:**
- Add test/sample items
- Confirm recommendation changes based on capacity

---

## Issue 11: Build completion reflection flow

**Labels:** `frontend`, `backend`, `P1`

**Goal:** Let the user reflect after completing an action.

**Acceptance Criteria:**
- User can mark ActionItem complete
- User can add Reflection
- Reflection can record stressReduced, momentumCreated, actualEffort, and notes
- Language is calm and non-shaming

**Validation:**
- Complete item
- Add reflection
- Confirm API stores both

---

## Issue 12: Build basic dashboard

**Labels:** `frontend`, `ux-flow`, `P1`

**Goal:** Build the first Arov dashboard around the core loop.

**Acceptance Criteria:**
- Shows latest capacity check-in
- Shows action list summary
- Shows recommended next small step
- Shows recent reflection
- Organizes items around Stabilize / Build / Restore

**Validation:**
- Run API and frontend
- Confirm dashboard displays live data
