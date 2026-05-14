# Arov Scripted Board Views

## Why scripted views?

The `gh` CLI and GitHub GraphQL API do not support creating or editing visual project board views (kanban boards, grouped table views with saved filters). Rather than requiring manual GitHub UI configuration, Arov uses `scripts/board-view.sh` to reproduce the same views from the terminal using `gh` and `jq`.

## All Commands

```bash
# Show all items with Status, Priority, Workstream, MVP Fit
./scripts/board-view.sh all

# Show items grouped by Status (kanban-style)
./scripts/board-view.sh kanban

# Show only P0/P1 priority items
./scripts/board-view.sh mvp

# Show items grouped by Workstream
./scripts/board-view.sh workstreams

# Show only blocked items
./scripts/board-view.sh blocked

# Show only items in review
./scripts/board-view.sh review

# Show items grouped by Priority
./scripts/board-view.sh priority

# Show DevOps/Support items
./scripts/board-view.sh deployment

# Print help
./scripts/board-view.sh help
```

## How it works

1. The script runs a GraphQL query against GitHub's API to fetch all project items with their Status, Priority, Workstream, and MVP Fit field values.
2. `jq` filters, groups, and formats the output as a terminal-friendly table or grouped list.
3. The script exits cleanly if `jq` is not installed with a pointer to `sudo apt install jq`.

## Expected use during OpenCode work

1. **Starting work**: Run `./scripts/board-view.sh mvp` to see what P0/P1 work is pending.
2. **Daily stand-in**: Run `./scripts/board-view.sh kanban` to see the board grouped by status.
3. **Checking for blockers**: Run `./scripts/board-view.sh blocked` to see stuck items.
4. **Reviewing completed work**: Run `./scripts/board-view.sh review` to see items needing validation.
5. **Deployment tasks**: Run `./scripts/board-view.sh deployment` to see DevOps/support work.

## Inspecting the actual GitHub Project

Open the project in your browser:

```
https://github.com/users/robertmccarn/projects/3
```

From the terminal, use `gh`:

```bash
gh project view 3 --owner robertmccarn
gh project item-list 3 --owner robertmccarn --limit 50
gh project field-list 3 --owner robertmccarn
```

## Updating issue fields

To set field values on an item programmatically:

```bash
# Set Status to "In Progress" for issue #13
gh project item-edit 3 --owner robertmccarn \
  --field-id PVTSSF_lAHOAzxw084BXvVQzhS6Jwo \
  --single-select-option-id 47fc9ee4 \
  --item-id <item-id>

# Find the item-id for an issue:
gh project item-list 3 --owner robertmccarn --format json \
  | jq '.items[] | select(.content.number == 13) | .id'
```

Field IDs and option IDs for reference:

| Field | Field ID | Options |
|---|---|---|
| Status | `PVTSSF_lAHOAzxw084BXvVQzhS6Jwo` | Todo (`f75ad846`), In Progress (`47fc9ee4`), Done (`98236657`), Blocked (`f75ad846`), Review (`47fc9ee4`) |
| Priority | `PVTSSF_lAHOAzxw084BXvVQzhS6JyI` | P0 (`8e245b53`), P1 (`bf690d13`), P2 (`93a9697f`), P3 (`1c902c9f`) |
| Workstream | `PVTSSF_lAHOAzxw084BXvVQzhS6JyM` | Product Docs (`148a1d6a`), Frontend (`dd6a6fa3`), Backend (`27f8f904`), Database (`2d309e2f`), UX Flow (`7697a1a1`), Validation (`8a07cd35`), DevOps (`95f870c0`) |
| MVP Fit | `PVTSSF_lAHOAzxw084BXvVQzhS6JyQ` | Core Loop (`5b9b58b0`), Support (`8a461d79`), Later (`3f878a6e`), Out of Scope (`583c6141`) |

## Board maintenance rules

| Action | Rule |
|---|---|
| New issues | Start in **Todo** status and add to the project |
| Active work | Move to **In Progress** |
| Completed work | Move to **Done** |
| Blocked work | Move to **Blocked** and add a comment explaining the blocker |
| Review/validation | Move to **Review** until validation passes |
| MVP Scope visibility | Ensure P0 and P1 items have their Priority field set |
| Support/Deployment | Ensure DevOps workstream or Support MVP Fit is set on deployment issues |
