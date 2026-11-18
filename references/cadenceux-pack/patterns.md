# CadenceUX design patterns

Applied **section by section** over ADK's Baseline: each section below replaces the Baseline
section with the same heading. Baseline sections not named here (Blank layout, Creating a
table, Custom function commenting, Passing script parameters, Script triggers, Organizing
scripts) still apply.

## Script commenting headers

Every script opens with the same five lines, then its body, then an explicit `Exit Script`:

| Line | Content |
|------|---------|
| 1 | Allow User Abort [ Off ] |
| 2 | Set Error Capture [ On ] |
| 3 | *(blank)* |
| 4 | Comment: `PURPOSE: {one sentence on what the script does} Called by: {the script, button or trigger that runs it}` |
| 5 | *(blank)* |
| 6+ | *(the script body)* |
| last | Exit Script [ Text Result: *result* ] |

- `Allow User Abort [ Off ]` stops Escape leaving records uncommitted or a transaction open.
  Turn it on only where a long process offers the user a deliberate cancel, and say so in the
  PURPOSE line.
- `Set Error Capture [ On ]` means the script handles its own errors, so every step that can
  fail is followed by an error check (see "Error handling").
- When the script takes a parameter, add a comment line after line 4:
  `PARAMETERS: {the JSON keys it reads}`. When it returns something other than `""`, add
  `RETURNS: {the JSON keys it returns}`.

## Script layout

- A blank line separates logical sections of a script: header, navigation, variable setup,
  main body, exit. It never separates the steps inside one section.
- Steps that form one unit of work stay together with no blank lines: a block of
  `Set Variable` setup, the whole body of a `Loop`, a run of `Set Field` steps building one
  record.
- Every section after the header starts with a one-line comment saying what it does.

## Error handling

- Every step that can fail is followed immediately by an error check, before any other step:

```
If [ AnErrorOccurred ]
    Exit Script [ Text Result: JSONSetElement ( "{}" ;
        [ "status" ; "ERROR" ; JSONString ] ;
        [ "errorCode" ; $$LastError ; JSONNumber ] ;
        [ "message" ; "<what failed>" ; JSONString ] ) ]
End If
```

- Checks use the custom functions `AnErrorOccurred` and `NoErrorOccurred`. When the file has
  neither, create both before the script that needs them:

```
AnErrorOccurred = Let ( $$LastError = Get ( LastError ) ; $$LastError ≠ 0 )
NoErrorOccurred = Let ( $$LastError = Get ( LastError ) ; $$LastError = 0 )
```

- Extend the check inline when a step reports failure in its result rather than an error
  code: `AnErrorOccurred or IsEmpty ( $result ) or PatternCount ( $result ; "Exception" )`.
- `$$LastError` is valid only until the next step of the same script. Read it at once (copy it
  into a local variable to log it), never branch on it in another script, and never trust it
  across a trigger or a session.

## Script results

- A script with nothing to report ends with `Exit Script [ Text Result: "" ]`.
- Any other script returns a JSON object built with `JSONSetElement`:
  - `status`: `"SUCCESS"` or `"ERROR"`
  - `errorCode`: `0` on success, the error number otherwise
  - `message`: text for a person, when there is something to say
  - `data`: the payload, when there is one
- Callers decide success from `status` alone: `JSONGetElement ( Get ( ScriptResult ) ;
  "status" ) = "SUCCESS"`.
- Every early exit on error returns the same shape (see "Error handling").

## Halt Script

`Halt Script` appears only in a named utility script that a trigger or a button calls, never
in business logic. Business logic exits with `Exit Script` and lets the caller decide.

## Configuration globals

- Global fields that hold configuration (company name, default paths, feature switches) live in
  one table named `Settings`, with one record.
- Every other table reads them through a relationship or a script, never by holding its own
  copy.
- When a solution has no `Settings` table and a configuration global is needed, create the
  table first, per the Baseline's "Creating a table".
