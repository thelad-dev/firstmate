# Grok composer-state classification: the gate that blocks fm-control relaunch/exit
# User-visible refusal when not empty:
#   error: task <id>'s composer state is 'unknown', not proven empty; refusing to type the /exit exit command
# Capture: grok 1.0.30 idle Herdr pane, 2026-10-02 (Grok 4.7 (high) · always-approve + status line exit 127)
# Backend capability profile: herdr (styled=1 cursor=0 identity=1)

## Screen under test (idle failure that blocked relaunch)
```
  ╭────────────────────────────────────────╮
  │ ❯                                      │
  ╰───── Grok 4.7 (high) · always-approve ─╯
  [status line: exit 127]
  Shift+Tab:mode  │  Ctrl+.:shortcuts
```

| case | expected after fix | BEFORE (base 8690c411) | AFTER (fix 45390310) |
| --- | --- | --- | --- |
| idle_status_exit_127 | empty | unknown | empty |
| idle_status_timed_out | empty | unknown | empty |
| idle_shortcuts_only | empty | unknown | empty |
| idle_aligned_middle_dot_title | empty | unknown | empty |
| typed_under_status_footer | pending | unknown | pending |
| activity_flush_under_box | unknown | unknown | unknown |
| script_status_stdout | unknown | unknown | unknown |

## Relaunch/exit implication
fm-control only types /exit when composer state is proven `empty`.
- BEFORE: idle status-line pane classified `unknown` → relaunch dies with 'not proven empty'
- AFTER:  idle status-line pane classified `empty` → exit command is allowed
- Safety retained: typed → `pending`; activity → `unknown`; script stdout → `unknown`

## Result: PASS
