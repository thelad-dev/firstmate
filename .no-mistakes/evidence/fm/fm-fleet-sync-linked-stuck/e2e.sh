#!/usr/bin/env bash
# Live E2E: fm-fleet-sync.sh gegen eine Wegwerf-Lab-Home mit verknüpftem Worktree
set -u
WT=${WT:-/home/ladwein/.no-mistakes/worktrees/ba6c6cc2a1ec/01M5ERFHMNV13E0DEG59Z5QK20}
LAB=$(mktemp -d "${TMPDIR:-/tmp}/fm-lab.XXXXXX")
"$WT/bin/fm-lab-home.sh" create "$LAB" >/dev/null
export GIT_AUTHOR_NAME=t GIT_AUTHOR_EMAIL=t@t GIT_COMMITTER_NAME=t GIT_COMMITTER_EMAIL=t@t
G="git -c init.defaultBranch=main"
step(){ echo; echo "### $*"; }
sync(){ echo "\$ fm-fleet-sync.sh $*"; env -u NO_MISTAKES_GATE -u FM_ROOT_OVERRIDE -u FM_PROJECTS_OVERRIDE FM_HOME="$LAB" "$WT/bin/fm-fleet-sync.sh" "$@" 2>&1; echo "(exit $?)"; }
head_of(){ echo "HEAD $(basename $1): $(git -C "$1" rev-parse --short HEAD) branch=$(git -C "$1" symbolic-ref -q --short HEAD || echo DETACHED)"; }
cd "$LAB"
$G init -q --bare origin.git
$G clone -q origin.git seed 2>/dev/null; cd seed; echo a>f; git add f; git commit -qm c1; git push -q origin main; cd "$LAB"
$G clone -q origin.git projects/app
git -C projects/app worktree add -q --detach "$LAB/projects/app-linked" main
# Origin rückt einen Commit vor
cd seed; echo b>>f; git commit -qam c2; git push -q origin main; cd "$LAB"
git -C projects/app-linked fetch -q
step "S1: sauberer verknüpfter Worktree, 1 Commit hinter origin/main"
head_of projects/app-linked; echo "origin/main: $(git -C projects/app rev-parse --short origin/main)"
sync projects/app-linked
head_of projects/app-linked; head_of projects/app
echo "lokaler main im Primärklon: $(git -C projects/app rev-parse --short main)"
step "S2: zweiter Lauf, 0 Commits Rückstand"
sync projects/app-linked
head_of projects/app-linked
step "S3: dirty verknüpfter Worktree bleibt STUCK und unangetastet"
cd seed; echo c>>f; git commit -qam c3; git push -q origin main; cd "$LAB"
echo dirty >> projects/app-linked/f
B=$(git -C projects/app-linked rev-parse --short HEAD)
sync projects/app-linked
head_of projects/app-linked; echo "vorher $B; diff: $(git -C projects/app-linked diff --stat | tail -1)"
git -C projects/app-linked checkout -q -- f
step "S4: verknüpfter Worktree mit eigenem Commit bleibt STUCK und unangetastet"
echo own > projects/app-linked/g; git -C projects/app-linked add g; git -C projects/app-linked commit -qm own
B=$(git -C projects/app-linked rev-parse --short HEAD)
sync projects/app-linked
head_of projects/app-linked; echo "vorher $B"
git -C projects/app-linked checkout -q --detach origin/main~1
step "S5: verknüpfter Worktree auf benanntem Nicht-Default-Branch bleibt STUCK"
git -C projects/app-linked checkout -q -b feature
sync projects/app-linked
head_of projects/app-linked
git -C projects/app-linked checkout -q --detach origin/main~1; git -C projects/app-linked branch -qD feature
step "S6: Primärklon wird normal synchronisiert; lokaler main nicht vom Linked-Lauf bewegt"
sync projects/app-linked
head_of projects/app-linked
echo "lokaler main im Primärklon vor eigenem Sync: $(git -C projects/app rev-parse --short main)"
sync projects/app
head_of projects/app
step "S7: freier Detached-Klon (Default nirgends ausgecheckt) wird weiterhin 'recovered'"
$G clone -q origin.git projects/solo; git -C projects/solo checkout -q --detach origin/main~1
sync projects/solo
head_of projects/solo
step "S8: Ganzer Flottenlauf ohne Argument"
sync
cd /; rm -rf "$LAB"; echo; echo "Lab entfernt: $LAB"
