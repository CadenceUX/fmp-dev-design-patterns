---
name: fmp-dev-design-patterns
description: >-
  Scripting conventions and design patterns for Claris FileMaker: script boilerplate, error
  handling, variable scope, loops, sub-scripts, JSON parameters and results, transactions,
  AI steps, custom functions, naming taxonomies and anti-patterns, plus a configurable
  design-patterns layer the developer keeps as written or re-derives by auditing a solution.
  With the Claris Agentic Development Toolkit (ADT) installed, scripts are written into the
  file through ADT rather than as clipboard XML. Use when writing, reviewing, refactoring or
  debugging FileMaker scripts, designing script architecture, or setting project conventions,
  even when phrased casually ("write a script that…"). Not for exact step or function syntax
  (claris-filemaker-pro) or plugin functions (the plugin skills).
license: CC-BY-4.0
compatibility: >-
  Claude.ai, Claude Desktop, Cowork and Claude Code. Writing scripts into the file needs the
  Claris ADT plugin; the patterns themselves work anywhere.
metadata:
  author: Darrin Southern, CadenceUX
  version: "2.0.0"
---

# FileMaker design patterns

Conventions and patterns for writing FileMaker scripts that are correct, readable and
maintainable by Developer Next. This skill owns *how* scripts are structured; exact step and
function syntax comes from `claris-filemaker-pro`, plugin functions from `goya-be-plugin`,
`monkeybread-mbs-plugin` and `beezwax-bbox-plugin`, and routing across the set from
`fmp-dev-orchestrator`.

## Session setup

Ask both questions once, at the start, and apply the answers for the session.

> **Design patterns:** should I (1) apply the configured patterns below, (2) audit this
> solution first and recommend patterns, or (3) audit, then merge what you accept into the
> configured patterns?

The audit method (through ADT on the live file, or from a Save as XML export without ADT) is
in [references/pattern-audit.md](references/pattern-audit.md). Never write a specific
solution's name or statistics into the configured section; it's generalised project
configuration.

> **Opening steps:** should I (1) always add `Allow User Abort [ Off ]` and
> `Set Error Capture [ On ]`, (2) ask each time, or (3) something else?

## Writing a script

Copy this checklist and work through it:

```
Script progress:
- [ ] Purpose comment and section plan
- [ ] Opening steps per the session choice
- [ ] Every step that can fail followed by an error check
- [ ] Parameters in as JSON, explicit Exit Script with a result out
- [ ] Step and function syntax confirmed with claris-filemaker-pro (or ADT's engine)
- [ ] Anti-patterns list checked
- [ ] Delivered (ADT, or as steps for the developer) and read back
```

## Configured design patterns

### Naming

- **Scripts**: a `Domain: Action` colon-prefix taxonomy (`Search:`, `Email:`, `Export:`,
  `Import:`, `Report:`, `Update:`, `Validate:`, ...) so related scripts sort and group
  together; a `| Variant` pipe suffix for variants of one action (`Search: Staff | Single`);
  a bracket suffix like `[Mode]` for mode-driven scripts and `[OLD]` for a superseded script
  kept for reference. If the solution organises by divider scripts (`--`) rather than
  folders, stay consistent with it rather than introducing folders piecemeal.
- **Fields**: dot-notation namespacing (`Entity.Purpose.Detail`), a `_g` suffix for globals,
  and configuration globals centralised in a single control/settings table rather than
  scattered per-table.
- **Table occurrences**: dot-notation context paths (`Anchor.Related.Purpose`); a short
  prefix (e.g. `xml_`) for import/staging occurrences.

### Error handling

- Error checks go through the custom functions `AnErrorOccurred` / `NoErrorOccurred`
  (see Custom Functions below), extended inline where needed:
  `AnErrorOccurred or IsEmpty ( $result ) or PatternCount ( $result ; "Exception" )`.
- **`$$LastError` discipline**: the side-effect global those CFs set is valid only until the
  next step of the same script. Read it immediately (e.g. into a local for logging), never
  branch on it in another script, and don't trust it across triggers or sessions.

### Script structure

- Open with `Allow User Abort [ Off ]` + `Set Error Capture [ On ]` (per the session
  preference captured under Script Boilerplate), close with an explicit
  `Exit Script [ Text Result: ... ]`, pass structured data as JSON parameters in and a JSON
  script result out.
- Reserve `Halt Script` for named utility scripts called from triggers and buttons — don't
  scatter Halt through business logic.

### Anti-patterns to avoid

- **Passing data or error state between scripts via `$$` globals.** A `$$` value set in one
  script and read in another survives early exits, reruns, and (on hosted or long-lived
  files) whole working sessions — the reader has no way to know whether it reflects the
  current call or a stale one. Prefer script parameters in and
  `Exit Script [ Text Result: ]` out. Where a `$$` flag is genuinely needed (halt flags,
  UI state), pair **every setter with a clearer**, initialise it in the startup script, and
  validate before branching on it.
- **Sneaky `$$` setters.** Watch for globals assigned outside `Set Variable`: `Let()`
  side effects inside custom functions, field calculations that assign `$$` variables as a
  side effect of evaluating, and step target-variables (e.g. Insert from URL into a `$$`).
  These make session state untraceable; also hunt casing twins (`$$Result` vs `$$result`)
  and reads of globals nothing ever sets.
- **Empty-comment-only scripts** — blank comment steps as spacing are fine, but scripts also
  need real comments (purpose header, section notes), and new or changed fields get a field
  comment.
- **Falling off the end** — a script without an explicit `Exit Script` gives callers no
  result to distinguish success from failure.
- **Error capture without error checks** — `Set Error Capture [ On ]` with no subsequent
  test just silences errors; every step that can fail gets a check immediately after it.
- **Dead disabled steps** — delete them, or duplicate the script to `Name [OLD]` first if
  the old logic must be kept.
- **Speculative custom functions** — check the existing CF library before writing a new
  one, and don't add functions nothing calls.

## Script boilerplate

```
Allow User Abort [ Off ]
Set Error Capture [ On ]

# PURPOSE: what this script does and who calls it.

# ... script body ...

Exit Script [ Text Result: "" ]
```

- `Allow User Abort [ Off ]` stops Escape/⌘. leaving records uncommitted or transactions
  open; turn it on only where a long process offers a deliberate cancel.
- `Set Error Capture [ On ]` silences FileMaker's dialogs so the script handles errors, which
  only works if every step that can fail is followed by a `Get ( LastError )` check (it resets on
  the next step).

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

## Patterns

Worked patterns for error handling, variable scope, loops, sub-scripts, JSON parameters,
scripted finds, transactions, AI steps and custom functions:
[references/scripting-patterns.md](references/scripting-patterns.md).

## Delivering scripts to the file

**With ADT installed (the default):** write the script into the file through ADT. ADT's
`fm-mcp-guide` skill names the tool for creating or editing scripts, custom functions and
layouts. Then close the loop:

1. Validate every calculation with ADT's engine before writing (see `claris-filemaker-pro`'s
   ADT mode).
2. Write the script through ADT.
3. Read it back through ADT and compare it with the intended steps.
4. If anything differs, fix and repeat. Report done only when the read-back matches.

**Without ADT:** present the script as readable steps, in the format used throughout this
skill, for the developer to enter in Script Workspace. Mention that ADT can write it directly
once installed. Don't generate fmxmlsnippet or clipboard XML.

## Old patterns

<details>
<summary>Clipboard XML delivery (retired in 2.0.0)</summary>

Versions 1.x generated `fmxmlsnippet` XML and pushed it to the pasteboard through the MBS or
BaseElements plugins, agentic-fm or ProofKit, with a manual paste into Script Workspace. ADT
writes to the file directly, so that path and its gotchas were removed. See CHANGELOG 2.0.0.
</details>

## Platform differences

Steps unsupported on a client (FileMaker Go, WebDirect, Server, Data API) are skipped and
return error 3. Branch with `Get ( SystemPlatform )` or `Get ( Device )` where behaviour must
differ; check each step's support matrix in `claris-filemaker-pro`.

## Configured functions

Project-specific limits on which reference-skill functions are in scope. None are configured,
so every lookup falls through to the reference skills.

## Licence

This skill is released under [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/).

Built and maintained by [Darrin Southern](https://www.linkedin.com/in/darrin-southern/) from [CadenceUX](https://cadenceux.com.au).
