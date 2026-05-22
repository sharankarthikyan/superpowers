# Research-First Anti-Assumption Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended), superpowers:team-driven-development (for 3+ parallel tracks), or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make superpowers skills and agents research-first by adding mandatory discovery, research gates, and replacing hardcoded stack references with profile-referenced patterns.

**Architecture:** Phase 1 applies mechanical string replacements (zero behavioral risk). Phase 2 adds Project Profile and research gates (behavioral changes). Phase 3 updates agent files with preamble and conditional expertise. Each phase produces independent, shippable commits.

**Tech Stack:** Markdown skill files, agent definition files

**Spec:** `docs/superpowers/specs/2026-05-22-research-first-anti-assumption-design.md`

---

## File Structure

### Phase 1: Stack-Adaptive References (9 skill files)

| File | Action | Change |
|---|---|---|
| `skills/subagent-driven-development/spec-reviewer-prompt.md` | Modify | Replace shadcn reference with profile-referenced |
| `skills/subagent-driven-development/code-quality-reviewer-prompt.md` | Modify | Replace shadcn references with profile-referenced |
| `skills/subagent-driven-development/implementer-prompt.md` | Modify | Replace shadcn in self-review with profile-referenced |
| `skills/team-driven-development/team-implementer-prompt.md` | Modify | Replace shadcn in self-review with profile-referenced |
| `skills/brainstorming/SKILL.md` | Modify | Rename "shadcn/ui Conventions" → "Component Library Conventions" |
| `skills/writing-plans/SKILL.md` | Modify | Label React example, add stack-agnostic markers |
| `skills/test-driven-development/SKILL.md` | Modify | Add stack-discovery prefix to component example |
| `skills/frontend-design-context/SKILL.md` | Modify | Genericize DESIGN.md template placeholders |
| `skills/systematic-debugging/SKILL.md` | Modify | Add domain research for unfamiliar errors |

### Phase 2: Project Profile + Research Gates (5 skill files)

| File | Action | Change |
|---|---|---|
| `skills/brainstorming/SKILL.md` | Modify | Replace Step 1, add spec template sections |
| `skills/writing-plans/SKILL.md` | Modify | Add research mandate preamble |
| `skills/subagent-driven-development/implementer-prompt.md` | Modify | Add Project Profile field + codebase search mandate |
| `skills/team-driven-development/team-implementer-prompt.md` | Modify | Add Project Profile field |
| `skills/test-driven-development/SKILL.md` | Modify | Add research-before-testing mandate |

### Phase 3: Agent Files (12 files)

| File | Action | Change |
|---|---|---|
| All 12 in `~/.claude/agents/` | Modify | Add Universal Agent Preamble |
| `~/.claude/agents/senior-frontend-engineer.md` | Modify | Restructure: core + React supplement |
| `~/.claude/agents/data-engineer.md` | Modify | Restructure: core + tool supplements |
| `~/.claude/agents/devops-engineer.md` | Modify | Restructure: core + tool supplements |

---

### Task 1: Replace hardcoded shadcn in reviewer templates

**Files:**
- Modify: `skills/subagent-driven-development/spec-reviewer-prompt.md:68`
- Modify: `skills/subagent-driven-development/code-quality-reviewer-prompt.md:26`

- [ ] **Step 1: Replace shadcn reference in spec-reviewer-prompt.md**

In `skills/subagent-driven-development/spec-reviewer-prompt.md`, find line 68:

```
    - Do components accept className and use cn() for shadcn composition?
```

Replace with:

```
    - Do components follow the composition pattern identified in the Project Profile? If no pattern identified, check existing components. If none found, skip.
```

- [ ] **Step 2: Replace shadcn reference in code-quality-reviewer-prompt.md**

In `skills/subagent-driven-development/code-quality-reviewer-prompt.md`, find line 26:

```
- If spec contains `## Design Ledger`: Do components follow shadcn composition (className prop, cn())?
```

Replace with:

```
- If spec contains `## Design Ledger`: Do components follow the project's composition pattern (per Project Profile)? If no pattern in Profile, check existing components.
```

- [ ] **Step 3: Verify**

```bash
grep -n "shadcn" skills/subagent-driven-development/spec-reviewer-prompt.md skills/subagent-driven-development/code-quality-reviewer-prompt.md
```

Expected: no matches.

- [ ] **Step 4: Commit**

```bash
git add skills/subagent-driven-development/spec-reviewer-prompt.md skills/subagent-driven-development/code-quality-reviewer-prompt.md
git commit -m "refactor(sdd): replace hardcoded shadcn references with profile-referenced patterns in reviewers"
```

---

### Task 2: Replace hardcoded shadcn in implementer self-reviews

**Files:**
- Modify: `skills/subagent-driven-development/implementer-prompt.md:111`
- Modify: `skills/team-driven-development/team-implementer-prompt.md:115`

- [ ] **Step 1: Replace in implementer-prompt.md**

Find line 111:

```
    - Does the component accept className and use cn() for composition?
```

Replace with:

```
    - Does the component follow the project's composition pattern (per Project Profile)?
```

- [ ] **Step 2: Replace in team-implementer-prompt.md**

Find line 115:

```
  - Does the component accept className and use cn() for composition?
```

Replace with:

```
  - Does the component follow the project's composition pattern (per Project Profile)?
```

- [ ] **Step 3: Verify**

```bash
grep -n "cn()" skills/subagent-driven-development/implementer-prompt.md skills/team-driven-development/team-implementer-prompt.md
```

Expected: no matches in self-review sections (may still appear in Design Context examples, which is fine — those come from the actual project's ledger).

- [ ] **Step 4: Commit**

```bash
git add skills/subagent-driven-development/implementer-prompt.md skills/team-driven-development/team-implementer-prompt.md
git commit -m "refactor(sdd): replace hardcoded cn()/className in implementer self-reviews with profile reference"
```

---

### Task 3: Rename Design Ledger's shadcn section in brainstorming

**Files:**
- Modify: `skills/brainstorming/SKILL.md:176-179`

- [ ] **Step 1: Rename section and genericize placeholders**

Find lines 176-179:

```
### shadcn/ui Conventions
- Installed components: [list]
- Extension pattern: [cva() in component file]
- Composition: [accept className, use cn()]
```

Replace with:

```
### Component Library Conventions
- Library: [discovered from codebase, e.g., shadcn/ui, MUI, Chakra, Vuetify]
- Installed components: [discovered — list what exists]
- Extension pattern: [discovered — how project extends base components]
- Composition: [discovered — how components accept customization]
```

- [ ] **Step 2: Verify**

```bash
grep -n "shadcn" skills/brainstorming/SKILL.md
```

Expected: no matches (the word "shadcn" should only appear as an example value in the replacement, inside brackets).

- [ ] **Step 3: Commit**

```bash
git add skills/brainstorming/SKILL.md
git commit -m "refactor(brainstorming): rename shadcn/ui Conventions to Component Library Conventions with generic placeholders"
```

---

### Task 4: Make writing-plans frontend decomposition stack-agnostic

**Files:**
- Modify: `skills/writing-plans/SKILL.md`

- [ ] **Step 1: Add stack-agnostic preamble to Frontend Task Decomposition section**

Find the line:

```
Key differences from generic template: UX Intent in design context, tests for ALL states written before implementation (Step 2), `className`/`cn()` composition, integration wiring step (Step 10), micro-copy from ledger.
```

Replace with:

```
Key differences from generic template: UX Intent in design context, tests for ALL states written before implementation (Step 2), project's composition pattern, integration wiring step (Step 10), micro-copy from ledger.

**Stack adaptation:** The example above shows React/Vitest/shadcn as one possible output. Adapt to the project's detected stack from the Project Profile: use the project's test framework, component patterns, styling approach, and composition conventions. RED-GREEN-REFACTOR is universal; specific imports and APIs adapt to the project.
```

- [ ] **Step 2: Commit**

```bash
git add skills/writing-plans/SKILL.md
git commit -m "refactor(writing-plans): add stack-adaptation note to frontend task decomposition"
```

---

### Task 5: Add stack-discovery prefix to TDD component example

**Files:**
- Modify: `skills/test-driven-development/SKILL.md`

- [ ] **Step 1: Add prefix before the component example**

Find the line:

```
## Example: Component with States (React)
```

Replace with:

```
## Example: Component with States (React)

> **Stack note:** This example shows React/Vitest/shadcn. Before writing component tests, discover your project's stack first: check the test config, read an existing test file, and match its patterns. The RED-GREEN-REFACTOR cycle below is universal — the specific imports and APIs adapt to your project.
```

- [ ] **Step 2: Commit**

```bash
git add skills/test-driven-development/SKILL.md
git commit -m "refactor(tdd): add stack-discovery prefix to React component example"
```

---

### Task 6: Genericize frontend-design-context DESIGN.md template

**Files:**
- Modify: `skills/frontend-design-context/SKILL.md`

- [ ] **Step 1: Add discovery note to DESIGN.md template section**

Find the line:

```
### DESIGN.md Template
```

Add immediately after it:

```

> **Important:** When creating DESIGN.md interactively, populate values from the Project Profile (discovered from the actual codebase), not from the generic defaults shown below. The template shows common examples — your project's actual values may differ.

```

- [ ] **Step 2: Commit**

```bash
git add skills/frontend-design-context/SKILL.md
git commit -m "refactor(frontend-design-context): add discovery note to DESIGN.md template"
```

---

### Task 7: Add domain research to systematic-debugging

**Files:**
- Modify: `skills/systematic-debugging/SKILL.md`

- [ ] **Step 1: Add domain research step**

Find the `### Phase 2: Pattern Analysis` heading. Insert the following immediately BEFORE it:

```markdown

7. **Domain Research for Unfamiliar Errors**

   **WHEN the error message or behavior is unfamiliar:**

   ```
   1. Search the web for the exact error message before proposing fixes
   2. Check if this error has been encountered before in this project (git log --grep)
   3. Read framework documentation for the specific API causing the error
   4. State what you found: "This error typically means ___ and is caused by ___"
   ```

   Do NOT guess at fixes for errors you haven't seen before. Research first.

```

- [ ] **Step 2: Verify**

```bash
grep "Domain Research for Unfamiliar" skills/systematic-debugging/SKILL.md
```

- [ ] **Step 3: Commit**

```bash
git add skills/systematic-debugging/SKILL.md
git commit -m "feat(debugging): add domain research step for unfamiliar errors"
```

---

### Task 8: Replace brainstorming Step 1 with two-phase discovery

**Files:**
- Modify: `skills/brainstorming/SKILL.md:24`

This is the biggest single change. It replaces the soft "explore project context" with mandatory discovery + domain research + assertion gates.

- [ ] **Step 1: Replace Step 1 in the checklist**

Find line 24:

```
1. **Explore project context** — check files, docs, recent commits
```

Replace with:

```
1. **Discover project and research the domain** — mandatory discovery + domain research before any design questions (see "Project Discovery and Research" section below)
```

- [ ] **Step 2: Add the Project Discovery and Research section**

Insert the following new section immediately BEFORE `## Design Ledger`:

```markdown
## Project Discovery and Research

**This replaces the previous soft "explore project context" step with a mandatory two-phase process.**

### Phase A — Project Discovery (mandatory, under 60 seconds)

Run adaptive discovery commands to build a Project Profile:

```bash
# Auto-detect project type — run what exists, skip what doesn't
cat package.json 2>/dev/null | head -50
cat pyproject.toml 2>/dev/null | head -30
cat go.mod 2>/dev/null | head -20
cat Cargo.toml 2>/dev/null | head -20
cat tsconfig.json 2>/dev/null | head -20
cat tailwind.config.* 2>/dev/null | head -30
cat next.config.* 2>/dev/null | head -20
cat vite.config.* 2>/dev/null | head -20
find . -maxdepth 3 -type d -not -path '*/node_modules/*' -not -path '*/.git/*' -not -path '*/venv/*' | head -40
git log --oneline -10
cat package.json 2>/dev/null | grep -A5 '"scripts"'
ls src/components/ 2>/dev/null || ls components/ 2>/dev/null || ls app/components/ 2>/dev/null || ls lib/ 2>/dev/null
```

From the output, build a **Project Profile** capturing: stack (language, framework, UI library, styling, component library, test framework, test command), structure (source root, component dirs, test location), and conventions (naming, exports, composition patterns, import aliases).

**Empty project:** If all commands return empty, state "no existing project detected" and ask the user what stack they intend to use.

**Monorepo:** If multiple package manifests found, ask user which package is in scope.

After discovery, check if project involves UI work (frontend files + user request involves visual output). If yes, create Design Ledger per the section below.

### Phase B — Domain Research (for non-trivial features, cap 5 minutes)

Before asking design questions, research how the feature works elsewhere:

- Search the web for how similar features are typically designed and implemented
- Search the codebase for related existing features
- Look at recent git history for related work in progress

**Skip domain research ONLY when:** You can link to a specific file in this codebase that implements the same feature type with the same interaction model. "We have a table component" does NOT justify skipping for a chart feature.

**If web search unavailable** (sandboxed/offline): skip domain research, note it in the assertion gate.

### Assertion Gate

**Before asking your first design question, state:**

- "**Project uses:** [stack summary — with evidence: file path or command output]"
- "**Related existing features:** [what you found in codebase, with file paths]"
- "**Domain research:** [what you learned about how this feature typically works, with sources]"

**Minimum specificity:** Each finding must include tool name + version/variant + one project-specific pattern observed. "Uses React" doesn't count. "React 18 with App Router, components in src/components/ use server components" does.

If any category is blank and you haven't skipped it per the rules above, you haven't done enough research. Go back.

### Spec Template Additions

Every spec includes these sections before the design content:

```
## Project Context

[Compact Project Profile — stack, structure, conventions, auth pattern, data-fetching approach]

## Research Findings

### Domain Research
- [How similar features work in comparable products — with sources]
- [Key patterns, trade-offs, common approaches discovered]

### Codebase Research
- [Existing related features found in this project — with file paths]
- [Patterns that should be followed or extended]
- [Recent related work in git history]
```

These flow through the pipeline: writing-plans reads them, implementers receive the compact Profile, reviewers verify against discovered patterns.

### Precedence Chain

When sources conflict, follow this hierarchy:

```
User intent (highest)
  > DESIGN.md (prescribed design intent)
    > Design Ledger (per-feature visual decisions)
      > Project Profile (detected codebase reality)
        > Skill defaults (lowest)
```

```

- [ ] **Step 3: Verify**

```bash
grep "Project Discovery and Research" skills/brainstorming/SKILL.md
grep "Assertion Gate" skills/brainstorming/SKILL.md
grep "Precedence Chain" skills/brainstorming/SKILL.md
```

All three should match.

- [ ] **Step 4: Commit**

```bash
git add skills/brainstorming/SKILL.md
git commit -m "feat(brainstorming): replace Step 1 with mandatory two-phase discovery and domain research"
```

---

### Task 9: Add Project Profile field to implementer prompts

**Files:**
- Modify: `skills/subagent-driven-development/implementer-prompt.md`
- Modify: `skills/team-driven-development/team-implementer-prompt.md`

- [ ] **Step 1: Add Project Profile to SDD implementer**

In `skills/subagent-driven-development/implementer-prompt.md`, find:

```
    ## Design Context (if spec contains `## Design Ledger`)
```

Insert the following BEFORE it (after the `## Context` placeholder line):

```

    ## Project Profile

    [Compact form from spec's Project Context — stack, structure, conventions, 
    test command, auth pattern, data-fetching approach]

    Match these conventions in your implementation. Use the test command shown 
    here, not a guessed one.

```

- [ ] **Step 2: Add codebase search mandate to Before You Begin**

In the same file, find `## Before You Begin`. Add to the beginning of that section:

```

    Before writing any new code:
    1. Search the codebase for existing similar code in the area you're working
    2. Read at least one existing component/module nearby — match its patterns
    3. State what you found: "Existing code in this area uses ___"
    If you can't find similar code, ask for guidance. Don't invent patterns.

```

- [ ] **Step 3: Add Project Profile to team implementer**

In `skills/team-driven-development/team-implementer-prompt.md`, find:

```
## Design Context (if spec contains `## Design Ledger`)
```

Insert the following BEFORE it:

```markdown

## Project Profile

[Compact form — stack, structure, conventions, test command]

Match these conventions in your implementation.

```

- [ ] **Step 4: Verify section ordering**

```bash
grep -n "## Context\|## Project Profile\|## Design Context\|## Before You Begin" skills/subagent-driven-development/implementer-prompt.md
```

Expected order: Context → Project Profile → Design Context → Before You Begin.

- [ ] **Step 5: Commit**

```bash
git add skills/subagent-driven-development/implementer-prompt.md skills/team-driven-development/team-implementer-prompt.md
git commit -m "feat(sdd): add Project Profile field and codebase search mandate to implementer prompts"
```

---

### Task 10: Add research mandates to writing-plans and TDD

**Files:**
- Modify: `skills/writing-plans/SKILL.md`
- Modify: `skills/test-driven-development/SKILL.md`

- [ ] **Step 1: Add research preamble to writing-plans**

In `skills/writing-plans/SKILL.md`, find `## File Structure`. Insert the following BEFORE it:

```markdown
## Research Before Planning

Before defining tasks:

1. Read `## Project Context` and `## Research Findings` from the spec
2. Scan the codebase for existing patterns related to this feature
3. Use the detected stack for task examples — not hardcoded frameworks
4. Match test framework, file structure, and conventions to the Project Profile

If the spec has no `## Project Context`, run discovery commands yourself (see brainstorming skill's "Project Discovery and Research" section) before writing tasks.

```

- [ ] **Step 2: Add research-before-testing to TDD**

In `skills/test-driven-development/SKILL.md`, find `### RED - Write Failing Test`. Insert the following BEFORE it:

```markdown
### Research Before Testing

Before writing your first test:

1. Check what test framework the project uses — look at existing test files, package.json scripts, or config files
2. Read at least one existing test file in the project — match its style (imports, assertion syntax, file naming)
3. Use the project's test runner command (from Project Profile or package.json), not a hardcoded one

Never assume Vitest/Jest/Pytest. Discover what's configured.

```

- [ ] **Step 3: Commit**

```bash
git add skills/writing-plans/SKILL.md skills/test-driven-development/SKILL.md
git commit -m "feat: add research mandates to writing-plans and TDD skills"
```

---

### Task 11: Add Universal Agent Preamble to all 12 agents

**Files:**
- Modify: all 12 files in `~/.claude/agents/`

For each agent file, add the Universal Agent Preamble immediately after the YAML frontmatter closing `---`, before the existing content. The preamble is the same for all agents except the discovery targets line.

- [ ] **Step 1: Add preamble to each agent**

For each of the 12 files in `~/.claude/agents/`, insert this block after the YAML frontmatter `---`:

```markdown

## Before You Begin

**If Project Profile already established in this session** (from brainstorming, a previous task, or the controller's dispatch context), skip to your main job below. Don't re-discover what's already known.

**Otherwise, discover the project:**
1. **Run discovery commands** — check config files, package manifests, existing code
2. **State what you found** — "This project uses [X] for [purpose]" with evidence (file path or command output)
3. **Match existing patterns** — follow conventions already established in the codebase
4. **Never assume** — if you can't determine something from the codebase, ask

Your expertise below applies WHEN the project matches. If the project uses a different stack, adapt to what's discovered.

**Discovery targets for this role:**
```

Then add agent-specific discovery targets:

| Agent file | Discovery targets line |
|---|---|
| `senior-frontend-engineer.md` | `- Check: package.json (UI framework), component dirs, styling config (tailwind/CSS modules), state management` |
| `senior-backend-architect.md` | `- Check: API framework config, database config, service structure, middleware patterns` |
| `data-engineer.md` | `- Check: pipeline configs, database connections, existing ETL/ELT code, scheduler setup` |
| `devops-engineer.md` | `- Check: CI configs (.github/workflows/), Dockerfiles, IaC dirs (terraform/, pulumi/), cloud provider` |
| `mobile-engineer.md` | `- Check: mobile framework config, navigation library, native module setup` |
| `qa-engineer.md` | `- Check: test config, existing test patterns, CI test commands, package.json scripts` |
| `ui-ux-designer.md` | `- Check: existing UI components, design tokens/theme config, accessibility setup` |
| `security-engineer.md` | `- Check: auth config, dependency audit setup, secret management patterns` |
| `code-reviewer.md` | `- Check: PR context, project conventions from CLAUDE.md, existing code patterns` |
| `product-manager.md` | `- Check: existing feature inventory, docs structure, issue tracker references` |
| `technical-writer.md` | `- Check: existing docs structure, API docs format, audience documentation` |
| `helpnest-author.md` | `- Already research-first. Check: HelpNest workspace, existing articles, code for content grounding` |

- [ ] **Step 2: Verify all agents have the preamble**

```bash
for f in ~/.claude/agents/*.md; do
  name=$(basename "$f")
  has_preamble=$(grep -c "Before You Begin" "$f" 2>/dev/null || echo 0)
  echo "$name: $has_preamble"
done
```

Expected: all 12 show count ≥ 1.

- [ ] **Step 3: Commit**

```bash
git -C ~ add .claude/agents/*.md
git -C ~ commit -m "feat(agents): add Universal Agent Preamble with discovery targets to all 12 agents"
```

Note: Agent files are in `~/.claude/agents/` (user-global), not in the superpowers repo. Commit to the user's dotfiles or track separately.

---

### Task 12: Restructure senior-frontend-engineer agent

**Files:**
- Modify: `~/.claude/agents/senior-frontend-engineer.md`

- [ ] **Step 1: Read current file structure**

```bash
head -5 ~/.claude/agents/senior-frontend-engineer.md
wc -l ~/.claude/agents/senior-frontend-engineer.md
```

Understand the current structure before restructuring.

- [ ] **Step 2: Restructure content**

The agent currently treats React/HeroUI/Redux-Saga as the assumed stack. Restructure so:

1. **Core Frontend Expertise** section comes FIRST — comprehensive, stack-agnostic frontend guidance (component architecture, state management principles, styling patterns, testing, performance, a11y). This MUST be equally detailed as the React supplement — not a sparse fallback.

2. **React/Next.js Supplement** section comes AFTER — with explicit gate: "Apply ONLY IF Project Profile detects React/Next.js." All existing React/HeroUI/Redux-Saga content moves here as supplemental depth.

The Core section should cover:
- Component architecture principles (composition, single responsibility, prop interfaces)
- State management patterns (local vs global, when to use each)
- Styling approach (follow project's discovered conventions)
- Testing philosophy (test behavior not implementation)
- Performance (bundle size awareness, lazy loading, render optimization)
- Accessibility (semantic HTML, ARIA, keyboard navigation, contrast)
- Code organization (follow project's discovered file structure)

- [ ] **Step 3: Verify structure**

```bash
grep "## Core Frontend" ~/.claude/agents/senior-frontend-engineer.md
grep "## React" ~/.claude/agents/senior-frontend-engineer.md
grep "ONLY IF" ~/.claude/agents/senior-frontend-engineer.md
```

All three should match.

- [ ] **Step 4: Commit**

```bash
git -C ~ add .claude/agents/senior-frontend-engineer.md
git -C ~ commit -m "refactor(agents): restructure senior-frontend-engineer with core + React supplement"
```

---

### Task 13: Restructure data-engineer agent

**Files:**
- Modify: `~/.claude/agents/data-engineer.md`

- [ ] **Step 1: Read current structure**

```bash
head -5 ~/.claude/agents/data-engineer.md
wc -l ~/.claude/agents/data-engineer.md
```

- [ ] **Step 2: Restructure content**

Same pattern as Task 12:

1. **Core Data Engineering** section FIRST — pipeline design principles, data modeling, quality checks, monitoring, testing strategies. Equally detailed as any tool supplement.

2. **Tool Supplements** AFTER — with explicit gates:
   - "### dbt (apply IF Project Profile detects dbt)" — existing dbt content
   - "### Airflow (apply IF Project Profile detects Airflow)" — existing Airflow content
   - "### Spark (apply IF Project Profile detects Spark)" — existing Spark content

- [ ] **Step 3: Verify**

```bash
grep "## Core Data" ~/.claude/agents/data-engineer.md
grep "apply IF" ~/.claude/agents/data-engineer.md
```

- [ ] **Step 4: Commit**

```bash
git -C ~ add .claude/agents/data-engineer.md
git -C ~ commit -m "refactor(agents): restructure data-engineer with core + tool supplements"
```

---

### Task 14: Restructure devops-engineer agent

**Files:**
- Modify: `~/.claude/agents/devops-engineer.md`

- [ ] **Step 1: Read current structure**

```bash
head -5 ~/.claude/agents/devops-engineer.md
wc -l ~/.claude/agents/devops-engineer.md
```

- [ ] **Step 2: Restructure content**

Same pattern:

1. **Core DevOps** section FIRST — CI/CD principles, deployment strategies, monitoring, security hardening, infrastructure patterns. Equally detailed.

2. **Tool Supplements** AFTER — with explicit gates:
   - "### Kubernetes (apply IF Project Profile detects Kubernetes)" — existing K8s content
   - "### Terraform (apply IF Project Profile detects Terraform)" — existing Terraform content
   - "### Docker (apply IF Project Profile detects Docker)" — existing Docker content

- [ ] **Step 3: Verify**

```bash
grep "## Core DevOps" ~/.claude/agents/devops-engineer.md
grep "apply IF" ~/.claude/agents/devops-engineer.md
```

- [ ] **Step 4: Commit**

```bash
git -C ~ add .claude/agents/devops-engineer.md
git -C ~ commit -m "refactor(agents): restructure devops-engineer with core + tool supplements"
```

---

## Self-Review

### Spec Coverage

| Spec Component | Tasks |
|---|---|
| 1. Project Profile | Task 8 (brainstorming discovery), Task 9 (implementer Profile fields) |
| 2. Research Gates | Task 8 (brainstorming assertion gate), Task 10 (writing-plans + TDD mandates), Task 7 (debugging domain research) |
| 3. Stack-Adaptive References — skill files | Tasks 1-6 (reviewer templates, brainstorming ledger, writing-plans, TDD example, frontend-design-context) |
| 3. Stack-Adaptive References — agent files | Tasks 11-14 (preamble + restructuring) |

All 3 spec components covered. All files from the spec's Files Changed table have a corresponding task.

### Placeholder Scan

No TBD/TODO found. Agent restructuring tasks (12-14) describe the structure but reference "existing content" — this is intentional since the implementer must read the current file to identify what moves where. The structure (Core section first, supplements after) is fully specified.

### Type Consistency

- "Project Profile" used consistently across Tasks 8, 9, 11
- "composition pattern" phrasing used consistently across Tasks 1, 2 (replacing "cn()")
- "Component Library Conventions" used consistently in Task 3
- Agent preamble text identical across all 12 agents in Task 11 (only discovery targets differ)
