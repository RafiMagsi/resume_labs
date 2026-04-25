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
  writeWorkExperienceBlock,
  Frame,
} from "./_shared";

const PAGE_MARGIN = 36;
const SIDEBAR_WIDTH = 170;
const COLUMN_GAP = 20;
const SIDEBAR_PADDING_X = 16;

const SIDEBAR_BG = "#1F2937";
const SIDEBAR_TEXT = "#FFFFFF";
const SIDEBAR_MUTED = "#CBD5E1";

const PRIMARY = "#2563EB";
const TEXT = "#334155";
const MUTED = "#6B7280";
const DIVIDER = "#E2E8F0";

const PHOTO_SIZE = 76;

export async function generateModernSidebarTemplate(resumeData: ResumeData): Promise<Buffer> {
  const doc = new PDFDocument({ size: "A4", margin: PAGE_MARGIN });

  const drawSidebarBackground = () => {
    doc.save();
    doc.rect(0, 0, SIDEBAR_WIDTH, doc.page.height).fill(SIDEBAR_BG);
    doc.restore();
  };

  drawSidebarBackground();
  doc.on("pageAdded", () => {
    drawSidebarBackground();
  });

  const imageBuffer = await downloadImage(resumeData.photoUrl);

  const sidebarFrame: Frame = {
    x: SIDEBAR_PADDING_X,
    width: SIDEBAR_WIDTH - SIDEBAR_PADDING_X * 2,
  };
  const mainFrame: Frame = {
    x: SIDEBAR_WIDTH + COLUMN_GAP,
    width: doc.page.width - (SIDEBAR_WIDTH + COLUMN_GAP) - PAGE_MARGIN,
  };

  const remainingSkills = buildSidebar(doc, resumeData, imageBuffer, sidebarFrame);
  buildMainHeader(doc, resumeData, mainFrame);
  buildMainContent(doc, resumeData, mainFrame, remainingSkills);

  doc.end();
  return createPdfBuffer(doc);
}

function buildSidebar(
  doc: PDFKit.PDFDocument,
  resumeData: ResumeData,
  imageBuffer: Buffer | null,
  frame: Frame,
): string[] {
  const bottomLimit = doc.page.height - doc.page.margins.bottom;
  let y = doc.page.margins.top;

  if (resumeData.photoUrl) {
    const photoX = Math.round((SIDEBAR_WIDTH - PHOTO_SIZE) / 2);
    renderPhoto(
      doc,
      imageBuffer,
      photoX,
      y,
      PHOTO_SIZE,
      "circle",
      "#FFFFFF",
      "#374151",
      SIDEBAR_MUTED,
    );
    y += PHOTO_SIZE + 18;
  }

  doc
    .font("Helvetica-Bold")
    .fontSize(16.5)
    .fillColor(SIDEBAR_TEXT)
    .text(resumeData.title?.trim() || "Untitled Resume", frame.x, y, {
      width: frame.width,
      align: "left",
    });
  y = doc.y + 10;

  doc
    .font("Helvetica")
    .fontSize(9.5)
    .fillColor(SIDEBAR_MUTED)
    .text("Modern Sidebar Resume", frame.x, y, { width: frame.width, align: "left" });
  y = doc.y + 14;

  const contactLines = extractContactLines(resumeData);
  if (contactLines.length) {
    y = renderSidebarHeading(doc, "CONTACT", frame, y);
    contactLines.forEach((line) => {
      if (y + 14 > bottomLimit) return;
      doc
        .font("Helvetica")
        .fontSize(8.9)
        .fillColor(SIDEBAR_MUTED)
        .text(line, frame.x, y, { width: frame.width, lineGap: 2 });
      y = doc.y + 6;
    });
    y += 8;
  }

  const skillLines = resumeData.skills.map((s) =>
    s.category?.trim() ? `${s.name} - ${s.category}` : s.name,
  );

  const remainingSkills: string[] = [];
  if (skillLines.length) {
    y = renderSidebarHeading(doc, "SKILLS", frame, y);
    skillLines.forEach((line) => {
      if (y + 14 > bottomLimit) {
        remainingSkills.push(line);
        return;
      }
      doc
        .font("Helvetica")
        .fontSize(8.8)
        .fillColor(SIDEBAR_MUTED)
        .text(line, frame.x, y, { width: frame.width, lineGap: 2 });
      y = doc.y + 6;
    });
  }

  return remainingSkills;
}

function renderSidebarHeading(
  doc: PDFKit.PDFDocument,
  title: string,
  frame: Frame,
  y: number,
): number {
  doc
    .font("Helvetica-Bold")
    .fontSize(10.2)
    .fillColor(SIDEBAR_TEXT)
    .text(title, frame.x, y, { width: frame.width, characterSpacing: 1 });

  const dividerY = doc.y + 6;
  doc
    .strokeColor("rgba(255,255,255,0.22)")
    .lineWidth(1)
    .moveTo(frame.x, dividerY)
    .lineTo(frame.x + frame.width, dividerY)
    .stroke();

  return dividerY + 10;
}

function buildMainHeader(
  doc: PDFKit.PDFDocument,
  resumeData: ResumeData,
  frame: Frame,
): void {
  const startY = doc.page.margins.top;

  doc.rect(frame.x, startY, frame.width, 4).fill(PRIMARY);
  const titleY = startY + 14;

  doc
    .font("Helvetica-Bold")
    .fontSize(24)
    .fillColor("#111111")
    .text(resumeData.title?.trim() || "Untitled Resume", frame.x, titleY, {
      width: frame.width,
      align: "left",
    });

  const bottomY = doc.y;
  doc
    .font("Helvetica")
    .fontSize(10.5)
    .fillColor(MUTED)
    .text("Modern Sidebar Resume", frame.x, bottomY + 4, {
      width: frame.width,
      align: "left",
    });

  const dividerY = doc.y + 18;
  drawDivider(doc, frame.x, dividerY, frame.width, DIVIDER, 1);
  doc.y = dividerY + 14;
}

function buildMainContent(
  doc: PDFKit.PDFDocument,
  resumeData: ResumeData,
  frame: Frame,
  remainingSkills: string[],
): void {
  renderSectionHeading(
    doc,
    "Professional Summary",
    {
      titleColor: PRIMARY,
      dividerColor: DIVIDER,
      fontSize: 10.8,
      uppercase: true,
      characterSpacing: 1.1,
      gapAfterDivider: 10,
    },
    frame,
  );
  writeBodyText(doc, resumeData.personalSummary?.trim() || "No personal summary provided.", { color: TEXT }, frame);
  doc.moveDown(1.0);

  renderSectionHeading(
    doc,
    "Work Experience",
    {
      titleColor: PRIMARY,
      dividerColor: DIVIDER,
      fontSize: 10.8,
      uppercase: true,
      characterSpacing: 1.1,
      gapAfterDivider: 10,
    },
    frame,
  );
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
            markerColor: PRIMARY,
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

  renderSectionHeading(
    doc,
    "Education",
    {
      titleColor: PRIMARY,
      dividerColor: DIVIDER,
      fontSize: 10.8,
      uppercase: true,
      characterSpacing: 1.1,
      gapAfterDivider: 10,
    },
    frame,
  );
  if (!resumeData.educations?.length) {
    writeBodyText(doc, "No education added.", { color: TEXT }, frame);
  } else {
    resumeData.educations.forEach((edu, index) => {
      writeEducationBlock(
        doc,
        edu,
        {
          degreeColor: "#111111",
          schoolColor: "#4B5563",
          metaColor: MUTED,
        },
        frame,
      );
      if (index < resumeData.educations.length - 1) doc.moveDown(0.8);
    });
  }
  doc.moveDown(1.0);

  const extras = readExtraLists(resumeData);
  const extraSections: Array<{ title: string; items: string[] }> = [
    { title: "Projects", items: extras.projects },
    { title: "Achievements & Awards", items: extras.achievements },
    { title: "Publications", items: extras.publications },
    { title: "Interests", items: extras.interests },
    { title: "Languages", items: extras.languages },
    { title: "References", items: extras.references },
  ];

  extraSections.forEach(({ title, items }) => {
    if (!items.length) return;
    renderSectionHeading(
      doc,
      title,
      {
        titleColor: PRIMARY,
        dividerColor: DIVIDER,
        fontSize: 10.8,
        uppercase: true,
        characterSpacing: 1.1,
        gapAfterDivider: 10,
      },
      frame,
    );
    items.forEach((line) => {
      ensureSpace(doc, 18);
      writeBodyText(doc, `• ${line}`, { color: TEXT, fontSize: 10.2 }, frame);
    });
    doc.moveDown(1.0);
  });

  if (remainingSkills.length) {
    renderSectionHeading(
      doc,
      "Additional Skills",
      {
        titleColor: PRIMARY,
        dividerColor: DIVIDER,
        fontSize: 10.8,
        uppercase: true,
        characterSpacing: 1.1,
        gapAfterDivider: 10,
      },
      frame,
    );
    writeBodyText(doc, remainingSkills.join(" • "), { color: TEXT }, frame);
    doc.moveDown(0.5);
  }
}

function extractContactLines(resumeData: ResumeData): string[] {
  const extra = resumeData as any;
  const contact = (extra.contact ?? extra.personalDetails ?? extra.profile) as any;

  const lines: string[] = [];
  const email = extra.email ?? contact?.email;
  const phone = extra.phone ?? contact?.phone;
  const location = extra.location ?? contact?.location;
  const website = extra.website ?? contact?.website;
  const linkedin = extra.linkedin ?? contact?.linkedin;
  const github = extra.github ?? contact?.github;

  [email, phone, location, website, linkedin, github].forEach((v) => {
    if (typeof v === "string" && v.trim()) lines.push(v.trim());
  });

  return lines;
}

