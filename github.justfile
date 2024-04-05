
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