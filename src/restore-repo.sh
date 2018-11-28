#!/bin/bash -e

repo="${1?"Usage: $0 <repo-name>"}"
bucket="${2:-$REPO_ARCHIVE_BUCKET}"

cwd="${PWD##*/}"
tmp=./tmp

if [[ "${PWD##*/}" == "$cwd" ]]; then
  rm -rf "$tmp"
else
  echo "ERROR: Not in archival repo root." > /dev/stderr
  exit 1
fi

mkdir -p "$tmp"
pushd "$tmp" > /dev/null

bundle="$repo".bundle

echo "Fetching archived bundle from S3..."

aws s3 cp s3://"$bucket"/"$bundle" ./"$bundle" 1>&2

echo "Unpacking bundle..."

git clone "$bundle" "$repo" 1>&2

pushd "$repo" > /dev/null

git branch -r \
| grep -v -e '\->' -e master \
| while read -r remote; do
  git branch --track "${remote#origin/}" "$remote" 1>&2
done
git remote rm origin

echo "Cleaning up..."

popd > /dev/null

if [[ "${PWD##*/}" == "${tmp##*/}" ]]; then
  rm ./"$bundle"
else
  echo "Not in $tmp (actually in $PWD)"
fi

popd > /dev/null

echo "Restored repository jayway/$repo into ./tmp/$repo"
