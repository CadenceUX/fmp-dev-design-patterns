# SaXML pattern audit — method

How to derive design-pattern recommendations from a FileMaker solution's **Save a Copy as
XML** export (`Tools → Save a Copy as XML` in FileMaker Pro with advanced tools enabled).
Run this when the developer chooses the audit option in SKILL.md's session-start question.
Findings are presented as **recommendations for the developer to accept or reject** — only
accepted items get folded into SKILL.md's "Configured design patterns" section, and always
in generalised form (no solution file names, no statistics baked into the skill).

**Execution surface:** this needs code execution (Claude Code, the Agent SDK, or a
code-execution-enabled chat) — the exports are tens of MB and the analysis is a Python
parse, not something to eyeball. In plain Claude.ai chat, ask the developer to run the
extraction locally or hand the audit to a Code session. For schema health, broken
references, and unreferenced fields, `clockwork-xml-inspector` is the complementary tool —
this audit is about *style and conventions*, not integrity.

## Extraction — where things live in FMSaveAsXML

The export root is `FMSaveAsXML → Structure → AddAction`, with one catalog element per
object type. Parse with a streaming or full XML parser; the gotchas below cost real time
when unknown:

| What | Where | Gotcha |
|---|---|---|
| Script names + folders | `ScriptCatalog` → `Script` / `Group` elements | A flat catalog (no `Group`s) means the solution organises by divider scripts instead of folders |
| Script steps | `StepsForScripts` → `Script` → `ObjectList` → `Step` | The script id is on the child `ScriptReference`, **not** on the `Script` element |
| Any calculation text | `Calculation` → nested `Calculation` → `Text` | The outer `Calculation`'s own text is whitespace — the formula is in the inner `Text` node |
| Comment step text | `Step name="# (comment)"` → `ParameterValues/Parameter[type=Comment]/Comment` | An empty `Comment` element = a blank-line separator, not a written comment |
| Set Variable target | `Step` → `ParameterValues/Parameter[type=Variable]/Name@value` | The variable being *assigned* is an attribute, not calculation text — a text-only scan sees reads, not writes |
| Fields | `FieldsForTables` → `FieldCatalog` (one per base table) → `ObjectList/Field` | Field comments are a `Comment` child; globals are `Storage@global="True"` |
| Custom functions | `CustomFunctionsCatalog` → `CustomFunction` | Same nested-`Calculation/Text` rule for the formula |
| Table occurrences | `TableOccurrenceCatalog` | Base table via `BaseTableSourceReference` |

## Stats to compute

1. **Script naming**: prefix taxonomy (text before `:`), suffix markers (`| X`, `[X]`),
   divider scripts, dev/test/OLD markers, folder usage.
2. **Opener/closer coverage**: % of scripts with `Allow User Abort` + `Set Error Capture`
   in the first steps; % containing any `Exit Script`; % whose *last* step is `Exit Script`;
   `Get(ScriptResult)` readers.
3. **Comment coverage**: comment steps with text vs empty separators; field-comment rate.
4. **Error handling**: `Get(LastError)` and error-CF usage vs `Set Error Capture` count —
   the gap is the silent-failure surface.
5. **Dead code**: disabled (`enable="False"`) step counts per script.
6. **`$$` global discipline** — build a set/clear/read map per variable:
   - *setters*: `Set Variable` `Name@value` starting `$$`, **plus** `$$X =` matches inside
     any calculation text (`Let()` side effects in scripts, custom functions, **and field
     calcs**), plus step target-variables (Insert from URL etc.) where visible.
   - *clearers*: setters whose calc is `""`.
   - *readers*: `$$X` occurrences in calculation text.
   - Hunt: variables read but never set (or set only by invisible plugin/step targets),
     casing twins (`$$Result` vs `$$result`), setters with no paired clearer, cross-script
     pairs (set in one script, read in others), and whether the startup script
     initialises/validates anything.
7. **CF hygiene**: functions unreferenced by scripts, field calcs, or other CFs.
   Zero-parameter CFs are called **without parentheses** — match bare names too. Layout
   calculations (conditional formatting, hide conditions, tooltips) are not covered by this
   scan; say so rather than declaring a layout-helper CF dead.
8. **Naming drift**: competing conventions for the same category (global suffix vs prefix,
   key-field styles, casing variants) — recommend the majority form as the standard.
9. **Secrets**: credential-like literals or credential-bearing globals/fields in script
   calcs — report to the developer as a security observation, separate from style.

## Presenting findings

Present two lists — **conventions to follow** (the majority patterns worth codifying) and
**anti-patterns observed** (habits new code should correct) — each item with its supporting
numbers from the audit. After the developer accepts/rejects items, update SKILL.md's
"Configured design patterns" in generalised wording and leave the numbers in the
conversation. Where a finding needs deeper tooling (layout calc references, broken refs),
point at `clockwork-xml-inspector` instead of over-claiming from this scan.
