# Frontend Awareness for Superpowers — Design Spec

## Problem Statement

The superpowers pipeline produces high-quality backend code but systematically fails at frontend/UI/UX work. Research from 6 parallel investigation agents identified two root causes:

1. **Visual context evaporates** — layout, spacing, design tokens, component states, and responsive decisions made during brainstorming are lost mid-conversation and don't survive into the spec, plan, or implementation.
2. **Wrong agent implements frontend tasks** — SDD hardcodes `general-purpose` for all subagents, ignoring specialized project agents (`senior-frontend-engineer`, `ui-ux-designer`, etc.) that have deep frontend knowledge.

Additionally:
- Zero of 10 frontend concerns (responsive, a11y, component states, design tokens, etc.) appear anywhere in the 15 existing skills
- All examples across all skills are Python/bash/server-side
- 5 existing frontend tools (ui-ux skill, ui-ux-designer agent, frontend-design plugin, senior-frontend-engineer agent, shadcn skill) are disconnected islands with no integration into the superpowers pipeline

## Architecture

The fix has 5 components, each addressing a specific gap:

1. **Design Context Ledger** — a structured, running record of visual and UX decisions maintained during brainstorming, written into the spec, and carried through the pipeline
2. **Agent-Aware Dispatch** — SDD discovers project agents and matches tasks to specialized agent types instead of always using `general-purpose`
3. **Frontend-Conditional Pipeline Patches** — writing-plans, implementer prompts, and reviewers gain frontend sections that activate only when a Design Ledger exists
4. **New `frontend-design-context` skill** — manages project-level DESIGN.md, bridges existing frontend tools, seeds the Design Ledger
5. **Frontend examples** — React/component test examples in TDD, browser DevTools in systematic-debugging

All changes are conditional — projects without UI work see zero behavioral change and zero token overhead.

## Component 1: Design Context Ledger

### Purpose

Prevent visual and UX decisions from evaporating during brainstorming by writing them down immediately in a structured format.

### Ledger Structure

The ledger uses a canonical `## Design Ledger` H2 heading as the machine-readable marker. All downstream gates detect this exact heading to determine whether frontend-conditional behavior activates.

**UX Intent comes first — before any tokens are decided.** If you can't articulate user goal and information priority, you're not ready to pick a color scheme.

**Ledger size cap:** Each section should be under 50 words. The full ledger should not exceed 400 words. This prevents token bloat when the ledger is copied into implementer prompts (8-12 tasks × 400 tokens = 3,200-4,800 tokens per plan execution — acceptable).

```markdown
## Design Ledger

### UX Intent
- User goal: [what the user is trying to accomplish on this screen]
- User context: [rushed? exploratory? expert? first-time?]
- Guiding principle: [e.g., "minimize clicks" / "scannable over dense" / "density over explanation"]
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
- Colors: [e.g., zinc-900 bg, zinc-50 text, blue-500 primary accent]
- Typography: [e.g., font-mono for data, font-sans for UI, text-sm base]
- Spacing: [e.g., 8px scale (space-2 base unit)]
- Radii: [e.g., rounded-lg cards, rounded-md inputs, rounded-sm badges]
- Icons: [library (e.g., Lucide), sizes (16/20/24px), stroke weight]

### Motion
- Transitions: [e.g., duration-150 ease-out for interactions, duration-300 for layout]
- Entrances: [e.g., blurFade, staggered reveals]
- Reduced motion: [respect prefers-reduced-motion]

### Component States
- [Component]: [state list with visual treatment for each]
- Loading pattern: [skeleton / spinner / optimistic — per context]
- Error boundary strategy: [route-level / widget-level / both]

### Z-Index Layers
- [e.g., dropdown: 40, modal: 50, toast: 60, tooltip: 70]

### Dark Mode
- [supported / not supported / follows system]
- [if supported: token mapping strategy]

### Responsive
- Mobile (<768px): [behavior]
- Tablet (768-1024px): [behavior]
- Desktop (>1024px): [behavior]

### Form Validation
- Strategy: [validate on blur / submit / live]
- Error placement: [inline below field / summary at top]

### Accessibility
- Focus order: [sequence]
- Contrast: [target level, e.g., WCAG AA 4.5:1]
- Keyboard: [navigation rules, Escape behavior]

### shadcn/ui Conventions
- Installed components: [list of added shadcn components]
- Extension pattern: [custom variants via cva() in component file]
- Composition: [all custom components accept className, use cn()]
```

### Rules

1. **Created when brainstorming detects UI work** — UI work is detected when BOTH conditions are met: (a) the project contains frontend files (`.tsx`/`.jsx`/`.vue`/`.svelte` in component/page directories, CSS framework configured) AND (b) the user's request involves visual output (mentions "page"/"component"/"layout"/"UI"/"design"/"form"/"dashboard" or describes user-facing interface work). Either signal alone is insufficient — a Next.js API route project with `.tsx` files doesn't trigger, and a user saying "design the API" doesn't trigger.
2. **UX Intent filled first** — before any tokens, layout, or styling decisions, the UX Intent section must be completed. This prevents correct-but-unusable implementations.
3. **Updated immediately** — every visual or UX decision appended to the relevant section as it's agreed upon, not at the end, not at a checkpoint
4. **Checked before proposing** — before suggesting any visual direction, agent checks the ledger for contradictions, preventing drift
5. **Written into spec** — the ledger becomes a structured section of the spec doc under the canonical `## Design Ledger` H2 heading (not embedded in prose)
6. **Carried into plan** — writing-plans reads the ledger and uses it for frontend task decomposition

### Changes to `brainstorming/SKILL.md`

- Add to the design coverage list (line 91): "architecture, components, data flow, error handling, testing, **and visual design (see Design Ledger)**"
- Add new section: "Design Ledger" — explains when to create (detection criteria), UX Intent first rule, how to maintain, structure template, size cap
- Spec self-review gets new check: "If project has UI work, does the spec include a `## Design Ledger` with UX Intent filled and all relevant sections completed?"
- **No change to terminal state** — brainstorming still only invokes writing-plans at the end. The `frontend-design-context` skill is invoked by the user or by `using-superpowers` at session start, not by brainstorming.

## Component 2: Agent-Aware Dispatch in SDD

### Purpose

Use specialized project agents (e.g., `senior-frontend-engineer`) for implementation instead of always dispatching `general-purpose` agents.

### Prerequisite: Verification

**Before implementing this component**, verify that Claude Code's Agent tool accepts custom agent types from `.claude/agents/`. Run a test session:

1. Create a task using `Agent tool` with `subagent_type` set to a project agent name (e.g., `senior-frontend-engineer`)
2. Confirm the dispatched agent loads the agent definition from `.claude/agents/senior-frontend-engineer.md`
3. If this doesn't work, investigate the correct dispatch mechanism and update the implementation accordingly

If the Agent tool does NOT support custom agent types, this component falls back to: include the agent's persona/expertise instructions directly in the implementer prompt template as a `## Role` section, selected by the controller based on task domain. This achieves the same effect (specialized knowledge) through prompt injection rather than agent routing.

### Current State

All three SDD prompt templates hardcode:
```
Task tool (general-purpose):
```

Project agents in `~/.claude/agents/` and `.claude/agents/` are never used.

### Discovery Step

Before dispatching any tasks, the controller:

1. Lists agents from `.claude/agents/` and `~/.claude/agents/`
2. Reads each agent's `name` and `description` fields from frontmatter
3. Builds an agent roster for task matching

### Task-to-Agent Matching

The controller examines each task's **description content** as the primary signal (since files may not exist yet for early tasks), with file paths as a secondary signal:

| Task signals | Agent to dispatch |
|---|---|
| Description mentions components, UI, styling; files are `.tsx`, `.css` | `senior-frontend-engineer` |
| Description mentions API, database, services; files are routes, models | `senior-backend-architect` |
| Description mentions UI design, layout, UX, user flow | `ui-ux-designer` |
| Description mentions tests, test strategy, coverage | `qa-engineer` |
| No matching agent found | `general-purpose` (fallback) |

Matching is signal-based — the controller uses judgment. The table is guidance, not a lookup.

### Changes

**`subagent-driven-development/SKILL.md`** — new section: "Agent Selection"
- After reading the plan, discover available project agents
- For each task, select the best-fit agent type based on task description and file paths
- Document selection in the task dispatch

**`subagent-driven-development/implementer-prompt.md`** — parameterize agent type:
```
# Before
Task tool (general-purpose):

# After
Task tool ({AGENT_TYPE}):
```

**`team-driven-development/SKILL.md`** — add agent-aware spawning to Phase 4
**`team-driven-development/team-implementer-prompt.md`** — teammates can be different agent types matched to their track

**Reviewers stay `general-purpose`** — spec compliance and code quality review are domain-agnostic

### Fallback

If no project agents exist (no `.claude/agents/` directory), SDD behaves exactly as today. Zero breaking change.

## Component 3: Frontend-Conditional Pipeline Patches

### Purpose

Give writing-plans, implementer prompts, and reviewers frontend-specific structure — but only when a Design Ledger exists.

### Gate

All patches use the same condition: **spec contains a `## Design Ledger` H2 heading.** This is a machine-readable marker. No heading = pure backend flow, zero token overhead.

### Writing-Plans: Frontend Task Decomposition

When plan references a Design Ledger, frontend tasks decompose as:

```markdown
### Task N: [Component Name]

**Files:**
- Create: `src/components/feature/ComponentName.tsx`
- Create: `src/components/feature/__tests__/ComponentName.test.tsx`

**Design Context:** (from ledger)
- UX Intent: [user goal, guiding principle from ledger]
- Tokens: zinc-900 bg, text-sm, rounded-lg, space-2 base
- States: default, hover, loading, error, empty
- Responsive: stack below 768px, 2-col at 768+

- [ ] **Step 1: Define component interface**
  - Props, state shape, className acceptance (for cn() composition)

- [ ] **Step 2: Write failing tests for ALL states**
  - Render test (default state)
  - Empty state test
  - Loading state test
  - Error state test
  - Interaction test (userEvent.click/type)

- [ ] **Step 3: Run tests to verify ALL fail**
  Run: `npx vitest run path/to/test.tsx`
  Expected: FAIL — component doesn't exist

- [ ] **Step 4: Implement default state (markup + styling)**
  - Use design tokens from ledger
  - Accept className prop, use cn() for composition

- [ ] **Step 5: Verify render test passes**

- [ ] **Step 6: Implement remaining states (loading, error, empty)**
  - Follow loading pattern from ledger (skeleton/spinner/optimistic)
  - Follow error strategy from ledger (inline/toast/modal)
  - Include micro-copy from ledger

- [ ] **Step 7: Verify ALL state tests pass**

- [ ] **Step 8: Add responsive behavior**
  - Follow breakpoints from ledger

- [ ] **Step 9: Accessibility check**
  - Keyboard navigation works
  - ARIA roles correct
  - Contrast passes target from ledger

- [ ] **Step 10: Integration wiring**
  - Import into parent component
  - Connect props to data source (store selector / server props / API response)
  - Handle null/undefined API fields per ledger conventions

- [ ] **Step 11: Commit**
```

Key differences from current template: UX Intent in design context, tests for ALL states written before implementation (Step 2, fixing the TDD ordering bug), className/cn() composition, integration wiring step (Step 10 — prevents orphaned components), micro-copy from ledger.

### Implementer Prompt: Design Context Field

New field between `## Context` and `## Before You Begin`:

```markdown
## Design Context

[From spec's Design Ledger — UX intent, layout, tokens, states, responsive, a11y]

**You MUST reference these values when writing markup and styles.**
Do not use default/generic values. If a token is specified (e.g., "rounded-lg"),
use it. If a state is listed (e.g., "empty: illustration + CTA"), implement it.
If micro-copy is specified, use it exactly. If a className composition pattern
is specified (cn()), follow it.
```

Only included when the spec has a `## Design Ledger`. Backend tasks don't get this section.

### Implementer Self-Review: Frontend Additions

Add to the self-review checklist in the implementer prompt (after existing "Testing" section):

```markdown
**Frontend (if Design Context provided):**
- Did I use design tokens from the ledger (not generic defaults)?
- Did I implement ALL listed component states?
- Does the component accept className and use cn() for composition?
- Did I follow the responsive breakpoints from the ledger?
- Did I use the specified micro-copy (not invented alternatives)?
```

### Spec Reviewer: UI Compliance Check

Add new section to the spec reviewer prompt:

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

### Plan Document Reviewer

Add to check table:

```markdown
| Frontend (if Design Ledger) | Tasks include component interface, ALL state tests before implementation, responsive, a11y, integration wiring |
```

### Code Quality Reviewer

Add to "in addition to standard concerns":

```markdown
- If Design Ledger exists: Are design tokens used consistently (not hardcoded one-off values)?
- Are all component states from the ledger present in the implementation?
- Do components follow shadcn composition patterns (className prop, cn())?
- Are there z-index values not in the ledger's z-index layers?
```

## Component 4: New `frontend-design-context` Skill

### Purpose

Manage project-level design context, bridge existing frontend tools into the superpowers pipeline, and seed the Design Ledger.

### Invocation

This skill is invoked by the user or by `using-superpowers` at session start when frontend work is detected — **not by brainstorming**. This preserves brainstorming's terminal state rule ("The ONLY skill you invoke after brainstorming is writing-plans").

The invocation flow:
1. Session starts → `using-superpowers` detects UI project → invokes `frontend-design-context`
2. Skill loads/creates DESIGN.md → makes project design context available
3. User starts brainstorming → brainstorming detects UI work → creates Design Ledger seeded from DESIGN.md
4. Brainstorming completes → invokes writing-plans (terminal state preserved)

### Three Responsibilities

**1. DESIGN.md Management**

When invoked, checks for a project-level `DESIGN.md` (or creates one interactively with the user). This file encodes project-wide design defaults:

```markdown
# Design System

## UX Defaults
- Target users: [description]
- Default interaction model: [e.g., keyboard-friendly power users / touch-first casual]

## Tokens
- **Colors:** zinc-900 bg, zinc-50 text, blue-500 primary
- **Typography:** font-sans UI, font-mono data, text-sm base
- **Spacing:** 8px scale (p-2 base)
- **Radii:** rounded-lg cards, rounded-md inputs
- **Shadows:** none (flat design)
- **Icons:** Lucide, 16/20/24px, stroke-width 1.5

## Motion
- **Transitions:** duration-150 ease-out interactions, duration-300 layout
- **Entrances:** blurFade
- **Reduced motion:** respect prefers-reduced-motion

## Component Library
- Framework: React/Next.js
- Styling: Tailwind CSS
- Components: shadcn/ui
- Installed: [list of added shadcn components]
- Extension: custom variants via cva() in component file
- Composition: all components accept className, use cn()

## Patterns
- Layout: max-w-2xl centered, no card borders, no shadows
- Loading: skeleton for layout-heavy, spinner for actions
- Error boundaries: route-level
- Form validation: on blur, inline error below field
- States: all components define default/hover/focus/loading/error/empty
- Responsive: mobile-first, stack below 768px
- Dark mode: [supported / not supported / follows system]

## Z-Index Scale
- dropdown: 40, modal: 50, toast: 60, tooltip: 70

## Accessibility
- Target: WCAG AA
- Contrast: 4.5:1 text, 3:1 large
- Focus: visible ring on all interactive elements
- Keyboard: full navigation, Escape closes overlays
```

DESIGN.md is the **persistent** version of the Design Ledger. The ledger captures per-feature decisions during brainstorming. DESIGN.md captures project-wide defaults.

**Staleness check:** When loading an existing DESIGN.md, verify key claims against the actual codebase:
- Does `tailwind.config` match the token claims?
- Do the listed shadcn components actually exist in `components/ui/`?
- Is the stated framework/styling approach still in use?

If discrepancies are found, flag them to the user before seeding the ledger. Stale DESIGN.md poisoning the ledger is worse than no DESIGN.md.

**2. Tool Bridge**

Routes to existing frontend tools based on the nature of the request:

| Request nature | Tool to use |
|---|---|
| User goals, flow, information architecture, UX decisions | `ui-ux` skill → delegates to `ui-ux-designer` agent |
| Visual refinement, polish, motion, distinctive aesthetics | `frontend-design` plugin |
| Component implementation | `senior-frontend-engineer` agent (via agent-aware dispatch) |
| shadcn component usage or extension | `shadcn` skill rules |
| Visual critique of implemented UI | `agentation-self-driving` (if toolbar installed) |

The agent decides based on request nature, not a rigid phase label.

**3. Ledger Seeding**

When brainstorming starts and DESIGN.md exists (and passes staleness check), the Design Ledger is pre-seeded with project defaults from DESIGN.md. Per-feature decisions override or extend these defaults. This prevents the agent from starting with a blank slate every time.

### Skill Definition

```yaml
---
name: frontend-design-context
description: Use when starting frontend/UI work in a project — manages DESIGN.md, seeds the Design Ledger, and routes to existing frontend tools (ui-ux, shadcn, frontend-design, senior-frontend-engineer)
---
```

### Location

`skills/frontend-design-context/SKILL.md` in the fork.

## Component 5: Frontend Examples

### Purpose

Give agents reference patterns for frontend TDD and debugging. Not replacing backend examples — adding alongside.

### TDD Skill — Component Test Examples

Add after the existing bug fix example. Two examples covering the most common frontend TDD patterns:

**Example 1: Component with States (render + empty state)**

```tsx
// RED — write tests for ALL states before implementing
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

// Verify RED — both fail: "Cannot find module './ItemList'"

// GREEN
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

// REFACTOR — extract EmptyState if pattern repeats
```

**Example 2: Interaction Test (user events)**

```tsx
// RED
test('calls onAdd when empty state button clicked', async () => {
  const onAdd = vi.fn();
  render(<ItemList items={[]} onAdd={onAdd} />);
  await userEvent.click(screen.getByRole('button', { name: 'Add first item' }));
  expect(onAdd).toHaveBeenCalledOnce();
});

// Verify RED — fails: onAdd not called (component doesn't exist)
// GREEN — already implemented above, test passes
```

**Note on visual regression:** Visual regression testing (Chromatic, Percy) is out of scope for this spec. It requires project-specific CI setup. Agents should not implement ad-hoc screenshot tests as a substitute.

### Systematic Debugging — Browser DevTools

Add to Phase 1 "Gather Evidence in Multi-Component Systems":

```markdown
**WHEN issue is visual/layout (wrong spacing, overflow, misalignment):**

1. Browser DevTools → Elements panel
   - Inspect computed styles (actual px values vs expected)
   - Check box model (margin/padding/border)
   - Verify Tailwind classes applied (not overridden by specificity)

2. Responsive check
   - Toggle device toolbar at each breakpoint from Design Ledger
   - Check if issue is viewport-specific

3. Component tree (React DevTools)
   - Verify props reaching component
   - Check state values
   - Use Profiler tab → "Highlight updates when components render" to catch re-render storms

4. CSS cascade
   - Check specificity conflicts
   - Look for !important overrides
   - Verify Tailwind layer ordering (@base, @components, @utilities)

**WHEN issue is Next.js hydration error:**

1. Disable JavaScript → view SSR HTML
2. Enable JavaScript → compare CSR output
3. Find the mismatched node (different attribute values, extra/missing elements)
4. Common causes: browser-only APIs in render (window, localStorage),
   date/time formatting differences, conditional rendering based on client state

**WHEN issue is performance (slow render, jank, layout shifts):**

1. Performance panel → record interaction
2. Check for: long tasks (>50ms), forced reflows, excessive re-renders
3. Experience lane → identify CLS events (which element shifted, why)
4. Network panel → waterfall view → find render-blocking resources

**Console error classification:**
- React errors (missing key, invalid hook call) → always bugs, fix immediately
- Browser warnings (non-passive listener, mixed content) → investigate, usually safe
- Third-party noise (analytics, extensions) → ignore unless affecting functionality
```

### What Doesn't Change

- `dispatching-parallel-agents` — already domain-agnostic
- `finishing-a-development-branch` — git workflow
- `receiving-code-review`, `requesting-code-review` — process skills
- `using-git-worktrees`, `using-superpowers` — infrastructure
- `verification-before-completion` — domain-agnostic gate
- `writing-skills` — meta skill

## Files Changed

| File | Change type | Description |
|---|---|---|
| `skills/brainstorming/SKILL.md` | Patch | Add Design Ledger section (with UX Intent first), update coverage list, update spec self-review |
| `skills/writing-plans/SKILL.md` | Patch | Add frontend task decomposition template (11-step with TDD-correct ordering), conditional on ledger |
| `skills/writing-plans/plan-document-reviewer-prompt.md` | Patch | Add frontend check to review table |
| `skills/subagent-driven-development/SKILL.md` | Patch | Add Agent Selection section with discovery + matching |
| `skills/subagent-driven-development/implementer-prompt.md` | Patch | Parameterize agent type, add Design Context field, add frontend self-review |
| `skills/subagent-driven-development/spec-reviewer-prompt.md` | Patch | Add UI Compliance check with specific verification criteria |
| `skills/subagent-driven-development/code-quality-reviewer-prompt.md` | Patch | Add design token consistency + shadcn composition checks |
| `skills/team-driven-development/SKILL.md` | Patch | Add agent-aware spawning to Phase 4 |
| `skills/team-driven-development/team-implementer-prompt.md` | Patch | Add Design Context field, add frontend self-review |
| `skills/test-driven-development/SKILL.md` | Patch | Add 2 component test examples (states + interaction) |
| `skills/systematic-debugging/SKILL.md` | Patch | Add browser DevTools, hydration errors, performance, console classification |
| `skills/frontend-design-context/SKILL.md` | New | DESIGN.md management with staleness check, tool bridge, ledger seeding |

## Non-Goals

- Not modifying the Visual Companion (it works for what it does)
- Not creating new agents (existing ones are sufficient)
- Not changing backend workflow (all changes are conditional on `## Design Ledger` heading)
- Not adding framework-specific skills beyond examples (React/Next.js examples are sufficient — agents can port)
- Not implementing visual regression testing (requires project-specific CI setup)
- Not adding browser-based visual verification as a required gate (agentation-self-driving exists as optional tool)

## Open Questions

1. **Agent dispatch mechanism** — Component 2 has a verification prerequisite. If the Agent tool doesn't accept custom agent types, the fallback (persona injection in prompt) must be implemented instead. This must be tested before implementation begins.
2. **DESIGN.md location** — project root or `.claude/DESIGN.md`? Root is more visible and follows the DESIGN.md industry convention. Recommend project root.
