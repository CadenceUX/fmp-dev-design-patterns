# fmp-dev-design-patterns

A [Claude skill](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview)
for writing Claris FileMaker scripts that are correct, readable and maintainable: boilerplate,
error handling, JSON parameters and results, transactions, AI steps, custom functions, naming
conventions and anti-patterns, plus a design-patterns layer you keep as configured or re-derive
by auditing your own solution.

With the Claris Agentic Development Toolkit (ADT) installed, scripts are written straight into
the FileMaker file through ADT and read back to confirm. No clipboard XML, no copy and paste.

Built and maintained by [Darrin Southern](https://www.linkedin.com/in/darrin-southern/) from [CadenceUX](https://cadenceux.com.au).

## What it covers

- **Session setup:** use the configured patterns, or audit your solution first (live through
  ADT, or from a Save as XML export without it) and accept the recommendations you want.
- **Configured design patterns:** `Domain: Action` script naming, dot-notation fields and table
  occurrences, CF-based error checks with `$$LastError` discipline, explicit exits with JSON
  results, and an anti-patterns list headed by passing state between scripts in `$$` globals.
- **A script-writing checklist** with an error check after every step that can fail.
- **Worked patterns** (`references/scripting-patterns.md`): error handling, variable scope,
  loops, sub-scripts, JSON parameters, scripted finds, transactions, AI steps, custom functions.
- **Delivery through ADT** with a write, read-back, compare loop.

Exact step and function syntax comes from
[claris-filemaker-pro](https://github.com/CadenceUX/claris-filemaker-pro-skill).

## Install

Part of the `cadenceux` plugin marketplace:

```bash
claude plugin marketplace add https://github.com/CadenceUX/cadenceux-skills.git
claude plugin install fmp-dev-design-patterns@cadenceux
```

On claude.ai and Cowork: Customize → Plugins → Add marketplace from GitHub →
`CadenceUX/cadenceux-skills`. Or download the `.skill` file from the latest release and
double-click it (macOS).

## Files

| Path | Purpose |
|---|---|
| `SKILL.md` | Session setup, configured patterns, boilerplate, delivery |
| `references/scripting-patterns.md` | Worked scripting patterns |
| `references/pattern-audit.md` | Audit method (ADT or Save as XML) |
| `evals/evals.json` | Test cases |

## Licence

[CC BY 4.0](https://creativecommons.org/licenses/by/4.0/). Use it, fork it, adapt it. Attribute it.

Built and maintained by [Darrin Southern](https://www.linkedin.com/in/darrin-southern/) from [CadenceUX](https://cadenceux.com.au).
