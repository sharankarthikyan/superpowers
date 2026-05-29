---
name: brainstorming
description: "You MUST use this before any creative work - creating features, building components, adding functionality, or modifying behavior. Explores user intent, requirements and design before implementation."
---

# Brainstorming Ideas Into Designs

Help turn ideas into fully formed designs and specs through natural collaborative dialogue.

Start by understanding the current project context, then ask questions one at a time to refine the idea. Once you understand what you're building, present the design and get user approval.

<HARD-GATE>
Do NOT invoke any implementation skill, write any code, scaffold any project, or take any implementation action until you have presented a design and the user has approved it. This applies to EVERY project regardless of perceived simplicity.
</HARD-GATE>

## Anti-Pattern: "This Is Too Simple To Need A Design"

Every project goes through this process. A todo list, a single-function utility, a config change — all of them. "Simple" projects are where unexamined assumptions cause the most wasted work. The design can be short (a few sentences for truly simple projects), but you MUST present it and get approval.

## Checklist

You MUST create a task for each of these items and complete them in order:

1. **Discover project and research the domain** — mandatory discovery + domain research before any design questions (see "Project Discovery and Research" section below)
2. **Offer visual companion** (if topic will involve visual questions) — this is its own message, not combined with a clarifying question. See the Visual Companion section below.
3. **Ask clarifying questions** — one at a time, understand purpose/constraints/success criteria
4. **Propose 2-3 approaches** — with trade-offs and your recommendation
5. **Present design** — in sections scaled to their complexity, get user approval after each section
6. **Write design doc** — save to `docs/superpowers/specs/YYYY-MM-DD-<topic>-design.md` and commit
7. **Spec self-review** — quick inline check for placeholders, contradictions, ambiguity, scope (see below)
8. **User reviews written spec** — ask user to review the spec file before proceeding
9. **Transition to implementation** — invoke writing-plans skill to create implementation plan

## Process Flow

```dot
digraph brainstorming {
    "Discover project + research domain" [shape=box];
    "Visual questions ahead?" [shape=diamond];
    "Offer Visual Companion\n(own message, no other content)" [shape=box];
    "Ask clarifying questions" [shape=box];
    "Propose 2-3 approaches" [shape=box];
    "Present design sections" [shape=box];
    "User approves design?" [shape=diamond];
    "Write design doc" [shape=box];
    "Spec self-review\n(fix inline)" [shape=box];
    "User reviews spec?" [shape=diamond];
    "Invoke writing-plans skill" [shape=doublecircle];

    "Discover project + research domain" -> "Visual questions ahead?";
    "Visual questions ahead?" -> "Offer Visual Companion\n(own message, no other content)" [label="yes"];
    "Visual questions ahead?" -> "Ask clarifying questions" [label="no"];
    "Offer Visual Companion\n(own message, no other content)" -> "Ask clarifying questions";
    "Ask clarifying questions" -> "Propose 2-3 approaches";
    "Propose 2-3 approaches" -> "Present design sections";
    "Present design sections" -> "User approves design?";
    "User approves design?" -> "Present design sections" [label="no, revise"];
    "User approves design?" -> "Write design doc" [label="yes"];
    "Write design doc" -> "Spec self-review\n(fix inline)";
    "Spec self-review\n(fix inline)" -> "User reviews spec?";
    "User reviews spec?" -> "Write design doc" [label="changes requested"];
    "User reviews spec?" -> "Invoke writing-plans skill" [label="approved"];
}
```

**The terminal state is invoking writing-plans.** Do NOT invoke frontend-design, mcp-builder, or any other implementation skill. The ONLY skill you invoke after brainstorming is writing-plans.

## The Process

**Understanding the idea:**

- Check out the current project state first (files, docs, recent commits)
- Before asking detailed questions, assess scope: if the request describes multiple independent subsystems (e.g., "build a platform with chat, file storage, billing, and analytics"), flag this immediately. Don't spend questions refining details of a project that needs to be decomposed first.
- If the project is too large for a single spec, help the user decompose into sub-projects: what are the independent pieces, how do they relate, what order should they be built? Then brainstorm the first sub-project through the normal design flow. Each sub-project gets its own spec → plan → implementation cycle.
- For appropriately-scoped projects, ask questions one at a time to refine the idea
- Prefer multiple choice questions when possible, but open-ended is fine too
- Only one question per message - if a topic needs more exploration, break it into multiple questions
- Focus on understanding: purpose, constraints, success criteria

**Exploring approaches:**

- Propose 2-3 different approaches with trade-offs
- Present options conversationally with your recommendation and reasoning
- Lead with your recommended option and explain why

**Presenting the design:**

- Once you believe you understand what you're building, present the design
- Scale each section to its complexity: a few sentences if straightforward, up to 200-300 words if nuanced
- Ask after each section whether it looks right so far
- Cover: architecture, components, data flow, error handling, testing, and visual design (see Design Ledger below)
- Be ready to go back and clarify if something doesn't make sense

**Design for isolation and clarity:**

- Break the system into smaller units that each have one clear purpose, communicate through well-defined interfaces, and can be understood and tested independently
- For each unit, you should be able to answer: what does it do, how do you use it, and what does it depend on?
- Can someone understand what a unit does without reading its internals? Can you change the internals without breaking consumers? If not, the boundaries need work.
- Smaller, well-bounded units are also easier for you to work with - you reason better about code you can hold in context at once, and your edits are more reliable when files are focused. When a file grows large, that's often a signal that it's doing too much.

**Working in existing codebases:**

- Explore the current structure before proposing changes. Follow existing patterns.
- Where existing code has problems that affect the work (e.g., a file that's grown too large, unclear boundaries, tangled responsibilities), include targeted improvements as part of the design - the way a good developer improves code they're working in.
- Don't propose unrelated refactoring. Stay focused on what serves the current goal.

## Project Discovery and Research

**This replaces the previous soft "explore project context" with a mandatory two-phase process.**

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

### Component Library Conventions
- Library: [discovered from codebase, e.g., shadcn/ui, MUI, Chakra, Vuetify]
- Installed components: [discovered — list what exists]
- Extension pattern: [discovered — how project extends base components]
- Composition: [discovered — how components accept customization]
```

### Ledger Rules

1. **UX Intent filled first** — before any tokens or layout
2. **Updated immediately** — every decision appended as agreed, not at checkpoints
3. **Checked before proposing** — before suggesting visual direction, check the ledger for contradictions
4. **Written into spec** — as a structured `## Design Ledger` section (this exact H2 heading is the machine-readable marker used by downstream skills)
5. **Not all sections required** — fill only what's relevant. A CLI tool with a single output page doesn't need Z-Index or Dark Mode sections.
6. **Carried into plan** — writing-plans reads the ledger and uses it for frontend task decomposition. The ledger is the source of truth for all visual decisions downstream.

## After the Design

**Documentation:**

- Write the validated design (spec) to `docs/superpowers/specs/YYYY-MM-DD-<topic>-design.md`
  - (User preferences for spec location override this default)
- Use elements-of-style:writing-clearly-and-concisely skill if available
- Commit the design document to git

**Spec Self-Review:**
After writing the spec document, look at it with fresh eyes:

1. **Placeholder scan:** Any "TBD", "TODO", incomplete sections, or vague requirements? Fix them.
2. **Internal consistency:** Do any sections contradict each other? Does the architecture match the feature descriptions?
3. **Scope check:** Is this focused enough for a single implementation plan, or does it need decomposition?
4. **Ambiguity check:** Could any requirement be interpreted two different ways? If so, pick one and make it explicit.
5. **Design Ledger check (if UI work):** Does the spec include a `## Design Ledger` with UX Intent filled and all relevant sections completed? Are there visual decisions discussed in brainstorming that didn't make it into the ledger?
6. **Research completeness (all projects):** Does the spec include `## Project Context` with a complete Profile and `## Research Findings` with domain and codebase research? Are there design decisions not grounded in either the Profile or research findings?

Fix any issues inline. No need to re-review — just fix and move on.

**User Review Gate:**
After the spec review loop passes, ask the user to review the written spec before proceeding:

> "Spec written and committed to `<path>`. Please review it and let me know if you want to make any changes before we start writing out the implementation plan."

Wait for the user's response. If they request changes, make them and re-run the spec review loop. Only proceed once the user approves.

**Implementation:**

- Invoke the writing-plans skill to create a detailed implementation plan
- Do NOT invoke any other skill. writing-plans is the next step.

## Key Principles

- **One question at a time** - Don't overwhelm with multiple questions
- **Multiple choice preferred** - Easier to answer than open-ended when possible
- **YAGNI ruthlessly** - Remove unnecessary features from all designs
- **Explore alternatives** - Always propose 2-3 approaches before settling
- **Incremental validation** - Present design, get approval before moving on
- **Be flexible** - Go back and clarify when something doesn't make sense

## Visual Companion

A browser-based companion for showing mockups, diagrams, and visual options during brainstorming. Available as a tool — not a mode. Accepting the companion means it's available for questions that benefit from visual treatment; it does NOT mean every question goes through the browser.

**Offering the companion:** When you anticipate that upcoming questions will involve visual content (mockups, layouts, diagrams), offer it once for consent:
> "Some of what we're working on might be easier to explain if I can show it to you in a web browser. I can put together mockups, diagrams, comparisons, and other visuals as we go. This feature is still new and can be token-intensive. Want to try it? (Requires opening a local URL)"

**This offer MUST be its own message.** Do not combine it with clarifying questions, context summaries, or any other content. The message should contain ONLY the offer above and nothing else. Wait for the user's response before continuing. If they decline, proceed with text-only brainstorming.

**Per-question decision:** Even after the user accepts, decide FOR EACH QUESTION whether to use the browser or the terminal. The test: **would the user understand this better by seeing it than reading it?**

- **Use the browser** for content that IS visual — mockups, wireframes, layout comparisons, architecture diagrams, side-by-side visual designs
- **Use the terminal** for content that is text — requirements questions, conceptual choices, tradeoff lists, A/B/C/D text options, scope decisions

A question about a UI topic is not automatically a visual question. "What does personality mean in this context?" is a conceptual question — use the terminal. "Which wizard layout works better?" is a visual question — use the browser.

If they agree to the companion, read the detailed guide before proceeding:
`skills/brainstorming/visual-companion.md`
