# Arov Project Board Setup

## Project Info

- **Name:** Arov V1 - Calm Command Center
- **Number:** 3
- **URL:** https://github.com/users/robertmccarn/projects/3
- **Owner:** robertmccarn

## Required Fields

These fields already exist on the project. Do not recreate them.

| Field | Type | Options |
|---|---|---|
| Status | Single select | Todo, In Progress, Done, Blocked, Review |
| Priority | Single select | P0, P1, P2, P3 |
| Workstream | Single select | Product Docs, Frontend, Backend, Database, UX Flow, Validation, DevOps |
| MVP Fit | Single select | Core Loop, Support, Later, Out of Scope |

### Status field notes

The Status field was extended via the GraphQL API to include **Blocked** (RED) and **Review** (BLUE) options. The AGENT_PROCESS.md "Board Statuses" section lists Backlog and Ready separately — the GitHub project uses **Todo** to represent all unstarted work (covering both Backlog and Ready). This is intentional: the project board is simpler than the process document.

## Current Views

The project currently has one default view ("View 1"). Views must be configured manually through the GitHub UI — the `gh` CLI and GraphQL API do not support creating or editing project views.

## Required Views (Create via GitHub UI)

Below are the exact manual steps to create each view.

---

### 1. V1 Kanban

- **Layout:** Board
- **Group by:** Status
- **Purpose:** Active execution board

Steps:
1. Open https://github.com/users/robertmccarn/projects/3
2. Click the dropdown next to "View 1" and select **New view**
3. Name it `V1 Kanban`
4. Click **Layout** and select **Board**
5. Click **Group** and select **Status**
6. Click **Save view** (floppy disk icon in the view tab)

---

### 2. MVP Scope

- **Layout:** Table
- **Filter:** Priority = P0 or P1
- **Purpose:** Shows only core/support MVP work

Steps:
1. Click the dropdown next to the current view tab and select **New view**
2. Name it `MVP Scope`
3. Leave layout as **Table**
4. Click the filter bar (shows "Filter by keyword or field") and enter:
   ```
   Priority:P0, Priority:P1
   ```
   (Or use the filter UI to select: Priority > P0, then add another filter with OR > Priority > P1)
5. Click **Save view**

---

### 3. Workstreams

- **Layout:** Table
- **Group by:** Workstream
- **Purpose:** Shows work grouped by Product Docs, Frontend, Backend, Database, UX Flow, Validation, DevOps

Steps:
1. Click the dropdown next to the current view tab and select **New view**
2. Name it `Workstreams`
3. Leave layout as **Table**
4. Click **Group** and select **Workstream**
5. Click **Save view**

---

### 4. Blocked

- **Layout:** Table
- **Filter:** Status = Blocked
- **Purpose:** Shows blocked work only

Steps:
1. Click the dropdown next to the current view tab and select **New view**
2. Name it `Blocked`
3. Leave layout as **Table**
4. Click the filter bar and enter: `Status:Blocked`
   (Or use filter UI: Status > Blocked)
5. Click **Save view**

---

### 5. Review

- **Layout:** Table
- **Filter:** Status = Review
- **Purpose:** Shows work waiting for validation/review

Steps:
1. Click the dropdown next to the current view tab and select **New view**
2. Name it `Review`
3. Leave layout as **Table**
4. Click the filter bar and enter: `Status:Review`
   (Or use filter UI: Status > Review)
5. Click **Save view**

---

### 6. Roadmap / Priority

- **Layout:** Table
- **Group by:** Priority
- **Purpose:** Shows P0-P3 sequencing

Steps:
1. Click the dropdown next to the current view tab and select **New view**
2. Name it `Roadmap / Priority`
3. Leave layout as **Table**
4. Click **Group** and select **Priority**
5. Click **Save view**

---

### 7. Support / Deployment

- **Layout:** Table
- **Filter:** Workstream = DevOps or MVP Fit = Support
- **Purpose:** Shows deployment and project-setup support work

Steps:
1. Click the dropdown next to the current view tab and select **New view**
2. Name it `Support / Deployment`
3. Leave layout as **Table**
4. Click the filter bar and enter:
   ```
   Workstream:DevOps MVP Fit:Support
   ```
   (Use the filter UI: Workstream > DevOps, then add another filter with OR > MVP Fit > Support)
5. If GitHub's filter OR syntax is `,` (comma), use:
   ```
   Workstream:DevOps, MVP Fit:Support
   ```
6. Click **Save view**

## Board Maintenance Rules

Follow these rules when triaging or updating the project board:

| Action | Rule |
|---|---|
| New issues | Start in **Todo** status |
| Active work | Move to **In Progress** |
| Completed work | Move to **Done** |
| Blocked work | Move to **Blocked** and add a comment explaining the blocker |
| Review/validation | Move to **Review** until validation passes |
| MVP Scope visibility | Ensure P0 and P1 items remain visible in the MVP Scope view |
| Support/Deployment | Ensure DevOps and Support items appear in the Support / Deployment view |

## Filter Syntax Notes

GitHub project filters use these patterns:

| Intent | Syntax |
|---|---|
| Equal match | `Field:Value` |
| Multiple values (OR) | `Field:Value1,Field:Value2` |
| Multiple fields (AND) | Separate with space: `Field1:Val1 Field2:Val2` |
| Negation | `-Field:Value` |

If the UI filter builder does not support OR between different fields, use the filter bar directly with the comma syntax.

## CLI Limitations

The `gh` CLI (v2.92.0) cannot create, edit, or delete project views. All view configuration must be done through the GitHub web UI as documented above. The CLI can be used to:
- Add issues to the project
- Set field values (Status, Priority, Workstream, MVP Fit)
- List project items and fields
- Add field options (e.g., adding Blocked and Review to the Status field was done via the GraphQL API)
