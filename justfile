# set shell := ["sh", "-c"]
# set windows-shell := ["powershell.exe", "-NoLogo", "-Command"]
set allow-duplicate-recipes
# set positional-arguments
set dotenv-load
set export 

# import 'worker/justfile'

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

set-secret SECRET_NAME ORG REPO SECRET_VALUE:
  # gh secret remove {{SECRET_NAME}} --org {{ORG}} --repo {{REPO}}
  # set or update secrets
  gh secret set {{SECRET_NAME}} --org {{ORG}} --repos {{REPO}} --body {{SECRET_VALUE}}

[unix] #only works for linux
@list-runners ORG : #="{{WORKER_ORG}}":
  gh api \
  -H "Accept: application/vnd.github+json" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  /orgs/{{ORG}}/actions/runners

[unix]
delete-runner ORG RunnerId:
  gh api \
  --method DELETE \
  -H "Accept: application/vnd.github+json" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  /orgs/{{ORG}}/actions/runners/{{RunnerId}}

[unix]
remove-all-runners ORG concurrency="1":
  just list-runners {{ORG}} | jq .runners[].id | xargs -P {{concurrency}} -I {} just delete-runner {{ORG}} {} 

[unix]
@get-runner-name ORG="{{WORKER_ORG}}" RunnerName="{{WORKER_NAME}}": 
  just list-runners {{ORG}} | jq '.runners[] | select(.name == "{{RunnerName}}")'

[unix]
delete-runner-name ORG="{{WORKER_ORG}}" RunnerName="{{WORKER_NAME}}": 
  just get-runner-name {{ORG}} {{RunnerName}} | jq '.id' | xargs -I {} just delete-runner {{ORG}} {} 


#TODO: move to worker just file with default oa to different jsutfile

# recipe params: https://just.systems/man/en/chapter_38.html