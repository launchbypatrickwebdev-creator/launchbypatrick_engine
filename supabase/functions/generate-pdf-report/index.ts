import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { Resend } from "npm:resend";
import PDFDocument from "npm:pdfkit";
import { Buffer } from "node:buffer";

// Initialize the mail delivery service using environment tokens
const resend = new Resend(Deno.env.get("RESEND_API_KEY"));

// Global Cross-Origin Resource Sharing (CORS) security header structures
const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

serve(async (req: Request) => {
  // Handle automatic browser preflight OPTIONS requests gracefully
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    // Ingest the raw analytical structural payload directly from the Flutter application
    const payload = await req.json();
    const { profile, infrastructureState, financialLedger, meta } = payload;
    
    const clientEmail = profile.corporateEmail;
    const companyName = profile.companyName;

    // 1. Initialize an in-memory secure PDF canvas instance
    const doc = new PDFDocument({ size: "A4", margin: 40 });
    const chunks: Uint8Array[] = [];

    // Stream streaming data fragments into our tracking array
    doc.on("data", (chunk: Uint8Array) => chunks.push(chunk));

    // Form an asynchronous bridge block to resolve when data streams reach final termination points
    const pdfCompilationPromise = new Promise<Buffer>((resolve) => {
      doc.on("end", () => {
        resolve(Buffer.concat(chunks));
      });
    });

    // 2. Programmatically sketch visual elements inside the Document
    const primaryThemeColor = "#00E5FF"; // High-fidelity operational neon cyan
    
    // Fill background bounding area
    doc.fillColor("#0A0B10").rect(0, 0, doc.page.width, doc.page.height).fill();
    
    // Primary Header Element
    doc.fillColor(primaryThemeColor).font("Helvetica-Bold").fontSize(20).text("GROWTH ENGINE SYSTEM AUDIT", 40, 50);
    doc.moveDown(0.5);
    doc.strokeColor("#222222").lineWidth(1).moveTo(40, doc.y).lineTo(550, doc.y).stroke();
    doc.moveDown(1.5);

    // Corporate Profile Context Parameters
    doc.fillColor("#FFFFFF").font("Helvetica").fontSize(11).text(`TARGET ENTITY: ${companyName.toUpperCase()}`);
    doc.text(`CORE DIAGNOSTIC TRACK: ${infrastructureState.analyzedTrack}`);
    doc.moveDown(2);

    // Financial Quantifications Blocks
    doc.fillColor("#888888").text("MONTHLY SYSTEMIC ESCAPE CAPITAL:");
    doc.fillColor("#FFFFFF").font("Helvetica-Bold").fontSize(18).text(`${financialLedger.formattedMonthlyLoss}`);
    doc.moveDown(1);
    
    doc.fillColor("#888888").fontSize(11).text("PROJECTED METRIC REVENUE LOSS (ANNUALIZED):");
    doc.fillColor(primaryThemeColor).fontSize(30).text(`${financialLedger.formattedAnnualLoss}`);
    doc.moveDown(2.5);

    // Raw Telemetry Input Verification Subgrid
    doc.strokeColor(primaryThemeColor).lineWidth(0.5).rect(40, doc.y, 515, 80).stroke();
    doc.fillColor("#FFFFFF").font("Helvetica").fontSize(10)
       .text(`INPUT PARAMETER A: ${infrastructureState.metricAlpha.label} -> ${infrastructureState.metricAlpha.rawInput} ${infrastructureState.metricAlpha.unit}`, 55, doc.y + 15);
    doc.text(`INPUT PARAMETER B: ${infrastructureState.metricBeta.label} -> ${infrastructureState.metricBeta.rawInput} ${infrastructureState.metricBeta.unit}`, 55, doc.y + 35);

    // Terminate document streams to calculate execution buffers
    doc.end();
    const pdfBuffer = await pdfCompilationPromise;

    // 3. Assemble Transactional Delivery Parameters
    const isLeadQualified = financialLedger.annualLossRaw >= meta.systemThresholdSetting;
    const clientSubjectLine = `Systemic Leakage Telemetry Matrix: ${companyName}`;
    
    const htmlTemplate = `
      <div style="font-family: monospace; background-color: #0A0B10; color: #FFFFFF; padding: 32px; border: 1px solid #222;">
        <h2 style="color: #00E5FF; border-bottom: 1px solid #111; padding-bottom: 8px;">SYSTEM DIAGNOSTICS COMPILATION</h2>
        <p>Hello ${profile.clientName},</p>
        <p>The architecture engine has finalized analysis for <strong>${companyName}</strong>.</p>
        <p>Your production bottleneck overview PDF has been successfully structured and attached to this communication profile.</p>
        <br/>
        <span style="color: #444; font-size: 11px;">Track Hash: ${infrastructureState.analyzedTrack}</span>
      </div>
    `;

    // 4. Dispatch the compiled asset via Resend API
    await resend.emails.send({
      from: "Architect Core <onboarding@resend.dev>",
      to: [clientEmail],
      subject: clientSubjectLine,
      html: htmlTemplate,
      attachments: [
        {
          filename: `Telemetry_Audit_${companyName.replace(/\s+/g, "_")}.pdf`,
          content: pdfBuffer.toString("base64"), // Pass raw bytes to Resend via clean base64 representation strings
        },
      ],
    });

    // 5. Dual-Path Routing: Target Capture Route notification alerts
    if (isLeadQualified) {
      await resend.emails.send({
        from: "Pipeline Alerts <system@yourcompany.com>",
        to: ["your-personal-email@domain.com"],
        subject: `🔥 HIGH-VALUE DEPLOYMENT ACTION LEAD: ${companyName}`,
        html: `<p>Organization <strong>${companyName}</strong> registered an annualized vulnerability totaling <strong>${financialLedger.formattedAnnualLoss}</strong> within tracking sequence <strong>${infrastructureState.analyzedTrack}</strong>.</p>`
      });
    }

    return new Response(JSON.stringify({ status: "Telemetry processed cleanly. Report routed." }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
      status: 200,
    });

  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
      status: 500,
    });
  }
});