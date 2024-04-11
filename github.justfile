
add-collaborator USER="lemniscite" REPO="antFame/ant":
  gh api --method=PUT 'repos/{{REPO}}/collaborators/{{USER}}' -f permission=admin

# https://docs.github.com/en/rest/collaborators/collaborators?apiVersion=2022-11-28

@list-invitations:
  gh api \
    -H "Accept: application/vnd.github+json" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    /user/repository_invitations

accept-invitation INVITATION_ID:
  gh api \
    --method PATCH \
    -H "Accept: application/vnd.github+json" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    /user/repository_invitations/{{INVITATION_ID}}

accept-all-invitations:
  just list-invitations | jq -r '.[] | .id' | xargs -I {} just accept-invitation {}


# 'direct_member' or 'admin' or 'billing_manager'
org-invite INVITE_EMAIL="lemniscite@gmail.com" ROLE="admin":
  gh api \
    --method POST \
    -H "Accept: application/vnd.github+json" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    /orgs/ORG/invitations \
    -f email={{INVITE_EMAIL}} \
  -f role= \
  
  # https://docs.github.com/en/rest/orgs/members?apiVersion=2022-11-28#create-an-organization-invitation


create-repo REPO_NAME ORG="{{WORKER_ORG}}":
  gh api --method POST /orgs/{{ORG}}/repos -f name="{{REPO_NAME}}" -f private=false -f auto_init=true -f gitignore_template=Node -f license_template=mit