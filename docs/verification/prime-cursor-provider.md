# Verification: Prime Agent Cursor provider (external)

Active empirical record for the standalone Cursor provider extension used with installed Prime Agent.
This is **not** a Firstmate harness adapter record.

## Subject

| Field | Value |
|---|---|
| Package | `/home/ladwein/workspaces/prime-agent-cursor-provider` → `thelad-dev/prime-agent-cursor-provider` |
| Prime Agent | `0.7.3` (`/home/ladwein/.local/lib/node_modules/prime-agent`) |
| Cursor Agent CLI | `2026.08.11-e8db854` (`agent`) |
| Verified | 2026-08-18 |

## Firstmate harness status

`kunchenguid/firstmate#1966` (Prime harness) is closed and not merged in this checkout.
`AGENTS.md` and `bin/fm-harness.sh` do not list `prime`.
No Firstmate Prime harness was invented for this task.

## Verified facts

- Extension uses Prime's `pi.registerProvider` + `streamSimple` (types in `prime-agent@0.7.3` `dist/core/extensions/types.d.ts`, docs in `docs/custom-provider.md`).
- Package manifest uses the inherited `pi.extensions` key (`docs/packages.md`).
- CLI invocation uses flags present in `agent --help`: `--print`, `--output-format stream-json`, `--model`, `--trust`, `--workspace`, `--api-key`.
- Unit tests: `npm test` → 17/17 pass.
- Registration smoke: `npm run e2e:register` registers provider id `cursor`, api `cursor-agent-cli`, slash commands `/cursor-login|status|logout`, and 18 fallback models when discovery fails.

## UNVERIFIED on the 2026-08-18 host

- Authenticated `agent models` inventory (CLI reported not logged in).
- Live NDJSON generation against a Cursor subscription.
- Interactive `prime-agent model list` while Cursor-authenticated.

## Commands that refresh this record

```bash
cd /home/ladwein/workspaces/prime-agent-cursor-provider
npm test
npm run e2e:register
npm run e2e:discovery
agent status
prime-agent -e /home/ladwein/workspaces/prime-agent-cursor-provider --provider cursor --model auto -p "ping"
```
