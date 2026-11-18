# fmp-dev-design-patterns

A [Claude skill](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview)
for writing Claris FileMaker scripts that are correct, readable and maintainable: script
structure, error handling, JSON parameters and results, transactions, AI steps, custom
functions, naming conventions and anti-patterns.

CadenceUX's conventions ship as the **`cadenceux` standards pack** for Claris's FileMaker
Agentic Development Kit (ADK), published as
[cadenceux-filemaker-standards](https://github.com/CadenceUX/cadenceux-filemaker-standards). A
project that follows it gets them on top of ADK's baseline. This skill applies the pack,
writes and reviews scripts with it, works without ADK, and audits an existing solution to
derive a client's own standards. With ADK, scripts are written straight into the file and read
back to confirm. No clipboard XML.

Built and maintained by [Darrin Southern](https://www.linkedin.com/in/darrin-southern/) from [CadenceUX](https://cadenceux.com.au).

## What it covers

- **The `cadenceux` pack, everywhere:** follow it in an ADK project
  (`adk standards use cadenceux`), copy it into `.adk/standards/` for Cursor, Codex or Gemini
  CLI, or apply it directly without ADK. `Domain: Action` script names, dot-notation fields and
  table occurrences, the CadenceUX script header, `AnErrorOccurred` error checks, JSON results,
  and review advice headed by passing state between scripts in `$$` globals.
- **A client's own standards:** audit the solution (live through ADK, or from a Save as XML
  export), accept the conventions worth keeping, and write them as the project's
  `.adk/standards/` files or a pack of their own, to Claris's rules for rules an agent can
  apply.
- **A script-writing checklist** with an error check after every step that can fail.
- **Worked patterns** (`references/scripting-patterns.md`): error handling, variable scope,
  loops, sub-scripts, JSON parameters, scripted finds, transactions, AI steps, custom functions.
- **Delivery through ADK** with a write, read-back, compare loop.

Exact step and function syntax comes from
[claris-filemaker-pro](https://github.com/CadenceUX/claris-filemaker-pro-skill).

## Install

**Claude Code** (from the `cadenceux` plugin marketplace):

```bash
claude plugin marketplace add https://github.com/CadenceUX/cadenceux-skills.git
claude plugin install fmp-dev-design-patterns@cadenceux
```

**claude.ai and Cowork:** Customize → Plugins → Add marketplace from GitHub →
`CadenceUX/cadenceux-skills`, then install **fmp-dev-design-patterns**.

**Claude desktop app (macOS):** download [`fmp-dev-design-patterns.skill`](https://github.com/CadenceUX/fmp-dev-design-patterns/releases/latest/download/fmp-dev-design-patterns.skill) and
double-click it.

**Claude.ai in a browser, as a single skill:** Customize → Skills → upload
[`fmp-dev-design-patterns.zip`](https://github.com/CadenceUX/fmp-dev-design-patterns/releases/latest/download/fmp-dev-design-patterns.zip).

> Both files are attached to the latest [release](https://github.com/CadenceUX/fmp-dev-design-patterns/releases).
> Don't use GitHub's green **Code → Download ZIP** button or a release's **Source code (zip)**:
> those are snapshots of the repository, not a packaged skill, and Claude won't install them
> as one.

## Files

| Path | Purpose |
|---|---|
| `SKILL.md` | Where the conventions apply, writing, delivering and reviewing scripts, deriving a client's standards |
| `references/cadenceux-pack/` | The `cadenceux` pack's `naming.md`, `patterns.md` and `advisory.md`, identical to the published pack |
| `references/baseline-summary.md` | The ADK Baseline rules the pack builds on, for work without ADK |
| `references/scripting-patterns.md` | Worked scripting patterns |
| `references/pattern-audit.md` | Audit method (ADK or Save as XML), ending in draft standards files |
| `evals/evals.json` | Test cases |

## Licence

[CC BY 4.0](https://creativecommons.org/licenses/by/4.0/). Use it, fork it, adapt it. Attribute it.

Built and maintained by [Darrin Southern](https://www.linkedin.com/in/darrin-southern/) from [CadenceUX](https://cadenceux.com.au).
