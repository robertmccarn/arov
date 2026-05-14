#!/usr/bin/env bash
set -euo pipefail

PROJECT_ID="PVT_kwHOAzxw084BXvVQ"
OWNER="robertmccarn"
GH="/tmp/gh_2.92.0_linux_amd64/bin/gh"

if ! command -v jq &>/dev/null; then
  echo "Error: jq is required but not installed."
  echo ""
  echo "Install it with:"
  echo "  sudo apt install jq"
  exit 1
fi

fetch_items() {
  $GH api graphql -f query='
    query($id: ID!) {
      node(id: $id) {
        ... on ProjectV2 {
          items(first: 100) {
            nodes {
              id
              content { ... on Issue { number title url } }
              fieldValues(first: 15) {
                nodes {
                  ... on ProjectV2ItemFieldSingleSelectValue {
                    optionName: name
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
    number: .content.number,
    title: .content.title,
    url: .content.url,
    fields: [.fieldValues.nodes[] | select(.field != null) | {(.field.name): .optionName}] | add
  }]'
}

help() {
  echo "Arov scripted project board views"
  echo ""
  echo "Usage: $0 <command>"
  echo ""
  echo "Commands:"
  echo "  all          Show all items with Status, Priority, Workstream, MVP Fit"
  echo "  kanban       Show items sorted by Status"
  echo "  mvp          Show items with Priority P0 or P1"
  echo "  workstreams  Show items grouped by Workstream"
  echo "  blocked      Show items with Status Blocked"
  echo "  review       Show items with Status Review"
  echo "  priority     Show items grouped by Priority"
  echo "  deployment   Show items where Workstream is DevOps or MVP Fit is Support"
  echo "  help         Show this message"
}

if [ $# -eq 0 ]; then
  help
  exit 0
fi

CMD="$1"
ITEMS=$(fetch_items)

case "$CMD" in
  all)
    echo "$ITEMS" | jq -r '["#","Title","Status","Priority","Workstream","MVP Fit"],
      (.[] | [.number, .title,
        (.fields.Status // "-"),
        (.fields.Priority // "-"),
        (.fields.Workstream // "-"),
        (.fields["MVP Fit"] // "-")
      ]),
      ["","","","","",""]
    | @tsv' | column -t -s $'\t'
    echo ""
    echo "$(echo "$ITEMS" | jq 'length') items total"
    ;;

  kanban)
    echo "$ITEMS" | jq -r '
      group_by(.fields.Status // "Unset")
      | sort_by(.[0].fields.Status // "")
      | .[] | (.[0].fields.Status // "Unset") as $status
      | "", "=== \($status) ===",
        (.[] | "  #\(.number)  \(.title)")
    '
    ;;

  mvp)
    echo "$ITEMS" | jq -r '[.[] | select(.fields.Priority == "P0" or .fields.Priority == "P1")]
      | if length == 0 then "No P0 or P1 items found."
        else ["#","Title","Priority","Status"],
          (.[] | [.number, .title, .fields.Priority, (.fields.Status // "-")]),
          ["","","",""]
        | @tsv end' | column -t -s $'\t'
    echo ""
    echo "$(echo "$ITEMS" | jq '[.[] | select(.fields.Priority == "P0" or .fields.Priority == "P1")] | length') MVP-scope items"
    ;;

  workstreams)
    echo "$ITEMS" | jq -r '
      group_by(.fields.Workstream // "Unset")
      | sort_by(.[0].fields.Workstream // "")
      | .[] | (.[0].fields.Workstream // "Unset") as $ws
      | "", "=== \($ws) ===",
        (.[] | "  #\(.number)  \(.title)")
    '
    ;;

  blocked)
    echo "$ITEMS" | jq -r '[.[] | select(.fields.Status == "Blocked")]
      | if length == 0 then "No blocked items."
        else ["#","Title","Priority","Workstream"],
          (.[] | [.number, .title, (.fields.Priority // "-"), (.fields.Workstream // "-")]),
          ["","","",""]
        | @tsv end' | column -t -s $'\t'
    ;;

  review)
    echo "$ITEMS" | jq -r '[.[] | select(.fields.Status == "Review")]
      | if length == 0 then "No items in review."
        else ["#","Title","Priority","Workstream"],
          (.[] | [.number, .title, (.fields.Priority // "-"), (.fields.Workstream // "-")]),
          ["","","",""]
        | @tsv end' | column -t -s $'\t'
    ;;

  priority)
    echo "$ITEMS" | jq -r '
      group_by(.fields.Priority // "Unset")
      | sort_by(.[0].fields.Priority // "")
      | .[] | (.[0].fields.Priority // "Unset") as $pri
      | "", "=== \($pri) ===",
        (.[] | "  #\(.number)  \(.title)")
    '
    ;;

  deployment)
    echo "$ITEMS" | jq -r '[.[] | select(.fields.Workstream == "DevOps" or .fields["MVP Fit"] == "Support")]
      | if length == 0 then "No deployment/support items."
        else ["#","Title","Workstream","MVP Fit"],
          (.[] | [.number, .title, (.fields.Workstream // "-"), (.fields["MVP Fit"] // "-")]),
          ["","","",""]
        | @tsv end' | column -t -s $'\t'
    echo ""
    echo "$(echo "$ITEMS" | jq '[.[] | select(.fields.Workstream == "DevOps" or .fields["MVP Fit"] == "Support")] | length') deployment/support items"
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
