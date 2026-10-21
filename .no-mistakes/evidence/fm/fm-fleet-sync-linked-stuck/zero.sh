#!/usr/bin/env bash
set -u
LAB=$(mktemp -d "${TMPDIR:-/tmp}/fm-lab.XXXXXX"); "$WT/bin/fm-lab-home.sh" create "$LAB" >/dev/null
export GIT_AUTHOR_NAME=t GIT_AUTHOR_EMAIL=t@t GIT_COMMITTER_NAME=t GIT_COMMITTER_EMAIL=t@t
cd "$LAB"; git -c init.defaultBranch=main init -q --bare origin.git
git -c init.defaultBranch=main clone -q origin.git seed 2>/dev/null; cd seed; echo a>f; git add f; git commit -qm c1; git push -q origin main; cd "$LAB"
git clone -q origin.git projects/app; git -C projects/app worktree add -q --detach "$LAB/projects/app-linked" main
cd seed; echo b>>f; git commit -qam c2; git push -q origin main; cd "$LAB"
git -C projects/app-linked fetch -q; git -C projects/app-linked checkout -q --detach origin/main
echo "manuell detached auf origin/main: $(git -C projects/app-linked rev-parse --short HEAD)"
env -u NO_MISTAKES_GATE -u FM_ROOT_OVERRIDE -u FM_PROJECTS_OVERRIDE FM_HOME="$LAB" "$WT/bin/fm-fleet-sync.sh" projects/app-linked 2>&1
cd /; rm -rf "$LAB"
