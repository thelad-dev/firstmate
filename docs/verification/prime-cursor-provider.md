# Verification: Prime Agent Cursor provider (external)

Active empirical record for the standalone Cursor provider extension used with installed Prime Agent.
This is **not** a Firstmate harness adapter record.

## Subject

| Field | Value |
|---|---|
| Repo | `git@github.com:thelad-dev/prime-agent-cursor-provider.git`, npm name `@thelad-dev/prime-agent-cursor-provider` (clone path is host-local; `$CURSOR_PROVIDER_DIR` below) |
| Prime Agent | `0.7.3` (globally installed `prime-agent`) |
| Cursor Agent CLI | `2026.08.11-e8db854`, invoked as `agent`; [`runtime-backends.md`](runtime-backends.md#cursor-agent-cli) owns the CLI's install tree, binary names, and process identity |
| Verified | 2026-08-18 |

## Firstmate harness status

`kunchenguid/firstmate#1966` (Prime harness) is closed and not merged in this checkout.
`AGENTS.md` and `bin/fm-harness.sh` do not list `prime`, so firstmate has no Prime harness adapter to verify.

## Verified facts

- Extension uses Prime's `pi.registerProvider` + `streamSimple` (types in `prime-agent@0.7.3` `dist/core/extensions/types.d.ts`, documented in that package's own `docs/custom-provider.md`).
- Package manifest uses the inherited `pi.extensions` key (`prime-agent@0.7.3`'s own `docs/packages.md`).
- CLI invocation uses flags present in `agent --help`: `--print`, `--output-format stream-json`, `--model`, `--trust`, `--workspace`.
- `CURSOR_API_KEY` reaches the CLI through the child environment only, never child argv (`agent --help` documents the env var as equivalent to `--api-key`).
- Unit tests: `npm test` → 19/19 pass from a clean clone, after `npm install` (`@earendil-works/pi-ai` is a dev dependency because `lib/stream.ts` imports it at runtime; consumers still get it from their Prime Agent install).
- Registration smoke: `npm run e2e:register` registers provider id `cursor`, api `cursor-agent-cli`, and slash commands `/cursor-login|status|logout`. With discovery forced to fail (`CURSOR_AGENT_PATH=/nonexistent/agent`) it falls back to the 18 static models; the live-discovery count is recorded in the section below.

## Verified against a Cursor-authenticated host (2026-08-18)

- `agent status` reports the CLI logged in, and `agent models` returns a 204-model inventory.
- Live NDJSON against a real Cursor subscription model: `prime-agent -e "$CURSOR_PROVIDER_DIR" --provider cursor --model composer-2.5 -p ...` streams and exits 0.
- Live discovery reaches Prime's model registry: `npm run e2e:register` registers 196 cursor models built from that inventory.

## Still UNVERIFIED

- `prime-agent model list` showing cursor rows. `-e` is only accepted on a run invocation, not before a subcommand, and the extension is not installed as a Prime package on this host, so the subcommand has no cursor provider to list. Live discovery itself is covered by the `e2e:register` row above.

## Commands that refresh this record

The clone lives outside this repo; point `CURSOR_PROVIDER_DIR` at wherever you checked it out.

```bash
CURSOR_PROVIDER_DIR="${CURSOR_PROVIDER_DIR:-$HOME/workspaces/prime-agent-cursor-provider}"
cd "$CURSOR_PROVIDER_DIR"
npm install
npm test
npm run e2e:register
npm run e2e:discovery
agent status
prime-agent -e "$CURSOR_PROVIDER_DIR" --provider cursor --model auto -p "ping"
```
