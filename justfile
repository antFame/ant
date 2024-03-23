
import 'worker/justfile'

git-sync:
  git submodule sync
  git submodule update --init --recursive


boot-worker: 
  just worker/genWorkerName
  just worker/boot