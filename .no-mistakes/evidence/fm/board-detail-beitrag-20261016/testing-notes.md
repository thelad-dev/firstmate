# Board detail + linkify evidence

## Intent
Decision/credential cards must show `detail`; http(s) addresses in detail become visible links that wrap on narrow viewports.

## Automated
- `TZ=UTC bash tests/fm-bearings-board-render.test.sh` — all ok, including the four new call-detail assertions.

## Manual / product evidence
Built a live board via `bin/fm-bearings-board.sh build` with four Captain's Call items (decision+URL, merge+URL, credential plain text, decision URL-in-parentheses), rendered through `tests/assets/board-render-harness.mjs`, and screenshotted in Chromium.

### Harness call cards (observable render)
See `board-call-cards.json`.

### Screenshots
- `board-detail-linkify-desktop.png` — decision card shows detail with blue underlined report URL
- `board-detail-linkify-mobile.png` — same link wraps on ~390px width (overflow-wrap)
- Built page: `bearings-board-detail-linkify.html`
