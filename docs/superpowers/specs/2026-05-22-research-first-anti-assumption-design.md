# Research-First Anti-Assumption Design Spec

## Problem Statement

Superpowers skills and agents assume instead of discovering. Three categories of assumption:

1. **No mandatory discovery step** — no skill requires agents to discover the project's stack, patterns, or conventions before acting. "Explore project context" is soft guidance, not a hard gate.
2. **Hardcoded stack references** — shadcn/Tailwind/React hardcoded in 4 reviewer templates, 3 skill files. `cn()` and `className` appear as review criteria even for non-shadcn projects.
3. **Agent expertise treated as assumption** — 3 agent files (senior-frontend-engineer, data-engineer, devops-engineer) hardcode specific tools as the assumed stack instead of conditional expertise.

Additionally:
- No skill mandates domain research (web search for how similar features work) before designing
- Agents say "understand context" as a principle but never require specific discovery commands
- Industry research shows: mandatory read phase + assertion gates + hard constraints over soft guidance is the proven pattern (SWE-Agent, Devin, CrewAI, production postmortems)
- "A weaker model with great context outperforms a stronger model with poor context" — context engineering is at least as important as model selection

## Architecture

The fix has 3 components:

1. **Project Profile** — a structured discovery artifact produced by mandatory commands at session start, flows through the entire pipeline
2. **Research Gates** — every skill gets a research mandate appropriate to its role (tiered: heavy/medium/light/none)
3. **Stack-Adaptive References** — all hardcoded stack references replaced with profile-referenced patterns; agent expertise becomes conditional

All changes preserve existing pipeline flow (brainstorming → plans → execution). Research enriches decisions, doesn't add new phases.

## Component 1: Project Profile

### Purpose

Replace assumptions with detected reality. A structured artifact produced by mandatory discovery commands that every downstream skill and agent references.

### Profile Structure

```markdown
## Project Profile

### Stack
- Language: [detected from package.json/pyproject.toml/go.mod/Cargo.toml]
- Framework: [e.g., Next.js 14 / Django 5 / Express / none]
- UI library: [e.g., React / Vue / Svelte / none]
- Styling: [e.g., Tailwind CSS / CSS Modules / styled-components / vanilla CSS]
- Component library: [e.g., shadcn/ui / MUI / Chakra / Vuetify / none]
- State management: [e.g., Redux / Zustand / Pinia / built-in / none]
- Test framework: [e.g., Vitest / Jest / Pytest / Go test]
- Test runner command: [exact command from package.json scripts or config]
- Build tool: [e.g., Vite / Webpack / Turbopack / esbuild]

### Structure
- Source root: [e.g., src/ / app/ / lib/ / root]
- Components dir: [e.g., src/components/ / app/components/ / none]
- Test location: [e.g., __tests__/ colocated / tests/ at root]
- API routes: [e.g., src/app/api/ / pages/api/ / routes/ / none]
- Config files found: [list of relevant configs]

### Conventions (from existing code)
- Naming: [e.g., PascalCase components, camelCase functions, kebab-case files]
- Exports: [e.g., named exports / default exports / mixed]
- Component pattern: [e.g., functional with hooks / class / SFC]
- Composition: [e.g., className + cn() / styled() / sx prop / CSS modules]
- Import aliases: [e.g., @/ → src/ / ~/ → root / none]

### Existing Patterns (sampled from codebase)
- Example component: [path to a representative component]
- Example test: [path to a representative test]
- Example API route: [path if applicable]
```

### Adaptive Discovery Commands

Commands are adaptive — run what exists, skip what doesn't:

```bash
# Auto-detect project type
cat package.json 2>/dev/null | head -50        # Node/JS
cat pyproject.toml 2>/dev/null | head -30      # Python
cat go.mod 2>/dev/null | head -20              # Go
cat Cargo.toml 2>/dev/null | head -20          # Rust
cat Gemfile 2>/dev/null | head -20             # Ruby

# Framework-specific configs (run only what exists)
cat tsconfig.json 2>/dev/null | head -20
cat tailwind.config.* 2>/dev/null | head -30
cat next.config.* 2>/dev/null | head -20
cat vite.config.* 2>/dev/null | head -20

# Structure
find . -maxdepth 3 -type d -not -path '*/node_modules/*' -not -path '*/.git/*' -not -path '*/venv/*' | head -40

# Recent activity
git log --oneline -10

# Test infrastructure
grep -r "test\|spec\|vitest\|jest\|pytest" package.json pyproject.toml Makefile 2>/dev/null | head -10
cat package.json 2>/dev/null | grep -A5 '"scripts"'

# Convention sampling — from source dirs, not random files
ls src/components/ 2>/dev/null || ls components/ 2>/dev/null || ls app/components/ 2>/dev/null || ls lib/ 2>/dev/null
```

### Compact Form (for subagent dispatch)

Under 100 words, included in implementer/teammate prompts:

```
Stack: Next.js 14, React, TypeScript, Tailwind CSS, shadcn/ui, Vitest
Structure: src/components/, src/app/api/, colocated tests
Conventions: PascalCase components, named exports, cn() composition, @/ alias
Auth: JWT via next-auth, session in cookies
Data fetching: server components + react-query for client mutations
Test command: npm run test
```

Note: auth pattern and data-fetching approach are critical for implementers touching any data flow — include them in the compact form when detected.

### Where It Lives

- **Working memory** during the session — not a file on disk
- **Embedded in specs** under `## Project Context` for cross-session persistence
- **Compact form in implementer prompts** for subagent dispatch

### Rules

1. **Never assume what you can detect** — if a discovery command can answer it, run it
2. **State what you found with evidence** — after discovery, state "This project uses X" with the file path or command output that proves it. Each finding must include: tool name + version/variant + one project-specific pattern observed. "Uses React" doesn't count. "React 18 with App Router, components in src/components/ use server components" does.
3. **Profile overrides defaults** — if Profile says "CSS Modules," use CSS Modules even if a skill example shows Tailwind
4. **User intent overrides Profile** — if user says "build this in Vue" but Profile detects React, user wins. Update Profile accordingly.
5. **Missing = ask** — if discovery can't determine something, ask the user instead of guessing
6. **Empty project = ask** — if all discovery commands return empty, state "no existing project detected" and ask the user what stack they intend to use. Don't silently produce an empty Profile.
7. **Monorepo = ask** — if multiple package manifests found (e.g., `packages/web/package.json`, `packages/api/package.json`), ask user which package is in scope before building Profile.
8. **Skip when already discovered** — if Project Profile was already established in this session (from brainstorming or a previous task), skip discovery. Don't re-discover what's already known.

### Precedence Chain

Single authoritative hierarchy across all specs:

```
User intent (highest)
  > DESIGN.md (prescribed design intent)
    > Design Ledger (per-feature visual decisions)
      > Project Profile (detected codebase reality)
        > Skill defaults (lowest — never override any of the above)
```

- **Project Profile** = what IS (detected from codebase)
- **DESIGN.md** = what SHOULD BE (prescribed design intent)
- **Design Ledger** = what THIS FEATURE needs (per-feature brainstorming decisions)
- If any layer conflicts with a higher layer, the higher layer wins

## Component 2: Research Gates

### Purpose

Every skill gets a research mandate appropriate to its role. Two types of research: project research (codebase exploration) and domain research (web search for how similar features work).

### Research Tiers

| Tier | Skills | Project research | Domain research |
|---|---|---|---|
| **Heavy** | brainstorming, implementers | Full Profile + existing pattern scan (under 60s) | Web search for feature patterns (best effort, cap 5 min). If web search unavailable, skip and note in assertion gate. |
| **Medium** | writing-plans, TDD, systematic-debugging | Read Profile from spec + check patterns | Web search for unfamiliar errors/patterns |
| **Light** | spec-reviewer, code-quality-reviewer, receiving-code-review, verification-before-completion | Verify against Profile in spec | None |
| **None** | finishing-branch, git-worktrees, using-superpowers, dispatching-parallel-agents, requesting-code-review, writing-skills | No change | No change |

### Brainstorming: Revised Step 1

Replace existing Step 1 ("Explore project context — check files, docs, recent commits") with the following. This supersedes the original Step 1 and incorporates the project discovery that was previously a soft suggestion:

```markdown
1. **Explore project context and research the domain**
   
   **Phase A — Project Discovery (mandatory):**
   Run discovery commands to build the Project Profile. Detect stack, structure, 
   conventions, existing patterns. State what you found with evidence.
   
   After discovery, check if project involves UI work (frontend files detected + 
   user request involves visual output). If yes, create Design Ledger per the 
   Design Ledger section below. This preserves the frontend awareness pipeline.
   
   **Phase B — Domain Research (for non-trivial features):**
   Before asking design questions, research how the feature you're about to design 
   works in comparable products and codebases:
   - Search the web for how similar features are typically designed and implemented
   - Search the codebase for related existing features
   - Look at recent git history for related work in progress
   
   **Skip domain research ONLY when:** You can link to a specific file in this 
   codebase that implements the same feature type with the same interaction model. 
   "We have a table component" does NOT justify skipping research for a dashboard 
   chart feature. If you can't point to an exact match, research.
   
   **Research time:** Project discovery under 60 seconds. Domain research best 
   effort, cap at 5 minutes. If web search is unavailable (sandboxed/offline), 
   skip domain research and note it in the assertion gate.
   
   **Assertion gate:** Before asking your first design question, state:
   - "Project uses: [stack summary — with evidence]"
   - "Related existing features: [what you found in codebase]"  
   - "Domain research: [what you learned about how this feature typically works]"
   
   Each category needs at least one specific, actionable finding. 
   "Uses React" doesn't count. "React 18 with App Router, existing components 
   use server components with client islands" does.
   
   If any category is blank, you haven't done enough research. Go back.
```

### Spec Template: New Mandatory Sections

Every spec gets two new sections before design content:

```markdown
## Project Context

[Compact Project Profile — stack, structure, conventions]

## Research Findings

### Domain Research
- [How similar features work in comparable products]
- [Key patterns, trade-offs, common approaches discovered]

### Codebase Research  
- [Existing related features found in this project]
- [Patterns that should be followed or extended]
- [Recent related work in git history]
```

These flow through the pipeline — writing-plans reads them, implementers receive compact Profile, reviewers verify against discovered patterns.

### Writing-Plans: Research Mandate

```markdown
Before defining tasks:
1. Read `## Project Context` and `## Research Findings` from the spec
2. Scan for existing code patterns related to this feature
3. Use the detected stack for task examples — not hardcoded frameworks
4. Match test framework, file structure, and conventions to the Profile
```

### Implementers: Research Before Coding

Add to implementer prompt template. Section order in the final template: `## Context → ## Project Profile → ## Design Context (if ledger) → ## Before You Begin`.

```markdown
## Project Profile

[Compact form — stack, structure, conventions, test command]

## Before You Begin

Before writing any new code:
1. Search the codebase for existing similar code
2. Read at least one existing component/module in the same area
3. Match the patterns you find — imports, naming, structure, composition
4. State what patterns you found: "Existing code in this area uses ___"

If you can't find similar code, ask for guidance. Don't invent patterns.
```

### TDD: Research Before Testing

```markdown
Before writing tests:
1. Check what test framework the project uses (from Project Profile)
2. Read an existing test file in the project — match its style
3. Use the project's test runner command, not a hardcoded one
```

### Systematic Debugging: Research Before Fixing

```markdown
For unfamiliar errors:
1. Search the web for the exact error message before proposing fixes
2. Check if this error has been encountered before in this project (git log)
3. Read framework documentation for the specific API causing the error
```

### Reviewers: Verify Against Profile

```markdown
Check implementation against discovered patterns:
1. Read `## Project Context` from the spec
2. Verify code follows the project's conventions (from Profile), not generic defaults
3. If Profile doesn't specify a convention, check existing code for the pattern
4. If neither Profile nor existing code establishes a pattern, skip the check
```

### The Assertion Gate Pattern

Universal pattern applied everywhere:

```
BEFORE acting:
  1. RESEARCH: Run discovery commands / search codebase / search web
  2. STATE: "I found: [specific findings with evidence]"
  3. VERIFY: Does what I found match what I'm about to do?
  4. ACT: Proceed with research-informed action

If RESEARCH returns nothing:
  ASK the user. Never guess.
```

Hard gate — "I didn't check but I'm pretty sure" is a violation.

## Component 3: Stack-Adaptive References

### Purpose

Replace every hardcoded stack reference with a pattern that defers to the Project Profile or Design Ledger.

### Replacement Pattern

```markdown
# BEFORE (hardcoded)
- Does the component accept className and use cn() for composition?

# AFTER (profile-referenced)
- Does the component follow the composition pattern from the Project Profile?
```

### Skill File Replacements

| File | Hardcoded | Replacement |
|---|---|---|
| `spec-reviewer-prompt.md` | "accept className and use cn() for shadcn composition" | "follow the composition pattern identified in the Project Profile. If no pattern identified, check existing components. If none found, skip." |
| `code-quality-reviewer-prompt.md` | "follow shadcn composition (className prop, cn())" | "follow the project's composition pattern (per Project Profile)" |
| `implementer-prompt.md` | self-review: "accept className and use cn()" | "follow the project's component composition pattern" |
| `team-implementer-prompt.md` | self-review: "className/cn() composition" | "project's composition pattern" |
| `brainstorming/SKILL.md` | Design Ledger "shadcn/ui Conventions" with `cn()`, `cva()` | Rename to "Component Library Conventions" — placeholders become `[discovered from codebase]` |
| `writing-plans/SKILL.md` | Frontend decomposition with `cn()`, `@/lib/utils`, React imports | Make template stack-agnostic with `[from Profile]` markers. Label React example as "example output for React projects" |
| `frontend-design-context/SKILL.md` | DESIGN.md template with Tailwind names, shadcn conventions | Add: "Use actual values discovered from Project Profile, not these defaults." Genericize placeholders. |
| `test-driven-development/SKILL.md` | React/Vitest component example | Prefix: "This shows React/Vitest. Discover your project's stack first. RED-GREEN-REFACTOR is universal; imports and APIs adapt to your stack." |

### Agent File Changes

**Universal Agent Preamble — added to all 12 agents:**

```markdown
## Before You Begin

**If Project Profile already established in this session** (from brainstorming, a 
previous task, or the controller's dispatch context), skip to "Your Job." Don't 
re-discover what's already known.

**Otherwise, discover the project:**
1. **Run discovery commands** — check config files, package manifests, existing code (see discovery targets for your domain below)
2. **State what you found** — "This project uses [X] for [purpose]" with evidence (file path or command output)
3. **Match existing patterns** — follow conventions already established in the codebase
4. **Never assume** — if you can't determine something from the codebase, ask

Your expertise below applies WHEN the project matches. If the project uses a different 
stack, adapt to what's discovered.
```

Each agent gets discovery targets specific to its domain:

| Agent | Discovery targets |
|---|---|
| senior-frontend-engineer | `package.json` (UI framework), component dirs, styling config, state management |
| senior-backend-architect | API framework, database config, service structure, middleware patterns |
| data-engineer | Pipeline configs, database connections, existing ETL/ELT code, scheduler setup |
| devops-engineer | CI configs (`.github/workflows/`), Dockerfiles, IaC dirs (`terraform/`, `pulumi/`), cloud provider |
| mobile-engineer | Mobile framework config, navigation library, native module setup |
| qa-engineer | Test config, existing test patterns, CI test commands |
| ui-ux-designer | Existing UI components, design tokens, theme config, accessibility setup |
| security-engineer | Auth config, dependency audit setup, secret management |
| code-reviewer | PR context, project conventions from CLAUDE.md or equivalent |
| product-manager | Existing feature inventory, issue tracker, stakeholder docs |
| technical-writer | Existing docs structure, API docs format, audience docs |
| helpnest-author | Already research-first — no changes needed |

**3 agents get deeper restructuring:**

**Restructuring principle:** The general/adaptive section MUST be the PRIMARY section — equally detailed, not a sparse fallback. Stack-specific sections are SUPPLEMENTS that add depth when the project matches. This prevents agents from defaulting to the richer stack-specific section just because it has more content.

**`senior-frontend-engineer.md`:**
```markdown
## Core Frontend Expertise (always apply)
[Comprehensive general frontend guidance — component architecture, state management 
principles, styling patterns, testing, performance, a11y. This section must be 
equally detailed as any stack-specific supplement.]

## React/Next.js Supplement (apply ONLY IF Project Profile detects React)
[existing React/HeroUI/Redux-Saga content — SUPPLEMENTS core, doesn't replace it]
```

**`data-engineer.md`:**
```markdown
## Core Data Engineering (always apply)
[Pipeline design principles, data modeling, quality checks, monitoring. 
Equally detailed as any tool supplement.]

## Tool Supplements (apply matching tools from Project Profile)
### dbt: [existing dbt content]
### Airflow: [existing Airflow content]
### Spark: [existing Spark content]
```

**`devops-engineer.md`:**
```markdown
## Core DevOps (always apply)
[CI/CD principles, deployment strategies, monitoring, security hardening.
Equally detailed as any tool supplement.]

## Tool Supplements (apply matching tools from Project Profile)
### Kubernetes: [existing K8s content]
### Terraform: [existing Terraform content]
```

## Files Changed

### Skills (9 files)

| File | Change |
|---|---|
| `skills/brainstorming/SKILL.md` | Replace Step 1 with two-phase discovery + domain research. Add assertion gate. Add `## Project Context` and `## Research Findings` to spec template. Rename "shadcn/ui Conventions" → "Component Library Conventions" with generic placeholders. |
| `skills/writing-plans/SKILL.md` | Add Project Profile preamble to frontend task decomposition. Make template stack-agnostic. Label React example as one possible output. |
| `skills/test-driven-development/SKILL.md` | Add stack-discovery prefix to component example. |
| `skills/systematic-debugging/SKILL.md` | Add domain research step: web search for unfamiliar errors before proposing fixes. |
| `skills/frontend-design-context/SKILL.md` | Genericize DESIGN.md template placeholders. Add "use discovered values" note. |
| `skills/subagent-driven-development/implementer-prompt.md` | Add `## Project Profile` field. Replace hardcoded composition references. Add "search for existing similar code" mandate. |
| `skills/subagent-driven-development/spec-reviewer-prompt.md` | Replace "shadcn composition" with "project's composition pattern per Profile" + fallback chain. |
| `skills/subagent-driven-development/code-quality-reviewer-prompt.md` | Replace "shadcn composition" with "project's composition pattern." |
| `skills/team-driven-development/team-implementer-prompt.md` | Add `## Project Profile` field. Replace hardcoded composition references. |

### Agents (12 files)

| File | Change |
|---|---|
| All 12 in `~/.claude/agents/` | Add Universal Agent Preamble with agent-specific discovery targets |
| `senior-frontend-engineer.md` | Restructure: React/HeroUI/Redux-Saga become conditional |
| `data-engineer.md` | Restructure: dbt/Airflow/Spark become conditional |
| `devops-engineer.md` | Restructure: Kubernetes/Terraform become conditional |

### Files NOT Changed

| File | Why |
|---|---|
| `finishing-a-development-branch/SKILL.md` | Workflow — no assumptions |
| `using-git-worktrees/SKILL.md` | Git — stack-agnostic |
| `using-superpowers/SKILL.md` | Bootstrap — already adaptive |
| `dispatching-parallel-agents/SKILL.md` | Coordination — no assumptions |
| `requesting-code-review/SKILL.md` | Process — template-based |
| `receiving-code-review/SKILL.md` | Process — already adaptive |
| `verification-before-completion/SKILL.md` | Gate — domain-agnostic |
| `writing-skills/SKILL.md` | Meta — no assumptions |
| `writing-plans/plan-document-reviewer-prompt.md` | Already checks Profile from frontend awareness spec |

## Non-Goals

- Not creating a persistent Project Profile file on disk (working memory artifact, embedded in specs)
- Not building automated stack detection tooling (manual commands interpreted by agent)
- Not removing agent expertise (stays as conditional knowledge)
- Not changing pipeline sequence (brainstorming → plans → execution stays same). Discovery and research are additive enrichment within existing steps, not new pipeline stages.
- Not making every skill do web research (tiered: only heavy-tier skills do domain research)

## Open Questions

1. **Profile persistence between sessions** — currently embedded in spec's `## Project Context`. If a session doesn't produce a spec (e.g., quick debugging), the Profile is lost. Acceptable since discovery is fast (under 60s) and re-running is cheap.
2. **Phasing option** — Component 3 (stack-adaptive references) is pure string substitution with zero behavioral risk. Components 1+2 (Profile + Research Gates) change how agents behave. These could ship separately: mechanical cleanup first, behavioral changes second. Worth considering if 21 files in one PR feels too large.
