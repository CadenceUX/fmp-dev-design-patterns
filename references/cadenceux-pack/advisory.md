# CadenceUX advisory guidelines

Cited **when reviewing** existing work, as suggestions. Never applied when generating.

## Global variables

- Passing data or error state between scripts in `$$` variables: a value set in one script and
  read in another survives early exits, reruns and, on hosted files, whole sessions, so the
  reader can't tell whether it's current. Prefer a script parameter in and a script result out.
  Where a `$$` flag is genuinely needed (a halt flag, UI state), pair every setter with a
  clearer, initialise it in the startup script, and validate it before branching on it.
- Hidden `$$` setters: `Let()` inside custom functions, field calculations that assign a `$$`
  as a side effect, and steps that target a `$$` (Insert from URL, for example). They make
  session state untraceable. Also look for casing twins (`$$Result` and `$$result`) and for
  globals that are read but never set.

## Comments

- Scripts with only blank comment steps: spacing is fine, but a script needs a real PURPOSE
  line and section comments.
- New or changed fields without a field comment.

## Dead code

- Disabled steps left in a script: delete them, or keep the old logic in a copy named with
  ` [OLD]` before changing the script.
- Custom functions that nothing calls, or that duplicate one already in the file's library.

## Script organisation

- A solution that groups scripts with divider scripts (`--`) instead of folders: keep using
  dividers in that solution rather than introducing folders piecemeal, and suggest a full move
  to folders as a separate piece of work.
