Evidence for: test(pi) custom before_agent_start without prompt

User intent: publish the regression that a sendCustomMessage-started run
(custom message, no prompt) must neither throw nor mirror as captain dialog.
Fix already landed in 8c9c67de; this change only adds the named test coverage.

1) pass-with-fix.txt
   Ran tests/fm-pi-branch-extension.test.sh :: test_branch_mirror_filters_order_and_cursor
   including the new before_agent_start custom/no-prompt case. Result: ok.

2) counterproof-without-narrowing.txt
   Same executable path with the custom early-return removed from a fixture
   copy of fm-branch-supervision.ts only. Result:
   COUNTERPROOF_ERROR=Cannot read properties of undefined (reading 'trim')
   Matches the intent's stated Gegenprobe.

3) regression-e2e-transcript.txt
   Combined transcript of fix site, new test block, pass, and counterproof.
