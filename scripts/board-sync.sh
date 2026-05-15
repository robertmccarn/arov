#!/usr/bin/env bash
set -euo pipefail

PROJECT_ID="PVT_kwHOAzxw084BXvVQ"
OWNER="robertmccarn"
PROJECT_NUMBER="3"

# Field IDs (stable GraphQL node IDs from introspection)
FIELD_STATUS="PVTSSF_lAHOAzxw084BXvVQzhS6Jwo"
FIELD_PRIORITY="PVTSSF_lAHOAzxw084BXvVQzhS6JyI"
FIELD_WORKSTREAM="PVTSSF_lAHOAzxw084BXvVQzhS6JyM"
FIELD_MVP_FIT="PVTSSF_lAHOAzxw084BXvVQzhS6JyQ"

# Option IDs (stable GraphQL node IDs from introspection)
OPT_TODO="f75ad846"
OPT_IN_PROGRESS="47fc9ee4"
OPT_DONE="98236657"
OPT_BLOCKED="94a97686"
OPT_REVIEW="7f475e6c"

OPT_P0="8e245b53"
OPT_P1="bf690d13"
OPT_P2="93a9697f"
OPT_P3="1c902c9f"

OPT_PRODUCT_DOCS="148a1d6a"
OPT_FRONTEND="dd6a6fa3"
OPT_BACKEND="27f8f904"
OPT_DATABASE="2d309e2f"
OPT_UX_FLOW="7697a1a1"
OPT_VALIDATION="8a07cd35"
OPT_DEVOPS="95f870c0"

OPT_CORE_LOOP="5b9b58b0"
OPT_SUPPORT="8a461d79"
OPT_LATER="3f878a6e"
OPT_OUT_OF_SCOPE="583c6141"

# ── gh binary detection ────────────────────────────────────────────────────

find_gh() {
  local tmp_gh="/tmp/gh_2.92.0_linux_amd64/bin/gh"
  if [ -x "$tmp_gh" ]; then
    echo "$tmp_gh"
    return
  fi
  if command -v gh &>/dev/null && gh version 2>&1 | grep -q "cli/cli"; then
    echo "gh"
    return
  fi
  echo ""
}

GH=$(find_gh)
if [ -z "$GH" ]; then
  echo "Error: GitHub CLI (gh) is required but not found or not authenticated."
  echo ""
  echo "Install the official gh CLI:"
  echo "  # On Ubuntu/Debian:"
  echo "  curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg"
  echo "  echo 'deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main' | sudo tee /etc/apt/sources.list.d/github-cli.list"
  echo "  sudo apt update && sudo apt install gh"
  echo ""
  echo "Then authenticate:"
  echo "  gh auth login"
  exit 1
fi

if ! command -v jq &>/dev/null; then
  echo "Error: jq is required but not installed."
  echo ""
  echo "Install it with:"
  echo "  sudo apt install jq"
  exit 1
fi

# ── Data fetching ──────────────────────────────────────────────────────────

fetch_items() {
  $GH api graphql -f query='
    query($id: ID!) {
      node(id: $id) {
        ... on ProjectV2 {
          items(first: 100) {
            nodes {
              id
              content { ... on Issue { number title } ... on PullRequest { number title } }
              fieldValues(first: 15) {
                nodes {
                  ... on ProjectV2ItemFieldSingleSelectValue {
                    name
                    field { ... on ProjectV2SingleSelectField { name } }
                  }
                }
              }
            }
          }
        }
      }
    }
  ' -F id="$PROJECT_ID" --jq '[.data.node.items.nodes[] | {
    id: .id,
    number: .content.number,
    title: .content.title,
    fields: [.fieldValues.nodes[] | select(.field != null) | {(.field.name): .name}] | add
  }]'
}

get_item_id() {
  local number="$1"
  fetch_items | jq -r --argjson n "$number" '.[] | select(.number == $n) | .id // empty'
}

get_item_field() {
  local number="$1"
  local field_name="$2"
  fetch_items | jq -r --argjson n "$number" --arg f "$field_name" '.[] | select(.number == $n) | .fields[$f] // "—"'
}

set_single_select() {
  local issue_number="$1"
  local field_id="$2"
  local option_id="$3"
  local field_label="$4"
  local option_label="$5"

  local item_id
  item_id=$(get_item_id "$issue_number")
  if [ -z "$item_id" ]; then
    echo "  ERROR: Issue #$issue_number not found on project. Skipping."
    return 1
  fi

  echo "  Issue #$issue_number: $field_label → $option_label"
  $GH api graphql -f query='
    mutation($projectId: ID!, $itemId: ID!, $fieldId: ID!, $optionId: String!) {
      updateProjectV2ItemFieldValue(input: {
        projectId: $projectId
        itemId: $itemId
        fieldId: $fieldId
        value: { singleSelectOptionId: $optionId }
      }) { projectV2Item { id } }
    }
  ' -f projectId="$PROJECT_ID" -f itemId="$item_id" -f fieldId="$field_id" -f optionId="$option_id" --jq '.' > /dev/null
}

# ── Status name → option ID map ───────────────────────────────────────────

resolve_status() {
  case "$1" in
    "Todo") echo "$OPT_TODO" ;;
    "In Progress") echo "$OPT_IN_PROGRESS" ;;
    "Done") echo "$OPT_DONE" ;;
    "Blocked") echo "$OPT_BLOCKED" ;;
    "Review") echo "$OPT_REVIEW" ;;
    *) echo "" ;;
  esac
}

resolve_priority() {
  case "$1" in
    "P0") echo "$OPT_P0" ;;
    "P1") echo "$OPT_P1" ;;
    "P2") echo "$OPT_P2" ;;
    "P3") echo "$OPT_P3" ;;
    *) echo "" ;;
  esac
}

resolve_workstream() {
  case "$1" in
    "Product Docs") echo "$OPT_PRODUCT_DOCS" ;;
    "Frontend") echo "$OPT_FRONTEND" ;;
    "Backend") echo "$OPT_BACKEND" ;;
    "Database") echo "$OPT_DATABASE" ;;
    "UX Flow") echo "$OPT_UX_FLOW" ;;
    "Validation") echo "$OPT_VALIDATION" ;;
    "DevOps") echo "$OPT_DEVOPS" ;;
    *) echo "" ;;
  esac
}

resolve_mvp_fit() {
  case "$1" in
    "Core Loop") echo "$OPT_CORE_LOOP" ;;
    "Support") echo "$OPT_SUPPORT" ;;
    "Later") echo "$OPT_LATER" ;;
    "Out of Scope") echo "$OPT_OUT_OF_SCOPE" ;;
    *) echo "" ;;
  esac
}

# ── Individual field setters ───────────────────────────────────────────────

cmd_set_status() {
  local number="$1"
  local value="$2"
  local opt_id
  opt_id=$(resolve_status "$value")
  if [ -z "$opt_id" ]; then
    echo "Error: Unknown status '$value'. Valid: Todo, In Progress, Done, Blocked, Review"
    return 1
  fi
  set_single_select "$number" "$FIELD_STATUS" "$opt_id" "Status" "$value"
}

cmd_set_priority() {
  local number="$1"
  local value="$2"
  local opt_id
  opt_id=$(resolve_priority "$value")
  if [ -z "$opt_id" ]; then
    echo "Error: Unknown priority '$value'. Valid: P0, P1, P2, P3"
    return 1
  fi
  set_single_select "$number" "$FIELD_PRIORITY" "$opt_id" "Priority" "$value"
}

cmd_set_workstream() {
  local number="$1"
  local value="$2"
  local opt_id
  opt_id=$(resolve_workstream "$value")
  if [ -z "$opt_id" ]; then
    echo "Error: Unknown workstream '$value'. Valid: Product Docs, Frontend, Backend, Database, UX Flow, Validation, DevOps"
    return 1
  fi
  set_single_select "$number" "$FIELD_WORKSTREAM" "$opt_id" "Workstream" "$value"
}

cmd_set_mvp_fit() {
  local number="$1"
  local value="$2"
  local opt_id
  opt_id=$(resolve_mvp_fit "$value")
  if [ -z "$opt_id" ]; then
    echo "Error: Unknown MVP Fit '$value'. Valid: Core Loop, Support, Later, Out of Scope"
    return 1
  fi
  set_single_select "$number" "$FIELD_MVP_FIT" "$opt_id" "MVP Fit" "$value"
}

cmd_done() {
  cmd_set_status "$1" "Done"
}

cmd_start() {
  cmd_set_status "$1" "In Progress"
}

# ── Bootstrap Core ─────────────────────────────────────────────────────────

cmd_bootstrap_core() {
  echo "Bootstrapping core issues (#1-#12)..."

  # #1 Add initial database migration
  echo "---"
  cmd_set_status    1 "Done"
  cmd_set_priority  1 "P0"
  cmd_set_workstream 1 "Database"
  cmd_set_mvp_fit   1 "Core Loop"

  # #2 Add Prisma client helper
  echo "---"
  cmd_set_status    2 "Done"
  cmd_set_priority  2 "P0"
  cmd_set_workstream 2 "Backend"
  cmd_set_mvp_fit   2 "Core Loop"

  # #3 Add ActionItem CRUD API
  echo "---"
  cmd_set_status    3 "Done"
  cmd_set_priority  3 "P0"
  cmd_set_workstream 3 "Backend"
  cmd_set_mvp_fit   3 "Core Loop"

  # #4 Add CapacityCheckIn API
  echo "---"
  cmd_set_status    4 "Todo"
  cmd_set_priority  4 "P0"
  cmd_set_workstream 4 "Backend"
  cmd_set_mvp_fit   4 "Core Loop"

  # #5 Add Reflection API
  echo "---"
  cmd_set_status    5 "Todo"
  cmd_set_priority  5 "P1"
  cmd_set_workstream 5 "Backend"
  cmd_set_mvp_fit   5 "Core Loop"

  # #6 Connect frontend to API health endpoint
  echo "---"
  cmd_set_status    6 "Todo"
  cmd_set_priority  6 "P1"
  cmd_set_workstream 6 "Frontend"
  cmd_set_mvp_fit   6 "Support"

  # #7 Build action capture form
  echo "---"
  cmd_set_status    7 "Todo"
  cmd_set_priority  7 "P0"
  cmd_set_workstream 7 "Frontend"
  cmd_set_mvp_fit   7 "Core Loop"

  # #8 Build action list view
  echo "---"
  cmd_set_status    8 "Todo"
  cmd_set_priority  8 "P0"
  cmd_set_workstream 8 "Frontend"
  cmd_set_mvp_fit   8 "Core Loop"

  # #9 Build daily capacity check-in screen
  echo "---"
  cmd_set_status    9 "Todo"
  cmd_set_priority  9 "P0"
  cmd_set_workstream 9 "Frontend"
  cmd_set_mvp_fit   9 "Core Loop"

  # #10 Build next-small-step rule
  echo "---"
  cmd_set_status    10 "Todo"
  cmd_set_priority  10 "P0"
  cmd_set_workstream 10 "UX Flow"
  cmd_set_mvp_fit   10 "Core Loop"

  # #11 Build completion reflection flow
  echo "---"
  cmd_set_status    11 "Todo"
  cmd_set_priority  11 "P1"
  cmd_set_workstream 11 "UX Flow"
  cmd_set_mvp_fit   11 "Core Loop"

  # #12 Build basic dashboard
  echo "---"
  cmd_set_status    12 "Todo"
  cmd_set_priority  12 "P1"
  cmd_set_workstream 12 "Frontend"
  cmd_set_mvp_fit   12 "Core Loop"

  echo "---"
  echo "Bootstrap complete."
}

# ── Validate ───────────────────────────────────────────────────────────────

cmd_validate() {
  local items
  items=$(fetch_items)
  echo "Validating project board hygiene..."
  echo ""

  local tmpfile
  tmpfile=$(mktemp)
  echo "$items" > "$tmpfile"

  local total
  total=$(echo "$items" | jq 'length')
  local errors=0
  local i=0

  while [ "$i" -lt "$total" ]; do
    local num title status priority ws mvp
    num=$(jq -r ".[$i].number" "$tmpfile")
    title=$(jq -r ".[$i].title" "$tmpfile")
    status=$(jq -r ".[$i].fields.Status // \"\"" "$tmpfile")
    priority=$(jq -r ".[$i].fields.Priority // \"\"" "$tmpfile")
    ws=$(jq -r ".[$i].fields.Workstream // \"\"" "$tmpfile")
    mvp=$(jq -r ".[$i].fields[\"MVP Fit\"] // \"\"" "$tmpfile")

    local issue_errors=0
    local issues=""

    if [ -z "$status" ]; then
      issues="$issues Status"
      issue_errors=$((issue_errors + 1))
    fi
    if [ -z "$priority" ]; then
      issues="$issues Priority"
      issue_errors=$((issue_errors + 1))
    fi
    if [ -z "$ws" ]; then
      issues="$issues Workstream"
      issue_errors=$((issue_errors + 1))
    fi
    if [ -z "$mvp" ]; then
      issues="$issues MVP_Fit"
      issue_errors=$((issue_errors + 1))
    fi

    if [ "$issue_errors" -eq 0 ]; then
      echo "  ✓ #$num ($title): Status=$status | Priority=$priority | Workstream=$ws | MVP Fit=$mvp"
    else
      echo "  ✗ #$num ($title): missing$issues"
      errors=$((errors + 1))
    fi

    i=$((i + 1))
  done

  rm -f "$tmpfile"

  echo ""
  if [ "$errors" -eq 0 ]; then
    echo "All $total issues have complete field data."
  else
    echo "$errors of $total issue(s) have missing fields."
  fi
  return "$errors"
}

# ── Help ───────────────────────────────────────────────────────────────────

help() {
  echo "Arov project board sync"
  echo ""
  echo "Usage: $0 <command> [args...]"
  echo ""
  echo "Commands:"
  echo "  bootstrap-core         Set Status, Priority, Workstream, MVP Fit for issues #1-#12"
  echo "  set-status <n> <val>   Set Status (Todo|In Progress|Done|Blocked|Review)"
  echo "  set-priority <n> <val> Set Priority (P0|P1|P2|P3)"
  echo "  set-workstream <n> <v> Set Workstream (Product Docs|Frontend|Backend|Database|UX Flow|Validation|DevOps)"
  echo "  set-mvp-fit <n> <val>  Set MVP Fit (Core Loop|Support|Later|Out of Scope)"
  echo "  start <n>              Shorthand: set Status = In Progress"
  echo "  done <n>               Shorthand: set Status = Done"
  echo "  validate               Check all issues for missing field values"
  echo "  help                   Show this message"
}

# ── Main ───────────────────────────────────────────────────────────────────

if [ $# -eq 0 ]; then
  help
  exit 0
fi

CMD="$1"
shift

case "$CMD" in
  bootstrap-core)
    cmd_bootstrap_core
    ;;
  set-status)
    [ $# -ge 2 ] || { echo "Usage: $0 set-status <issue-number> <status>"; exit 1; }
    cmd_set_status "$1" "$2"
    ;;
  set-priority)
    [ $# -ge 2 ] || { echo "Usage: $0 set-priority <issue-number> <priority>"; exit 1; }
    cmd_set_priority "$1" "$2"
    ;;
  set-workstream)
    [ $# -ge 2 ] || { echo "Usage: $0 set-workstream <issue-number> <workstream>"; exit 1; }
    cmd_set_workstream "$1" "$2"
    ;;
  set-mvp-fit)
    [ $# -ge 2 ] || { echo "Usage: $0 set-mvp-fit <issue-number> <mvp-fit>"; exit 1; }
    cmd_set_mvp_fit "$1" "$2"
    ;;
  done)
    [ $# -ge 1 ] || { echo "Usage: $0 done <issue-number>"; exit 1; }
    cmd_done "$1"
    ;;
  start)
    [ $# -ge 1 ] || { echo "Usage: $0 start <issue-number>"; exit 1; }
    cmd_start "$1"
    ;;
  validate)
    cmd_validate
    ;;
  help)
    help
    ;;
  *)
    echo "Unknown command: $CMD"
    help
    exit 1
    ;;
esac
