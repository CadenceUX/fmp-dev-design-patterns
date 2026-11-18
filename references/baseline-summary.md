# The rules the pack builds on (for work without ADK)

The `cadenceux` pack states only where CadenceUX differs from ADK's built-in Baseline. With
ADK installed, ADK's `filemaker-standards` skill carries the Baseline itself and is the
authority. Without ADK, apply this summary first, then the pack's files over it. It is a
summary in this skill's words, checked against ADK 0.16.0 (November 2026).

## Contents
- Naming the pack doesn't change
- Shapes the pack doesn't change

## Naming the pack doesn't change

- **Tables:** singular, named for one record's entity (`Contact`, `Invoice`); a join table
  names both sides (`ContactEvent`); never leave `Table 2`.
- **Keys:** the primary key is `ID`, auto-entered (serial or UUID), meaningless to the business,
  never edited. A foreign key is `ID_` plus the target table (`ID_Contact`). Index every key.
- **Housekeeping fields on every table:** `recCreateAccountName`, `recCreateTimestamp`,
  `recModifyAccountName`, `recModifyTimestamp`, auto-entered, with modification prohibited.
- **Field types that behave differently** carry a suffix: `_calc`, `_unstored`, `_summary`
  (the pack replaces `_global` with `_g`).
- **File names:** every file in a solution shares a prefix; never hardcode a file name in a
  calculation (use `Get ( FileName )`); mark non-production copies in the name.
- **Layouts:** user-facing layouts are named for what the user does there ("Contact List");
  developer and utility layouts get a prefix and are hidden from the layout menu; each base
  table has a blank context layout.
- **Layout objects:** name only the objects something refers to, for what they're for
  (`contactList`, not `portal3`).
- **Scripts:** the pack sets the name format (`Domain: Action`), keeps parameters out of the
  name and names trigger wrappers with the `Trigger` domain. From the Baseline: never empty
  parentheses in a name, and scripts are grouped in folders.
- **Variables:** local `$lowerCamelCase`; global `$$UPPER_CASE` with a namespace for what owns
  it (`$$SEARCH_LAST_QUERY`); set a global in one place.
- **Custom functions:** named for what they return; `lowerCamelCase` parameters; a family
  shares a prefix (`Date_`, `List_`).
- **Value lists:** named for their source and any filter (`ContactNameByCompany`).
- **Deprecation:** mark, don't delete: a sorting prefix and the date
  (`DEPRECATED_2026-06-07_OldName`); delete only after a full business cycle unreferenced.
- **What FileMaker itself refuses or warns about** applies to every layer: names that start
  with a digit, contain operator characters or reserved words, or exceed 100 characters for a
  script.

## Shapes the pack doesn't change

- **Creating a table:** the table, its occurrence, `ID`, the four housekeeping fields and a
  blank layout, in one piece of work, plus anything the pack requires of every table.
- **Blank layout:** one per base table, no objects, hidden, for script context only.
- **Custom function comments:** the signature, one sentence on what it does, each parameter and
  what happens when it's empty, the result, and what it returns when it can't compute one.
- **Script parameters:** one JSON object, read into named local variables at the top, with
  what the script can't run without validated first.
- **Script triggers:** a trigger calls a wrapper script, never the shared script itself; the
  wrapper first checks a trigger-disable global and exits when it's set; its header names the
  trigger and where it's attached.
- **Organising scripts:** folders by function (one per entity, plus controller, utility,
  trigger wrappers and deprecated), and a never-run notes script at the top recording the
  parameter and result formats, the trigger-disable global and any plug-ins.
