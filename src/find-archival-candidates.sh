#!/bin/bash -e

function query {
  cursor=$1
  echo "{
    organization(login: \\\"jayway\\\") {
      repositories(first: 100, after: \\\"$cursor\\\") {
        nodes {
          name
          pushedAt
          createdAt
          isArchived
          isPrivate
        }
        pageInfo {
          hasNextPage
          endCursor
        }
      }
    }
  }"
}

function get_100_repos {
  cursor=${1:-''}

  q=$(query $cursor)
  data="{\"query\": \"${q//$'\n'/}\"}"

  curl -s \
      -H 'Content-Type: application/json' \
      -H "Authorization: bearer $GITHUB_API_TOKEN" \
      -X POST \
      -d "$data" \
      https://api.github.com/graphql
}

function get_repos {
  cursor=''
  hasNext='true'
  while [[ "$hasNext" == "true" ]]; do
    response=$(get_100_repos $cursor)

    hasNext=$(echo "$response" | jq '.data.organization.repositories.pageInfo.hasNextPage')
    repos=$(echo "$response" | jq '.data.organization.repositories.nodes')
    cursor=$(echo "$response" | jq -r '.data.organization.repositories.pageInfo.endCursor')
    echo "$repos"
  done
}

threeYearsAgo=$(date +%s -d "3 years ago")

cache='./.repos.tmp'
if ! [[ -f "$cache" ]]; then
  get_repos > "$cache"
fi

jquery="
  flatten 
  | sort_by(.pushedAt | fromdateiso8601? * -1)
  | map(select(.pushedAt | fromdateiso8601? <= $threeYearsAgo))
  | map(\"\(.pushedAt)  \(.name)\")
  | .[]
"
jq -s -r "${jquery//\\n/}" "$cache"
