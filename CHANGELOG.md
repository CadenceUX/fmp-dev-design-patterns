# fmp-dev-design-patterns — Changelog

(Named `fmp-dev-gate` through v1.2 — renamed at v1.3.)

## [3.0.2] — 2026-11-24

Claris's FileMaker Agentic Development Kit (ADK) 0.17.0. No change to what the skill does.

### Changed

- `references/baseline-summary.md` checked against ADK 0.17.0: ADK's built-in Baseline is
  unchanged from 0.16.0.

### Verified

- `adk standards list` in ADK 0.17.0 shows `cadenceux 1.0.0` and `default 0.17.0`.
- `validate_skill.py` clean.

## [3.0.1] — 2026-11-19

`cadenceux-dx` replaces the retired `fmp-dev-orchestrator`, and Claris's public FileMaker
Agentic Development Kit (ADK) replaces the ADT preview name. No change to what the skill does.

### Changed

- The skill update self-check skips when `cadenceux-dx` is installed (its stack check covers
  every CadenceUX skill), in place of `fmp-dev-orchestrator`.
- ADT is now ADK in the instructions, README and evals.

### Verified

- `validate_skill.py` clean; `cadenceux-github` scanners clean.
- Evals not re-run: names only, no change to instructions or reference data.

## [3.0.0] — 2026-11-19

CadenceUX's conventions move into the `cadenceux` standards pack for Claris's FileMaker Agentic
Development Kit (ADK), using `cadenceux-skill-creator` 2.4.2. Major version: the configured
patterns and the session-setup questions are gone from this file.

### Added

- **The `cadenceux` pack**, published as the `cadenceux-filemaker-standards` plugin (1.0.0) in
  the `cadenceux` marketplace, with a copy in `references/cadenceux-pack/`. `naming.md`,
  `patterns.md` and `advisory.md` restate the 2.x conventions as rules an agent can apply, over
  ADK's Baseline: `Domain: Action` script names, dot-notation fields and table occurrences,
  `_g` globals, the CadenceUX script header, script layout, `AnErrorOccurred` error handling,
  JSON script results (`status`, `errorCode`, `message`, `data`), Halt Script, the Settings
  table, and the anti-patterns as review advice.
- **Where the conventions apply:** ADK in Claude Code (`adk standards use cadenceux`), ADK in
  another harness (copy the pack into `.adk/standards/`), no ADK (apply the pack over
  `references/baseline-summary.md`), or a client's own conventions.
- **Deriving a client's standards:** the audit now ends in draft `naming.md`, `patterns.md` and
  `advisory.md` rules, written to the project's `.adk/standards/` or a client pack, checked
  against Claris's checklist for rules an agent can carry out.
- `references/baseline-summary.md`: the ADK Baseline rules the pack builds on, in this skill's
  words, for work without ADK.
- `maintainer/check_pack_sync.sh`: confirms this skill's pack copy matches the published pack.
- Evals: `follow-pack`, `name-script`, `client-pack`.

### Changed

- ADT is now ADK throughout. The script-writing checklist, delivery loop and review guidance
  follow the layers ADK resolves.
- The worked error-handling pattern uses the pack's `AnErrorOccurred` check and JSON result.

### Decisions made writing the pack (review before projects adopt it)

Where 2.x offered options or left a choice open, the pack picks one default, as Claris's rules
require:

- Script domains: the 2.x list plus `Create`, `Delete`, `Navigate`, `Print` and `Utility`, and
  the base table's name when none fits.
- Fields: dot-notation namespaces (`Address.City`), as 2.x stated; a global calculation is
  `_calc_g`.
- Table occurrences: the default occurrence keeps the base table's name; import and staging
  occurrences use a source prefix, `imp_` when the source has no short name.
- Script header: the 2.x boilerplate (abort and error capture first, then `PURPOSE`), plus
  `Called by:`, and `PARAMETERS` and `RETURNS` lines when they apply.
- Script results: one JSON shape for every reporting script, replacing the 2.x menu of `""`,
  `"SUCCESS"`, `"ERROR:"` text and JSON.
- Configuration globals live in a one-record `Settings` table.

### Verified

- The pack resolves in ADK 0.16.0: `adk standards list` shows `cadenceux 1.0.0`;
  `adk standards use cadenceux` records it; `adk standards` shows Baseline then Pack for each
  file.
- Every formula the pack prescribes evaluated on the FileMaker 26.1.1 engine.
- Evals: 4 cases on Haiku, Sonnet and Opus, all passing (2.1.1 baseline about 1.5 of 4);
  see `evals/results-2026-11-19-v3.0.0.md`. One pack ambiguity Opus found was fixed and re-checked.
- `validate_skill.py` clean; `cadenceux-github` scanners clean.

## [2.1.1] — 2026-10-16

Packaging fix for GitHub installs, using `cadenceux-skill-creator` 2.1.2. No change to the skill's instructions or reference data.

### Fixed

- **GitHub source zips no longer install as a plugin.** The repository root carries
  `.claude-plugin/plugin.json` for the plugin marketplace, so GitHub's **Code → Download
  ZIP** and a release's **Source code (zip)** looked like a plugin to the Claude desktop app,
  which pointed to the plugin installer instead of installing the skill. A new `.gitattributes`
  leaves `.claude-plugin/`, `evals/`, `maintainer/` and the git dotfiles out of those archives.
  The marketplace is unaffected: it reads the repository, not the archive.

### Changed

- README install section links straight to the latest release's `.skill` and `.zip`, and
  warns against the source zips.
- Each release now also attaches unversioned copies (`<name>.skill`, `<name>.zip`) so the
  README's `releases/latest/download/…` links don't change between versions.

### Verified

- `validate_skill.py` clean on the folder and on both release archives.
- Evals not re-run: no instruction or data change since the last run.

## [2.1.0] — 2026-10-11

### Added

- **Skill update self-check.** Once per session the skill compares its version with the repo's
  `VERSION` and says when a newer release is out. It defers to `fmp-dev-orchestrator`'s stack
  check when that's installed, which covers every CadenceUX skill plus Claris ADT, FileMaker Pro
  and the ADT project. New eval case: skill-update-check.

### Changed

- Configured design patterns now say how they relate to ADT's `filemaker-standards` skill:
  ADT carries the baseline; these patterns are the developer's layer on top.

## [2.0.0] — 2026-10-11

Rebuilt for the Claris Agentic Development Toolkit (ADT) and Anthropic's skill authoring best
practices, using `cadenceux-skill-creator` 2.0.0.

### Changed

- **Scripts go into the file through ADT.** New "Delivering scripts to the file" section: validate
  calculations with ADT's engine, write through ADT, read back and compare, repeat until it
  matches. Without ADT, scripts are presented as readable steps for the developer to enter.
- **The design-pattern audit reads the live file through ADT** (`references/pattern-audit.md`,
  renamed from `saxml-pattern-audit.md`); the Save as XML export remains the fallback without ADT.
- SKILL.md body cut from 690 to under 250 lines; the worked patterns moved to
  `references/scripting-patterns.md` (with a contents list). New "Writing a script" checklist.
- Frontmatter to the CadenceUX standard (third-person description, "Use when" and "Not for",
  `license`, `metadata.author`); `.claude-plugin/plugin.json` added; `evals/evals.json` added.

### Removed

- **fmxmlsnippet authoring gotchas and the five clipboard delivery methods** (MBS, BaseElements,
  agentic-fm, ProofKit, manual paste). ADT writes to the file directly. Summarised under
  "Old patterns".
- Hand-offs to the XML skills (`filemaker-xml`, `filemaker-field-xml`, `filemaker-layout-xml`),
  the retired `fmp-dev-full-script`, and `clockwork-xml-inspector`.

## v1.3 — 2026-07-05

Renamed to `fmp-dev-design-patterns`, with a new solution-agnostic, developer-configurable
design-patterns layer.

- **Renamed from `fmp-dev-gate` to `fmp-dev-design-patterns`** — the skill's job is the
  design patterns the developer builds up for a project, not just gating function scope.
  Cross-references in `fmp-dev-orchestrator` and `fmp-dev-full-script` updated in the same
  release set. Remove any installed `fmp-dev-gate` copy.
- **New configurable design-patterns layer**, deliberately solution-agnostic (the skill
  never cites a specific solution's file name or statistics — those stay in the audit
  conversation):
  - A **session-start question** asks the developer whether to follow the configured
    patterns or audit a solution's Save as XML export to derive recommendations (or both).
  - **"Configured design patterns"** is the developer-built layer, seeded with generalised
    patterns accepted from a full audit of a production FileMaker solution (2026-07-05):
    `Domain: Action` script naming with `| Variant`/`[Mode]`/`[OLD]` markers, CF-based
    error checks, dot-notation field/TO namespacing with `_g` globals and a central
    control table, explicit JSON exits, `Halt Script` reserved for named utilities — plus
    a generalised anti-patterns list (empty-comment-only scripts, missing exits, error
    capture without checks, dead disabled steps, naming drift, speculative CFs).
  - **New `references/saxml-pattern-audit.md`** captures the repeatable audit method: the
    FMSaveAsXML extraction map (ScriptReference id, nested Calculation/Text, comment and
    Set Variable target locations), the stats to compute, the `$$` set/clear/read mapping,
    CF-hygiene rules (zero-param CFs are called without parentheses; layout calcs are out
    of scope for the scan), and the accept/reject presentation flow.
- **Headline anti-pattern: `$$` globals as inter-script data/error transport** (per
  Developer). A `$$` value survives early exits, reruns, and long-lived sessions with no
  validation that it reflects the current call. Prefer parameters in / script result out;
  where a `$$` flag is needed, pair every setter with a clearer and initialise at startup.
  Includes the sneaky-setter variants surfaced by the audit: `Let()` side effects in CFs,
  field calculations assigning globals, step target-variables, casing twins, and reads of
  globals nothing sets.
- **`AnErrorOccurred`/`NoErrorOccurred` guidance updated**: the CFs stay (they're the
  established idiom), but the `$$LastError` side effect is now documented with discipline —
  valid only until the next step, capture to a local for logging, never read cross-script.
  The previous wording praised the persistence; that's reversed.
- README updated for the rename, the new layer, and the `.skill` double-click install
  convention.

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
