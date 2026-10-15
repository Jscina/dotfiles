# Shell write scope

Treat the shell tool as read/execute only outside this machine's active project workspace.

Do not use shell -- touch, redirection (>, >>), tee, cp, mv, interpreter one-liners
(python3 -c, perl -e, node -e, etc.), or any other means -- to create or modify files
anywhere outside ~/Repos/** or a project's own build-tool caches (e.g. ~/.gradle/**,
excluding ~/.gradle/daemon/**).

Use the Edit or Write tool for intentional file changes, and keep shell-based file writes
confined to the current project's working tree.

This is a behavioral expectation, not a technical enforcement -- the permission system cannot
reliably catch every way to write a file from a shell command. Follow this even in cases the
permission system would not block.
