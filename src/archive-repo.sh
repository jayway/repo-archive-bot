#!/bin/bash -e

repo="${1?"Usage: $0 <repo-name>"}"
bucket="${2:-$REPO_ARCHIVE_BUCKET}"

cwd="${PWD##*/}"

tmp=./tmp/"$repo"

if [[ "${PWD##*/}" == "$cwd" ]]; then
  rm -rf "$tmp"
else
  echo "Not in archival repo root; skipping initial temp data cleanup"
fi

echo "Cloning jayway/$repo into $tmp..."
git clone git@github.com:jayway/"$repo" "$tmp" 1>&2

pushd "$tmp" > /dev/null

if [[ "$(git log --oneline -n1)" =~ "Post archival notice" ]]; then
  echo "This repository has already been archived."
  exit 0
fi

branch="$(git rev-parse --abbrev-ref HEAD)"

echo "Creating bundle from jayway/$repo..."
git branch -r \
| grep -v -e '\->' -e master \
| while read -r remote; do
  git branch --track "${remote#origin/}" "$remote" 1>&2
done
git remote rm origin

bundle="$repo".bundle
git branch --format='%(refname:short)' \
| xargs git bundle create ../"$bundle" HEAD 1>&2

echo "Backing up bundle to AWS S3..."
aws s3 cp ../"$bundle" s3://"$bucket"/"$bundle" 1>&2

if [[ "${PWD##*/}" == "$repo" ]]; then
    git rm -r ./* ./.[^.]* --ignore-unmatch 1>&2
    cp ../../src/ARCHIVAL-NOTICE.md README.md 1>&2
    git add . 1>&2
    git commit -m "Post archival notice" 1>&2
    git remote add origin git@github.com:jayway/"$repo" 1>&2
    git push -u origin "$branch" 1>&2
else
  echo "Not in repo directory; skipping archival notice replacement"
fi

popd > /dev/null

if [[ "${PWD##*/}" == "archiver" ]]; then
  rm -rf ./tmp
else
  echo "Not in archiver repo root, skipping removal of temp directory"
fi

echo "Successfully archived jayway/$repo"
