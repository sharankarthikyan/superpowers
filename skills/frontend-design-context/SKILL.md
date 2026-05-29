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

> **Important:** When creating DESIGN.md interactively, populate values from the Project Profile (discovered from the actual codebase), not from the generic defaults shown below. The template shows common examples — your project's actual values may differ.

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
- Do the listed component-library components exist at the path from the Project Profile (e.g. `components/ui/` for shadcn, `src/components/` for custom, `node_modules/` for installed libraries)?
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
