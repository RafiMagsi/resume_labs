import PDFDocument from "pdfkit";
import https from "https";
import http from "http";
import { ResumeData, formatDate, createPdfBuffer } from "../types";

const PAGE_MARGIN = 40;
const CONTENT_WIDTH = 595.28 - PAGE_MARGIN * 2;
const PHOTO_DIAMETER = 64;
const PHOTO_RADIUS = PHOTO_DIAMETER / 2;
const PHOTO_GAP = 16;
const HEADER_BOTTOM_GAP = 18;

async function downloadImage(url: string): Promise<Buffer | null> {
  return new Promise((resolve) => {
    if (!url) {
      resolve(null);
      return;
    }
    try {
      const protocol = url.startsWith("https") ? https : http;
      const timeout = setTimeout(() => resolve(null), 8000);
      protocol.get(url, { timeout: 8000 }, (response) => {
        clearTimeout(timeout);
        if (response.statusCode !== 200) { resolve(null); return; }
        const chunks: Buffer[] = [];
        response.on("data", (chunk) => chunks.push(chunk));
        response.on("end", () => resolve(Buffer.concat(chunks)));
        response.on("error", () => resolve(null));
      }).on("error", () => resolve(null));
    } catch (error) { resolve(null); }
  });
}

export async function generateHealthcareTemplate(resumeData: ResumeData): Promise<Buffer> {
  return new Promise(async (resolve, reject) => {
    try {
      const doc = new PDFDocument({ size: "A4", margin: PAGE_MARGIN });
      const accentColor = "#0F766E";
      const textColor = "#374151";
      const mutedColor = "#6B7280";
      const dividerColor = "#D1FAE5";

      let imageBuffer: Buffer | null = null;
      if (resumeData.photoUrl) imageBuffer = await downloadImage(resumeData.photoUrl);

      buildHeader(doc, resumeData, imageBuffer, { accentColor, mutedColor, dividerColor });

      addSection(doc, "Professional Profile", "#0F766E", dividerColor, () => {
        writeBodyText(doc, resumeData.personalSummary?.trim() || "No personal summary provided.", textColor);
      });

      addSection(doc, "Clinical Experience", "#0F766E", dividerColor, () => {
        if (!resumeData.workExperiences?.length) return writeBodyText(doc, "No work experience added.", textColor);
        resumeData.workExperiences.forEach((exp, index) => {
          writeWorkExperience(doc, exp, { accentColor, mutedColor, textColor });
          if (index < resumeData.workExperiences.length - 1) doc.moveDown(0.9);
        });
      });

      addSection(doc, "Education & Training", "#0F766E", dividerColor, () => {
        if (!resumeData.educations?.length) return writeBodyText(doc, "No education added.", textColor);
        resumeData.educations.forEach((edu, index) => {
          writeEducation(doc, edu, { accentColor, mutedColor });
          if (index < resumeData.educations.length - 1) doc.moveDown(0.8);
        });
      });

      addSection(doc, "Certifications & Highlights", "#0F766E", dividerColor, () => {
        const extraData = resumeData as any;
        const projectItems = Array.isArray(extraData.projects) ? extraData.projects : [];
        const achievementItems = Array.isArray(extraData.achievements) ? extraData.achievements : Array.isArray(extraData.awards) ? extraData.awards : [];
        const publicationItems = Array.isArray(extraData.publications) ? extraData.publications : [];
        if (!projectItems.length && !achievementItems.length && !publicationItems.length) return writeBodyText(doc, "No additional highlights added.", textColor);
        if (projectItems.length) writeMiniListBlock(doc, "Projects", projectItems, { textColor, mutedColor });
        if (achievementItems.length) writeMiniListBlock(doc, "Achievements", achievementItems, { textColor, mutedColor });
        if (publicationItems.length) writeMiniListBlock(doc, "Publications", publicationItems, { textColor, mutedColor });
      });

      addSection(doc, "Skills", "#0F766E", dividerColor, () => {
        if (!resumeData.skills?.length) return writeBodyText(doc, "No skills added.", textColor);
        const skillsLine = resumeData.skills.map((skill) => skill.category?.trim() ? `${skill.name} - ${skill.category}` : skill.name).join(" • ");
        writeBodyText(doc, skillsLine, textColor);
      });

      doc.end();
      createPdfBuffer(doc).then(resolve).catch(reject);
    } catch (error) { reject(error); }
  });
}

function buildHeader(doc: PDFKit.PDFDocument, resumeData: ResumeData, imageBuffer: Buffer | null, colors: { accentColor: string; mutedColor: string; dividerColor: string; }): void {
  const hasPhotoSlot = Boolean(resumeData.photoUrl);
  const headerStartY = doc.y;
  const photoX = PAGE_MARGIN + CONTENT_WIDTH - PHOTO_DIAMETER;
  const photoY = headerStartY;
  const textColumnWidth = hasPhotoSlot ? CONTENT_WIDTH - PHOTO_DIAMETER - PHOTO_GAP : CONTENT_WIDTH;

  doc.rect(PAGE_MARGIN, headerStartY, CONTENT_WIDTH, 4).fill(colors.accentColor);

  const titleY = headerStartY + 14;
  if (hasPhotoSlot) {
    if (imageBuffer) {
      try {
        doc.save();
        doc.circle(photoX + PHOTO_RADIUS, photoY + PHOTO_RADIUS, PHOTO_RADIUS);
        doc.clip();
        doc.image(imageBuffer, photoX, photoY, { width: PHOTO_DIAMETER, height: PHOTO_DIAMETER });
        doc.restore();
        doc.circle(photoX + PHOTO_RADIUS, photoY + PHOTO_RADIUS, PHOTO_RADIUS).lineWidth(1).stroke(colors.dividerColor);
      } catch (error) {
        drawPhotoPlaceholder(doc, photoX, photoY, PHOTO_DIAMETER, colors.dividerColor, colors.mutedColor);
      }
    } else {
      drawPhotoPlaceholder(doc, photoX, photoY, PHOTO_DIAMETER, colors.dividerColor, colors.mutedColor);
    }
  }

  doc.font("Helvetica-Bold").fontSize(25).fillColor(colors.accentColor).text(resumeData.title?.trim() || "Untitled Resume", PAGE_MARGIN, titleY, { width: textColumnWidth, align: "left" });
  const titleBottomY = doc.y;
  doc.font("Helvetica").fontSize(10.5).fillColor(colors.mutedColor).text("Healthcare Resume", PAGE_MARGIN, titleBottomY + 4, { width: textColumnWidth, align: "left" });
  const dividerY = Math.max(doc.y, hasPhotoSlot ? photoY + PHOTO_DIAMETER : titleY) + HEADER_BOTTOM_GAP;
  doc.strokeColor(colors.dividerColor).lineWidth(1).moveTo(PAGE_MARGIN, dividerY).lineTo(PAGE_MARGIN + CONTENT_WIDTH, dividerY).stroke();
  doc.y = dividerY + 16;
}

function drawPhotoPlaceholder(doc: PDFKit.PDFDocument, x: number, y: number, size: number, borderColor: string, mutedColor: string): void {
  const radius = size / 2;
  doc.save().circle(x + radius, y + radius, radius).fillAndStroke("#F8FAFC", borderColor).restore();
  doc.font("Helvetica").fontSize(9).fillColor(mutedColor).text("Photo", x, y + radius - 5, { width: size, align: "center" });
}

function addSection(doc: PDFKit.PDFDocument, title: string, titleColor: string, dividerColor: string, renderContent: () => void): void {
  doc.font("Helvetica-Bold").fontSize(11).fillColor(titleColor).text(title.toUpperCase(), PAGE_MARGIN, doc.y, { width: CONTENT_WIDTH, characterSpacing: 1.1 });
  doc.moveDown(0.18);
  const dividerY = doc.y;
  doc.strokeColor(dividerColor).lineWidth(1).moveTo(PAGE_MARGIN, dividerY).lineTo(PAGE_MARGIN + CONTENT_WIDTH, dividerY).stroke();
  doc.y = dividerY + 12;
  renderContent();
  doc.moveDown(1.05);
}

function writeWorkExperience(doc: PDFKit.PDFDocument, exp: ResumeData["workExperiences"][number], colors: { accentColor: string; mutedColor: string; textColor: string; }): void {
  doc.font("Helvetica-Bold").fontSize(12.2).fillColor(colors.accentColor).text(exp.role?.trim() || "Untitled Role", PAGE_MARGIN, doc.y, { width: CONTENT_WIDTH });
  const companyLocation = [exp.company?.trim(), exp.location?.trim()].filter(Boolean).join(" - ");
  if (companyLocation) { doc.moveDown(0.12); doc.font("Helvetica").fontSize(10.3).fillColor("#4B5563").text(companyLocation, PAGE_MARGIN, doc.y, { width: CONTENT_WIDTH }); }
  const start = formatDate(exp.startDate); const end = exp.endDate ? formatDate(exp.endDate) : "Present";
  doc.moveDown(0.1); doc.font("Helvetica").fontSize(9.8).fillColor(colors.mutedColor).text(`${start} - ${end}`, PAGE_MARGIN, doc.y, { width: CONTENT_WIDTH });
  if (exp.bulletPoints?.length) {
    doc.moveDown(0.3);
    exp.bulletPoints.forEach((bullet) => {
      const text = bullet?.trim(); if (!text) return;
      const currentY = doc.y;
      doc.font("Helvetica").fontSize(10.2).fillColor("#0F766E").text("•", PAGE_MARGIN, currentY, { width: 8 });
      doc.font("Helvetica").fontSize(10.2).fillColor(colors.textColor).text(text, PAGE_MARGIN + 12, currentY, { width: CONTENT_WIDTH - 12, lineGap: 3 });
    });
  }
}

function writeEducation(doc: PDFKit.PDFDocument, edu: ResumeData["educations"][number], colors: { accentColor: string; mutedColor: string; }): void {
  const degreeLine = [edu.degree?.trim(), edu.field?.trim()].filter(Boolean).join(" in ") || "Education";
  doc.font("Helvetica-Bold").fontSize(11.8).fillColor(colors.accentColor).text(degreeLine, PAGE_MARGIN, doc.y, { width: CONTENT_WIDTH });
  const schoolLine = edu.school?.trim() || "";
  if (schoolLine) { doc.moveDown(0.12); doc.font("Helvetica").fontSize(10.3).fillColor("#4B5563").text(schoolLine, PAGE_MARGIN, doc.y, { width: CONTENT_WIDTH }); }
  const grad = edu.graduationDate ? formatDate(edu.graduationDate) : "";
  const meta = [grad ? `Graduation: ${grad}` : null, edu.gpa ? `GPA: ${edu.gpa}` : null].filter(Boolean).join(" - ");
  if (meta) { doc.moveDown(0.1); doc.font("Helvetica").fontSize(9.8).fillColor(colors.mutedColor).text(meta, PAGE_MARGIN, doc.y, { width: CONTENT_WIDTH }); }
}

function writeMiniListBlock(doc: PDFKit.PDFDocument, label: string, items: any[], colors: { textColor: string; mutedColor: string }): void {
  doc.font("Helvetica-Bold").fontSize(9.8).fillColor(colors.mutedColor).text(label.toUpperCase(), PAGE_MARGIN, doc.y, { width: CONTENT_WIDTH });
  doc.moveDown(0.15);
  items.slice(0, 3).forEach((item) => {
    const text = typeof item === "string" ? item : item?.name || item?.title || item?.label || JSON.stringify(item);
    doc.font("Helvetica").fontSize(9.8).fillColor(colors.textColor).text(`• ${text}`, PAGE_MARGIN + 8, doc.y, { width: CONTENT_WIDTH - 8, lineGap: 2 });
  });
  doc.moveDown(0.25);
}

function writeBodyText(doc: PDFKit.PDFDocument, text: string, textColor: string): void {
  doc.font("Helvetica").fontSize(10.6).fillColor(textColor).text(text, PAGE_MARGIN, doc.y, { width: CONTENT_WIDTH, lineGap: 4 });
}
