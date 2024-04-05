
add-collaborator USER="lemniscite" REPO="antFame/ant":
  gh api --method=PUT 'repos/{{REPO}}/collaborators/{{USER}}'
