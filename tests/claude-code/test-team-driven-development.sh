#!/usr/bin/env bash
# Test: team-driven-development skill
# Verifies the skill loads and describes the corrected coordination workflow.
# Guards the audit fixes:
#   - P0-1: there is no SendMessage 'broadcast' type — announce to each affected peer / via lead
#   - P0-2: lead populates Project Profile (and Design Context) before spawning teammates
#   - dependencies are set via TaskUpdate addBlockedBy, not as a TaskCreate parameter
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/test-helpers.sh"

echo "=== Test: team-driven-development skill ==="
echo ""

# Test 1: Skill recognized + platform gating
echo "Test 1: Skill loading and platform gating..."
output=$(run_claude "What is the team-driven-development skill and which platform/feature does it require?" 30)
if assert_contains "$output" "team-driven-development\|Team-Driven Development\|agent team" "Skill recognized"; then : ; else exit 1; fi
if assert_contains "$output" "Claude Code\|agent teams" "Mentions Claude Code agent teams"; then : ; else exit 1; fi
echo ""

# Test 2: File ownership discipline
echo "Test 2: File ownership..."
output=$(run_claude "In team-driven-development, can two teammates edit the same file? How is file ownership handled?" 30)
if assert_contains "$output" "one owner\|exactly one\|single owner\|one teammate\|same file" "Each file has exactly one owner"; then : ; else exit 1; fi
echo ""

# Test 3: Peer communication — NO broadcast primitive (guards P0-1)
echo "Test 3: Communication mechanism (no broadcast primitive)..."
output=$(run_claude "In team-driven-development, if a teammate changes a shared interface that several peers depend on, how do they notify the others? Is there a broadcast tool, or do they message peers individually?" 30)
if assert_contains "$output" "each.*peer\|each affected\|by name\|individually\|every affected\|message.*peer\|escalate.*lead\|via the lead\|relay" "Notify affected peers directly or via the lead"; then : ; else exit 1; fi
echo ""

# Test 4: Lead populates Project Profile / Design Context before spawning (guards P0-2)
echo "Test 4: Spawn context includes Project Profile..."
output=$(run_claude "Before spawning teammates in team-driven-development, what project context must the lead put in each teammate's spawn prompt? Mention how the stack and conventions are conveyed." 30)
if assert_contains "$output" "Project Profile\|stack\|conventions\|test command" "Spawn prompt carries Project Profile"; then : ; else exit 1; fi
echo ""

# Test 5: Dependencies via TaskUpdate addBlockedBy
echo "Test 5: Task dependency mechanism..."
output=$(run_claude "In team-driven-development, after creating the task list, how does the lead set up dependencies between tasks? Which tool and field are used?" 30)
if assert_contains "$output" "TaskUpdate\|addBlockedBy\|blockedBy" "Dependencies set via TaskUpdate addBlockedBy"; then : ; else exit 1; fi
echo ""

# Test 6: Integration review bounded
echo "Test 6: Integration review limit..."
output=$(run_claude "In team-driven-development, after all tasks complete, what review happens and how many rounds are allowed?" 30)
if assert_contains "$output" "integration review\|integration reviewer" "Mentions integration review"; then : ; else exit 1; fi
if assert_contains "$output" "2 round\|two round\|max.*2\|maximum.*2" "Bounded to 2 review rounds"; then : ; else exit 1; fi
echo ""

# Test 7: Lead coordinates, does not implement
echo "Test 7: Lead role discipline..."
output=$(run_claude "In team-driven-development, should the lead implement tasks themselves or only coordinate? What should happen if the lead starts coding?" 30)
if assert_contains "$output" "coordinate\|not implement\|don't implement\|do not implement\|stop.*wait\|hands-off\|hands off" "Lead coordinates rather than implements"; then : ; else exit 1; fi
echo ""

echo "=== All team-driven-development skill tests passed ==="
