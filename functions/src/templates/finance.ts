import PDFDocument from "pdfkit";
import { createPdfBuffer, ResumeData } from "../types";
import {
  downloadImage,
  drawDivider,
  ensureSpace,
  getContactLine,
  getDisplayHeadline,
  getDisplayName,
  readExtraLists,
  renderPhoto,
  renderSectionHeading,
  writeBodyText,
  writeEducationBlockDateRight,
  writeTwoColumnList,
  writeWorkExperienceBlockDateRight,
  Frame,
} from "./_shared";

const PAGE_MARGIN = 40;
const SIDEBAR_WIDTH = 172;
const COLUMN_GAP = 20;
const SIDEBAR_PADDING_X = 16;

const SIDEBAR_BG = "#0F172A";
const SIDEBAR_TEXT = "#FFFFFF";
const SIDEBAR_MUTED = "#CBD5E1";
const SIDEBAR_DIVIDER = "rgba(255,255,255,0.22)";

const ACCENT = "#1E3A8A";
const TEXT = "#374151";
const MUTED = "#6B7280";
const DIVIDER = "#E5E7EB";

const PHOTO_SIZE = 70;

export async function generateFinanceTemplate(resumeData: ResumeData): Promise<Buffer> {
  const doc = new PDFDocument({ size: "A4", margin: PAGE_MARGIN });

  const drawSidebarBackground = () => {
    doc.save();
    doc.rect(0, 0, SIDEBAR_WIDTH, doc.page.height).fill(SIDEBAR_BG);
    doc.restore();
  };
  drawSidebarBackground();
  doc.on("pageAdded", drawSidebarBackground);

  const imageBuffer = await downloadImage(resumeData.photoUrl);

  const sidebarFrame: Frame = {
    x: SIDEBAR_PADDING_X,
    width: SIDEBAR_WIDTH - SIDEBAR_PADDING_X * 2,
  };
  const mainFrame: Frame = {
    x: SIDEBAR_WIDTH + COLUMN_GAP,
    width: doc.page.width - (SIDEBAR_WIDTH + COLUMN_GAP) - PAGE_MARGIN,
  };

  buildSidebar(doc, resumeData, imageBuffer, sidebarFrame);
  buildMainHeader(doc, resumeData, mainFrame);
  buildMainContent(doc, resumeData, mainFrame);

  doc.end();
  return createPdfBuffer(doc);
}

function buildSidebar(
  doc: PDFKit.PDFDocument,
  resumeData: ResumeData,
  imageBuffer: Buffer | null,
  frame: Frame,
): void {
  const bottomLimit = doc.page.height - doc.page.margins.bottom;
  let y = doc.page.margins.top;

  if (resumeData.photoUrl) {
    const photoX = Math.round((SIDEBAR_WIDTH - PHOTO_SIZE) / 2);
    renderPhoto(doc, imageBuffer, photoX, y, PHOTO_SIZE, "square", "#FFFFFF", "#111827", SIDEBAR_MUTED);
    y += PHOTO_SIZE + 18;
  }

  doc
    .font("Helvetica-Bold")
    .fontSize(15.8)
    .fillColor(SIDEBAR_TEXT)
    .text(getDisplayName(resumeData), frame.x, y, { width: frame.width });

  const headline = getDisplayHeadline(resumeData);
  if (headline) {
    doc
      .font("Helvetica")
      .fontSize(9.2)
      .fillColor(SIDEBAR_MUTED)
      .text(headline, frame.x, doc.y + 4, { width: frame.width });
  }

  const contactLine = getContactLine(resumeData);
  if (contactLine) {
    doc
      .font("Helvetica")
      .fontSize(8.6)
      .fillColor(SIDEBAR_MUTED)
      .text(contactLine, frame.x, doc.y + 6, { width: frame.width, lineGap: 2 });
  }

  y = doc.y + 14;

  const extras = readExtraLists(resumeData);
  const certifications = extras.achievements.slice(0, 10);

  const skills = resumeData.skills
    .map((s) => (s.category?.trim() ? `${s.name} (${s.category})` : s.name))
    .filter((s) => s.trim());

  if (skills.length) {
    y = renderSidebarHeading(doc, "CORE COMPETENCIES", frame, y);
    skills.slice(0, 14).forEach((line) => {
      if (y + 14 > bottomLimit) return;
      doc
        .font("Helvetica")
        .fontSize(8.7)
        .fillColor(SIDEBAR_MUTED)
        .text(line, frame.x, y, { width: frame.width, lineGap: 2 });
      y = doc.y + 5;
    });
    y += 10;
  }

  if (certifications.length) {
    y = renderSidebarHeading(doc, "CERTIFICATIONS", frame, y);
    certifications.forEach((line) => {
      if (y + 14 > bottomLimit) return;
      doc
        .font("Helvetica")
        .fontSize(8.7)
        .fillColor(SIDEBAR_MUTED)
        .text(`• ${line}`, frame.x, y, { width: frame.width, lineGap: 2 });
      y = doc.y + 5;
    });
  }
}

function renderSidebarHeading(
  doc: PDFKit.PDFDocument,
  title: string,
  frame: Frame,
  y: number,
): number {
  doc
    .font("Helvetica-Bold")
    .fontSize(9.8)
    .fillColor(SIDEBAR_TEXT)
    .text(title, frame.x, y, { width: frame.width, characterSpacing: 0.9 });

  const dividerY = doc.y + 6;
  doc
    .strokeColor(SIDEBAR_DIVIDER)
    .lineWidth(1)
    .moveTo(frame.x, dividerY)
    .lineTo(frame.x + frame.width, dividerY)
    .stroke();

  return dividerY + 10;
}

function buildMainHeader(doc: PDFKit.PDFDocument, resumeData: ResumeData, frame: Frame): void {
  const startY = doc.page.margins.top;
  doc.rect(frame.x, startY, frame.width, 4).fill(ACCENT);

  const titleY = startY + 14;
  doc
    .font("Helvetica-Bold")
    .fontSize(24)
    .fillColor("#111111")
    .text(getDisplayName(resumeData), frame.x, titleY, {
      width: frame.width,
      align: "left",
    });

  const bottomY = doc.y;
  const headline = getDisplayHeadline(resumeData);
  if (headline) {
    doc
      .font("Helvetica")
      .fontSize(10.5)
      .fillColor(MUTED)
      .text(headline, frame.x, bottomY + 4, { width: frame.width });
  }

  const dividerY = doc.y + 18;
  drawDivider(doc, frame.x, dividerY, frame.width, DIVIDER, 1);
  doc.y = dividerY + 14;
}

function buildMainContent(doc: PDFKit.PDFDocument, resumeData: ResumeData, frame: Frame): void {
  const headingStyle = {
    titleColor: ACCENT,
    dividerColor: DIVIDER,
    fontSize: 10.8,
    uppercase: true,
    characterSpacing: 1.1,
    gapAfterDivider: 10,
  } as const;

  renderSectionHeading(doc, "Financial Summary", headingStyle, frame);
  writeBodyText(doc, resumeData.personalSummary?.trim() || "No personal summary provided.", { color: TEXT }, frame);
  doc.moveDown(1.0);

  const extras = readExtraLists(resumeData);
  const achievements = extras.achievements.slice(0, 6);
  if (achievements.length) {
    renderSectionHeading(doc, "Key Achievements", headingStyle, frame);
    achievements.forEach((line) => {
      ensureSpace(doc, 18);
      writeBodyText(doc, `• ${line}`, { color: TEXT, fontSize: 10.2 }, frame);
    });
    doc.moveDown(1.0);
  }

  renderSectionHeading(doc, "Professional Experience", headingStyle, frame);
  if (!resumeData.workExperiences?.length) {
    writeBodyText(doc, "No work experience added.", { color: TEXT }, frame);
  } else {
    resumeData.workExperiences.forEach((exp, index) => {
      writeWorkExperienceBlockDateRight(
        doc,
        exp,
        {
          roleColor: "#111111",
          companyColor: "#4B5563",
          dateColor: MUTED,
          bodyColor: TEXT,
          dateWidth: 140,
          gap: 12,
          bullet: {
            marker: "•",
            markerColor: ACCENT,
            textColor: TEXT,
            fontSize: 10.2,
            lineGap: 3,
            indent: 12,
          },
        },
        frame,
      );
      if (index < resumeData.workExperiences.length - 1) doc.moveDown(0.9);
    });
  }
  doc.moveDown(1.0);

  renderSectionHeading(doc, "Education", headingStyle, frame);
  if (!resumeData.educations?.length) {
    writeBodyText(doc, "No education added.", { color: TEXT }, frame);
  } else {
    resumeData.educations.forEach((edu, index) => {
      writeEducationBlockDateRight(
        doc,
        edu,
        {
          degreeColor: "#111111",
          schoolColor: "#4B5563",
          metaColor: MUTED,
          dateColor: MUTED,
          dateWidth: 140,
          gap: 12,
        },
        frame,
      );
      if (index < resumeData.educations.length - 1) doc.moveDown(0.8);
    });
  }

  doc.moveDown(1.0);
  renderSectionHeading(doc, "Skills", headingStyle, frame);
  if (!resumeData.skills?.length) {
    writeBodyText(doc, "No skills added.", { color: TEXT }, frame);
  } else {
    const lines = resumeData.skills
      .map((s) => (s.category?.trim() ? `${s.name} - ${s.category}` : s.name))
      .filter((s) => s.trim());
    writeTwoColumnList(doc, lines, { color: TEXT, fontSize: 10.1, columnGap: 18, bulletMarker: "•" }, frame);
  }
}
