# Scripting patterns

Worked patterns for common FileMaker scripting tasks. Every script follows the session's
boilerplate choice from SKILL.md (Allow User Abort / Set Error Capture) and closes with an
explicit `Exit Script`. For step and function syntax, use `claris-filemaker-pro`.

## Contents
- Error handling (standard pattern)
- Variable scope
- Looping over records
- Sub-scripts
- JSON parameter passing
- Perform Find (scripted)
- Transactions
- AI / ML integration
- Custom functions


## Error Handling (Standard Pattern)
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
- Use `Set Error Logging [ On ]` during development — it logs script errors (timestamp, script
  name, step, error code) to `ScriptErrors.log` in the user's Documents folder, not to a console.
  Logging stays on for all scripts in the file until turned off or the file closes.

## Variable Scope
- `$localVar` — local to the script, cleared when the script ends.
- `$$globalVar` — shared across all scripts in the file for the current session; cleared when
  the file closes (it does **not** survive closing and reopening the file).
- Use `Set Variable` to assign; pass `$$` vars carefully to avoid side-effects — and don't
  use them to pass data or error state between scripts (see the `$$` anti-pattern in SKILL.md): parameters in, script result out.

## Looping Over Records
```
Allow User Abort [ Off ]
Set Error Capture [ On ]

Go to Record/Request/Page [ First ]
Loop
    # Do work on current record
    Commit Records/Requests [ With dialog: Off ]
    Go to Record/Request/Page [ Next ; Exit after last ]
End Loop

Exit Script [ Text Result: "" ]
```

## Sub-Scripts (Modular Design)
```
Allow User Abort [ Off ]
Set Error Capture [ On ]

Perform Script [ "MySubScript" ; Parameter: $param ]
Set Variable [ $result ; Value: Get(ScriptResult) ]

Exit Script [ Text Result: $result ]
```
- Use `Exit Script [Text Result: ...]` in sub-scripts to return values.
- Pass complex data as JSON using `JSONSetElement` / `JSONGetElement`.

## JSON Parameter Passing
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

## Perform Find (Scripted)
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

## Transactions (Multi-record atomic operations)
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

## AI / ML Integration Pattern
```
Allow User Abort [ Off ]
Set Error Capture [ On ]

Configure AI Account [ Account Name: "myOpenAI" ; Model Provider: OpenAI ; API key: $apiKey ]
Generate Response from Model [
    Account Name: "myOpenAI" ;
    Model: "gpt-4o" ;
    User Prompt: "Summarise the following: " & Table::TextField ;
    Agentic mode: Off ;
    Response: Table::SummaryField
]

Exit Script [ Text Result: "" ]
```

- `Configure AI Account` has **no Model parameter** — it takes Account Name, Model Provider,
  API key, and (for custom providers) Endpoint. The model is chosen on
  `Generate Response from Model` itself.
- `Generate Response from Model` takes User Prompt / Instructions / Response / Messages /
  Agentic mode — there is no Prompt Template, Input, or Target option on this step.
- `Configure Prompt Template` is a separate step for **named templates used by the
  natural-language and RAG steps** (template types: SQL Query, Find Request, RAG Prompt, with
  constants like `:question:` and `:schema:`) — it does not feed `Generate Response from Model`.

For step-specific syntax (Configure AI Account options, model names, parameter fields) —
hand off to **`claris-filemaker-pro`**.

## Custom Functions

Custom functions are pure calculation formulas (Manage Custom Functions) — no side effects,
callable from any calculation context. Reach for a script instead when the task needs to modify
data, navigate, or run multi-step logic.

**Rules:**
- Names must be unique file-wide and ≤100 characters. You can't create a custom function whose
  name matches an existing built-in, and if Claris later ships a built-in with the same name as
  an existing custom function, behaviour in that file is not reliably documented — avoid names
  that could plausibly collide with future built-ins (the community `_cf` suffix convention
  below sidesteps this entirely).
- Editing requires Full Access or the "Manage database, data sources, containers, and custom
  functions" privilege. A function can be marked private so non-Full-Access users see
  `<Private Function>` instead of the formula.
- Recursive custom functions and `While()` share a default 50,000-iteration limit (FileMaker 18+).
  Use `SetRecursion ( expression ; maxIterations )` to raise or lower it. Tail recursion (result
  carried forward, no pending work after the recursive call) is safe up to that limit; standard
  recursion can also exhaust the stack and return `?` before hitting it.
- Give every recursive function an explicit exit case — a `Case`/`If` branch that stops the
  recursive call once a counter, list, or other stop condition is reached.

Before writing a common utility from scratch, check **Brian Dunning's FileMaker Custom Functions
library** ([briandunning.com/filemaker-custom-functions](https://www.briandunning.com/filemaker-custom-functions/))
— a free, 2,600+ function community repository with ratings, worked examples, and per-function
platform-limitation notes. Many entries there use an `_cf` suffix (e.g. `AddWorkingDays_cf`) to
visually flag custom vs. built-in functions in a formula.

**Common examples:**
```
AnErrorOccurred
Let ( $$LastError = Get ( LastError ) ; $$LastError ≠ 0 )

NoErrorOccurred
Let ( $$LastError = Get ( LastError ) ; $$LastError = 0 )
```
- Drop these into the standard error pattern instead of repeating `Get(LastError) ≠ 0` inline —
  same check, shorter calls. Note the side effect: they assign `$$LastError`. Treat that value
  as valid only until the next step of the same script — capture it into a local immediately
  if it's needed for logging, and never read it from another script (see the `$$` anti-pattern
  in SKILL.md).

```
optionKey
Get ( ActiveModifierKeys ) = 8
```
- `Get(ActiveModifierKeys)` returns a bitmask sum; `8` is Option (Mac) / Alt (Windows). Test in
  a script `If` or button conditional formatting for modifier-key-driven behaviour.

```
PortalNext
GetNthRecord ( Field ; Get(ActivePortalRowNumber) + 1 )

PortalPrev
GetNthRecord ( Field ; Get(ActivePortalRowNumber) - 1 )
```
- Reads an adjacent portal row's field value without a script or re-sort. Guard the row-number
  argument if the active row can be first/last in the portal.

For calculation function syntax used above (`Get`, `Let`, `Case`, `GetNthRecord`, `SetRecursion`,
`While`), use **`claris-filemaker-pro`**. To create or edit a custom function in the file, use
ADT (see "Delivering scripts to the file" in SKILL.md).

