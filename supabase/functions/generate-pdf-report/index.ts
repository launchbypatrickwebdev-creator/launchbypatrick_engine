import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { Resend } from "npm:resend";
import PDFDocument from "npm:pdfkit";
import { Buffer } from "node:buffer";

const resend = new Resend(Deno.env.get("RESEND_API_KEY"));

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const payload = await req.json();

    // Map the incoming flat payload directly from Flutter
    const clientEmail = payload.email;
    const companyName = payload.organization || "Valued Client";
    const track = payload.audience || "General Audit";
    const location = payload.location || "N/A";

    if (!clientEmail) {
      return new Response(JSON.stringify({ error: "Missing recipient email address." }), {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
        status: 400,
      });
    }

    // 1. Initialize in-memory PDF canvas
    const doc = new PDFDocument({ size: "A4", margin: 40 });
    const chunks: Uint8Array[] = [];

    doc.on("data", (chunk: Uint8Array) => chunks.push(chunk));

    const pdfCompilationPromise = new Promise<Buffer>((resolve) => {
      doc.on("end", () => {
        resolve(Buffer.concat(chunks));
      });
    });

    // 2. Build PDF UI Structure
    const primaryThemeColor = "#00E5FF";

    doc.fillColor("#0A0B10").rect(0, 0, doc.page.width, doc.page.height).fill();

    doc.fillColor(primaryThemeColor).font("Helvetica-Bold").fontSize(20).text("GROWTH ENGINE SYSTEM AUDIT", 40, 50);
    doc.moveDown(0.5);
    doc.strokeColor("#222222").lineWidth(1).moveTo(40, doc.y).lineTo(550, doc.y).stroke();
    doc.moveDown(1.5);

    doc.fillColor("#FFFFFF").font("Helvetica").fontSize(11).text(`TARGET ENTITY: ${companyName.toUpperCase()}`);
    doc.text(`LOCATION: ${location.toUpperCase()}`);
    doc.text(`CORE DIAGNOSTIC TRACK: ${track}`);
    doc.moveDown(2);

    // Telemetry Highlights
    doc.fillColor("#888888").text("GENERATOR UNITS TRACKED:");
    doc.fillColor("#FFFFFF").font("Helvetica-Bold").fontSize(16).text(`${payload.gen_count || 0} Units`);
    doc.moveDown(1);

    doc.fillColor("#888888").fontSize(11).text("FLEET MONTHLY SPEND:");
    doc.fillColor(primaryThemeColor).fontSize(22).text(`$${payload.fleet_spend || 0}`);
    doc.moveDown(2.5);

    // Telemetry Grid Box
    const boxY = doc.y;
    doc.strokeColor(primaryThemeColor).lineWidth(0.5).rect(40, boxY, 515, 60).stroke();
    doc.fillColor("#FFFFFF").font("Helvetica").fontSize(10)
       .text(`Downtime Hours: ${payload.downtime_hrs || 0} hrs`, 55, boxY + 15);
    doc.text(`Emergency Volume: ${payload.emergency_vol || 0} L`, 55, boxY + 35);

    doc.end();
    const pdfBuffer = await pdfCompilationPromise;

    // 3. Email Dispatch via Resend
    const clientSubjectLine = `Systemic Leakage Telemetry Matrix: ${companyName}`;

    const htmlTemplate = `
      <div style="font-family: monospace; background-color: #0A0B10; color: #FFFFFF; padding: 32px; border: 1px solid #222;">
        <h2 style="color: #00E5FF; border-bottom: 1px solid #111; padding-bottom: 8px;">SYSTEM DIAGNOSTICS COMPILATION</h2>
        <p>Hello,</p>
        <p>The architecture engine has finalized analysis for <strong>${companyName}</strong>.</p>
        <p>Your production bottleneck overview PDF has been successfully structured and attached to this email.</p>
        <br/>
        <span style="color: #444; font-size: 11px;">Track Hash: ${track}</span>
      </div>
    `;

    await resend.emails.send({
      from: "Architect Core <onboarding@resend.dev>",
      to: [clientEmail],
      subject: clientSubjectLine,
      html: htmlTemplate,
      attachments: [
        {
          filename: `Telemetry_Audit_${companyName.replace(/\s+/g, "_")}.pdf`,
          content: pdfBuffer.toString("base64"),
        },
      ],
    });

    // 4. Alert Routing (Using test domain until custom domain is verified)
    await resend.emails.send({
      from: "Pipeline Alerts <onboarding@resend.dev>",
      to: ["launchbypatrick.webdev@gmail.com"],
      subject: `🔥 AUDIT REPORT DISPATCHED: ${companyName}`,
      html: `<p>Organization <strong>${companyName}</strong> (${location}) requested an audit report sent to <strong>${clientEmail}</strong>.</p>`,
    });

    return new Response(JSON.stringify({ status: "Telemetry processed cleanly. Report routed." }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
      status: 200,
    });

  } catch (error: any) {
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
      status: 500,
    });
  }
});