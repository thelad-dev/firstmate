#!/usr/bin/env bash
# Manual end-to-end evidence: board build with filed UTC timestamp under many TZs.
set -u
ROOT=${1:?repo root}
EVID=${2:?evidence dir}
cd "$ROOT"
# shellcheck disable=SC1091
. tests/lib.sh
BOARD="$ROOT/bin/fm-bearings-board.sh"
TMP_ROOT=$(fm_test_tmproot fm-board-tz-e2e)
TRANSCRIPT="$EVID/e2e-filed-timestamp-timezone-transcript.txt"

make_home() {
  local home="$TMP_ROOT/$1" fakebin
  fm_test_track_procevent_home "$home" "$home/procevent-claims"
  mkdir -p "$home/state" "$home/data" "$home/lavish-state"
  fakebin=$(fm_fakebin "$home")
  cat > "$fakebin/lavish-axi" <<'SH'
#!/usr/bin/env bash
set -u
state=${LAVISH_FAKE_STATE:?}
emit() {
  printf 'session:\n'
  printf '  file: %s\n' "$1"
  printf '  url: "http://127.0.0.1:4387/session/0123456789abcdef"\n'
  printf '  status: %s\n' "$2"
}
case "${1-}" in
  --version) printf '0.1.61\n'; exit 0 ;;
  poll)
    limit=${FM_TEST_STUB_MAX_BLOCK_SECONDS:-120}
    while [ ! -e "$state/poll-trigger" ]; do
      [ "$SECONDS" -lt "$limit" ] || exit 75
      sleep 0.05
    done
    printf 'session:\n  status: ended\n'
    exit 0
    ;;
  '')
    printf 'sessions[1]{file,status,url,pending_prompts}:\n'
    if [ -s "$state/open" ]; then
      while IFS= read -r listed; do
        [ -n "$listed" ] || continue
        printf '  %s,open,"http://127.0.0.1:4387/session/0123456789abcdef",0\n' "$listed"
      done < "$state/open"
    fi
    exit 0
    ;;
  end) : > "$state/open"; printf 'session:\n  status: ended\n'; exit 0 ;;
esac
file=$1
shift
real=$(cd "$(dirname "$file")" && pwd -P)/$(basename "$file")
printf '%s\n' "$real" > "$state/open"
jq -n --arg file "$real" \
  '{sessions:{"0123456789abcdef":{file:$file,url:"http://127.0.0.1:4387/session/0123456789abcdef"}}}' \
  > "$state/state.json"
emit "$real" opened
exit 0
SH
  chmod +x "$fakebin/lavish-axi"
  printf '%s\n' "$home"
}

run_board() {
  local home=$1
  shift
  PATH="$home/fakebin:$PATH" FM_HOME="$home" \
    FM_STATE_OVERRIDE="$home/state" FM_DATA_OVERRIDE="$home/data" \
    FM_PROCEVENT_CLAIM_ROOT="$home/procevent-claims" \
    LAVISH_FAKE_STATE="$home/lavish-state" LAVISH_AXI_STATE_DIR="$home/lavish-state" \
    "$BOARD" "$@"
}

write_valid_payload() {
  cat > "$1" <<'EOF'
{
  "schema": "fm-bearings-board.v1",
  "home": "test-home",
  "generated": "2026-08-19T00:00Z",
  "prs_live": false,
  "captains_call": [
    {
      "key": "sample-instruction-layer-refinement-review-decision-perishable-first-admission-choice",
      "type": "decision",
      "repo": "sample",
      "title": "Perishable-first admission",
      "about": "about",
      "decide": "Adopt it?",
      "options": [
        { "value": "yes", "label": "Adopt", "hint": "recommended" },
        { "value": "no", "label": "Keep current" }
      ],
      "allow_freeform": true
    }
  ],
  "underway": [],
  "landed": [],
  "charted": [
    { "id": "sample-queued", "repo": "sample", "title": "Queued work", "reason": "", "dispatchable": true }
  ],
  "charted_more": 0
}
EOF
}

extract_payload() {
  sed -n '/<script id="bearings-data" type="application\/json">/,/<\/script>/p' "$1" \
    | sed '1d;$d'
}

{
  echo "=== End-to-end: board build with filed timestamp under non-UTC TZ ==="
  echo "jq version: $(jq --version)"
  echo "repo: $ROOT"
  echo "host date default TZ=${TZ:-<unset>}: $(date)"
  echo

  for tz in UTC Europe/Berlin America/New_York Asia/Kolkata; do
    echo "--- TZ=$tz ---"
    export TZ="$tz"
    home=$(make_home "e2e-${tz//\//-}")
    data="$home/payload.json"
    write_valid_payload "$data"
    jq '.charted[0].filed = "2026-08-14T09:30:00Z"' "$data" > "$data.tmp" && mv "$data.tmp" "$data"
    echo "payload.filed=$(jq -r '.charted[0].filed' "$data")"
    set +e
    out=$(run_board "$home" build "$data" 2>&1)
    rc=$?
    set -e
    echo "build_exit=$rc"
    if [ "$rc" -eq 0 ]; then
      board="$home/.lavish/bearings-board.html"
      echo "board_exists=$([ -f "$board" ] && echo yes || echo no)"
      filed=$(extract_payload "$board" | jq -r '.charted[0].filed')
      echo "built_board.charted[0].filed=$filed"
      if grep -q '2026-08-14T09:30:00Z' "$board"; then
        echo "html_contains_timestamp=yes"
      else
        echo "html_contains_timestamp=no"
      fi
      cp "$board" "$EVID/bearings-board-${tz//\//-}.html"
    else
      echo "build_output:"
      printf '%s\n' "$out" | head -40
    fi

    write_valid_payload "$data"
    jq '.charted[0].filed = "2026-08-14T12:00:61Z"' "$data" > "$data.tmp" && mv "$data.tmp" "$data"
    set +e
    out=$(run_board "$home" build "$data" 2>&1)
    rc=$?
    set -e
    echo "invalid_second61_exit=$rc (expect non-zero)"
    printf '%s\n' "$out" | head -3
    echo
  done

  echo "=== jq 1.6 regression demonstration (old vs new path) under Europe/Berlin ==="
  export TZ=Europe/Berlin
  echo "TZ=$TZ"
  echo -n "OLD fromdateiso8601 path: "
  jq -n '"2026-08-14T09:30:00Z" as $f | $f | fromdateiso8601 | strftime("%Y-%m-%dT%H:%M:%SZ")'
  echo -n "NEW strptime|strftime path: "
  jq -n '"2026-08-14T09:30:00Z" as $f | $f | strptime("%Y-%m-%dT%H:%M:%SZ") | strftime("%Y-%m-%dT%H:%M:%SZ")'
  echo -n "second 61 bound check: "
  jq -n '
    "2026-08-14T12:00:61Z" as $filed
    | try (
        $filed | strptime("%Y-%m-%dT%H:%M:%SZ") as $parts
        | (($parts | strftime("%Y-%m-%dT%H:%M:%SZ")) == $filed)
          and ($parts[5] <= 59)
      ) catch false
  '
  echo
  echo "=== done ==="
} | tee "$TRANSCRIPT"
