# fmp-dev-gate

Customisable gate skill for the **`fmp-dev-orchestrator`** workflow. Defines which FileMaker
script steps and calculation functions are in scope for a specific project, and holds
project-specific overrides, naming conventions, and scripting constraints.

Current version: **v1.0** — see [CHANGELOG.md](./CHANGELOG.md) for full version history.

Built and maintained by [Darrin Southern](https://www.linkedin.com/in/darrin-southern/) from [CadenceUX](https://cadenceux.com.au).

## What it will contain

- Approved script steps — the subset of FileMaker's 165 steps permitted in this project
- Function restrictions — project-specific allowlist or constraints on calculation functions
- Naming conventions and boilerplate variations for the team
- Environment configuration — solution-specific constants, table names, or layout targets

## Current state

v1.0 is a skeleton. No customisations are defined yet. Install alongside `fmp-dev-orchestrator`
— features will be built out in subsequent releases.

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
