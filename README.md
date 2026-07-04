# fmp-dev-gate

Customisable gate skill for the **`fmp-dev-orchestrator`** workflow. Defines which FileMaker
script steps and calculation functions are in scope for a specific project, and holds
project-specific overrides, naming conventions, and scripting constraints.

Current version: **v1.2** — see [CHANGELOG.md](./CHANGELOG.md) for full version history.

Built and maintained by [Darrin Southern](https://www.linkedin.com/in/darrin-southern/) from [CadenceUX](https://cadenceux.com.au).

## What it contains

- Script boilerplate — Allow User Abort / Set Error Capture, standard Exit Script patterns
- Key scripting patterns — error handling, variable scope, looping, sub-scripts, JSON parameter
  passing, scripted finds, transactions, AI/ML integration (Generate Response from Model)
- Compatibility notes across FileMaker Pro, Go, WebDirect, and Server
- A project-level summary of fmxmlsnippet authoring gotchas (delegates to the dedicated XML
  skills below for the full spec)
- Two delivery methods for getting generated XML onto the FileMaker pasteboard (MBS Plugin,
  manual paste)
- A placeholder "Configured Functions" section for project-specific function restrictions —
  not yet built out

## Current state

v1.2 gates its XML-related sections ("Reference skills", "fmxmlsnippet Authoring Gotchas",
"Delivering Code to FileMaker") to hand off actual XML generation to `filemaker-xml`,
`filemaker-field-xml`, and `filemaker-layout-xml` rather than duplicating their content. The
"Configured Functions" section remains a skeleton — no project-specific restrictions are
defined yet. Install alongside `fmp-dev-orchestrator`.

## Files

```
fmp-dev-gate/
├── SKILL.md        — the skill itself
├── VERSION          — bare version string
├── CHANGELOG.md     — version history
└── README.md        — this file
```

## Licence

[CC BY 4.0](https://creativecommons.org/licenses/by/4.0/) — free to use, adapt, and redistribute with attribution.
