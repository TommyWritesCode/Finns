import type { APIRoute } from "astro";

export const prerender = false;

// Basic email format validator
function isValidEmail(email: string): boolean {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email.trim());
}

export const POST: APIRoute = async ({ request }) => {
  // Parse request body
  let body: Record<string, unknown>;
  try {
    body = await request.json() as Record<string, unknown>;
  } catch {
    return new Response(
      JSON.stringify({ error: "Invalid request body." }),
      { status: 400, headers: { "Content-Type": "application/json" } }
    );
  }

  const email = typeof body.email === "string" ? body.email.trim() : "";

  if (!email || !isValidEmail(email)) {
    return new Response(
      JSON.stringify({ error: "Please provide a valid email address." }),
      { status: 422, headers: { "Content-Type": "application/json" } }
    );
  }

  // Retrieve env vars (Cloudflare Workers / Astro SSR runtime)
  const apiKey = import.meta.env.MAILCHIMP_API_KEY as string | undefined;
  const listId = import.meta.env.MAILCHIMP_LIST_ID as string | undefined;

  if (!apiKey || !listId) {
    // In development without env vars, return a stub success so the UI works
    if (import.meta.env.DEV) {
      return new Response(
        JSON.stringify({ success: true, dev: true }),
        { status: 200, headers: { "Content-Type": "application/json" } }
      );
    }
    return new Response(
      JSON.stringify({ error: "Service not configured." }),
      { status: 503, headers: { "Content-Type": "application/json" } }
    );
  }

  // Mailchimp data center is encoded in the API key after the last dash (e.g. "us1")
  const dc = apiKey.split("-").pop() ?? "us1";
  const url = `https://${dc}.api.mailchimp.com/3.0/lists/${listId}/members`;

  const mailchimpPayload = JSON.stringify({
    email_address: email,
    status: "subscribed",
  });

  // Base64-encode credentials for Basic Auth
  const credentials = btoa(`anystring:${apiKey}`);

  let mcRes: Response;
  try {
    mcRes = await fetch(url, {
      method: "POST",
      headers: {
        "Authorization": `Basic ${credentials}`,
        "Content-Type": "application/json",
      },
      body: mailchimpPayload,
    });
  } catch (err) {
    return new Response(
      JSON.stringify({ error: "Failed to reach email service." }),
      { status: 502, headers: { "Content-Type": "application/json" } }
    );
  }

  // 200 = newly subscribed, 400 with "Member Exists" (title: "Member Exists") = already on list
  if (mcRes.ok) {
    return new Response(
      JSON.stringify({ success: true }),
      { status: 200, headers: { "Content-Type": "application/json" } }
    );
  }

  // Parse Mailchimp error body
  let mcError: Record<string, unknown> = {};
  try {
    mcError = await mcRes.json() as Record<string, unknown>;
  } catch { /* ignore */ }

  // 400 with title "Member Exists" — treat as success
  if (mcRes.status === 400 && mcError.title === "Member Exists") {
    return new Response(
      JSON.stringify({ success: true }),
      { status: 200, headers: { "Content-Type": "application/json" } }
    );
  }

  // Anything else is a real failure
  return new Response(
    JSON.stringify({
      error: (mcError.detail as string) || "Something went wrong. Please try again.",
    }),
    { status: 500, headers: { "Content-Type": "application/json" } }
  );
};

// Reject non-POST requests explicitly
export const GET: APIRoute = () =>
  new Response(JSON.stringify({ error: "Method not allowed." }), {
    status: 405,
    headers: { "Content-Type": "application/json", Allow: "POST" },
  });
