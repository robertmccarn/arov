# Arov Board Sync

## Why visual views are not automated

GitHub Projects v2 does not expose view creation or modification through any public API — neither GraphQL nor REST. The `ProjectV2View` type is read-only in the schema, and no `createProjectV2View` or `updateProjectV2View` mutation exists. All visual view configuration (Board layout, Table layout, filters, grouping) must be done through the GitHub web UI.

However, individual **issue field values** (Status, Priority, Workstream, MVP Fit) can be set programmatically via the `updateProjectV2ItemFieldValue` GraphQL mutation. This script automates field updates so you do not need to use the GitHub UI for day-to-day board operations.

## What board-sync.sh does

`scripts/board-sync.sh` is a bash script that uses the `gh` CLI, `jq`, and GitHub's GraphQL API to update field values on project board items. It discovers project item IDs dynamically by issue number — no hard-coded opaque node IDs for items.

## Commands and examples

### Bootstrap core issues

Sets Status, Priority, Workstream, and MVP Fit for issues #1–#12 according to the MVP plan.

```bash
./scripts/board-sync.sh bootstrap-core
```

### Set individual fields

```bash
# Status
./scripts/board-sync.sh set-status 4 "In Progress"
./scripts/board-sync.sh set-status 4 "Done"
./scripts/board-sync.sh set-status 4 "Blocked"
./scripts/board-sync.sh set-status 4 "Review"

# Priority
./scripts/board-sync.sh set-priority 5 "P1"

# Workstream
./scripts/board-sync.sh set-workstream 7 "Frontend"

# MVP Fit
./scripts/board-sync.sh set-mvp-fit 6 "Support"
```

### Shorthands

```bash
./scripts/board-sync.sh start 4      # Status → In Progress
./scripts/board-sync.sh done 3       # Status → Done
```

### Validate

Checks all project items for missing field values.

```bash
./scripts/board-sync.sh validate
```

## How to bootstrap core issue fields

1. Ensure `gh` is installed and authenticated (`gh auth status`).
2. Run:

```bash
./scripts/board-sync.sh bootstrap-core
```

This sets all four fields (Status, Priority, Workstream, MVP Fit) for issues #1–#12 according to the MVP plan:

| Issue | Status | Priority | Workstream | MVP Fit |
|-------|--------|----------|------------|---------|
| #1 Add initial database migration | Done | P0 | Database | Core Loop |
| #2 Add Prisma client helper | Done | P0 | Backend | Core Loop |
| #3 Add ActionItem CRUD API | Done | P0 | Backend | Core Loop |
| #4 Add CapacityCheckIn API | Todo | P0 | Backend | Core Loop |
| #5 Add Reflection API | Todo | P1 | Backend | Core Loop |
| #6 Connect frontend to API health endpoint | Todo | P1 | Frontend | Support |
| #7 Build action capture form | Todo | P0 | Frontend | Core Loop |
| #8 Build action list view | Todo | P0 | Frontend | Core Loop |
| #9 Build daily capacity check-in screen | Todo | P0 | Frontend | Core Loop |
| #10 Build next-small-step rule | Todo | P0 | UX Flow | Core Loop |
| #11 Build completion reflection flow | Todo | P1 | UX Flow | Core Loop |
| #12 Build basic dashboard | Todo | P1 | Frontend | Core Loop |

## How to mark an issue in progress

```bash
./scripts/board-sync.sh start <issue-number>
```

This sets Status to "In Progress".

## How to mark an issue done

```bash
./scripts/board-sync.sh done <issue-number>
```

This sets Status to "Done".

## How to validate board hygiene

```bash
./scripts/board-sync.sh validate
```

This checks every issue on the project for:
- Status is set
- Priority is set
- Workstream is set
- MVP Fit is set

Missing fields are reported per issue. The script exits with a non-zero code if any issues are incomplete.

## Relationship between board-sync.sh and board-view.sh

- **board-view.sh** — Read-only. Fetches project items and displays them in terminal-friendly views (kanban, MVP scope, blocked, etc.). Use this to inspect the board.
- **board-sync.sh** — Write. Updates field values. Use this to update issue statuses and metadata.

Together they let you manage the entire project board lifecycle from the terminal without touching the GitHub web UI for day-to-day operations. Only the initial visual view setup (creating views, setting layouts/filters/grouping) requires the web UI.

## Field reference

| Field | Field ID | Options |
|---|---|---|
| Status | `PVTSSF_lAHOAzxw084BXvVQzhS6Jwo` | Todo, In Progress, Done, Blocked, Review |
| Priority | `PVTSSF_lAHOAzxw084BXvVQzhS6JyI` | P0, P1, P2, P3 |
| Workstream | `PVTSSF_lAHOAzxw084BXvVQzhS6JyM` | Product Docs, Frontend, Backend, Database, UX Flow, Validation, DevOps |
| MVP Fit | `PVTSSF_lAHOAzxw084BXvVQzhS6JyQ` | Core Loop, Support, Later, Out of Scope |
