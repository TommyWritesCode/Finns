# CLAUDE.md — Agentic Web Build Orchestrator

You are operating inside Tommy's freelance brochure-site framework.

## Stack

- Astro 5/6, Tailwind, TypeScript-ready.
- CodeStitch component library or CodeStitch starter kits.
- Deployment target: Cloudflare Workers unless the client explicitly requires something else.
- Keep static pages zero-JS unless interactivity is required.

## Primary objective

Build high-quality small-business websites quickly without letting the main context turn into a junk drawer.

## Subagent routing

Use specialists instead of doing everything inline:

- `discovery-strategist`: new project strategy and site architecture.
- `site-planner`: convert architecture into file-level implementation plan.
- `design-advisor`: Opus review of architecture/plan/design risks.
- `content-copywriter`: all page copy, SEO meta, alt text, schema copy.
- `astro-builder`: code, Astro pages/components, Tailwind, CodeStitch integration.
- `qa-validator`: read-only QA checks and report.
- `rubric-grader`: independent outcome grader; writes fix queue.
- `deploy-engineer`: deploy only after QA and grading pass.
- `memory-curator`: post-run learning consolidation.

## Phase order

1. Read `docs/brief.md`.
2. Run `discovery-strategist`; require `READY_FOR_PLANNING`.
3. Run `site-planner`; require `READY_FOR_BUILD`.
4. Run `design-advisor` before build; require `ADVICE_READY`.
5. Run `content-copywriter` for `[CONTENT]` tasks.
6. Run `astro-builder` for `[SCAFFOLD]` and `[BUILD]` tasks.
7. Run `qa-validator`; require `QA_PASSED` or route Critical issues back to builder.
8. Run `rubric-grader`; require `GRADE_PASS` or route `docs/fix-queue.md` back to builder/copywriter.
9. Repeat QA/grading loop up to `docs/iteration-state.json.max_iterations`.
10. Run `deploy-engineer` only after both `QA_PASSED` and `GRADE_PASS`.
11. Run `memory-curator` after deploy or after a stopped/failed run.

## Delegation rules

- If you are about to read more than 3 source files, delegate.
- If you are about to paste or inspect a whole CodeStitch component, delegate to `astro-builder`.
- If the task is copy, use `content-copywriter`.
- If the task is subjective design strategy, use `design-advisor`.
- If the task is evaluation, use `qa-validator` or `rubric-grader`, not the builder.
- If a client fact is missing, mark `[NEEDS: fact]`; do not invent.

## Iteration limits

Default max fix loops: 2.

Stop instead of thrashing when:

- the same build error survives two builder attempts,
- a missing client fact blocks quality,
- deployment credentials or DNS access are missing,
- the rubric requires new assets the client has not provided.

## Slash commands

Operators drive this framework through slash commands, not raw prompts:

- `/new-site "<Client>" [tier]` — scaffold a fresh client workspace.
- `/build-site` — run the full pipeline via `web-commander`.
- `/continue` — resume from QA/grading failure; routes the fix queue back.
- `/qa`, `/grade`, `/deploy` — invoke a single phase only.
- `/dream` — run `memory-curator` over `memory/run-events.jsonl`.
- `/status` — print current phase, iteration, blockers. No subagent.

## Logging

Two parallel logs:

1. **`docs/session-log.md`** — human-readable phase summary. Append after every phase:

   ```markdown
   ## <date time> — <phase>
   - Agent: <name>
   - Input files: <files>
   - Output files: <files>
   - Result: <READY/PASS/FAIL/BLOCKED>
   - Notes: <3 bullets max>
   ```

2. **`memory/run-events.jsonl`** — structured telemetry the `memory-curator` mines. Hooks in `.claude/settings.json` populate `post_edit`, `post_bash`, `subagent_stop`, `session_stop`, and `user_prompt` events automatically. Agents should additionally append their own `agent_handoff`, `qa`, `grade`, `iteration`, `deploy`, and `dream` events when they complete a phase.

## Quality bar

Use `docs/rubrics/site-quality-rubric.md` as the pass/fail authority. The site is not done because it builds. It is done when it builds, reads like a real business, works on mobile, has clean SEO basics, passes accessibility sanity checks, and matches the client tier.

## Visual quality loop (NEW)

After astro-builder reports BUILD_COMPLETE and qa-validator returns QA_PASSED, run:
1. `npm run preview` so design-critic has a URL to hit
2. use design-critic on http://localhost:4321
3. Review docs/critique/design-critique.md with Tommy
4. If top-5 polish list is non-trivial: use astro-builder on the polish list
5. Re-run design-critic. Cap at 2 critique cycles per build to prevent infinite polish.
6. Then proceed to deploy-engineer.

## Revision loop (NEW)

For ANY change request after the initial build (whether from Tommy or the client):
1. use revision-handler, then paste the request verbatim
2. Review docs/revisions/revision-<n>.md
3. If blockers exist (missing content from client), pause and resolve
4. If no blockers: use astro-builder on the revision tasks
5. Run qa-validator on the affected pages only (skip full QA)
6. Optional: run design-critic if the change was visual
7. Deploy with deploy-engineer

## Revision pricing reminder

Revisions inside the original 2-revision-round contract: free.
Revisions outside contract: $65/hr quick edits, $135/hr if rush.
Tommy enforces this, agents do not.
