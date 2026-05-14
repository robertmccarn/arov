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

## GraphQL API Introspection Results

On 2026-05-14, the GitHub GraphQL API was introspected to confirm whether project view creation/editing is supported.

### Mutations checked

All mutation names were enumerated from the schema. No `createProjectV2View`, `updateProjectV2View`, or any view-related mutation for project boards exists. The only "view" mutations are for pull request reviews (e.g., `addPullRequestReview`, `submitPullRequestReview`).

Full list of ProjectV2 mutations available:

| Mutation | Purpose |
|---|---|
| `addProjectV2DraftIssue` | Add draft issue |
| `addProjectV2ItemById` | Add existing issue/PR |
| `archiveProjectV2Item` | Archive item |
| `clearProjectV2ItemFieldValue` | Clear field value |
| `convertProjectV2DraftIssueItemToIssue` | Convert draft to issue |
| `copyProjectV2` | Copy project |
| `createProjectV2` | Create project |
| `createProjectV2Field` | Create field |
| `createProjectV2IssueField` | Create issue field |
| `createProjectV2StatusUpdate` | Create status update |
| `deleteProjectV2` | Delete project |
| `deleteProjectV2Field` | Delete field |
| `deleteProjectV2Item` | Delete item |
| `deleteProjectV2StatusUpdate` | Delete status update |
| `deleteProjectV2Workflow` | Delete workflow |
| `linkProjectV2ToRepository` | Link to repo |
| `linkProjectV2ToTeam` | Link to team |
| `markProjectV2AsTemplate` | Mark as template |
| `unarchiveProjectV2Item` | Unarchive item |
| `unlinkProjectV2FromRepository` | Unlink from repo |
| `unlinkProjectV2FromTeam` | Unlink from team |
| `unmarkProjectV2AsTemplate` | Unmark as template |
| `updateProjectV2` | Update project title/description |
| `updateProjectV2Collaborators` | Update collaborators |
| `updateProjectV2DraftIssue` | Update draft issue |
| `updateProjectV2Field` | Update field config |
| `updateProjectV2ItemFieldValue` | Set field value on item |
| `updateProjectV2ItemPosition` | Reorder items |
| `updateProjectV2StatusUpdate` | Update status update |

### ProjectV2View type (read-only)

The `ProjectV2View` type exists in the schema but is **read-only** — there are no input types for creating or modifying views. Key fields:

| Field | Type | Description |
|---|---|---|
| `id` | ID | View identifier |
| `name` | String | View name |
| `layout` | ProjectV2ViewLayout | BOARD_LAYOUT, TABLE_LAYOUT, or ROADMAP_LAYOUT |
| `filter` | String | Filter string |
| `groupByFields` | Connection | Fields used for grouping |
| `sortByFields` | Connection | Fields used for sorting |

### Existing project state (fetched via GraphQL)

```
Project ID: PVT_kwHOAzxw084BXvVQ
Title: Arov V1 - Calm Command Center
Number: 3
```

Fields with options:

| Field | ID | Options |
|---|---|---|
| Status | `PVTSSF_lAHOAzxw084BXvVQzhS6Jwo` | Todo, In Progress, Done, Blocked, Review |
| Priority | `PVTSSF_lAHOAzxw084BXvVQzhS6JyI` | P0, P1, P2, P3 |
| Workstream | `PVTSSF_lAHOAzxw084BXvVQzhS6JyM` | Product Docs, Frontend, Backend, Database, UX Flow, Validation, DevOps |
| MVP Fit | `PVTSSF_lAHOAzxw084BXvVQzhS6JyQ` | Core Loop, Support, Later, Out of Scope |

Existing views before configuration: 1 view ("View 1", TABLE_LAYOUT, no filter, no grouping).

### Commands used for introspection

```bash
# Check auth
gh auth status

# Enumerate all mutations
gh api graphql -f query='{ __schema { mutationType { fields { name args { name type { kind name } } } } } }'

# Introspect ProjectV2View type
gh api graphql -f query='{ __type(name: "ProjectV2View") { name kind fields { name type { kind name } } } }'

# Fetch project fields and views
gh api graphql -f query='query { user(login: "robertmccarn") { projectV2(number: 3) { id title fields(first: 50) { nodes { ... on ProjectV2Field { id name dataType } ... on ProjectV2SingleSelectField { id name dataType options { id name } } } } views(first: 50) { nodes { id name layout number filter groupByFields(first: 10) { nodes { ... on ProjectV2Field { id name } ... on ProjectV2SingleSelectField { id name } } } } } } } }'

# Check ProjectV2ViewLayout enum
gh api graphql -f query='{ __type(name: "ProjectV2ViewLayout") { enumValues { name } } }'
```

### Conclusion

**GitHub's GraphQL API and REST API do not support creating or modifying project views.** All view configuration must be done through the GitHub web UI. The `gh` CLI can be used for all other project operations (item CRUD, field value updates, field management).

## CLI Capabilities

The `gh` CLI (v2.92.0) can:
- Add issues to the project
- Set field values (Status, Priority, Workstream, MVP Fit)
- List project items and fields
- Add field options via GraphQL
- Copy projects
- Cannot create, edit, or delete views
