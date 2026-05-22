# Frontend Awareness Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended), superpowers:team-driven-development (for 3+ parallel tracks), or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the superpowers skills pipeline frontend-aware by adding a Design Context Ledger, agent-aware dispatch, conditional frontend sections in pipeline skills, a new frontend-design-context skill, and frontend examples.

**Architecture:** Patch 11 existing skill/template files with conditional frontend sections gated on a `## Design Ledger` H2 heading in the spec. Create 1 new skill (`frontend-design-context`). All changes are additive — backend-only projects see zero behavioral change.

**Tech Stack:** Markdown skill files, no runtime dependencies

**Spec:** `docs/superpowers/specs/2026-05-17-frontend-awareness-design.md`

---

## File Structure

| File | Action | Responsibility |
|---|---|---|
| `skills/frontend-design-context/SKILL.md` | Create | DESIGN.md management, tool bridge, ledger seeding |
| `skills/brainstorming/SKILL.md` | Modify | Add Design Ledger section, update coverage list, update spec self-review |
| `skills/writing-plans/SKILL.md` | Modify | Add frontend task decomposition template |
| `skills/writing-plans/plan-document-reviewer-prompt.md` | Modify | Add frontend check row |
| `skills/subagent-driven-development/SKILL.md` | Modify | Add Agent Selection section |
| `skills/subagent-driven-development/implementer-prompt.md` | Modify | Parameterize agent type, add Design Context field, add frontend self-review |
| `skills/subagent-driven-development/spec-reviewer-prompt.md` | Modify | Add UI Compliance check |
| `skills/subagent-driven-development/code-quality-reviewer-prompt.md` | Modify | Add frontend quality checks |
| `skills/team-driven-development/SKILL.md` | Modify | Add agent-aware spawning note |
| `skills/team-driven-development/team-implementer-prompt.md` | Modify | Add Design Context field, add frontend self-review |
| `skills/test-driven-development/SKILL.md` | Modify | Add 2 component test examples |
| `skills/systematic-debugging/SKILL.md` | Modify | Add browser DevTools, hydration, performance debugging |

---

### Task 1: Create `frontend-design-context` Skill

**Files:**
- Create: `skills/frontend-design-context/SKILL.md`

This is the foundation — other tasks reference this skill.

- [ ] **Step 1: Create the skill directory**

```bash
mkdir -p skills/frontend-design-context
```

- [ ] **Step 2: Write the skill file**

Create `skills/frontend-design-context/SKILL.md` with this exact content:

```markdown
---
name: frontend-design-context
description: Use when starting frontend/UI work in a project — manages DESIGN.md, seeds the Design Ledger, and routes to existing frontend tools (ui-ux, shadcn, frontend-design, senior-frontend-engineer)
---

# Frontend Design Context

## Overview

Manage project-level design context for frontend work. Three jobs: maintain DESIGN.md, seed the Design Ledger for brainstorming, and route to existing frontend tools.

**Core principle:** Design context must be explicit, persistent, and flow through the entire pipeline.

## When to Use

- Session starts in a project with frontend files AND user requests UI work
- Before brainstorming any feature involving visual output
- When DESIGN.md needs creation or updating

**Detection signals (BOTH required):**
- Project contains frontend files (`.tsx`/`.jsx`/`.vue`/`.svelte` in component/page directories, CSS framework configured)
- User's request involves visual output (mentions "page"/"component"/"layout"/"UI"/"design"/"form"/"dashboard" or describes user-facing interface work)

Either signal alone is insufficient — a Next.js API-only project doesn't trigger, "design the API" doesn't trigger.

## DESIGN.md Management

Check for `DESIGN.md` at project root. If it exists, load it. If not, create one interactively with the user.

### DESIGN.md Template

```
# Design System

## UX Defaults
- Target users: [description]
- Default interaction model: [e.g., keyboard-friendly power users / touch-first casual]

## Tokens
- **Colors:** [e.g., zinc-900 bg, zinc-50 text, blue-500 primary]
- **Typography:** [e.g., font-sans UI, font-mono data, text-sm base]
- **Spacing:** [e.g., 8px scale (p-2 base)]
- **Radii:** [e.g., rounded-lg cards, rounded-md inputs]
- **Shadows:** [e.g., none (flat design)]
- **Icons:** [e.g., Lucide, 16/20/24px, stroke-width 1.5]

## Motion
- **Transitions:** [e.g., duration-150 ease-out interactions, duration-300 layout]
- **Entrances:** [e.g., blurFade]
- **Reduced motion:** respect prefers-reduced-motion

## Component Library
- Framework: [e.g., React/Next.js]
- Styling: [e.g., Tailwind CSS]
- Components: [e.g., shadcn/ui]
- Installed: [list of added shadcn components]
- Extension: [e.g., custom variants via cva() in component file]
- Composition: [e.g., all components accept className, use cn()]

## Patterns
- Layout: [e.g., max-w-2xl centered, no card borders, no shadows]
- Loading: [e.g., skeleton for layout-heavy, spinner for actions]
- Error boundaries: [e.g., route-level]
- Form validation: [e.g., on blur, inline error below field]
- States: [e.g., all components define default/hover/focus/loading/error/empty]
- Responsive: [e.g., mobile-first, stack below 768px]
- Dark mode: [e.g., supported / not supported / follows system]

## Z-Index Scale
- [e.g., dropdown: 40, modal: 50, toast: 60, tooltip: 70]

## Accessibility
- Target: [e.g., WCAG AA]
- Contrast: [e.g., 4.5:1 text, 3:1 large]
- Focus: [e.g., visible ring on all interactive elements]
- Keyboard: [e.g., full navigation, Escape closes overlays]
```

### Staleness Check

When loading an existing DESIGN.md, verify key claims against the actual codebase:
- Does `tailwind.config` match the token claims?
- Do listed shadcn components actually exist in `components/ui/`?
- Is the stated framework/styling approach still in use?

If discrepancies found, flag them to the user before seeding the ledger.

## Tool Bridge

Route to existing frontend tools based on request nature:

| Request nature | Tool to use |
|---|---|
| User goals, flow, information architecture, UX decisions | `ui-ux` skill → delegates to `ui-ux-designer` agent |
| Visual refinement, polish, motion, distinctive aesthetics | `frontend-design` plugin |
| Component implementation | `senior-frontend-engineer` agent (via agent-aware dispatch) |
| shadcn component usage or extension | `shadcn` skill rules |
| Visual critique of implemented UI | `agentation-self-driving` (if toolbar installed) |

The agent decides based on request nature, not a rigid phase label.

## Ledger Seeding

When brainstorming starts and DESIGN.md exists (and passes staleness check), the Design Ledger is pre-seeded with project defaults from DESIGN.md. Per-feature decisions override or extend these defaults.

## Integration

This skill is invoked by `using-superpowers` at session start when frontend work is detected, or by the user directly. It is NOT invoked by brainstorming — brainstorming's terminal state ("invoke writing-plans only") is preserved.

Flow:
1. Session starts → `using-superpowers` detects UI project → invokes this skill
2. Skill loads/creates DESIGN.md → makes project design context available
3. User starts brainstorming → brainstorming creates Design Ledger seeded from DESIGN.md
4. Brainstorming completes → invokes writing-plans (terminal state preserved)
```

- [ ] **Step 3: Verify the skill file structure**

```bash
head -3 skills/frontend-design-context/SKILL.md
```

Expected: YAML frontmatter with `name: frontend-design-context`

- [ ] **Step 4: Commit**

```bash
git add skills/frontend-design-context/SKILL.md
git commit -m "feat: add frontend-design-context skill for DESIGN.md management and ledger seeding"
```

---

### Task 2: Add Design Ledger to Brainstorming

**Files:**
- Modify: `skills/brainstorming/SKILL.md`

Three changes: update coverage list, add Design Ledger section, update spec self-review.

- [ ] **Step 1: Update the design coverage list**

In `skills/brainstorming/SKILL.md`, find this line (line 91):

```
- Cover: architecture, components, data flow, error handling, testing
```

Replace with:

```
- Cover: architecture, components, data flow, error handling, testing, and visual design (see Design Ledger below)
```

- [ ] **Step 2: Add the Design Ledger section**

In `skills/brainstorming/SKILL.md`, insert the following new section immediately before `## After the Design` (before line 108):

```markdown
## Design Ledger

**When the project involves frontend/UI work**, maintain a running Design Ledger throughout brainstorming. This is a structured record of every visual and UX decision, updated immediately as decisions are made.

**Detection (BOTH required):** Project contains frontend files (`.tsx`/`.jsx`/`.vue`/`.svelte` in component/page dirs, CSS framework configured) AND user's request involves visual output (mentions "page"/"component"/"layout"/"UI"/"design"/"form"/"dashboard").

**If `frontend-design-context` skill was invoked at session start**, seed the ledger from the project's DESIGN.md. Otherwise, start with a blank ledger.

**UX Intent comes first.** Before deciding any tokens, layout, or styling, fill the UX Intent section. If you can't articulate user goal and information priority, you're not ready to pick a color scheme.

**Size cap:** Each section under 50 words. Full ledger under 400 words.

### Ledger Template

```
## Design Ledger

### UX Intent
- User goal: [what the user is trying to accomplish]
- User context: [rushed? exploratory? expert? first-time?]
- Guiding principle: [e.g., "minimize clicks" / "scannable over dense"]
- Flow: [entry point → key action → exit/next step]
- Information priority: [P1, P2, P3 on this screen]
- Error strategy: [inline / toast / blocking modal — and why]
- Empty state action: [what does a new user do first?]
- Micro-copy: [key button labels, placeholder text, empty state messages]

### Layout
- Structure: [e.g., sidebar (240px fixed) + main content area]
- Grid: [e.g., 12-column, gap-6]
- Max width: [e.g., max-w-7xl centered]

### Design Tokens
- Colors: [e.g., zinc-900 bg, zinc-50 text, blue-500 primary]
- Typography: [e.g., font-mono for data, font-sans for UI, text-sm base]
- Spacing: [e.g., 8px scale (space-2 base unit)]
- Radii: [e.g., rounded-lg cards, rounded-md inputs]
- Icons: [library, sizes, stroke weight]

### Motion
- Transitions: [e.g., duration-150 ease-out for interactions]
- Entrances: [e.g., blurFade, staggered reveals]
- Reduced motion: [respect prefers-reduced-motion]

### Component States
- [Component]: [state list with visual treatment]
- Loading pattern: [skeleton / spinner / optimistic — per context]
- Error boundary strategy: [route-level / widget-level / both]

### Z-Index Layers
- [e.g., dropdown: 40, modal: 50, toast: 60, tooltip: 70]

### Dark Mode
- [supported / not supported / follows system]

### Responsive
- Mobile (<768px): [behavior]
- Tablet (768-1024px): [behavior]
- Desktop (>1024px): [behavior]

### Form Validation
- Strategy: [on blur / submit / live]
- Error placement: [inline below field / summary at top]

### Accessibility
- Focus order: [sequence]
- Contrast: [target, e.g., WCAG AA 4.5:1]
- Keyboard: [navigation rules]

### shadcn/ui Conventions
- Installed components: [list]
- Extension pattern: [cva() in component file]
- Composition: [accept className, use cn()]
```

### Ledger Rules

1. **UX Intent filled first** — before any tokens or layout
2. **Updated immediately** — every decision appended as agreed, not at checkpoints
3. **Checked before proposing** — before suggesting visual direction, check the ledger for contradictions
4. **Written into spec** — as a structured `## Design Ledger` section (this exact H2 heading is the machine-readable marker used by downstream skills)
5. **Not all sections required** — fill only what's relevant. A CLI tool with a single output page doesn't need Z-Index or Dark Mode sections.

```

- [ ] **Step 3: Update the spec self-review**

In `skills/brainstorming/SKILL.md`, find the spec self-review section (around line 116-124). After the existing item 4 ("Ambiguity check"), add:

```markdown
5. **Design Ledger check (if UI work):** Does the spec include a `## Design Ledger` with UX Intent filled and all relevant sections completed? Are there visual decisions discussed in brainstorming that didn't make it into the ledger?
```

- [ ] **Step 4: Verify the file parses correctly**

```bash
head -5 skills/brainstorming/SKILL.md
grep "Design Ledger" skills/brainstorming/SKILL.md | head -5
```

Expected: YAML frontmatter intact, "Design Ledger" appears in coverage list, new section, and self-review.

- [ ] **Step 5: Commit**

```bash
git add skills/brainstorming/SKILL.md
git commit -m "feat(brainstorming): add Design Ledger for frontend context retention"
```

---

### Task 3: Add Frontend Task Decomposition to Writing-Plans

**Files:**
- Modify: `skills/writing-plans/SKILL.md`

- [ ] **Step 1: Add frontend task decomposition section**

In `skills/writing-plans/SKILL.md`, insert the following immediately after the existing Task Structure section (after the closing `````  on line 104, before `## No Placeholders` on line 106):

```markdown

## Frontend Task Decomposition

**When the spec contains a `## Design Ledger` heading**, frontend component tasks use this extended structure instead of the generic task structure above:

````markdown
### Task N: [Component Name]

**Files:**
- Create: `src/components/feature/ComponentName.tsx`
- Create: `src/components/feature/__tests__/ComponentName.test.tsx`

**Design Context:** (from spec's Design Ledger)
- UX Intent: [user goal, guiding principle]
- Tokens: [colors, spacing, radii from ledger]
- States: [default, hover, loading, error, empty]
- Responsive: [breakpoint behavior from ledger]

- [ ] **Step 1: Define component interface**

```tsx
interface ComponentNameProps {
  data: DataType;
  onAction: (id: string) => void;
  isLoading?: boolean;
  className?: string; // required for cn() composition
}
```

- [ ] **Step 2: Write failing tests for ALL states**

```tsx
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';

test('renders component with data', () => {
  render(<ComponentName data={mockData} onAction={vi.fn()} />);
  expect(screen.getByRole('region')).toBeInTheDocument();
});

test('shows empty state when no data', () => {
  render(<ComponentName data={[]} onAction={vi.fn()} />);
  expect(screen.getByText('[micro-copy from ledger]')).toBeInTheDocument();
});

test('shows loading skeleton', () => {
  render(<ComponentName data={[]} onAction={vi.fn()} isLoading />);
  expect(screen.getByRole('progressbar')).toBeInTheDocument();
});

test('calls onAction when clicked', async () => {
  const onAction = vi.fn();
  render(<ComponentName data={mockData} onAction={onAction} />);
  await userEvent.click(screen.getByRole('button', { name: '[label from ledger]' }));
  expect(onAction).toHaveBeenCalledOnce();
});
```

- [ ] **Step 3: Run tests to verify ALL fail**

Run: `npx vitest run path/to/test.tsx`
Expected: FAIL — component doesn't exist

- [ ] **Step 4: Implement default state (markup + styling)**

```tsx
import { cn } from '@/lib/utils';

export function ComponentName({ data, onAction, isLoading, className }: ComponentNameProps) {
  // Use design tokens from ledger — not generic defaults
  return (
    <div className={cn("[tokens from ledger]", className)}>
      ...
    </div>
  );
}
```

- [ ] **Step 5: Verify render test passes**

- [ ] **Step 6: Implement remaining states (loading, error, empty)**
  - Follow loading pattern from ledger (skeleton/spinner/optimistic)
  - Follow error strategy from ledger (inline/toast/modal)
  - Include micro-copy from ledger exactly

- [ ] **Step 7: Verify ALL state tests pass**

- [ ] **Step 8: Add responsive behavior**
  - Follow breakpoints from ledger

- [ ] **Step 9: Accessibility check**
  - Keyboard navigation works
  - ARIA roles correct
  - Contrast passes target from ledger

- [ ] **Step 10: Integration wiring**
  - Import into parent component
  - Connect props to data source
  - Handle null/undefined API fields per ledger conventions

- [ ] **Step 11: Commit**
````

Key differences from generic template: UX Intent in design context, tests for ALL states written before implementation (Step 2), `className`/`cn()` composition, integration wiring step (Step 10), micro-copy from ledger.

When no `## Design Ledger` exists in the spec, use the generic task structure above — no frontend decomposition needed.

```

- [ ] **Step 2: Verify the file**

```bash
grep "Frontend Task Decomposition" skills/writing-plans/SKILL.md
```

Expected: heading found.

- [ ] **Step 3: Commit**

```bash
git add skills/writing-plans/SKILL.md
git commit -m "feat(writing-plans): add frontend task decomposition template gated on Design Ledger"
```

---

### Task 4: Add Frontend Check to Plan Document Reviewer

**Files:**
- Modify: `skills/writing-plans/plan-document-reviewer-prompt.md`

- [ ] **Step 1: Add frontend row to check table**

In `skills/writing-plans/plan-document-reviewer-prompt.md`, find the check table (around line 22-27). Add a new row after the `Buildability` row:

```markdown
    | Frontend (if `## Design Ledger` in spec) | Tasks include component interface, ALL state tests before implementation, responsive, a11y, integration wiring |
```

- [ ] **Step 2: Commit**

```bash
git add skills/writing-plans/plan-document-reviewer-prompt.md
git commit -m "feat(plan-reviewer): add frontend check for Design Ledger plans"
```

---

### Task 5: Add Agent Selection to SDD

**Files:**
- Modify: `skills/subagent-driven-development/SKILL.md`

- [ ] **Step 1: Add Agent Selection section**

In `skills/subagent-driven-development/SKILL.md`, insert the following new section immediately after the "## Model Selection" section (after line 111, before "## Handling Implementer Status"):

```markdown
## Agent Selection

When project agents exist in `.claude/agents/` or `~/.claude/agents/`, use them instead of always dispatching `general-purpose`.

### Discovery

Before dispatching any tasks:

1. List agents from `.claude/agents/` and `~/.claude/agents/`
2. Read each agent's `name` and `description` fields from frontmatter
3. Build an agent roster for task matching

### Matching

Select agent type for each task based on **task description** (primary) and **file paths** (secondary):

| Task signals | Agent type |
|---|---|
| Description mentions components, UI, styling; files are `.tsx`, `.css` | `senior-frontend-engineer` |
| Description mentions API, database, services; files are routes, models | `senior-backend-architect` |
| Description mentions UI design, layout, UX, user flow | `ui-ux-designer` |
| Description mentions tests, test strategy, coverage | `qa-engineer` |
| No matching agent | `general-purpose` (fallback) |

Task description is the primary signal because files may not exist yet for early tasks.

### Dispatch

Use the selected agent type in the implementer prompt template (see `implementer-prompt.md`). Reviewers stay `general-purpose` — spec compliance and code quality review are domain-agnostic.

### Fallback

If no `.claude/agents/` directory exists, dispatch `general-purpose` for all tasks — identical to current behavior.

```

- [ ] **Step 2: Verify insertion**

```bash
grep "Agent Selection" skills/subagent-driven-development/SKILL.md
```

Expected: heading found.

- [ ] **Step 3: Commit**

```bash
git add skills/subagent-driven-development/SKILL.md
git commit -m "feat(sdd): add agent selection for specialized implementer dispatch"
```

---

### Task 6: Patch SDD Implementer Prompt

**Files:**
- Modify: `skills/subagent-driven-development/implementer-prompt.md`

Three changes: parameterize agent type, add Design Context field, add frontend self-review.

- [ ] **Step 1: Parameterize agent type**

In `skills/subagent-driven-development/implementer-prompt.md`, find line 6:

```
Task tool (general-purpose):
```

Replace with:

```
Task tool ({AGENT_TYPE}):
```

- [ ] **Step 2: Add Design Context field**

In `skills/subagent-driven-development/implementer-prompt.md`, find the `## Context` section (around line 16). Insert the following immediately after it (before `## Before You Begin`):

```markdown

    ## Design Context (if spec has Design Ledger)

    [From spec's Design Ledger — UX intent, layout, tokens, states, responsive, a11y]

    **You MUST reference these values when writing markup and styles.**
    Do not use default/generic values. If a token is specified (e.g., "rounded-lg"),
    use it. If a state is listed (e.g., "empty: illustration + CTA"), implement it.
    If micro-copy is specified, use it exactly. If a className composition pattern
    is specified (cn()), follow it.
```

- [ ] **Step 3: Add frontend self-review items**

In `skills/subagent-driven-development/implementer-prompt.md`, find the self-review section (around line 74-98). After the `**Testing:**` subsection (after line 96), add:

```markdown

    **Frontend (if Design Context provided):**
    - Did I use design tokens from the ledger (not generic defaults)?
    - Did I implement ALL listed component states?
    - Does the component accept className and use cn() for composition?
    - Did I follow the responsive breakpoints from the ledger?
    - Did I use the specified micro-copy (not invented alternatives)?
```

- [ ] **Step 4: Verify changes**

```bash
grep "AGENT_TYPE" skills/subagent-driven-development/implementer-prompt.md
grep "Design Context" skills/subagent-driven-development/implementer-prompt.md
grep "Frontend" skills/subagent-driven-development/implementer-prompt.md
```

Expected: all three found.

- [ ] **Step 5: Commit**

```bash
git add skills/subagent-driven-development/implementer-prompt.md
git commit -m "feat(sdd): parameterize agent type, add Design Context and frontend self-review"
```

---

### Task 7: Patch SDD Spec Reviewer Prompt

**Files:**
- Modify: `skills/subagent-driven-development/spec-reviewer-prompt.md`

- [ ] **Step 1: Add UI Compliance check**

In `skills/subagent-driven-development/spec-reviewer-prompt.md`, find the report format section at the end (around line 56-61). Insert the following immediately before the report format:

```markdown

    **UI Compliance (if spec contains `## Design Ledger`):**

    In addition to functional spec compliance, verify:
    - Does implementation use the specified design tokens (colors, spacing, radii)?
      Not generic defaults, not different-shade approximations — the exact tokens.
    - Are ALL listed component states implemented (not just happy path)?
      Check each state from the ledger against actual code.
    - Does responsive behavior match the ledger's breakpoint rules?
    - Are accessibility requirements met (focus order, contrast, ARIA)?
    - Does micro-copy match the ledger (not paraphrased)?
    - Do components accept className and use cn() for shadcn composition?

    Report UI compliance issues with the same format as functional issues:
    - ❌ UI Issue: [what's wrong] — [file:line] — [what ledger specifies]
```

- [ ] **Step 2: Commit**

```bash
git add skills/subagent-driven-development/spec-reviewer-prompt.md
git commit -m "feat(sdd): add UI compliance check to spec reviewer"
```

---

### Task 8: Patch SDD Code Quality Reviewer Prompt

**Files:**
- Modify: `skills/subagent-driven-development/code-quality-reviewer-prompt.md`

- [ ] **Step 1: Add frontend quality checks**

In `skills/subagent-driven-development/code-quality-reviewer-prompt.md`, find the additional checks list (lines 20-23). Add these items at the end of the list:

```markdown
- If spec has `## Design Ledger`: Are design tokens used consistently (not hardcoded one-off values)?
- If spec has `## Design Ledger`: Are all component states from the ledger present?
- If spec has `## Design Ledger`: Do components follow shadcn composition (className prop, cn())?
- If spec has `## Design Ledger`: Are there z-index values not in the ledger's z-index scale?
```

- [ ] **Step 2: Commit**

```bash
git add skills/subagent-driven-development/code-quality-reviewer-prompt.md
git commit -m "feat(sdd): add frontend quality checks to code quality reviewer"
```

---

### Task 9: Add Agent-Aware Spawning to Team-Driven Development

**Files:**
- Modify: `skills/team-driven-development/SKILL.md`

- [ ] **Step 1: Add agent-aware note to Phase 4**

In `skills/team-driven-development/SKILL.md`, find the "### Phase 4 — Create Team & Spawn" section. Add the following paragraph after "Lead's conversation history does NOT carry over" (after the existing content about spawn prompts):

```markdown

**Agent-aware spawning:** If project agents exist in `.claude/agents/` or `~/.claude/agents/`, match each teammate's agent type to their track. For example, a frontend track uses `senior-frontend-engineer`, a backend track uses `senior-backend-architect`. Use `general-purpose` as fallback. See `subagent-driven-development` skill's "Agent Selection" section for the matching table.
```

- [ ] **Step 2: Commit**

```bash
git add skills/team-driven-development/SKILL.md
git commit -m "feat(tdd-team): add agent-aware teammate spawning"
```

---

### Task 10: Patch Team Implementer Prompt

**Files:**
- Modify: `skills/team-driven-development/team-implementer-prompt.md`

Two changes: add Design Context field and frontend self-review.

- [ ] **Step 1: Add Design Context field**

In `skills/team-driven-development/team-implementer-prompt.md`, find the `## Shared Context` section (around line 37). Insert the following immediately after it (before `## Your Teammates`):

```markdown

## Design Context (if spec has Design Ledger)

[From spec's Design Ledger — UX intent, layout, tokens, states, responsive, a11y]

**You MUST reference these values when writing markup and styles.**
Do not use default/generic values. If a token is specified, use it.
If a state is listed, implement it. If micro-copy is specified, use it exactly.
```

- [ ] **Step 2: Add frontend self-review items**

In `skills/team-driven-development/team-implementer-prompt.md`, find the self-review section (around line 95-106). After the `**Contracts:**` item, add:

```markdown
- **Frontend (if Design Context provided):** Did I use ledger tokens? All states implemented? className/cn() composition? Responsive breakpoints? Specified micro-copy?
```

- [ ] **Step 3: Commit**

```bash
git add skills/team-driven-development/team-implementer-prompt.md
git commit -m "feat(tdd-team): add Design Context and frontend self-review to team implementer"
```

---

### Task 11: Add Component Test Examples to TDD

**Files:**
- Modify: `skills/test-driven-development/SKILL.md`

- [ ] **Step 1: Add component test examples**

In `skills/test-driven-development/SKILL.md`, find the end of the "Example: Bug Fix" section (after "Extract validation for multiple fields if needed." on line 325, before `## Verification Checklist` on line 327). Insert:

```markdown

## Example: Component with States (React)

**Goal:** Component that renders a list with empty state

**RED — write tests for ALL states before implementing**
```tsx
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';

test('renders items as list', () => {
  render(<ItemList items={mockItems} onAdd={vi.fn()} />);
  expect(screen.getByRole('list')).toBeInTheDocument();
  expect(screen.getAllByRole('listitem')).toHaveLength(3);
});

test('shows empty state when no items', () => {
  render(<ItemList items={[]} onAdd={vi.fn()} />);
  expect(screen.getByText('No items yet')).toBeInTheDocument();
  expect(screen.getByRole('button', { name: 'Add first item' })).toBeInTheDocument();
});

test('calls onAdd when empty state button clicked', async () => {
  const onAdd = vi.fn();
  render(<ItemList items={[]} onAdd={onAdd} />);
  await userEvent.click(screen.getByRole('button', { name: 'Add first item' }));
  expect(onAdd).toHaveBeenCalledOnce();
});
```

**Verify RED**
```bash
$ npx vitest run src/components/__tests__/ItemList.test.tsx
FAIL: Cannot find module './ItemList'
```

**GREEN**
```tsx
import { cn } from '@/lib/utils';
import { Button } from '@/components/ui/button';

interface ItemListProps {
  items: Item[];
  onAdd: () => void;
  className?: string;
}

export function ItemList({ items, onAdd, className }: ItemListProps) {
  if (items.length === 0) {
    return (
      <div className={cn("flex flex-col items-center gap-2 py-8 text-zinc-400", className)}>
        <p className="text-sm">No items yet</p>
        <Button onClick={onAdd} variant="outline" size="sm">Add first item</Button>
      </div>
    );
  }
  return (
    <ul role="list" className={cn("space-y-2", className)}>
      {items.map(item => <li key={item.id} role="listitem">...</li>)}
    </ul>
  );
}
```

**Verify GREEN** — all 3 tests pass

**REFACTOR** — extract `EmptyState` component if pattern repeats across components

Note: Tests cover render output AND user interaction (userEvent.click). Components accept `className` for `cn()` composition. Visual regression testing (Chromatic, Percy) is out of scope — don't implement ad-hoc screenshot tests.

```

- [ ] **Step 2: Verify insertion**

```bash
grep "Component with States" skills/test-driven-development/SKILL.md
```

Expected: heading found.

- [ ] **Step 3: Commit**

```bash
git add skills/test-driven-development/SKILL.md
git commit -m "feat(tdd): add React component test example with states and interaction"
```

---

### Task 12: Add Browser DevTools to Systematic Debugging

**Files:**
- Modify: `skills/systematic-debugging/SKILL.md`

- [ ] **Step 1: Add frontend debugging techniques**

In `skills/systematic-debugging/SKILL.md`, find the end of Phase 1's "Trace Data Flow" section (around line 120, after "Fix at source, not at symptom", before `### Phase 2: Pattern Analysis`). Insert:

```markdown

6. **Frontend-Specific Evidence Gathering**

   **WHEN issue is visual/layout (wrong spacing, overflow, misalignment):**

   ```
   1. Browser DevTools → Elements panel
      - Inspect computed styles (actual px values vs expected)
      - Check box model (margin/padding/border)
      - Verify Tailwind classes applied (not overridden by specificity)

   2. Responsive check
      - Toggle device toolbar at each breakpoint
      - Check if issue is viewport-specific

   3. Component tree (React DevTools)
      - Verify props reaching component
      - Check state values
      - Profiler tab → "Highlight updates" to catch re-render storms

   4. CSS cascade
      - Check specificity conflicts
      - Look for !important overrides
      - Verify Tailwind layer ordering (@base, @components, @utilities)
   ```

   **WHEN issue is Next.js hydration error:**

   ```
   1. Disable JavaScript → view SSR HTML
   2. Enable JavaScript → compare CSR output
   3. Find mismatched node (different attributes, extra/missing elements)
   4. Common causes: browser-only APIs in render (window, localStorage),
      date/time formatting differences, conditional rendering on client state
   ```

   **WHEN issue is performance (slow render, jank, layout shifts):**

   ```
   1. Performance panel → record interaction
   2. Check for: long tasks (>50ms), forced reflows, excessive re-renders
   3. Experience lane → identify CLS events (which element shifted, why)
   4. Network panel → waterfall view → find render-blocking resources
   ```

   **Console error classification:**
   - React errors (missing key, invalid hook call) → always bugs, fix immediately
   - Browser warnings (non-passive listener, mixed content) → investigate, usually safe
   - Third-party noise (analytics, extensions) → ignore unless affecting functionality

```

- [ ] **Step 2: Verify insertion**

```bash
grep "Frontend-Specific Evidence" skills/systematic-debugging/SKILL.md
grep "hydration" skills/systematic-debugging/SKILL.md
```

Expected: both found.

- [ ] **Step 3: Commit**

```bash
git add skills/systematic-debugging/SKILL.md
git commit -m "feat(debugging): add browser DevTools, hydration errors, performance debugging"
```

---

## Self-Review

### Spec Coverage

| Spec Component | Tasks |
|---|---|
| 1. Design Context Ledger | Task 2 (brainstorming patch) |
| 2. Agent-Aware Dispatch | Task 5 (SDD SKILL.md), Task 6 (implementer), Task 9 (TDD team SKILL.md) |
| 3. Frontend-Conditional Pipeline | Task 3 (writing-plans), Task 4 (plan reviewer), Task 6 (implementer), Task 7 (spec reviewer), Task 8 (code quality reviewer), Task 10 (team implementer) |
| 4. frontend-design-context skill | Task 1 |
| 5. Frontend examples | Task 11 (TDD), Task 12 (debugging) |

All 5 spec components covered. All 12 files from the spec's Files Changed table have a corresponding task.

### Placeholder Scan

No TBD, TODO, or "implement later" found. All code blocks contain complete content. Bracketed placeholders (e.g., `[from ledger]`) are intentional template markers, not omissions.

### Type Consistency

- `## Design Ledger` H2 heading used consistently as the gate marker across all tasks
- `{AGENT_TYPE}` placeholder used consistently in implementer prompt
- `cn()` and `className` composition referenced consistently across implementer, team implementer, and TDD example
- "Design Context" section name used consistently across implementer prompt (Task 6) and team implementer prompt (Task 10)
