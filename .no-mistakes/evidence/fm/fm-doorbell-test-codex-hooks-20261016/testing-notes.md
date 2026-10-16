# Doorbell codex launch parity — local test evidence

## Change under test
`tests/fm-send-inbox-doorbell-live-e2e.test.sh` `launch_cmd codex` now matches
`bin/fm-spawn.sh` crewmate path by adding `--disable hooks`.

## Observable behavior on this machine (codex-cli 0.163.0)

### Hook feature effect of the recipe (no model tokens)
- FIXED recipe `codex --dangerously-bypass-approvals-and-sandbox --disable hooks features list`
  → `hooks ... false`
- WITHOUT flag `codex --dangerously-bypass-approvals-and-sandbox features list`
  → `hooks ... true` (machine `~/.codex/config.toml` has `[features] hooks = true` and `hooks.json` present)

### fm-spawn parity (no model tokens)
`tests/fm-codex-hook-layer-live-e2e.test.sh` passed:
- installed codex still publishes the hooks feature
- captured firstmate crewmate launch flags leave hooks disabled

### Live doorbell attempt (codex only, timeout 45s)
`FM_SEND_INBOX_LIVE_E2E=1 FM_SEND_INBOX_LIVE_HARNESSES=codex FM_SEND_INBOX_LIVE_TIMEOUT=45 bash tests/fm-send-inbox-doorbell-live-e2e.test.sh`

Result: failed on **Sign in with ChatGPT** login screen (`codex login status` → Not logged in).
Pane capture showed login choices, **not** "Hooks need review".
So the fixed recipe no longer parks on the hook-trust modal; the remaining blocker on this host is missing Codex auth, which prevents the full acted+acked doorbell proof the intent requires.

## Not available here
- Codex is not logged in (`codex login status` → Not logged in)
- No OPENAI_API_KEY / CODEX_API_KEY in the environment
- Therefore the triple live doorbell success line
  `ok - codex (codex-cli 0.163.0): the doorbell reached a real worker, which acted and acked with the mv`
  cannot be reproduced on this gate host.

## Behavioral proof of the test's own launch_cmd (no login)
Extracted `launch_cmd` from `tests/fm-send-inbox-doorbell-live-e2e.test.sh` and ran:
`codex --dangerously-bypass-approvals-and-sandbox --disable hooks features list`
→ hooks=false on codex-cli 0.163.0.
Counterfactual without the flag trips the test's own pin message.
