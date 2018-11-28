# Jayway GitHub Repository Archiver

## Quick Start

0. Install [prerequisites](#prerequisites) and set [environment variable secrets](#secrets).

1. Archive a repository

   ```bash
   ./src/archive-repo.sh <repo>
   ```

   where you can browse the repo at `https://github.com/jayway/<repo>`

1. List archived repositories

   ```bash
   ./src/list-archived-repos.sh
   ```

1. Restore an archived repository

   ```bash
   ./src/restore-repo.sh <repo>
   ```

   where the archive, as listed by `./src/list-archived-repos.sh`, is
   called `<repo>.bundle`

   You can also ask the [GitHub Admin team][admins] for help. Look for us on Slack
   (in the [#github][slack] channel).

[admins]: https://github.com/orgs/jayway/people?utf8=%E2%9C%93&query=+role%3Aowner
[slack]: https://jayway.slack.com/messages/C7D8ETPUL/

## Prerequisites

You need to have the following software installed:

- A [git][git] client
- The [AWS CLI][aws]

[git]: https://git-scm.com/book/en/v2/Getting-Started-Installing-Git
[aws]: https://docs.aws.amazon.com/cli/latest/userguide/installing.html

## Secrets

You should have the following environment variables defined (with sufficient
privileges associated to the accounts) for this to work:

```env
AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
GITHUB_API_TOKEN=
REPO_ARCHIVE_BUCKET=
```
