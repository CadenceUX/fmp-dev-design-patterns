---
name: fmp-dev-design-patterns
description: >-
  Scripting conventions and design patterns for Claris FileMaker: script structure, error
  handling, variable scope, loops, sub-scripts, JSON parameters and results, transactions, AI
  steps, custom functions, naming and anti-patterns. CadenceUX's conventions ship as the
  cadenceux standards pack for Claris's FileMaker Agentic Development Kit (ADK); this skill
  applies them, writes and reviews scripts with them, works without ADK, and audits an
  existing solution to derive a client's own standards pack. Use when writing, reviewing,
  refactoring or debugging FileMaker scripts, setting or changing a project's conventions,
  choosing or writing a standards pack, or asking why a naming or script rule exists. Not for
  exact step or function syntax (claris-filemaker-pro) or plug-in functions (the plug-in
  skills).
license: CC-BY-4.0
compatibility: >-
  Claude.ai, Claude Desktop, Cowork and Claude Code, and any harness that reads skills.
  Following the pack and writing scripts into the file need ADK (FileMaker Pro 26.1 or later);
  the patterns themselves work anywhere.
metadata:
  author: Darrin Southern, CadenceUX
  version: "3.0.2"
---

# FileMaker design patterns

Conventions and patterns for FileMaker scripts that are correct, readable and maintainable by
Developer Next. This skill owns *how* scripts and schema are shaped; exact step and function
syntax comes from `claris-filemaker-pro`, plug-in functions from `goya-be-plugin`,
`monkeybread-mbs-plugin` and `beezwax-bbox-plugin`.

## Requirements

| Kind | Name | Used for | Surfaces |
|---|---|---|---|
| Plugin | `cadenceux-filemaker-standards@cadenceux` | The `cadenceux` standards pack, for ADK projects | Claude Code |
| CLI | `adk` (ADK) | `adk standards` status, follow and init | Claude Code or any harness with a shell |
| Path | `.adk/standards/` in an ADK project | A project's own rules, or the pack copied for other harnesses | Any harness with file access |
| API | `raw.githubusercontent.com` (public, no key) | This skill's version check | Any surface that can fetch |

Without ADK or a shell, the skill answers from its own files.

## Where the conventions live

CadenceUX's conventions are **the `cadenceux` standards pack**, applied in layers by ADK:
ADK's built-in Baseline first, then the pack, then the project's own `.adk/standards/` files.
A later layer wins only where it says something about the same thing. This skill carries a
copy of the pack in [references/cadenceux-pack/](references/cadenceux-pack/naming.md):
[naming.md](references/cadenceux-pack/naming.md),
[patterns.md](references/cadenceux-pack/patterns.md) and
[advisory.md](references/cadenceux-pack/advisory.md). They are identical to the published pack.

Work out which situation you're in, once per session:

| Situation | How the conventions apply |
|---|---|
| **ADK in Claude Code** | Check `adk standards` in the project. If it follows no pack and the developer wants CadenceUX's conventions: install `cadenceux-filemaker-standards@cadenceux` if `adk standards list` lacks it, then `adk standards use cadenceux`. ADK's `filemaker-standards` skill then applies the layers; follow it. |
| **ADK in another harness** (Cursor, Codex, Gemini CLI) | Packs install only through Claude Code. Copy the three files from `references/cadenceux-pack/` into the project's `.adk/standards/` (ask first if files are already there). ADK reads them as the project's own rules. |
| **No ADK** (chat, FileMaker 26.0.3 or earlier) | Apply the pack files yourself, over the Baseline rules summarised in [references/baseline-summary.md](references/baseline-summary.md). |
| **A client with its own conventions** | Follow their pack or `.adk/standards/` files, not CadenceUX's. To write them one, see "Deriving a client's standards" below. |

Say which layers apply in your first reply about FileMaker work, and every open choice you
settled. **Generate with `naming.md` and `patterns.md`; use `advisory.md` only when reviewing**,
and call those points advisory.

## Writing a script

Copy this checklist and work through it:

```
Script progress:
- [ ] Standards resolved (which layers apply) and the header from "Script commenting headers"
- [ ] Name per the Scripts rules in naming.md (Domain: Action)
- [ ] Sections separated by blank lines, each with a one-line comment
- [ ] Every step that can fail followed by an error check (AnErrorOccurred)
- [ ] Parameters in as JSON; a JSON script result out, or "" when nothing to report
- [ ] Step and function syntax confirmed with claris-filemaker-pro (or ADK's engine)
- [ ] advisory.md anti-patterns avoided
- [ ] Delivered (ADK, or as steps for the developer) and read back
```

Worked patterns for error handling, variable scope, loops, sub-scripts, JSON parameters,
scripted finds, transactions, AI steps and custom functions are in
[references/scripting-patterns.md](references/scripting-patterns.md).

## Delivering scripts to the file

**With ADK:** write the script into the file through ADK (`fm-cli`, or the tool
`fm-mcp-guide` names), then close the loop:

1. Validate every calculation on ADK's engine before writing (`claris-filemaker-pro`'s ADK
   mode).
2. Write the script.
3. Read it back and compare it with the intended steps.
4. If anything differs, fix and repeat. Report done only when the read-back matches.

**Without ADK:** present the script as readable steps, in the format used throughout this skill,
for the developer to enter in Script Workspace, and mention that ADK can write it directly.
Never generate fmxmlsnippet or clipboard XML.

## Reviewing a script or a solution

Review against the layers that apply: `naming.md` and `patterns.md` as rules, `advisory.md` as
suggestions. Name the layer and the rule for each finding ("Pack naming.md, Scripts: Domain:
Action"). Standards change what is created and reviewed from now on; never rename or rewrite
existing objects unless the developer asks.

## Deriving a client's standards

When a client's solution has its own conventions, derive them rather than imposing
CadenceUX's. The method (through ADK on the live file, or from a Save a Copy as XML export
without ADK) is in [references/pattern-audit.md](references/pattern-audit.md). It ends with
draft `naming.md`, `patterns.md` and `advisory.md` text for the developer to accept, and then:

- **One project:** write the accepted rules into that project's `.adk/standards/` (create the
  files with `adk standards init`). Only rules that differ from the layers below.
- **Several projects:** a pack. `adk standards init --pack <name> --dir <folder>` writes the
  skeleton; ADK's `filemaker-standards` skill (its `authoring-packs.md`) covers publishing.
  The pack name is permanent once projects follow it.

Every rule must pass Claris's checklist before it goes in: one result when applied to an empty
file; never "consistent with the existing file"; a default for every choice; every category
that carries a rule defined; case, plurals, prefixes and separators stated in a sentence. Never
write a client's name or statistics into the CadenceUX pack.

## Platform differences

Steps unsupported on a client (FileMaker Go, WebDirect, Server, Data API) are skipped and return
error 3. Branch with `Get ( SystemPlatform )` or `Get ( Device )` where behaviour must differ;
check each step's support in `claris-filemaker-pro`.

## Old patterns

<details>
<summary>Configured design patterns in this file (retired in 3.0.0)</summary>

Versions 2.x kept the conventions in a "Configured design patterns" section here and asked two
setup questions each session. They now live in the `cadenceux` pack, which ADK applies in
layers; this skill's copy is `references/cadenceux-pack/`. See CHANGELOG 3.0.0.
</details>

<details>
<summary>Clipboard XML delivery (retired in 2.0.0)</summary>

Versions 1.x generated `fmxmlsnippet` XML for a manual paste into Script Workspace. ADK writes
to the file directly, so that path was removed.
</details>

## Skill update self-check

Once per session, on the first request this skill handles: fetch
`https://github.com/CadenceUX/fmp-dev-design-patterns/raw/main/VERSION` and compare it with
this skill's version (3.0.2). If newer, start the answer with:

> ⚠️ **Skill update available:** this skill is v[installed]; v[latest] is at
> https://github.com/CadenceUX/fmp-dev-design-patterns/releases

Skip silently if the fetch fails. If the skill was installed as a plugin, suggest
`claude plugin update` (or the Plugins page on claude.ai) instead. If `cadenceux-dx` is installed, skip this check: its stack check covers every CadenceUX skill.

## Relationship to other skills

- **ADK's `filemaker-standards`** owns how layers combine and the Baseline. This skill owns the
  CadenceUX layer and the method for deriving a client's. Where they disagree on how layers
  work, ADK's skill wins.
- **`cadenceux-filemaker-standards`** (the pack plugin) is the published copy of
  `references/cadenceux-pack/`. Change both in the same release; the pack's version moves with
  any rule change.
- **`claris-filemaker-pro`** owns step and function syntax and platform support.

## Licence

This skill is released under [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/).

Built and maintained by [Darrin Southern](https://www.linkedin.com/in/darrin-southern/) from [CadenceUX](https://cadenceux.com.au).
