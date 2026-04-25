import PDFDocument from "pdfkit";
import { createPdfBuffer, ResumeData } from "../types";
import {
  downloadImage,
  drawDivider,
  ensureSpace,
  readExtraLists,
  renderPhoto,
  renderSectionHeading,
  writeBodyText,
  writeEducationBlock,
  writeTwoColumnList,
  writeWorkExperienceBlock,
  Frame,
} from "./_shared";

const PAGE_MARGIN = 36;
const SIDEBAR_WIDTH = 170;
const COLUMN_GAP = 20;
const SIDEBAR_PADDING_X = 16;

const SIDEBAR_BG = "#064E3B";
const SIDEBAR_TEXT = "#FFFFFF";
const SIDEBAR_MUTED = "#D1FAE5";
const SIDEBAR_DIVIDER = "rgba(255,255,255,0.22)";

const ACCENT = "#0F766E";
const TEXT = "#334155";
const MUTED = "#6B7280";
const DIVIDER = "#E5E7EB";

const PHOTO_SIZE = 72;

export async function generateHealthcareTemplate(resumeData: ResumeData): Promise<Buffer> {
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
  buildMainHeader(doc, "Healthcare Resume", mainFrame);
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
    renderPhoto(doc, imageBuffer, photoX, y, PHOTO_SIZE, "circle", "#FFFFFF", "#065F46", SIDEBAR_MUTED);
    y += PHOTO_SIZE + 18;
  }

  doc
    .font("Helvetica-Bold")
    .fontSize(15.6)
    .fillColor(SIDEBAR_TEXT)
    .text(resumeData.title?.trim() || "Untitled Resume", frame.x, y, { width: frame.width });
  y = doc.y + 14;

  const extras = readExtraLists(resumeData);
  if (extras.achievements.length) {
    y = renderSidebarHeading(doc, "LICENSURE", frame, y);
    extras.achievements.slice(0, 10).forEach((line) => {
      if (y + 14 > bottomLimit) return;
      doc
        .font("Helvetica")
        .fontSize(8.8)
        .fillColor(SIDEBAR_MUTED)
        .text(`• ${line}`, frame.x, y, { width: frame.width, lineGap: 2 });
      y = doc.y + 5;
    });
    y += 10;
  }

  const competencies = resumeData.skills.map((s) => s.name).filter((s) => s.trim());
  if (competencies.length) {
    y = renderSidebarHeading(doc, "COMPETENCIES", frame, y);
    competencies.slice(0, 16).forEach((line) => {
      if (y + 14 > bottomLimit) return;
      doc
        .font("Helvetica")
        .fontSize(8.8)
        .fillColor(SIDEBAR_MUTED)
        .text(line, frame.x, y, { width: frame.width, lineGap: 2 });
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
    .fontSize(9.9)
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

function buildMainHeader(doc: PDFKit.PDFDocument, subtitle: string, frame: Frame): void {
  const startY = doc.page.margins.top;
  doc.rect(frame.x, startY, frame.width, 4).fill(ACCENT);

  const titleY = startY + 14;
  doc
    .font("Helvetica-Bold")
    .fontSize(24)
    .fillColor("#111111")
    .text("Healthcare", frame.x, titleY, { width: frame.width, align: "left" });

  const bottomY = doc.y;
  doc
    .font("Helvetica")
    .fontSize(10.5)
    .fillColor(MUTED)
    .text(subtitle, frame.x, bottomY + 4, { width: frame.width });

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

  renderSectionHeading(doc, "Clinical Summary", headingStyle, frame);
  writeBodyText(doc, resumeData.personalSummary?.trim() || "No personal summary provided.", { color: TEXT }, frame);
  doc.moveDown(1.0);

  renderSectionHeading(doc, "Experience", headingStyle, frame);
  if (!resumeData.workExperiences?.length) {
    writeBodyText(doc, "No work experience added.", { color: TEXT }, frame);
  } else {
    resumeData.workExperiences.forEach((exp, index) => {
      writeWorkExperienceBlock(
        doc,
        exp,
        {
          roleColor: "#111111",
          companyColor: "#4B5563",
          dateColor: MUTED,
          bodyColor: TEXT,
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
      writeEducationBlock(doc, edu, { degreeColor: "#111111", schoolColor: "#4B5563", metaColor: MUTED }, frame);
      if (index < resumeData.educations.length - 1) doc.moveDown(0.8);
    });
  }

  const extras = readExtraLists(resumeData);
  if (extras.projects.length) {
    doc.moveDown(1.0);
    renderSectionHeading(doc, "Projects & Volunteering", headingStyle, frame);
    extras.projects.slice(0, 8).forEach((line) => {
      ensureSpace(doc, 18);
      writeBodyText(doc, `• ${line}`, { color: TEXT, fontSize: 10.2 }, frame);
    });
  }

  if (resumeData.skills.length) {
    doc.moveDown(1.0);
    renderSectionHeading(doc, "Core Competencies", headingStyle, frame);
    const lines = resumeData.skills.map((s) => s.name).filter((s) => s.trim());
    writeTwoColumnList(doc, lines, { color: TEXT, fontSize: 10.1, columnGap: 18, bulletMarker: "•" }, frame);
  }
}

