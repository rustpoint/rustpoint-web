/**
 * POST /api/contact
 *
 * Receives contact form submissions and forwards them via Resend.
 * Requires RESEND_API_KEY environment variable (set via `wrangler pages secret put`).
 */
export async function onRequestPost(context) {
  const { request, env } = context;

  // Parse form data
  let data;
  const contentType = request.headers.get("content-type") || "";
  if (contentType.includes("application/json")) {
    data = await request.json();
  } else {
    const formData = await request.formData();
    data = Object.fromEntries(formData);
  }

  const { name, email, message } = data;

  // Basic validation
  if (!name || !email || !message) {
    return Response.json(
      { error: "All fields are required." },
      { status: 400 }
    );
  }

  if (!email.includes("@") || email.length > 320) {
    return Response.json(
      { error: "Please provide a valid email address." },
      { status: 400 }
    );
  }

  if (message.length > 5000) {
    return Response.json(
      { error: "Message is too long (max 5000 characters)." },
      { status: 400 }
    );
  }

  // Send via Resend
  try {
    const res = await fetch("https://api.resend.com/emails", {
      method: "POST",
      headers: {
        Authorization: `Bearer ${env.RESEND_API_KEY}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        from: "Rustpoint Contact <contact@rustpoint.ai>",
        to: "hello@rustpoint.ai",
        reply_to: email,
        subject: `Contact form: ${name}`,
        text: `Name: ${name}\nEmail: ${email}\n\n${message}`,
      }),
    });

    if (!res.ok) {
      const err = await res.text();
      console.error("Resend API error:", err);
      return Response.json(
        { error: "Failed to send message. Please try again later." },
        { status: 502 }
      );
    }

    return Response.json({ ok: true });
  } catch (err) {
    console.error("Contact form error:", err);
    return Response.json(
      { error: "Something went wrong. Please try again later." },
      { status: 500 }
    );
  }
}
