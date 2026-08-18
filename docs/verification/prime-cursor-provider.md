# Verification: Prime Agent Cursor provider (external)

Active empirical record for the standalone Cursor provider extension used with installed Prime Agent.
This is **not** a Firstmate harness adapter record.

## Subject

| Field | Value |
|---|---|
| Package | `thelad-dev/prime-agent-cursor-provider` (clone path is host-local; `$CURSOR_PROVIDER_DIR` below) |
| Prime Agent | `0.7.3` (globally installed `prime-agent`) |
| Cursor Agent CLI | `2026.08.11-e8db854` (`agent`) |
| Verified | 2026-08-18 |

## Firstmate harness status

`kunchenguid/firstmate#1966` (Prime harness) is closed and not merged in this checkout.
`AGENTS.md` and `bin/fm-harness.sh` do not list `prime`.
No Firstmate Prime harness was invented for this task.

## Verified facts

- Extension uses Prime's `pi.registerProvider` + `streamSimple` (types in `prime-agent@0.7.3` `dist/core/extensions/types.d.ts`, documented in that package's own `docs/custom-provider.md`).
- Package manifest uses the inherited `pi.extensions` key (`prime-agent@0.7.3`'s own `docs/packages.md`).
- CLI invocation uses flags present in `agent --help`: `--print`, `--output-format stream-json`, `--model`, `--trust`, `--workspace`.
- `CURSOR_API_KEY` reaches the CLI through the child environment only, never child argv (`agent --help` documents the env var as equivalent to `--api-key`).
- Unit tests: `npm test` → 18/18 pass.
- Registration smoke: `npm run e2e:register` registers provider id `cursor`, api `cursor-agent-cli`, slash commands `/cursor-login|status|logout`, and 18 fallback models when discovery fails.

## UNVERIFIED on the 2026-08-18 host

- Authenticated `agent models` inventory (CLI reported not logged in).
- Live NDJSON generation against a Cursor subscription.
- Interactive `prime-agent model list` while Cursor-authenticated.

## Commands that refresh this record

The clone lives outside this repo; point `CURSOR_PROVIDER_DIR` at wherever you checked it out.

```bash
CURSOR_PROVIDER_DIR="${CURSOR_PROVIDER_DIR:-$HOME/workspaces/prime-agent-cursor-provider}"
cd "$CURSOR_PROVIDER_DIR"
npm test
npm run e2e:register
npm run e2e:discovery
agent status
prime-agent -e "$CURSOR_PROVIDER_DIR" --provider cursor --model auto -p "ping"
```
