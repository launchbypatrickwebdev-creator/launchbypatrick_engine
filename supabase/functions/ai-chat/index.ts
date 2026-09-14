import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

const MISTRAL_API_KEY = Deno.env.get("MISTRAL_API_KEY") ?? "";
const MISTRAL_URL = "https://api.mistral.ai/v1/chat/completions";

async function callMistral(messages: any[], retries = 2): Promise<Response> {
  const response = await fetch(MISTRAL_URL, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${MISTRAL_API_KEY}`,
    },
    body: JSON.stringify({
      model: "open-mistral-7b", // or whatever lighter model you are using
      messages,
      temperature: 0.7,
      max_tokens: 700,
    }),
  });

  // If rate limited and we still have retries left → wait and try again
  if (response.status === 429 && retries > 0) {
    console.log(`Rate limited. Waiting 3 seconds... (${retries} retries left)`);
    await new Promise((resolve) => setTimeout(resolve, 3000));
    return callMistral(messages, retries - 1);
  }

  return response;
}

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    if (!MISTRAL_API_KEY) {
      throw new Error("MISTRAL_API_KEY is not set");
    }

    const body = await req.json();
    const { systemPrompt, messages, userMessage } = body;

    if (!userMessage) {
      throw new Error("userMessage is required");
    }

    const mistralMessages = [
      { role: "system", content: systemPrompt || "You are a helpful assistant." },
      ...(Array.isArray(messages) ? messages : []),
      { role: "user", content: userMessage },
    ];

    const response = await callMistral(mistralMessages);

    if (!response.ok) {
      const errorText = await response.text();
      console.error("Mistral error:", response.status, errorText);

      if (response.status === 429) {
        return new Response(
          JSON.stringify({
            success: false,
            error: "Rate limited. Please wait a few seconds and try again.",
          }),
          { status: 429, headers: { ...corsHeaders, "Content-Type": "application/json" } },
        );
      }

      return new Response(
        JSON.stringify({ success: false, error: `AI service error (${response.status})` }),
        { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    const data = await response.json();
    const aiReply = data.choices?.[0]?.message?.content?.trim() ?? "No response from AI.";

    return new Response(
      JSON.stringify({ success: true, reply: aiReply }),
      { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  } catch (error) {
    console.error("Edge Function error:", error);
    return new Response(
      JSON.stringify({ success: false, error: (error as Error).message }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  }
});