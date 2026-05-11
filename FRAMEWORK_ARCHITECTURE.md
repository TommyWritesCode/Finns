# Framework Architecture

## Core pipeline

```text
brief.md
  ↓
discovery-strategist → architecture.md
  ↓
site-planner → plan.md
  ↓
design-advisor → design-advice.md
  ↓
content-copywriter ─┐
                    ├→ astro-builder → source files
astro-builder ──────┘
  ↓
qa-validator → qa-report.md
  ↓
rubric-grader → grading-report.md + fix-queue.md
  ↓
astro-builder fix loop, max N
  ↓
deploy-engineer → deployment.md
  ↓
memory-curator → portable playbook
```

## Why this framework has 10 agents, not 6

Your old 6-agent roster was the correct floor. The new release patterns add three missing production controls plus one optional commander:

- `web-commander`: main-session coordinator; keeps orchestration rules out of random chat instructions.
- `design-advisor`: Opus strategic review; Claude Code version of the advisor pattern.
- `rubric-grader`: separate evaluator; prevents the builder from grading its own homework.
- `memory-curator`: asynchronous learning/dreaming layer; converts repeated mistakes into portable heuristics.

The original six remain the build spine:

- `discovery-strategist`
- `site-planner`
- `content-copywriter`
- `astro-builder`
- `qa-validator`
- `deploy-engineer`

## Model routing

| Agent | Model | Reason |
|---|---:|---|
| web-commander | sonnet | coordination, not deep strategy |
| discovery-strategist | opus | ambiguous strategic decisions cascade into all later work |
| design-advisor | opus | high-leverage advisor pass |
| site-planner | sonnet | structured file/task reasoning |
| content-copywriter | haiku | deterministic copy from known facts |
| astro-builder | sonnet | multi-file coding and build debugging |
| qa-validator | sonnet | build + a11y/SEO triage |
| rubric-grader | sonnet | outcome evaluation with judgment |
| deploy-engineer | sonnet | command execution and failure handling |
| memory-curator | haiku | summarization and pattern extraction |

## Iteration policy

Default max iterations: 2.

Each iteration must produce:

- `docs/qa-report.md`
- `docs/grading-report.md`
- `docs/fix-queue.md`
- an entry in `docs/session-log.md`

The commander stops when:

- QA has zero Critical issues,
- rubric grade is pass,
- deployment is complete or intentionally skipped.

The commander also stops early when:

- a blocker requires client facts,
- the same Critical issue appears twice,
- max iterations are exhausted.

## Memory policy

The framework has two memory layers:

1. Claude Code subagent memory using the `memory:` field where useful.
2. Portable project memory in `memory/`, which you can move across tools.

The portable memory is the source of truth. Do not bury business-critical lessons only in Claude’s hidden/local memory.

## Rule for adding future agents

Add a new agent only when it differs on at least two of these:

- output artifact,
- model tier,
- tool permissions,
- required domain expertise,
- lifecycle phase.

Otherwise you are fragmenting because it feels productive. That is fake work.
