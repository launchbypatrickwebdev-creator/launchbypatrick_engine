import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { PDFDocument, rgb, StandardFonts, PDFName, PDFString, PDFArray } from "npm:pdf-lib";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

function formatNaira(amount: number): string {
  return "NGN " + Math.round(amount).toLocaleString("en-NG");
}

function generateAuditId(): string {
  const chars = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";
  let result = "";
  for (let i = 0; i < 5; i++) {
    result += chars.charAt(Math.floor(Math.random() * chars.length));
  }
  return `ELS-2026-${result}`;
}

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const payload = await req.json();

    const email: string = payload.email;
    if (!email) throw new Error("Target email address is required");

    const audience: "generator" | "fleet" | "both" = payload.audience || "both";
    const organization: string = payload.organization || "Unspecified Organisation";
    const location: string = payload.location || "Unspecified Location";
    const dateStr = new Date().toLocaleDateString("en-GB", {
      day: "2-digit",
      month: "short",
      year: "numeric",
    });
    const auditId = payload.auditId || generateAuditId();

    // Metrics
    const genCount = payload.gen_count ?? 5;
    const genBudget = payload.gen_budget ?? 200000;
    const genLossPct = payload.gen_loss_pct ?? 15;
    const fleetCount = payload.fleet_count ?? 20;
    const fleetSpend = payload.fleet_spend ?? 120000;
    const fleetUnaccountedPct = payload.fleet_unaccounted_pct ?? 20;
    const dtHrs = payload.downtime_hrs ?? 8;
    const dtValue = payload.downtime_val ?? 50000;
    const staffHrs = payload.logging_hrs ?? 10;
    const costPerHr = payload.logging_cost_hr ?? 2500;
    const loggingSites = payload.logging_sites ?? 3;
    const emergencyBuys = payload.emergency_buys ?? 6;
    const emergencyPremiumPct = payload.emergency_premium_pct ?? 25;
    const emergencyVol = payload.emergency_vol ?? 150000;
    const adulterLitres = payload.adulter_litres ?? 2000;
    const adulterPct = payload.adulter_pct ?? 10;
    const costPerLitre = payload.cost_per_litre ?? 950;
    const multisiteCount = payload.multisite_count ?? 5;
    const multisiteLoss = payload.multisite_loss ?? 30000;
    const audits = payload.compliance_audits ?? 2;
    const auditFindingCost = payload.compliance_cost ?? 500000;
    const auditProb = payload.compliance_prob ?? 40;

    // Loss Calculations
    const genLoss = genCount * genBudget * (genLossPct / 100) * 12;
    const fleetLoss = fleetCount * fleetSpend * (fleetUnaccountedPct / 100) * 12;
    const downtimeLoss = dtHrs * dtValue * 12;
    const loggingLoss = staffHrs * costPerHr * loggingSites * 52;
    const emergencyLoss = emergencyBuys * emergencyVol * (emergencyPremiumPct / 100);
    const adulterationLoss = adulterLitres * (adulterPct / 100) * costPerLitre * 12;
    const multisiteLossVal = multisiteCount * multisiteLoss * 12;
    const complianceLoss = audits * auditFindingCost * (auditProb / 100);

    const breakdown: { name: string; loss: number }[] = [];
    if (audience === "generator" || audience === "both") {
      breakdown.push({ name: "Standby Generators", loss: genLoss });
    }
    if (audience === "fleet" || audience === "both") {
      breakdown.push({ name: "Logistics & Fleets", loss: fleetLoss });
    }
    breakdown.push(
      { name: "Generator Downtime Cost", loss: downtimeLoss },
      { name: "Manual Logging Overhead", loss: loggingLoss },
      { name: "Emergency Procurement Premium", loss: emergencyLoss },
      { name: "Fuel Adulteration Loss", loss: adulterationLoss },
      { name: "Multi-Site Oversight Gap", loss: multisiteLossVal },
      { name: "Compliance & Audit Risk", loss: complianceLoss },
    );

    const totalAnnualLoss = breakdown.reduce((acc, item) => acc + item.loss, 0);
    const primaryRiskSector = breakdown.reduce(
      (max, item) => (item.loss > max.loss ? item : max),
      breakdown[0],
    ).name;

    let totalAssets = 0;
    if (audience === "generator") totalAssets = genCount;
    else if (audience === "fleet") totalAssets = fleetCount;
    else totalAssets = genCount + fleetCount;

    const threeYearLoss = totalAnnualLoss * 3;
    const unaccountedLitres = Math.round(totalAnnualLoss / costPerLitre);

    // ──────────────────────────────
    // Build PDF
    // ──────────────────────────────
    const pdfDoc = await PDFDocument.create();
    const page = pdfDoc.addPage([595, 842]); // A4
    const fontBold = await pdfDoc.embedFont(StandardFonts.HelveticaBold);
    const fontRegular = await pdfDoc.embedFont(StandardFonts.Helvetica);

    const emeraldGreen = rgb(0.0, 0.9, 0.4);
    const darkBackground = rgb(0.04, 0.06, 0.08);
    const cardBg = rgb(0.08, 0.11, 0.15);
    const textLight = rgb(0.95, 0.95, 0.95);
    const textMuted = rgb(0.55, 0.6, 0.65);
    const alertRed = rgb(1.0, 0.3, 0.3);

    // Header Banner
    page.drawRectangle({
      x: 0,
      y: 762,
      width: 595,
      height: 80,
      color: darkBackground,
    });
    page.drawRectangle({
      x: 0,
      y: 758,
      width: 595,
      height: 4,
      color: emeraldGreen,
    });

    // === LOGO + COMPANY NAME ===
    try {
      const logoResponse = await fetch(
        "https://jjlmgoxcnvedwbqzrero.supabase.co/storage/v1/object/public/sentinel%20pdf%20logo/d9JyZ.png"
      );
      if (logoResponse.ok) {
        const logoBytes = new Uint8Array(await logoResponse.arrayBuffer());
        const logoImage = await pdfDoc.embedPng(logoBytes);
        page.drawImage(logoImage, {
          x: 40,
          y: 772,
          width: 58,
          height: 58,
        });

        // Company Name
        page.drawText("ECHOLEVEL SENTINEL", {
          x: 110,
          y: 805,
          size: 16,
          font: fontBold,
          color: rgb(1, 1, 1),
        });

        // Tagline
        page.drawText("INDUSTRIAL IoT & ASSET MONITORING", {
          x: 110,
          y: 788,
          size: 8,
          font: fontBold,
          color: emeraldGreen,
        });
      } else {
        // Fallback if logo fails
        page.drawText("ECHOLEVEL SENTINEL", {
          x: 40,
          y: 805,
          size: 16,
          font: fontBold,
          color: emeraldGreen,
        });
        page.drawText("INDUSTRIAL IoT & ASSET MONITORING", {
          x: 40,
          y: 788,
          size: 8,
          font: fontBold,
          color: textMuted,
        });
      }
    } catch (e) {
      console.error("Logo fetch failed:", e);
      page.drawText("ECHOLEVEL SENTINEL", {
        x: 40,
        y: 805,
        size: 16,
        font: fontBold,
        color: emeraldGreen,
      });
      page.drawText("INDUSTRIAL IoT & ASSET MONITORING", {
        x: 40,
        y: 788,
        size: 8,
        font: fontBold,
        color: textMuted,
      });
    }

    page.drawText("CONFIDENTIAL", {
      x: 480,
      y: 805,
      size: 9,
      font: fontBold,
      color: alertRed,
    });
    page.drawText(`ID: ${auditId}`, {
      x: 450,
      y: 785,
      size: 9,
      font: fontRegular,
      color: textMuted,
    });

    // Metadata
    let y = 725;
    page.drawText("Organisation:", {
      x: 40,
      y,
      size: 9,
      font: fontBold,
      color: rgb(0.3, 0.3, 0.3),
    });
    page.drawText(organization, {
      x: 110,
      y,
      size: 9,
      font: fontRegular,
      color: rgb(0.1, 0.1, 0.1),
    });
    page.drawText("Location:", {
      x: 260,
      y,
      size: 9,
      font: fontBold,
      color: rgb(0.3, 0.3, 0.3),
    });
    page.drawText(location, {
      x: 310,
      y,
      size: 9,
      font: fontRegular,
      color: rgb(0.1, 0.1, 0.1),
    });
    page.drawText("Date:", {
      x: 460,
      y,
      size: 9,
      font: fontBold,
      color: rgb(0.3, 0.3, 0.3),
    });
    page.drawText(dateStr, {
      x: 490,
      y,
      size: 9,
      font: fontRegular,
      color: rgb(0.1, 0.1, 0.1),
    });
    page.drawLine({
      start: { x: 40, y: y - 10 },
      end: { x: 555, y: y - 10 },
      thickness: 0.5,
      color: rgb(0.85, 0.85, 0.85),
    });

    // Executive Summary
    y -= 30;
    page.drawRectangle({
      x: 40,
      y: y - 85,
      width: 515,
      height: 95,
      color: cardBg,
      borderColor: emeraldGreen,
      borderWidth: 1,
    });
    page.drawText("EXECUTIVE AUDIT SUMMARY", {
      x: 55,
      y: y - 18,
      size: 10,
      font: fontBold,
      color: emeraldGreen,
    });
    page.drawText("Total Annual Loss Exposure", {
      x: 55,
      y: y - 36,
      size: 9,
      font: fontRegular,
      color: textMuted,
    });
    page.drawText(formatNaira(totalAnnualLoss), {
      x: 55,
      y: y - 58,
      size: 22,
      font: fontBold,
      color: alertRed,
    });
    page.drawText(`Primary Risk Sector: ${primaryRiskSector}`, {
      x: 310,
      y: y - 36,
      size: 9,
      font: fontRegular,
      color: textLight,
    });
    page.drawText(`Assessed Asset Fleet: ${totalAssets} Units/Vehicles`, {
      x: 310,
      y: y - 52,
      size: 9,
      font: fontRegular,
      color: textLight,
    });
    page.drawText(`Operation Target: ${audience.toUpperCase()} OPERATIONS`, {
      x: 310,
      y: y - 68,
      size: 9,
      font: fontBold,
      color: emeraldGreen,
    });

    // Sector Breakdown Table
    y -= 120;
    page.drawText("SECTOR RISK BREAKDOWN", {
      x: 40,
      y,
      size: 10,
      font: fontBold,
      color: rgb(0.1, 0.1, 0.1),
    });
    y -= 15;
    page.drawRectangle({
      x: 40,
      y: y - 5,
      width: 515,
      height: 18,
      color: rgb(0.93, 0.95, 0.96),
    });
    page.drawText("Risk Vector", {
      x: 50,
      y,
      size: 8,
      font: fontBold,
      color: rgb(0.3, 0.3, 0.3),
    });
    page.drawText("Annual Financial Impact", {
      x: 310,
      y,
      size: 8,
      font: fontBold,
      color: rgb(0.3, 0.3, 0.3),
    });
    page.drawText("% Share", {
      x: 480,
      y,
      size: 8,
      font: fontBold,
      color: rgb(0.3, 0.3, 0.3),
    });
    y -= 10;

    for (let i = 0; i < breakdown.length; i++) {
      const item = breakdown[i];
      y -= 18;
      if (i % 2 === 0) {
        page.drawRectangle({
          x: 40,
          y: y - 4,
          width: 515,
          height: 16,
          color: rgb(0.97, 0.98, 0.99),
        });
      }
      const pct = totalAnnualLoss > 0
        ? ((item.loss / totalAnnualLoss) * 100).toFixed(1)
        : "0.0";
      page.drawText(item.name, {
        x: 50,
        y,
        size: 8.5,
        font: fontRegular,
        color: rgb(0.15, 0.15, 0.15),
      });
      page.drawText(formatNaira(item.loss), {
        x: 310,
        y,
        size: 8.5,
        font: fontBold,
        color: rgb(0.1, 0.1, 0.1),
      });
      page.drawText(`${pct}%`, {
        x: 480,
        y,
        size: 8.5,
        font: fontRegular,
        color: rgb(0.3, 0.3, 0.3),
      });
    }

    // 3-Year Forecast
    y -= 40;
    page.drawRectangle({
      x: 40,
      y: y - 45,
      width: 515,
      height: 50,
      color: rgb(0.97, 0.97, 0.97),
      borderColor: rgb(0.85, 0.85, 0.85),
      borderWidth: 0.5,
    });
    page.drawText("3-YEAR EXPOSURE FORECAST", {
      x: 55,
      y: y - 15,
      size: 9,
      font: fontBold,
      color: alertRed,
    });
    page.drawText(
      `At current unmonitored loss rates, ${organization} will absorb ${formatNaira(threeYearLoss)} in unrecoverable fuel costs over 36 months.`,
      {
        x: 55,
        y: y - 30,
        size: 8.5,
        font: fontRegular,
        color: rgb(0.2, 0.2, 0.2),
      },
    );
    page.drawText(
      `Estimated lost fuel volume: ~${unaccountedLitres.toLocaleString("en-NG")} Litres of Diesel.`,
      {
        x: 55,
        y: y - 41,
        size: 8.5,
        font: fontBold,
        color: rgb(0.1, 0.1, 0.1),
      },
    );

    // CTA Box
    y -= 130;
    page.drawRectangle({
      x: 40,
      y: y,
      width: 515,
      height: 100,
      color: darkBackground,
    });
    page.drawRectangle({
      x: 40,
      y: y,
      width: 5,
      height: 100,
      color: emeraldGreen,
    });
    page.drawText("NEXT STEP: DEPLOY FREE SENTINEL PILOT", {
      x: 60,
      y: y + 75,
      size: 10,
      font: fontBold,
      color: emeraldGreen,
    });
    page.drawText(
      "Verify these financial loss figures against live operational data at zero cost.",
      {
        x: 60,
        y: y + 58,
        size: 8.5,
        font: fontRegular,
        color: textLight,
      },
    );
    page.drawText(
      "Visit the link below to request a 2-4 week hardware pilot.",
      {
        x: 60,
        y: y + 44,
        size: 8.5,
        font: fontRegular,
        color: textMuted,
      },
    );

    // === CLICKABLE LINK ===
    const linkUrl = "https://echolevel.vercel.app/sentinel/connect";
    page.drawText("URL: echolevel.vercel.app/sentinel/connect", {
      x: 60,
      y: y + 20,
      size: 9,
      font: fontBold,
      color: emeraldGreen,
    });

    const linkAnnotation = pdfDoc.context.obj({
      Type: "Annot",
      Subtype: "Link",
      Rect: [60, y + 12, 360, y + 32],
      Border: [0, 0, 0],
      A: {
        Type: "Action",
        S: "URI",
        URI: PDFString.of(linkUrl),
      },
    });

    const annotsKey = PDFName.of("Annots");
    let annots = page.node.lookup(annotsKey, PDFArray);
    if (!annots) {
      annots = pdfDoc.context.obj([]) as PDFArray;
      page.node.set(annotsKey, annots);
    }
    annots.push(linkAnnotation);

    // Footer
    page.drawLine({
      start: { x: 40, y: 45 },
      end: { x: 555, y: 45 },
      thickness: 0.5,
      color: rgb(0.85, 0.85, 0.85),
    });
    page.drawText(
      "EchoLevel Sentinel Limited · Industrial Telemetry & Fuel Verification Systems",
      {
        x: 40,
        y: 30,
        size: 8,
        font: fontBold,
        color: rgb(0.4, 0.4, 0.4),
      },
    );
    page.drawText(
      "Ibadan, Oyo State, Nigeria · echolevel.vercel.app/sentinel/connect",
      {
        x: 40,
        y: 18,
        size: 8,
        font: fontRegular,
        color: rgb(0.6, 0.6, 0.6),
      },
    );

    // Watermark
    page.drawText("CONFIDENTIAL PREVIEW — OFFICIAL COPY SENT TO EMAIL", {
      x: 70,
      y: 420,
      size: 14,
      font: fontBold,
      color: rgb(0.85, 0.2, 0.2),
      opacity: 0.28,
      rotate: { type: "degrees", angle: 32 },
    });

    const pdfBytes = await pdfDoc.save();

    // Safe base64 conversion
    let binary = "";
    for (let i = 0; i < pdfBytes.length; i++) {
      binary += String.fromCharCode(pdfBytes[i]);
    }
    const base64Pdf = btoa(binary);

    // ──────────────────────────────
    // Send via Brevo
    // ──────────────────────────────
    const BREVO_API_KEY = Deno.env.get("BREVO_API_KEY");

    if (BREVO_API_KEY) {
      try {
        const brevoRes = await fetch("https://api.brevo.com/v3/smtp/email", {
          method: "POST",
          headers: {
            "api-key": BREVO_API_KEY,
            "Content-Type": "application/json",
            "Accept": "application/json",
          },
          body: JSON.stringify({
            sender: {
              name: "EchoLevel Sentinel",
              email: "launchbypatrick.webdev@gmail.com",
            },
            to: [
              {
                email: email,
                name: organization || "Valued Client",
              },
            ],
            subject: `Sentinel Audit Report – ${organization} (${auditId})`,
            htmlContent: `
              <p>Hello,</p>
              <p>Your official high-resolution <strong>Fuel Loss Exposure Audit</strong> is attached.</p>
              <p>
                <strong>Organisation:</strong> ${organization}<br>
                <strong>Audit ID:</strong> ${auditId}<br>
                <strong>Estimated Annual Loss:</strong> ${formatNaira(totalAnnualLoss)}
              </p>
              <p>This is the full report. The in-app preview is intentionally limited.</p>
              <p>Best regards,<br>EchoLevel Sentinel Team</p>
            `,
            attachment: [
              {
                name: `Sentinel_Audit_Report_${auditId}.pdf`,
                content: base64Pdf,
              },
            ],
          }),
        });

        if (!brevoRes.ok) {
          const errData = await brevoRes.json();
          console.error("Brevo API Error:", errData);
        } else {
          console.log("Email sent successfully via Brevo");
        }
      } catch (err) {
        console.error("Brevo request failed:", err);
      }
    } else {
      console.warn("BREVO_API_KEY not set – skipping email");
    }

    return new Response(
      JSON.stringify({
        success: true,
        email,
        auditId,
        previewBase64: base64Pdf,
      }),
      {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
        status: 200,
      },
    );
  } catch (error) {
    console.error("Function error:", error);
    return new Response(
      JSON.stringify({
        success: false,
        error: (error as Error).message,
      }),
      {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
        status: 400,
      },
    );
  }
});