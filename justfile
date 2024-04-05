# set shell := ["sh", "-c"]
# set windows-shell := ["powershell.exe", "-NoLogo", "-Command"]
set allow-duplicate-recipes
# set positional-arguments
set dotenv-load
set export 

# import 'worker/justfile'

import 'github.justfile'

default: boot-worker
sync: git-sync

git-sync:
  git submodule sync
  git submodule update --init --recursive


boot-worker: 
  just worker/genWorkerName
  just worker/boot

setup-ssh SSH_PRIVATE_KEY :
  mkdir -p ~/.ssh/
  echo -e "Host github.com\nHostName github.com\nUser git\nIdentityFile ~/.ssh/github.com\nIdentitiesOnly yes" > ~/.ssh/config
  echo "{{ SSH_PRIVATE_KEY }}" > ~/.ssh/github.com
  chmod 600 ~/.ssh/config ~/.ssh/github.com

cancel-github-jobs:
  #!/bin/bash

  # Retrieve list of workflow runs
  runs=$(gh api repos/:owner/:repo/actions/runs)

  # Get current timestamp in epoch format
  current_timestamp=$(date +%s)

  # Iterate over each workflow run
  echo "$runs" | jq -r '.workflow_runs[] | select(.created_at | fromdateiso8601 | (. / 1000) < '"$((current_timestamp - 3600))"') | .id' | while read -r run_id; do
      # Cancel workflow run
      gh run cancel "$run_id"
  done

# https://cli.github.com/manual/gh_secret_set
set-secret SECRET_NAME SECRET_VALUE ORG REPO :
  gh secret set {{SECRET_NAME}} -R github.com/{{ORG}}/{{REPO}} --body "{{SECRET_VALUE}}"
  
# TODO: refer doc and if to set secrets accordiing if org or repo passed and stuff
# gh secret remove {{SECRET_NAME}} --org {{ORG}} --repo {{REPO}}
# set or update secrets
# gh secret set {{SECRET_NAME}} --org {{ORG}} --repos {{REPO}} --body {{SECRET_VALUE}}



# recipe params: https://just.systems/man/en/chapter_38.html