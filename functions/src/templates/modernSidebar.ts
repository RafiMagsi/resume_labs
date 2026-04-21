import PDFDocument from "pdfkit";
import https from "https";
import http from "http";
import { ResumeData, formatDate, createPdfBuffer } from "../types";

const PAGE_MARGIN = 36;
const PAGE_WIDTH = 595.28;
const PAGE_HEIGHT = 841.89;
const SIDEBAR_WIDTH = 156;
const CONTENT_X = SIDEBAR_WIDTH + 20;
const CONTENT_WIDTH = PAGE_WIDTH - CONTENT_X - PAGE_MARGIN;
const PHOTO_DIAMETER = 76;
const PHOTO_RADIUS = PHOTO_DIAMETER / 2;
const HEADER_BOTTOM_GAP = 18;

async function downloadImage(url: string): Promise<Buffer | null> {
  return new Promise((resolve) => {
    if (!url) {
      resolve(null);
      return;
    }

    try {
      const protocol = url.startsWith("https") ? https : http;
      const timeout = setTimeout(() => {
        resolve(null);
      }, 8000);

      protocol
        .get(url, { timeout: 8000 }, (response) => {
          clearTimeout(timeout);
          if (response.statusCode !== 200) {
            resolve(null);
            return;
          }

          const chunks: Buffer[] = [];
          response.on("data", (chunk) => chunks.push(chunk));
          response.on("end", () => {
            resolve(Buffer.concat(chunks));
          });
          response.on("error", () => resolve(null));
        })
        .on("error", () => resolve(null));
    } catch (error) {
      resolve(null);
    }
  });
}

export async function generateModernSidebarTemplate(resumeData: ResumeData): Promise<Buffer> {
  return new Promise(async (resolve, reject) => {
    try {
      const doc = new PDFDocument({ size: "A4", margin: 0 });
      const sidebarColor = "#1F2937";
      const sidebarMuted = "#CBD5E1";
      const sidebarText = "#FFFFFF";
      const primaryColor = "#2563EB";
      const accentColor = "#111111";
      const textColor = "#334155";
      const mutedColor = "#6B7280";
      const dividerColor = "#E2E8F0";

      let imageBuffer: Buffer | null = null;
      if (resumeData.photoUrl) {
        imageBuffer = await downloadImage(resumeData.photoUrl);
      }

      doc.rect(0, 0, SIDEBAR_WIDTH, PAGE_HEIGHT).fill(sidebarColor);

      const sidebarState = buildSidebar(doc, resumeData, imageBuffer, {
        sidebarColor,
        sidebarMuted,
        sidebarText,
      });

      const contentStartY = buildMainHeader(doc, resumeData, {
        primaryColor,
        accentColor,
        mutedColor,
        dividerColor,
      });

      let contentY = contentStartY;

      contentY = addSection(doc, "Professional Summary", contentY, primaryColor, dividerColor, () => {
        const summary = resumeData.personalSummary?.trim() || "No personal summary provided.";
        writeBodyText(doc, summary, textColor, contentY);
        return doc.y;
      });

      contentY = addSection(doc, "Work Experience", contentY, primaryColor, dividerColor, () => {
        if (!resumeData.workExperiences || resumeData.workExperiences.length === 0) {
          writeBodyText(doc, "No work experience added.", textColor, contentY);
          return doc.y;
        }

        let currentY = contentY;
        resumeData.workExperiences.forEach((exp, index) => {
          currentY = writeWorkExperience(doc, exp, currentY, {
            accentColor,
            mutedColor,
            textColor,
            primaryColor,
          });
          if (index < resumeData.workExperiences.length - 1) {
            currentY += 14;
          }
        });
        return currentY;
      });

      contentY = addSection(doc, "Education", contentY, primaryColor, dividerColor, () => {
        if (!resumeData.educations || resumeData.educations.length === 0) {
          writeBodyText(doc, "No education added.", textColor, contentY);
          return doc.y;
        }

        let currentY = contentY;
        resumeData.educations.forEach((edu, index) => {
          currentY = writeEducation(doc, edu, currentY, {
            accentColor,
            mutedColor,
          });
          if (index < resumeData.educations.length - 1) {
            currentY += 12;
          }
        });
        return currentY;
      });

      const mainBottomY = contentY;
      const finalBottomY = Math.max(mainBottomY, sidebarState.sidebarBottomY);
      if (finalBottomY > doc.y) {
        doc.y = finalBottomY;
      }

      doc.end();
      createPdfBuffer(doc).then(resolve).catch(reject);
    } catch (error) {
      reject(error);
    }
  });
}

function buildSidebar(
  doc: PDFKit.PDFDocument,
  resumeData: ResumeData,
  imageBuffer: Buffer | null,
  colors: {
    sidebarColor: string;
    sidebarMuted: string;
    sidebarText: string;
  },
): { sidebarBottomY: number } {
  const centerX = SIDEBAR_WIDTH / 2;
  const photoX = centerX - PHOTO_RADIUS;
  const photoY = 36;

  if (resumeData.photoUrl) {
    if (imageBuffer) {
      try {
        doc.save();
        doc.circle(centerX, photoY + PHOTO_RADIUS, PHOTO_RADIUS);
        doc.clip();
        doc.image(imageBuffer, photoX, photoY, {
          width: PHOTO_DIAMETER,
          height: PHOTO_DIAMETER,
        });
        doc.restore();

        doc
          .circle(centerX, photoY + PHOTO_RADIUS, PHOTO_RADIUS)
          .lineWidth(1)
          .stroke("#FFFFFF");
      } catch (error) {
        drawSidebarPhotoPlaceholder(doc, photoX, photoY, PHOTO_DIAMETER);
      }
    } else {
      drawSidebarPhotoPlaceholder(doc, photoX, photoY, PHOTO_DIAMETER);
    }
  }

  let currentY = photoY + PHOTO_DIAMETER + 20;

  doc
    .font("Helvetica-Bold")
    .fontSize(18)
    .fillColor(colors.sidebarText)
    .text(resumeData.title?.trim() || "Untitled Resume", 16, currentY, {
      width: SIDEBAR_WIDTH - 32,
      align: "left",
    });

  currentY = doc.y + 16;

  if (resumeData.skills && resumeData.skills.length > 0) {
    doc
      .font("Helvetica-Bold")
      .fontSize(10.5)
      .fillColor(colors.sidebarText)
      .text("SKILLS", 16, currentY, {
        width: SIDEBAR_WIDTH - 32,
        align: "left",
        characterSpacing: 1,
      });

    currentY = doc.y + 8;

    resumeData.skills.forEach((skill) => {
      const line = skill.category?.trim()
        ? `${skill.name} - ${skill.category}`
        : skill.name;

      doc
        .font("Helvetica")
        .fontSize(8.8)
        .fillColor(colors.sidebarMuted)
        .text(line, 16, currentY, {
          width: SIDEBAR_WIDTH - 32,
          align: "left",
          lineGap: 2,
        });

      currentY = doc.y + 6;
    });
  }

  return { sidebarBottomY: currentY };
}

function drawSidebarPhotoPlaceholder(
  doc: PDFKit.PDFDocument,
  x: number,
  y: number,
  size: number,
): void {
  const radius = size / 2;

  doc
    .save()
    .circle(x + radius, y + radius, radius)
    .fillAndStroke("#374151", "#FFFFFF")
    .restore();

  doc
    .font("Helvetica")
    .fontSize(9)
    .fillColor("#CBD5E1")
    .text("Photo", x, y + radius - 5, {
      width: size,
      align: "center",
    });
}

function buildMainHeader(
  doc: PDFKit.PDFDocument,
  resumeData: ResumeData,
  colors: {
    primaryColor: string;
    accentColor: string;
    mutedColor: string;
    dividerColor: string;
  },
): number {
  const startY = 42;

  doc
    .rect(CONTENT_X, startY, CONTENT_WIDTH, 4)
    .fill(colors.primaryColor);

  const titleY = startY + 14;

  doc
    .font("Helvetica-Bold")
    .fontSize(24)
    .fillColor(colors.accentColor)
    .text(resumeData.title?.trim() || "Untitled Resume", CONTENT_X, titleY, {
      width: CONTENT_WIDTH,
      align: "left",
    });

  const titleBottomY = doc.y;

  doc
    .font("Helvetica")
    .fontSize(10.5)
    .fillColor(colors.mutedColor)
    .text("Modern Sidebar Resume", CONTENT_X, titleBottomY + 4, {
      width: CONTENT_WIDTH,
      align: "left",
    });

  const dividerY = doc.y + HEADER_BOTTOM_GAP;

  doc
    .strokeColor(colors.dividerColor)
    .lineWidth(1)
    .moveTo(CONTENT_X, dividerY)
    .lineTo(CONTENT_X + CONTENT_WIDTH, dividerY)
    .stroke();

  return dividerY + 16;
}

function addSection(
  doc: PDFKit.PDFDocument,
  title: string,
  startY: number,
  titleColor: string,
  dividerColor: string,
  renderContent: () => number,
): number {
  doc
    .font("Helvetica-Bold")
    .fontSize(10.8)
    .fillColor(titleColor)
    .text(title.toUpperCase(), CONTENT_X, startY, {
      width: CONTENT_WIDTH,
      align: "left",
      characterSpacing: 1.1,
    });

  const labelBottomY = doc.y;
  const dividerY = labelBottomY + 4;

  doc
    .strokeColor(dividerColor)
    .lineWidth(1)
    .moveTo(CONTENT_X, dividerY)
    .lineTo(CONTENT_X + CONTENT_WIDTH, dividerY)
    .stroke();

  doc.y = dividerY + 12;
  const contentEndY = renderContent();
  return contentEndY + 18;
}

function writeWorkExperience(
  doc: PDFKit.PDFDocument,
  exp: ResumeData["workExperiences"][number],
  startY: number,
  colors: {
    accentColor: string;
    mutedColor: string;
    textColor: string;
    primaryColor: string;
  },
): number {
  const roleLine = exp.role?.trim() || "Untitled Role";

  doc
    .font("Helvetica-Bold")
    .fontSize(12.2)
    .fillColor(colors.accentColor)
    .text(roleLine, CONTENT_X, startY, {
      width: CONTENT_WIDTH,
      align: "left",
    });

  let currentY = doc.y + 2;

  const companyLocation = [exp.company?.trim(), exp.location?.trim()]
    .filter(Boolean)
    .join(" - ");

  if (companyLocation) {
    doc
      .font("Helvetica")
      .fontSize(10.3)
      .fillColor("#4B5563")
      .text(companyLocation, CONTENT_X, currentY, {
        width: CONTENT_WIDTH,
        align: "left",
      });

    currentY = doc.y + 2;
  }

  const start = formatDate(exp.startDate);
  const end = exp.endDate ? formatDate(exp.endDate) : "Present";
  const dateRange = `${start} - ${end}`;

  doc
    .font("Helvetica")
    .fontSize(9.8)
    .fillColor(colors.mutedColor)
    .text(dateRange, CONTENT_X, currentY, {
      width: CONTENT_WIDTH,
      align: "left",
    });

  currentY = doc.y + 6;

  if (exp.bulletPoints && exp.bulletPoints.length > 0) {
    exp.bulletPoints.forEach((bullet) => {
      const text = bullet?.trim();
      if (!text) return;

      doc
        .font("Helvetica")
        .fontSize(10.2)
        .fillColor(colors.primaryColor)
        .text("•", CONTENT_X, currentY, {
          width: 8,
          align: "left",
        });

      doc
        .font("Helvetica")
        .fontSize(10.2)
        .fillColor(colors.textColor)
        .text(text, CONTENT_X + 12, currentY, {
          width: CONTENT_WIDTH - 12,
          align: "left",
          lineGap: 3,
        });

      currentY = doc.y + 4;
    });
  }

  return currentY;
}

function writeEducation(
  doc: PDFKit.PDFDocument,
  edu: ResumeData["educations"][number],
  startY: number,
  colors: {
    accentColor: string;
    mutedColor: string;
  },
): number {
  const degreeLine = [edu.degree?.trim(), edu.field?.trim()]
    .filter(Boolean)
    .join(" in ") || "Education";

  doc
    .font("Helvetica-Bold")
    .fontSize(11.8)
    .fillColor(colors.accentColor)
    .text(degreeLine, CONTENT_X, startY, {
      width: CONTENT_WIDTH,
      align: "left",
    });

  let currentY = doc.y + 2;

  const schoolLine = edu.school?.trim() || "";
  if (schoolLine) {
    doc
      .font("Helvetica")
      .fontSize(10.3)
      .fillColor("#4B5563")
      .text(schoolLine, CONTENT_X, currentY, {
        width: CONTENT_WIDTH,
        align: "left",
      });

    currentY = doc.y + 2;
  }

  const grad = edu.graduationDate ? formatDate(edu.graduationDate) : "";
  const meta = [
    grad ? `Graduation: ${grad}` : null,
    edu.gpa ? `GPA: ${edu.gpa}` : null,
  ]
    .filter(Boolean)
    .join(" - ");

  if (meta) {
    doc
      .font("Helvetica")
      .fontSize(9.8)
      .fillColor(colors.mutedColor)
      .text(meta, CONTENT_X, currentY, {
        width: CONTENT_WIDTH,
        align: "left",
      });

    currentY = doc.y;
  }

  return currentY;
}

function writeBodyText(
  doc: PDFKit.PDFDocument,
  text: string,
  textColor: string,
  startY: number,
): void {
  doc
    .font("Helvetica")
    .fontSize(10.4)
    .fillColor(textColor)
    .text(text, CONTENT_X, startY, {
      width: CONTENT_WIDTH,
      align: "left",
      lineGap: 4,
    });
}
