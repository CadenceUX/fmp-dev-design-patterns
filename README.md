# fmp-dev-design-patterns

Design-patterns and scripting-rules skill for the **`fmp-dev-orchestrator`** workflow
(formerly `fmp-dev-gate`). Holds the scripting patterns,
boilerplate, and a **configurable design-patterns layer** — naming taxonomies, error-state
discipline, and anti-patterns — that the developer either keeps as configured or re-derives
by auditing a solution's Save as XML export.

Current version: **v1.3** — see [CHANGELOG.md](./CHANGELOG.md) for full version history.

Built and maintained by [Darrin Southern](https://www.linkedin.com/in/darrin-southern/) from [CadenceUX](https://cadenceux.com.au).

## What it contains

- **A session-start question**: follow the configured design patterns, or audit a solution's
  SaXML export to derive and recommend patterns — the configured section is the
  developer-built layer, updated as audit recommendations are accepted
- **Configured design patterns** (seeded, generalised): `Domain: Action` script naming with
  variant markers, dot-notation field/TO namespacing with `_g` globals, CF-based error
  checks with `$$LastError` discipline, explicit exits with JSON results — plus an
  anti-patterns list headed by `$$`-global state passing between scripts (stale-value risk,
  sneaky setters, missing clearers)
- **`references/saxml-pattern-audit.md`**: the repeatable audit method — extraction map for
  the FMSaveAsXML format (with its parsing gotchas), the stats to compute, and how to
  present findings as accept/reject recommendations
- Script boilerplate — Allow User Abort / Set Error Capture, standard Exit Script patterns
- Key scripting patterns — error handling, variable scope, looping, sub-scripts, JSON
  parameter passing, scripted finds, transactions, AI/ML integration
- A project-level summary of fmxmlsnippet authoring gotchas (delegates to the dedicated XML
  skills for the full spec)
- Five delivery methods for getting generated XML onto the FileMaker pasteboard
- A placeholder "Configured Functions" section for project-specific function restrictions

## Installing

**macOS (Claude desktop app):** double-click the `fmp-dev-design-patterns-v1.3.skill` file —
it opens Claude's skill-install flow directly. (The `.skill` file is just the release zip
renamed.)

**Claude.ai in a browser (or if double-click doesn't work):** upload the release zip via
Settings → Customize → Skills.

If a copy of `fmp-dev-gate` is still installed, remove it — this skill replaces it under
the new name.

## Files

```
fmp-dev-design-patterns/
├── SKILL.md                             — the skill itself
├── VERSION                              — bare version string
├── CHANGELOG.md                         — version history
├── README.md                            — this file
└── references/
    └── saxml-pattern-audit.md           — the SaXML audit method
```

## Licence

[CC BY 4.0](https://creativecommons.org/licenses/by/4.0/) — free to use, adapt, and redistribute with attribution.

Built and maintained by [Darrin Southern](https://www.linkedin.com/in/darrin-southern/) from [CadenceUX](https://cadenceux.com.au).
