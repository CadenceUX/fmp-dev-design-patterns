---
compatibility: Claude.ai, Claude Chat, Claude Code
metadata:
  "Built and maintained": "Darrin Southern from CadenceUX"
  version: "1.1"
name: fmp-dev-gate
description: |
  FileMaker scripting rules and project configuration skill — all scripting patterns, boilerplate,
  error handling, variable scope, loops, sub-scripts, JSON parameter passing, fmxmlsnippet
  authoring gotchas, and code delivery methods. Defines which functions from claris-filemaker-pro,
  goya-be-plugin, and monkeybread-mbs-plugin are configured for use in this project. Use for:
  writing and debugging FileMaker scripts, designing script architecture, error handling
  strategies, AI integration via Generate Response from Model, and modular script workflows.
  Does not cover script step syntax or function reference — delegates to claris-filemaker-pro.
  Trigger when the user asks to write a FileMaker script, design a scripting workflow, debug
  script logic, or automate a FileMaker task — even casually phrased. Always trigger when
  "FileMaker", "Claris", "Script Workspace", or "scripting" appears in a development context.
---

# FMP Dev Gate — Scripting Rules & Configuration (v1.1)

You are an expert Claris FileMaker Pro developer. Your job is to help users write, debug, and
design FileMaker scripts using correct patterns, boilerplate, and architecture — using the
rules and configured functions defined in this skill.

## Reference skills

Script step syntax and calculation function reference are handled exclusively by the
**`claris-filemaker-pro`** skill. Plugin function lookups go to **`goya-be-plugin`** (BE_*)
or **`monkeybread-mbs-plugin`** (MBS). For routing across the full skill set, see
**`fmp-dev-orchestrator`**.

---

## Script Boilerplate

At the start of each session, before writing any scripts, ask the developer how they want
the two opening steps handled:

> How should I handle **Allow User Abort [ Off ]** and **Set Error Capture [ On ]** when
> writing scripts in this session?
>
> 1. **Always add them** — include both steps at the top of every new script without asking
> 2. **Ask me each time** — confirm before adding them each time a new script is created
> 3. **Custom** — describe how you'd like them handled

Apply the developer's choice for the remainder of the session.

The standard opening structure is:

```
Allow User Abort [ Off ]
Set Error Capture [ On ]

# ... script body ...

Exit Script [ Text Result: "" ]
```

- The blank line after the two opening steps is a visual separator marking where script logic begins.
- `Exit Script` is covered in detail below — always close with an explicit exit.

---

## Allow User Abort and Set Error Capture

These are the required first two steps of every script.

**Allow User Abort [ Off ]**
Prevents the user from interrupting the script mid-run (e.g. pressing Escape or ⌘. on Mac).
Without this, FileMaker's default behaviour allows a user to halt a script at any point — which
can leave records uncommitted, transactions open, or data in an inconsistent state. Set to `On`
only when you deliberately want the user to have a controlled exit path, such as a long-running
import with a progress dialog that offers an explicit cancel option.

**Set Error Capture [ On ]**
Suppresses FileMaker's built-in error dialogs. Without it, any step that encounters an error
shows a system alert and stops — the script has no opportunity to handle the error in code. With
it on, errors are silent; use `Get(LastError)` immediately after any step that can fail to
detect and respond. `Get(LastError)` resets on every subsequent step, so it must be read before
anything else runs.

For full syntax, parameters, and platform compatibility of both steps, use `claris-filemaker-pro`.

---

## Exit Script

Every script should close with an explicit `Exit Script [ Text Result: ... ]` step — not by
falling off the end. When a script ends without an explicit exit, FileMaker returns an empty
result and gives no indication whether it completed normally or stopped early. An explicit
`Exit Script` makes the termination point clear and allows a result value to be passed back
to any calling script.

**Reading the result in a calling script:**
```
Perform Script [ "MyScript" ; Parameter: $params ]
Set Variable [ $result ; Value: Get(ScriptResult) ]
```

`Get(ScriptResult)` reads whatever string was passed in the last `Exit Script [ Text Result: ]`
of the called script. It returns empty if no result was set or if the script ended without an
explicit exit.

**Common result patterns:**

| Use case | Text Result value |
|---|---|
| Script has no meaningful result | `""` (empty string) |
| Simple success/failure | `"SUCCESS"` or `"ERROR"` |
| Error with code | `"ERROR:" & Get(LastError)` |
| Structured result | A JSON object built with `JSONSetElement` |

**Using JSON for structured results:**
```
Exit Script [ Text Result:
    JSONSetElement ( "{}" ;
        ["status" ; "SUCCESS" ; JSONString] ;
        ["recordId" ; Get(RecordID) ; JSONNumber]
    )
]
```
The caller reads individual fields with `JSONGetElement ( Get(ScriptResult) ; "status" )`.

**Early exit on error:**
`Exit Script` can appear anywhere in a script — not just at the end. The standard error pattern
exits early with an error result so the caller knows the script did not complete:
```
If [ Get(LastError) ≠ 0 ]
    Exit Script [ Text Result: "ERROR:" & Get(LastError) ]
End If
```

For full syntax and platform compatibility of `Exit Script`, use `claris-filemaker-pro`.

---

### Blank lines mark section boundaries, not every step

A blank line separates **logical sections** of a script — it is not inserted between every
individual step. Steps that form one tightly-related unit of work (a block of `Set Variable`
setup lines, the full body of a `Loop`, a run of `Set Field` calls building one record) stay
together with no blank lines between them. Add a blank line only at the boundary where one
section ends and the next begins (header → purpose comment → navigation → variable setup →
main loop/body → exit).

```
Allow User Abort [ Off ]
Set Error Capture [ On ]

# PURPOSE: Create 20 sample Products records for testing.

Go to Layout [ "Product Details" (Products) ; Animation: None ]

Set Variable [ $categories ; Value: List ( "Engine" ; "Brakes" ; "Suspension" ; "Electrical" ; "Body" ) ]
Set Variable [ $manufacturers ; Value: List ( "Bosch" ; "Denso" ; "ACDelco" ; "Moog" ; "Gates" ) ]
Set Variable [ $i ; Value: 1 ]

Loop [ Flush: Always ]
    Exit Loop If [ $i > 20 ]
    New Record/Request
    Set Field [ Products::Name ; "Sample Part " & $i ]
    Set Field [ Products::Category ; GetValue ( $categories ; Mod ( $i - 1 ; 5 ) + 1 ) ]
    Commit Records/Requests [ With dialog: Off ]
    Set Variable [ $i ; Value: $i + 1 ]
End Loop

Exit Script [ Text Result: "" ]
```

---

## Key Scripting Patterns

### Error Handling (Standard Pattern)
```
Allow User Abort [ Off ]
Set Error Capture [ On ]

<your script step here>
If [ Get(LastError) ≠ 0 ]
    Set Variable [ $error ; Value: Get(LastError) ]
    Show Custom Dialog [ "Error: " & $error ]
    Exit Script [ Text Result: "ERROR:" & $error ]
End If

Exit Script [ Text Result: "" ]
```

- Use `Get(LastError)` immediately after the step — it resets on the next step.
- Use `Set Error Logging [On]` during development to log errors to the console.

### Variable Scope
- `$localVar` — local to the script, cleared when the script ends.
- `$$globalVar` — persists across scripts and sessions until cleared or FileMaker quits.
- Use `Set Variable` to assign; pass `$$` vars carefully to avoid side-effects.

### Looping Over Records
```
Allow User Abort [ Off ]
Set Error Capture [ On ]

Go to Record/Request/Page [ First ]
Loop
    # Do work on current record
    Commit Records/Requests [ No dialog ]
    Go to Record/Request/Page [ Next ; Exit after last ]
End Loop

Exit Script [ Text Result: "" ]
```

### Sub-Scripts (Modular Design)
```
Allow User Abort [ Off ]
Set Error Capture [ On ]

Perform Script [ "MySubScript" ; Parameter: $param ]
Set Variable [ $result ; Value: Get(ScriptResult) ]

Exit Script [ Text Result: $result ]
```
- Use `Exit Script [Text Result: ...]` in sub-scripts to return values.
- Pass complex data as JSON using `JSONSetElement` / `JSONGetElement`.

### JSON Parameter Passing
```
# Caller script
Allow User Abort [ Off ]
Set Error Capture [ On ]

Set Variable [ $params ; Value:
    JSONSetElement ( "{}" ;
        ["id" ; $id ; JSONNumber] ;
        ["mode" ; "create" ; JSONString]
    )
]
Perform Script [ "ProcessRecord" ; Parameter: $params ]

Exit Script [ Text Result: "" ]

# ───────────────────────────────────────────────
# Sub-script: ProcessRecord
Allow User Abort [ Off ]
Set Error Capture [ On ]

Set Variable [ $id   ; Value: JSONGetElement ( Get(ScriptParameter) ; "id" ) ]
Set Variable [ $mode ; Value: JSONGetElement ( Get(ScriptParameter) ; "mode" ) ]

Exit Script [ Text Result: "" ]
```

### Perform Find (Scripted)
```
Allow User Abort [ Off ]
Set Error Capture [ On ]

Enter Find Mode [ Pause: Off ]
Set Field [ Table::SearchField ; $searchValue ]
Perform Find [ ]
If [ Get(LastError) = 401 ]  # No records found
    Show All Records
    Show Custom Dialog [ "No matching records found." ]
End If

Exit Script [ Text Result: "" ]
```

### Transactions (Multi-record atomic operations)
```
Allow User Abort [ Off ]
Set Error Capture [ On ]

Open Transaction
# ... multiple record modifications ...
If [ $success ]
    Commit Transaction
Else
    Revert Transaction
End If

Exit Script [ Text Result: "" ]
```

### AI / ML Integration Pattern
```
Allow User Abort [ Off ]
Set Error Capture [ On ]

Configure AI Account [ Account Name: "myOpenAI" ; Model: "gpt-4o" ]
Configure Prompt Template [ Template Name: "summarise" ;
    Template: "Summarise the following: {{input}}" ]
Generate Response from Model [
    Account Name: "myOpenAI" ;
    Prompt Template: "summarise" ;
    Input: Table::TextField ;
    Target: Table::SummaryField
]

Exit Script [ Text Result: "" ]
```

For step-specific syntax (Configure AI Account options, model names, parameter fields) —
hand off to **`claris-filemaker-pro`**.

---

## Compatibility Notes

Each script step has a compatibility matrix across FileMaker Pro (macOS/Windows), FileMaker Go
(iOS/iPadOS), WebDirect, FileMaker Server (server-side scripts), and the Data API. Steps that are
not supported on a platform are silently skipped and return error 3. Use `Get(ApplicationVersion)`
or `Get(Device)` to branch for platform-specific behaviour.

For the full compatibility matrix for any specific step, fetch live docs via `claris-filemaker-pro`.

---

## fmxmlsnippet Authoring Gotchas

### `Set Variable` requires a `<Value>` wrapper around `<Calculation>`
A `Set Variable` step's calculation must be nested as `<Value><Calculation>...</Calculation></Value>`.
A bare `<Calculation>` placed directly under the `<Step>` element is **structurally valid XML**
but produces a `Set Variable` with an empty value — XML validators will not catch this. If a
pasted `Set Variable` step shows no value, this is the first thing to check.

### `Move/Resize Window` — `Window` is an enum, not a literal window name
The `Window` element's `value` attribute must be `"ByName"` or `"Current"` — not a literal string.
To target a specific window, use `value="ByName"` plus a `<Name>` element containing the
calculation (e.g. `Get ( FileName )`).

### When invoked externally, target windows `By Name`, not `Current`
A script triggered from outside FileMaker's normal UI focus (e.g. via a plugin's HTTP bridge or
MCP connection while Script Workspace is frontmost) has no "current window" context. A
`Window value="Current"` target fails with **error 112 ("Window is missing")**. Fix: use
`Window value="ByName"` with `<Name><Calculation>Get ( FileName )</Calculation></Name>`.

### HR-to-XML converters can scramble field order for multi-clause steps
For steps with several positional clauses (e.g. `Move/Resize Window`'s Top/Left/Height/Width),
converters have been observed to shift a later clause's value into an earlier field. Always
round-trip back through an XML-to-HR converter and confirm the rendered HR matches intent.

### Validate, but don't stop at validation
XML validation only checks well-formedness — it does not catch semantically-wrong-but-structurally-
valid mistakes. After validating, round-trip through an XML-to-HR converter and read the rendered
HR back to confirm it says what you meant.

---

## Delivering Code to FileMaker — Two Methods

### Method 1 — MBS Plugin (within FileMaker scripting)

**When to use:** MBS Plugin is installed — drive the clipboard from inside a FileMaker script.

**Key MBS functions:**
```
MBS( "ScriptWorkspace.OpenScript" ; scriptID ; fileRef )
MBS( "Clipboard.SetFileMakerData" ; "com.filemaker.script" ; xmlText )
MBS( "Clipboard.GetFileMakerData" ; "com.filemaker.script" )
```

**Workflow:** Claude generates the XML → developer stores it in a field/variable → utility script
calls `MBS("Clipboard.SetFileMakerData"; ...)` → navigate to Script Workspace → Cmd+V.

The pasteboard UTI `com.filemaker.script` covers scripts and script step snippets. Custom
functions and layout objects use different UTI types — consult `monkeybread-mbs-plugin` for the
correct type string. Full MBS API reference: `https://www.mbsplugins.eu/component_Clipboard.shtml`

### Method 2 — Manual paste (no plugin required)

**When to use:** No MBS Plugin installed — zero dependencies, works everywhere.

Claude presents the `fmxmlsnippet` XML and the matching HR step list. Developer manually rebuilds
the steps in Script Workspace using the HR list as the reference. A plain text paste of raw XML
into Script Workspace will **not** be interpreted as steps — the MBS Plugin is the only supported
way to push the FileMaker pasteboard UTI from outside FileMaker.

| Situation | Best method |
|---|---|
| Working inside FileMaker with MBS installed | **MBS Plugin** |
| Need to open a specific script by ID | **MBS** (`ScriptWorkspace.OpenScript`) |
| No plugin installed, one-off edit | **Manual paste** |

---

## Configured Functions

This section defines which functions from the reference skills are in scope for this project.
Features to be built out in subsequent releases — no restrictions are currently configured.
All function lookups fall through to the reference skills via standard routing.

---

## Version History

See [`CHANGELOG.md`](./CHANGELOG.md) for the full version history.

---

## Licence

This skill is released under [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/).
