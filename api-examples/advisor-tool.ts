import Anthropic from "@anthropic-ai/sdk";

const anthropic = new Anthropic({ apiKey: process.env.ANTHROPIC_API_KEY });

/**
 * API-level advisor pattern.
 *
 * This is for a custom runner, not normal Claude Code markdown subagents.
 * The executor does the mechanical work; the advisor gives strategic course correction.
 */
async function runWithAdvisor(userPrompt: string) {
  const response = await anthropic.beta.messages.create({
    model: "claude-sonnet-4-6",
    max_tokens: 4096,
    betas: ["advisor-tool-2026-03-01"],
    tools: [
      {
        type: "advisor_20260301",
        name: "advisor",
        model: "claude-opus-4-7",
        max_uses: 2,
      },
    ],
    messages: [
      {
        role: "user",
        content: userPrompt,
      },
    ],
  });

  return response;
}

const prompt = `
You are building an Astro/Tailwind/CodeStitch brochure site.
Use the advisor early for architecture/design risks and again if build/QA fails.
Task: Create a high-quality landing page plan for the provided client brief.
`;

runWithAdvisor(prompt)
  .then((res) => console.log(JSON.stringify(res, null, 2)))
  .catch((err) => {
    console.error(err);
    process.exit(1);
  });
