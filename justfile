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