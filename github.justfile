
add-user-org USER="lemniscite" REPO="antFame/ant":
  gh api --method=PUT 'repos/{{REPO}}/collaborators/{{USER}}'
