# fmp-dev-gate — Changelog

## v1.2 — 2026-07-01 (updated 2026-07-04)

### Fixed — 2026-07-04 accuracy pass (no version bump; v1.2 not yet on GitHub)

Findings from a four-skill review verified against the claris-filemaker-pro catalog and live
Claris Help docs:

- **AI / ML Integration Pattern rewritten — the previous example used invented parameters.**
  `Configure AI Account` has no Model parameter (it takes Account Name, Model Provider, API key,
  Endpoint — verified live); the model is specified on `Generate Response from Model`, whose real
  options are User Prompt / Instructions / Response / Messages / Agentic mode — not "Prompt
  Template", "Input", or "Target". The `{{input}}` placeholder was also invented:
  `Configure Prompt Template` uses constants like `:question:`/`:schema:` and its template types
  (SQL Query, Find Request, RAG Prompt) serve the natural-language/RAG steps, not
  `Generate Response from Model`. The example now uses only real parameters, with a note
  explaining each correction.
- **Set Error Logging** — corrected "logs errors to the console" to the real behaviour: logs to
  `ScriptErrors.log` in the user's Documents folder, and stays on for all scripts in the file
  until turned off or the file closes.
- **`$$globalVar` scope** — corrected "persists across scripts and sessions" to the real scope:
  shared across scripts for the current file session only; cleared when the file closes.
- **Boilerplate contradiction resolved** — "required first two steps" softened to "standard
  first two steps", consistent with the session preference the skill asks the developer for.
- **Set Error Capture description** — no longer claims an uncaptured error "stops" the script;
  FileMaker shows its own dialog (often Continue/Cancel) and the user decides.
- **Custom function naming** — removed the unverified claim that a later built-in with the same
  name "silently wins"; now advises avoiding collision-prone names (the `_cf` suffix convention
  sidesteps it).
- Loop example notation normalised to `Commit Records/Requests [ With dialog: Off ]`.
- Added the standard attribution line to the Licence section.

### Changed — expanded "Delivering Code to FileMaker" from two methods to five
- Renamed the section from "Two Methods" to "Five Methods" and reordered to the priority the
  developer specified: **1. MBS Plugin, 2. BE Plugin, 3. agentic-fm, 4. ProofKit, 5. Manual
  paste**.
- **New Method 2 — BE (BaseElements) Plugin**: `BE_ClipboardSetText`/`BE_ClipboardGetText`/
  `BE_ClipboardFormats`, using the FileMaker script-step pasteboard UTI
  `"dyn.ah62d4rv4gk8zuxnxnq"` — confirmed directly from `goya-be-plugin`'s own catalog example,
  not guessed. Two gaps flagged rather than assumed: the Windows-equivalent format string is
  undocumented in the BE catalog, and BE has no equivalent to MBS's `ScriptWorkspace.OpenScript`.
- **New Method 3 — agentic-fm**, with two sub-modes rather than one, since they're genuinely
  different mechanisms: **3a** the live HTTP bridge from this project's own `CLAUDE.md`
  (`/api/ui/script/insert`, `/api/ui/script/save` — no clipboard, no manual paste) and **3b** the
  `agentic-fm` skill's `clipboard.py` toolchain (external Python pushes to the OS clipboard,
  developer still does a manual Cmd+V). Flags an unresolved conflict between agentic-fm's own
  skill (which mandates Unicode comparison operators) and `filemaker-xml`'s recommendation
  (ASCII, for transport safety) — documented as an open conflict, not silently resolved.
- **New Method 4 — ProofKit**: confirmed capability is `deploy_html` (HTML web-viewer apps into
  `ProofKitApps::HTML`), not a script-XML delivery mechanism — the `filemaker-proofkit-webviewer`
  skill uses standard paste conventions + MBS for scripts, nothing ProofKit-specific. Separately
  flagged as **unconfirmed**: `CLAUDE.md`'s phrasing ("agfm / ProofKit-style plugin") implies
  ProofKit may share Method 3a's HTTP bridge API, but this hasn't been verified against a
  ProofKit-specific API reference.
- Former "Method 2 — Manual paste" renumbered to **Method 5**, wording updated to reflect that
  four other methods (not one) exist before falling back to it.
- Added a closing note that this is a living roster — more delivery methods are expected to be
  added as they're confirmed, not a closed set of five.
- No version bump — content addition to the existing v1.2 release.

### Added — Custom Functions section (Key Scripting Patterns)
- New **"Custom Functions"** subsection: rules for naming/uniqueness, privilege requirements,
  the private-function display behaviour, and the shared 50,000-iteration default limit for
  recursive custom functions and `While()` (with `SetRecursion` to adjust it).
- Points to **Brian Dunning's FileMaker Custom Functions library**
  (briandunning.com/filemaker-custom-functions) as the reference to check before writing a
  common utility from scratch, and notes the `_cf` naming suffix convention used there.
- Adds five worked examples: `AnErrorOccurred` / `NoErrorOccurred` (error-check helpers),
  `optionKey` (modifier-key bitmask check), `PortalNext` / `PortalPrev` (adjacent portal row
  lookup via `GetNthRecord`).
- Description frontmatter updated to mention custom function authoring (recursion, naming, exit
  conditions) as in scope.
- No version bump — this is a content addition to the existing v1.2 release, not a new release.

### Changed — gated XML-generation sections to the dedicated XML skills
- **"Reference skills"** now names `filemaker-xml`, `filemaker-field-xml`, and
  `filemaker-layout-xml` as the hand-off targets whenever the deliverable is actual paste-ready
  XML, not script step text.
- **"fmxmlsnippet Authoring Gotchas"** now opens with a note that its gotchas are a quick,
  project-level summary only — the full empirically-verified spec and progressive-loading
  reference files live in `filemaker-xml` / `filemaker-field-xml` / `filemaker-layout-xml`, and
  those skills should generate the actual XML rather than this section being used from memory.
- **"Delivering Code to FileMaker"** now states explicitly that both delivery methods (MBS
  Plugin, manual paste) assume the XML was already generated by the correct object-specific
  skill first.
- No scripting pattern content changed — this release only adds routing/delegation pointers to
  the three new XML skills reviewed alongside `fmp-dev-orchestrator` v1.2.

---

## v1.1 — 2026-06-30

### Changed — receives all scripting content from fmp-dev-orchestrator
- **All scripting patterns moved here** from `fmp-dev-orchestrator` — boilerplate, error
  handling, variable scope, looping, sub-scripts, JSON parameter passing, scripted finds,
  transactions, AI/ML integration pattern, compatibility notes, fmxmlsnippet authoring gotchas,
  and delivery methods (MBS Plugin + manual paste).
- **Description updated** to broad FileMaker scripting trigger — this is now the primary
  scripting skill; `fmp-dev-orchestrator` is the routing directory.
- **Configured Functions section added** — skeleton placeholder for project-specific function
  configuration to be built out in subsequent releases.

---

## v1.0 — 2026-06-30

Initial release — skeleton skill.

- New companion skill to `fmp-dev-orchestrator` — the customisable gate layer for
  project-specific FileMaker script step and function constraints.
- v1.0 is a skeleton: standard CadenceUX frontmatter card, placeholder sections for
  approved steps, function restrictions, naming conventions, and environment configuration.
- Features will be built out in subsequent releases.
