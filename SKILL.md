---
compatibility: Claude.ai, Claude Chat, Claude Code
metadata:
  "Built and maintained": "Darrin Southern from CadenceUX"
  version: "1.2"
name: fmp-dev-gate
description: |
  FileMaker scripting rules and project configuration skill — all scripting patterns, boilerplate,
  error handling, variable scope, loops, sub-scripts, JSON parameter passing, custom function
  authoring (recursion, naming, exit conditions), fmxmlsnippet authoring gotchas, and code
  delivery methods. Defines which functions from claris-filemaker-pro,
  goya-be-plugin, and monkeybread-mbs-plugin are configured for use in this project. Use for:
  writing and debugging FileMaker scripts, designing script architecture, error handling
  strategies, AI integration via Generate Response from Model, and modular script workflows.
  Does not cover script step syntax or function reference — delegates to claris-filemaker-pro.
  Trigger when the user asks to write a FileMaker script, design a scripting workflow, debug
  script logic, or automate a FileMaker task — even casually phrased. Always trigger when
  "FileMaker", "Claris", "Script Workspace", or "scripting" appears in a development context.
---

# FMP Dev Gate — Scripting Rules & Configuration (v1.2)

You are an expert Claris FileMaker Pro developer. Your job is to help users write, debug, and
design FileMaker scripts using correct patterns, boilerplate, and architecture — using the
rules and configured functions defined in this skill.

## Reference skills

Script step syntax and calculation function reference are handled exclusively by the
**`claris-filemaker-pro`** skill. Plugin function lookups go to **`goya-be-plugin`** (BE_*)
or **`monkeybread-mbs-plugin`** (MBS). When the deliverable is actual paste-ready XML rather
than script step text or authoring guidance, hand off to the dedicated XML skill for the
object type: **`filemaker-xml`** (scripts and custom functions, `fmxmlsnippet type="FMObjectList"`),
**`filemaker-field-xml`** (field definitions for Manage Database), or **`filemaker-layout-xml`**
(layout objects, `fmxmlsnippet type="LayoutObjectList"`). For routing across the full skill set,
see **`fmp-dev-orchestrator`**.

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

These are the standard first two steps of every script — applied per the developer's
session preference captured above.

**Allow User Abort [ Off ]**
Prevents the user from interrupting the script mid-run (e.g. pressing Escape or ⌘. on Mac).
Without this, FileMaker's default behaviour allows a user to halt a script at any point — which
can leave records uncommitted, transactions open, or data in an inconsistent state. Set to `On`
only when you deliberately want the user to have a controlled exit path, such as a long-running
import with a progress dialog that offers an explicit cancel option.

**Set Error Capture [ On ]**
Suppresses FileMaker's built-in error dialogs. Without it, a step that encounters an error
shows FileMaker's own alert (often offering Continue/Cancel) and the user — not the script —
decides what happens next; the script has no opportunity to handle the error in code. With
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
- Use `Set Error Logging [ On ]` during development — it logs script errors (timestamp, script
  name, step, error code) to `ScriptErrors.log` in the user's Documents folder, not to a console.
  Logging stays on for all scripts in the file until turned off or the file closes.

### Variable Scope
- `$localVar` — local to the script, cleared when the script ends.
- `$$globalVar` — shared across all scripts in the file for the current session; cleared when
  the file closes (it does **not** survive closing and reopening the file).
- Use `Set Variable` to assign; pass `$$` vars carefully to avoid side-effects.

### Looping Over Records
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

### Custom Functions

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
  same check, shorter calls, and `$$LastError` stays set for logging afterward.

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
`While`) — hand off to **`claris-filemaker-pro`**. For paste-ready
`fmxmlsnippet type="FMObjectList"` custom function XML — hand off to **`filemaker-xml`**.

---

## Compatibility Notes

Each script step has a compatibility matrix across FileMaker Pro (macOS/Windows), FileMaker Go
(iOS/iPadOS), WebDirect, FileMaker Server (server-side scripts), and the Data API. Steps that are
not supported on a platform are silently skipped and return error 3. Use `Get(ApplicationVersion)`
or `Get(Device)` to branch for platform-specific behaviour.

For the full compatibility matrix for any specific step, fetch live docs via `claris-filemaker-pro`.

---

## fmxmlsnippet Authoring Gotchas

The gotchas below are the quick, project-level version — high-frequency mistakes worth knowing
without a skill hop. For the full, empirically-verified spec (progressive-loading reference
files, every step/field/layout-object edge case, and the complete silent-failure catalogue),
delegate the actual XML generation to the dedicated skill for the object type: **`filemaker-xml`**
for scripts and custom functions, **`filemaker-field-xml`** for field definitions, or
**`filemaker-layout-xml`** for layout objects. Do not hand-author XML for any of these from this
section alone — it is a summary, not the authoritative source.

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

## Delivering Code to FileMaker — Five Methods

All methods below assume the XML already exists. Generate it with the object-appropriate skill
first — **`filemaker-xml`** for scripts/custom functions, **`filemaker-field-xml`** for field
definitions, **`filemaker-layout-xml`** for layout objects — then use one of these methods to
get it onto the FileMaker pasteboard, in this priority order. More delivery methods exist beyond
these five and are expected to be added here as they're confirmed — this list is not final.

### Method 1 — MBS Plugin (confirmed: no field, no variable, no FileMaker-side script call needed)

**When to use:** MBS Plugin is installed in the target FileMaker Pro instance.

**Confirmed by direct testing (2026-07-03):** Claude (or any external process — this session used
`pbcopy`) writes the XML straight onto the OS clipboard. **No FileMaker field or variable stores
the XML, and no FileMaker script calls an MBS clipboard function.** MBS Plugin merely needs to be
installed for Script Workspace's paste handler to recognize the clipboard content as real steps
on Cmd+V — the plugin's presence is what matters, not an explicit `Clipboard.SetFileMakerData`
call from inside a script. That function still exists and is documented below for the case where
the XML needs to be generated or moved *from inside* a running FileMaker script rather than
delivered externally, but it is not required for the external-delivery path.

**Workflow (external delivery, confirmed):** Claude generates the XML → writes it directly to
the OS clipboard → developer switches to FileMaker, opens Script Workspace, positions the cursor
→ Cmd+V.

**Known caveat, confirmed the same day:** a paste delivered this way can still fail to *save* in
Script Workspace with an "invalid script step" error — that failure is a defect in the specific
step's XML structure (see `fmp-dev-full-script`'s known-issues.md for the bisection approach),
**not** a problem with this clipboard-delivery mechanism. The mechanism itself is confirmed
working; don't misdiagnose a save failure as a delivery-method problem.

**Key MBS functions** (for the inside-FileMaker-script case):
```
MBS( "ScriptWorkspace.OpenScript" ; scriptID ; fileRef )
MBS( "Clipboard.SetFileMakerData" ; "com.filemaker.script" ; xmlText )
MBS( "Clipboard.GetFileMakerData" ; "com.filemaker.script" )
```

The pasteboard UTI `com.filemaker.script` covers scripts and script step snippets. Custom
functions and layout objects use different UTI types — consult `monkeybread-mbs-plugin` for the
correct type string. Full MBS API reference: `https://www.mbsplugins.eu/component_Clipboard.shtml`

### Method 2 — BE (BaseElements) Plugin (parity with Method 1 NOT yet confirmed)

**When to use:** BaseElements Plugin installed instead of MBS — free/open-source alternative.

**Unconfirmed — do not assume this mirrors Method 1.** Whether BE also supports the
external-delivery path (Claude/`pbcopy` writes straight to the OS clipboard, BE merely installed,
no script call) has not been tested as of 2026-07-03. `goya-be-plugin`'s own catalog only
documents the explicit function-call mechanism below as its verified pattern — it does not
describe a "plugin merely present" mode the way MBS has now been confirmed to have. Test the
external-delivery path with BE before relying on it; until then, use the documented function-call
workflow.

**Key BE functions:**
```
BE_ClipboardSetText ( text ; format )     — push XML onto the clipboard
BE_ClipboardGetText ( format )            — read XML back off the clipboard
BE_ClipboardFormats                       — list formats currently on the clipboard (discovery)
```

**Workflow (documented/verified pattern):** Claude generates the XML → developer stores it in a
field/variable → utility script calls
`BE_ClipboardSetText ( $xml ; "dyn.ah62d4rv4gk8zuxnxnq" )` → navigate to Script Workspace →
Cmd+V. The format string `"dyn.ah62d4rv4gk8zuxnxnq"` is FileMaker's script-step pasteboard UTI on
macOS, confirmed directly in `goya-be-plugin`'s own catalog example.

Two further gaps, not guesses — confirm before relying on either: the **Windows equivalent format
string is undocumented** in the BE catalog (test with `BE_ClipboardFormats` after copying a real
script step on Windows rather than assuming a code); and BE has **no equivalent to MBS's
`ScriptWorkspace.OpenScript`** — it covers clipboard push/pull only, not navigating to or opening
a specific script by ID.

### Method 3 — agentic-fm

**When to use:** The agentic-fm toolchain (`github.com/petrowsky/agentic-fm`) is set up for this
solution. Two distinct sub-modes exist — pick based on whether Script Workspace is already open
and being edited live, or a batch of XML is being generated for later paste.

**3a — HTTP bridge (live editing, no clipboard, no manual paste).** Per this project's own
`CLAUDE.md`: a local HTTP API (`GET /api/ui/script`, `POST /api/ui/script/select`,
`POST /api/ui/script/delete`, `POST /api/ui/script/insert`, `POST /api/ui/script/save`,
`POST /api/hr-to-xml`) manipulates the currently-open script directly — insert, delete, and save
all happen through the API with no clipboard step and no manual Cmd+V. This is the fastest method
when Script Workspace is already open and the bridge is running.

**3b — `clipboard.py` toolchain (offline/batch generation).** The agentic-fm skill file
(separate from this project, found at `agent/scripts/clipboard.py`) pushes a generated
`fmxmlsnippet` file straight onto the OS clipboard from outside FileMaker entirely —
`python3 agent/scripts/clipboard.py write agent/sandbox/<file>.xml` — then the developer still
does a manual Cmd+V into Script Workspace. Also runs its own `validate_snippet.py` pre-check
(well-formed XML, balanced If/Loop/Transaction pairs, known step names against its own
`step-catalog-en.json`) before the clipboard write.

**Known conflict, not yet resolved — flag rather than silently pick a side:** the agentic-fm
skill mandates **Unicode comparison operators** (`≠`, `≤`, `≥`) in generated calculations, the
exact opposite of `filemaker-xml`'s explicit recommendation to prefer **ASCII** (`<>`, `<=`,
`>=`) for transport safety through pipelines that might corrupt multi-byte characters. Don't
default to one silently — ask which convention the specific delivery path needs, since agentic-fm's
own `validate_snippet.py` may reject ASCII operators it doesn't expect.

### Method 4 — ProofKit

**When to use:** ProofKit is installed for this solution. Verified capability differs by task —
don't assume ProofKit has a script-XML delivery mechanism of its own beyond what's confirmed here.

**Confirmed**: ProofKit's distinguishing capability is `deploy_html` — deploying a self-contained
HTML web-viewer app into a container field (`ProofKitApps::HTML`), not delivering script-step
XML. For script steps and MBS-based file-system operations (folder listing, file move, path
building), the `filemaker-proofkit-webviewer` skill just uses standard `fmxmlsnippet` paste
conventions and MBS Plugin — no distinct ProofKit-specific script-clipboard mechanism was found
in that skill's reference material.

**Unconfirmed — this project's `CLAUDE.md` refers to "the agfm / ProofKit-style plugin" as if
ProofKit shares the same local HTTP bridge API as agentic-fm's Method 3a** (`/api/ui/script/insert`,
`/api/ui/script/save`, etc.). This hasn't been independently verified against a ProofKit-specific
API reference — treat it as a plausible but unconfirmed extension of Method 3a until a ProofKit
API doc surfaces to confirm or correct it.

### Method 5 — Manual paste (no plugin required)

**When to use:** No plugin installed — zero dependencies, works everywhere.

Claude presents the `fmxmlsnippet` XML and the matching HR step list. Developer manually rebuilds
the steps in Script Workspace using the HR list as the reference. A plain text paste of raw XML
into Script Workspace will **not** be interpreted as steps — one of Methods 1–4 is required to
push the FileMaker pasteboard UTI (or drive the API directly, for 3a) from outside FileMaker;
manual rebuild from the HR list is the only paste-free fallback.

| Situation | Best method |
|---|---|
| MBS installed in the target instance (confirmed: external clipboard write, no field/script call needed) | **Method 1 — MBS Plugin** |
| MBS not installed, BE Plugin is (external-delivery parity unconfirmed — use the documented function-call workflow) | **Method 2 — BE Plugin** |
| agentic-fm HTTP bridge running, Script Workspace open | **Method 3a — agentic-fm HTTP bridge** |
| agentic-fm set up but generating for later paste | **Method 3b — agentic-fm clipboard.py** |
| ProofKit web-viewer app to deploy (not a script) | **Method 4 — ProofKit `deploy_html`** |
| Need to open a specific script by ID | **MBS** (`ScriptWorkspace.OpenScript`) — no confirmed BE or ProofKit equivalent |
| No plugin installed, one-off edit | **Method 5 — Manual paste** |

More delivery methods are expected to be added to this list as they're confirmed — treat this as
a living roster, not a closed set of five.

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

Built and maintained by [Darrin Southern](https://www.linkedin.com/in/darrin-southern/) from [CadenceUX](https://cadenceux.com.au).
