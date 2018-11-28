#!/bin/bash -e

bucket="${2:-$REPO_ARCHIVE_BUCKET}"

aws s3 ls --human-readable s3://"$bucket"/
