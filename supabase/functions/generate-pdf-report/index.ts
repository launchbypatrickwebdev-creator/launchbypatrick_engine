import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { Resend } from "npm:resend";
import { PDFDocument, rgb, StandardFonts } from "npm:pdf-lib";
import { Buffer } from "node:buffer";

const resend = new Resend(Deno.env.get("RESEND_API_KEY"));

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

// Helper: Prevents pdf-lib WinAnsi font encoding crashes on non-ASCII characters
const cleanText = (str: string): string => {
  if (!str) return "";
  return str
    .replace(/[^\x00-\x7F]/g, "") // Strip non-WinAnsi characters
    .trim();
};

// Helper: Formats metric outputs based on unit position (e.g. "$50,000" vs "400 ms")
const formatMetric = (val: number | string, unit: string): string => {
  const num = typeof val === "number" ? val : parseFloat(val) || 0;
  const formattedNum = num.toLocaleString("en-US");
  return unit === "$" ? `$${formattedNum}` : `${formattedNum} ${unit}`.trim();
};

serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const payload = await req.json();

    // Map nested Flutter payload
    const profile = payload.profile || {};
    const infra = payload.infrastructureState || {};
    const ledger = payload.financialLedger || {};

    const clientEmail = cleanText(profile.corporateEmail);
    const clientName = cleanText(profile.clientName) || "Valued Client";
    const companyName = cleanText(profile.companyName) || "Valued Entity";
    const track = cleanText(infra.analyzedTrack) || "GENERAL DIAGNOSTIC TRACK";

    if (!clientEmail) {
      return new Response(JSON.stringify({ error: "Missing recipient email address." }), {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
        status: 400,
      });
    }

    // 1. Build PDF document in memory
    const pdfDoc = await PDFDocument.create();
    const page = pdfDoc.addPage([595.28, 841.89]); // A4 dimensions
    const fontBold = await pdfDoc.embedFont(StandardFonts.HelveticaBold);
    const fontRegular = await pdfDoc.embedFont(StandardFonts.Helvetica);

    const primaryColor = rgb(0, 0.9, 1); // Neon Cyan
    const darkBg = rgb(0.04, 0.04, 0.06);

    // Dark Background Fill
    page.drawRectangle({
      x: 0,
      y: 0,
      width: 595.28,
      height: 841.89,
      color: darkBg,
    });

    // Header Title
    page.drawText("SYSTEM LEAKAGE DIAGNOSTIC", {
      x: 40,
      y: 780,
      size: 20,
      font: fontBold,
      color: primaryColor,
    });

    // Separator Line
    page.drawLine({
      start: { x: 40, y: 765 },
      end: { x: 550, y: 765 },
      thickness: 1,
      color: rgb(0.13, 0.13, 0.13),
    });

    // Target Metadata
    page.drawText(`CLIENT NAME: ${clientName.toUpperCase()}`, { x: 40, y: 735, size: 10, font: fontRegular, color: rgb(1, 1, 1) });
    page.drawText(`TARGET ENTITY: ${companyName.toUpperCase()}`, { x: 40, y: 715, size: 10, font: fontRegular, color: rgb(1, 1, 1) });
    page.drawText(`DIAGNOSTIC TRACK: ${track.toUpperCase()}`, { x: 40, y: 695, size: 10, font: fontRegular, color: rgb(1, 1, 1) });

    // Financial Losses
    page.drawText("PROJECTED MONTHLY SYSTEMIC LOSS:", { x: 40, y: 655, size: 10, font: fontRegular, color: rgb(0.53, 0.53, 0.53) });
    page.drawText(`${cleanText(ledger.formattedMonthlyLoss) || "$0"}`, { x: 40, y: 635, size: 18, font: fontBold, color: rgb(1, 1, 1) });

    page.drawText("PROJECTED ANNUAL LEAKAGE IMPACT:", { x: 40, y: 595, size: 10, font: fontRegular, color: rgb(0.53, 0.53, 0.53) });
    page.drawText(`${cleanText(ledger.formattedAnnualLoss) || "$0"}`, { x: 40, y: 570, size: 24, font: fontBold, color: primaryColor });

    // Telemetry Grid Box
    const boxY = 460;
    page.drawRectangle({
      x: 40,
      y: boxY,
      width: 515,
      height: 80,
      borderColor: primaryColor,
      borderWidth: 0.5,
    });

    const mAlpha = infra.metricAlpha || {};
    const mBeta = infra.metricBeta || {};

    const labelAlpha = cleanText(mAlpha.label) || "Metric Alpha";
    const formattedAlphaVal = formatMetric(mAlpha.rawInput, cleanText(mAlpha.unit));

    const labelBeta = cleanText(mBeta.label) || "Metric Beta";
    const formattedBetaVal = formatMetric(mBeta.rawInput, cleanText(mBeta.unit));

    page.drawText(`[TELEMETRY ALPHA]  ${labelAlpha}: ${formattedAlphaVal}`, { x: 55, y: boxY + 50, size: 10, font: fontRegular, color: rgb(1, 1, 1) });
    page.drawText(`[TELEMETRY BETA]   ${labelBeta}: ${formattedBetaVal}`, { x: 55, y: boxY + 20, size: 10, font: fontRegular, color: rgb(1, 1, 1) });

    // Export PDF to Base64
    const pdfBytes = await pdfDoc.save();
    const pdfBase64 = Buffer.from(pdfBytes).toString("base64");

    // 2. Email Dispatch via Resend
    const clientSubjectLine = `Systemic Leakage Telemetry Matrix: ${companyName}`;

    const htmlTemplate = `
      <div style="font-family: monospace; background-color: #0A0B10; color: #FFFFFF; padding: 32px; border: 1px solid #222;">
        <h2 style="color: #00E5FF; border-bottom: 1px solid #111; padding-bottom: 8px;">SYSTEM DIAGNOSTICS COMPILATION</h2>
        <p>Hello ${clientName},</p>
        <p>The architecture engine has finalized analysis for <strong>${companyName}</strong>.</p>
        <p>Your production bottleneck overview PDF has been successfully structured and attached to this email.</p>
        <br/>
        <span style="color: #666; font-size: 11px;">Track Hash: ${track}</span>
      </div>
    `;

    const sendRes = await resend.emails.send({
      from: "Architect Core <onboarding@resend.dev>",
      to: [clientEmail],
      subject: clientSubjectLine,
      html: htmlTemplate,
      attachments: [
        {
          filename: `Telemetry_Audit_${companyName.replace(/\s+/g, "_")}.pdf`,
          content: pdfBase64,
        },
      ],
    });

    if (sendRes.error) {
      throw new Error(`Resend Dispatch Failed: ${sendRes.error.message}`);
    }

    // 3. Admin Notification Dispatch
    await resend.emails.send({
      from: "Pipeline Alerts <onboarding@resend.dev>",
      to: ["launchbypatrick.webdev@gmail.com"],
      subject: `🔥 AUDIT REPORT DISPATCHED: ${companyName}`,
      html: `<p>Organization <strong>${companyName}</strong> requested an audit report sent to <strong>${clientEmail}</strong>.</p>`,
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