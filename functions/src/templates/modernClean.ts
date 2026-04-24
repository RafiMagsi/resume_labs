import PDFDocument from "pdfkit";
import https from "https";
import http from "http";
import { ResumeData, formatDate, createPdfBuffer } from "../types";

const PAGE_MARGIN = 36;
const CONTENT_WIDTH = 595.28 - PAGE_MARGIN * 2;
const PHOTO_DIAMETER = 68;
const PHOTO_RADIUS = PHOTO_DIAMETER / 2;
const PHOTO_GAP = 16;
const HEADER_BOTTOM_GAP = 8;

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

export async function generateModernCleanTemplate(resumeData: ResumeData): Promise<Buffer> {
  return new Promise(async (resolve, reject) => {
    try {
      const doc = new PDFDocument({ size: "A4", margin: PAGE_MARGIN });
      const accentColor = "#111111";
      const textColor = "#334155";
      const mutedColor = "#6B7280";
      const dividerColor = "#CBD5E1";
      const softDividerColor = "#E2E8F0";

      let imageBuffer: Buffer | null = null;
      if (resumeData.photoUrl) {
        imageBuffer = await downloadImage(resumeData.photoUrl);
      }

      buildHeader(doc, resumeData, imageBuffer, {
        accentColor,
        mutedColor,
        dividerColor,
      });

      addSection(doc, "Professional Summary", softDividerColor, () => {
        const summary = resumeData.personalSummary?.trim() || "No personal summary provided.";
        writeBodyText(doc, summary, textColor);
      });

      addSection(doc, "Professional Experience", softDividerColor, () => {
        if (!resumeData.workExperiences || resumeData.workExperiences.length === 0) {
          writeBodyText(doc, "No work experience added.", textColor);
          return;
        }

        resumeData.workExperiences.forEach((exp, index) => {
          writeWorkExperience(doc, exp, {
            accentColor,
            mutedColor,
            textColor,
          });
          if (index < resumeData.workExperiences.length - 1) {
              doc.moveDown(0.5);
          }
        });
      });

      addSection(doc, "Education", softDividerColor, () => {
        if (!resumeData.educations || resumeData.educations.length === 0) {
          writeBodyText(doc, "No education added.", textColor);
          return;
        }

        resumeData.educations.forEach((edu, index) => {
          writeEducation(doc, edu, {
            accentColor,
            mutedColor,
          });
          if (index < resumeData.educations.length - 1) {
              doc.moveDown(0.4);
          }
        });
      });

      addSection(doc, "Skills", softDividerColor, () => {
        if (!resumeData.skills || resumeData.skills.length === 0) {
          writeBodyText(doc, "No skills added.", textColor);
          return;
        }

        const skillsLine = resumeData.skills
          .map((skill) => {
            const category = skill.category?.trim();
            return category ? `${skill.name} - ${category}` : skill.name;
          })
          .join(" • ");

        writeBodyText(doc, skillsLine, textColor);
      });

      doc.end();
      createPdfBuffer(doc).then(resolve).catch(reject);
    } catch (error) {
      reject(error);
    }
  });
}

function buildHeader(
  doc: PDFKit.PDFDocument,
  resumeData: ResumeData,
  imageBuffer: Buffer | null,
  colors: {
    accentColor: string;
    mutedColor: string;
    dividerColor: string;
  },
): void {
  const hasPhotoSlot = Boolean(resumeData.photoUrl);
  const headerStartY = doc.y;
  const photoX = PAGE_MARGIN + CONTENT_WIDTH - PHOTO_DIAMETER;
  const photoY = headerStartY;
  const textColumnWidth = hasPhotoSlot
    ? CONTENT_WIDTH - PHOTO_DIAMETER - PHOTO_GAP
    : CONTENT_WIDTH;

  if (hasPhotoSlot) {
    if (imageBuffer) {
      try {
        doc.save();
        doc.circle(photoX + PHOTO_RADIUS, photoY + PHOTO_RADIUS, PHOTO_RADIUS);
        doc.clip();
        doc.image(imageBuffer, photoX, photoY, {
          width: PHOTO_DIAMETER,
          height: PHOTO_DIAMETER,
        });
        doc.restore();

        doc
          .circle(photoX + PHOTO_RADIUS, photoY + PHOTO_RADIUS, PHOTO_RADIUS)
          .lineWidth(1)
          .stroke(colors.dividerColor);
      } catch (error) {
        drawPhotoPlaceholder(doc, photoX, photoY, PHOTO_DIAMETER, colors.dividerColor);
      }
    } else {
      drawPhotoPlaceholder(doc, photoX, photoY, PHOTO_DIAMETER, colors.dividerColor);
    }
  }

  doc
    .font("Helvetica-Bold")
    .fontSize(25)
    .fillColor(colors.accentColor)
    .text(resumeData.title?.trim() || "Untitled Resume", PAGE_MARGIN, headerStartY, {
      width: textColumnWidth,
      align: "left",
    });

  const titleBottomY = doc.y;

  doc
    .font("Helvetica")
    .fontSize(10.5)
    .fillColor(colors.mutedColor)
    .text("Modern Resume", PAGE_MARGIN, titleBottomY + 4, {
      width: textColumnWidth,
      align: "left",
    });

  const textBottomY = doc.y;
  const photoBottomY = hasPhotoSlot ? photoY + PHOTO_DIAMETER : headerStartY;
  const dividerY = Math.max(textBottomY, photoBottomY) + HEADER_BOTTOM_GAP;

  doc
    .strokeColor(colors.dividerColor)
    .lineWidth(1)
    .moveTo(PAGE_MARGIN, dividerY)
    .lineTo(PAGE_MARGIN + CONTENT_WIDTH, dividerY)
    .stroke();

    doc.y = dividerY + 10;
}

function drawPhotoPlaceholder(
  doc: PDFKit.PDFDocument,
  x: number,
  y: number,
  size: number,
  borderColor: string,
): void {
  const radius = size / 2;

  doc
    .save()
    .circle(x + radius, y + radius, radius)
    .fillAndStroke("#F8FAFC", borderColor)
    .restore();

  doc
    .font("Helvetica")
    .fontSize(9)
    .fillColor("#94A3B8")
    .text("Photo", x, y + radius - 5, {
      width: size,
      align: "center",
    });
}

function addSection(
  doc: PDFKit.PDFDocument,
  title: string,
  dividerColor: string,
  renderContent: () => void,
): void {
  doc
    .font("Helvetica-Bold")
    .fontSize(11)
    .fillColor("#111111")
    .text(title.toUpperCase(), PAGE_MARGIN, doc.y, {
      width: CONTENT_WIDTH,
      align: "left",
      characterSpacing: 1.1,
    });

  doc.moveDown(0.18);
  const dividerY = doc.y;
  doc
    .strokeColor(dividerColor)
    .lineWidth(1)
    .moveTo(PAGE_MARGIN, dividerY)
    .lineTo(PAGE_MARGIN + CONTENT_WIDTH, dividerY)
    .stroke();

    doc.y = dividerY + 8;
  renderContent();
      doc.moveDown(0.2);
}

function writeWorkExperience(
  doc: PDFKit.PDFDocument,
  exp: ResumeData["workExperiences"][number],
  colors: {
    accentColor: string;
    mutedColor: string;
    textColor: string;
  },
): void {
  const roleLine = exp.role?.trim() || "Untitled Role";

  doc
    .font("Helvetica-Bold")
    .fontSize(12.5)
    .fillColor(colors.accentColor)
    .text(roleLine, PAGE_MARGIN, doc.y, {
      width: CONTENT_WIDTH,
      align: "left",
    });

  const companyLocation = [exp.company?.trim(), exp.location?.trim()]
    .filter(Boolean)
    .join(" - ");

  if (companyLocation) {
    doc.moveDown(0.12);
    doc
      .font("Helvetica")
      .fontSize(10.5)
      .fillColor("#4B5563")
      .text(companyLocation, PAGE_MARGIN, doc.y, {
        width: CONTENT_WIDTH,
        align: "left",
      });
  }

  const start = formatDate(exp.startDate);
  const end = exp.endDate ? formatDate(exp.endDate) : "Present";
  const dateRange = `${start} - ${end}`;

  doc.moveDown(0.1);
  doc
    .font("Helvetica")
    .fontSize(10)
    .fillColor(colors.mutedColor)
    .text(dateRange, PAGE_MARGIN, doc.y, {
      width: CONTENT_WIDTH,
      align: "left",
    });

  if (exp.bulletPoints && exp.bulletPoints.length > 0) {
      doc.moveDown(0.2);
    exp.bulletPoints.forEach((bullet) => {
      const text = bullet?.trim();
      if (!text) return;

      const bulletX = PAGE_MARGIN;
      const textX = PAGE_MARGIN + 12;
      const currentY = doc.y;

      doc
        .font("Helvetica")
        .fontSize(10.4)
        .fillColor("#6B7280")
        .text("•", bulletX, currentY, {
          width: 8,
          align: "left",
        });

      doc
        .font("Helvetica")
        .fontSize(10.4)
        .fillColor(colors.textColor)
        .text(text, textX, currentY, {
          width: CONTENT_WIDTH - 12,
          align: "left",
          lineGap: 3,
        });
    });
  }
}

function writeEducation(
  doc: PDFKit.PDFDocument,
  edu: ResumeData["educations"][number],
  colors: {
    accentColor: string;
    mutedColor: string;
  },
): void {
  const degreeLine = [edu.degree?.trim(), edu.field?.trim()]
    .filter(Boolean)
    .join(" in ") || "Education";

  doc
    .font("Helvetica-Bold")
    .fontSize(12)
    .fillColor(colors.accentColor)
    .text(degreeLine, PAGE_MARGIN, doc.y, {
      width: CONTENT_WIDTH,
      align: "left",
    });

  const schoolLine = edu.school?.trim() || "";
  if (schoolLine) {
    doc.moveDown(0.12);
    doc
      .font("Helvetica")
      .fontSize(10.5)
      .fillColor("#4B5563")
      .text(schoolLine, PAGE_MARGIN, doc.y, {
        width: CONTENT_WIDTH,
        align: "left",
      });
  }

  const grad = edu.graduationDate ? formatDate(edu.graduationDate) : "";
  const meta = [
    grad ? `Graduation: ${grad}` : null,
    edu.gpa ? `GPA: ${edu.gpa}` : null,
  ]
    .filter(Boolean)
    .join(" - ");

  if (meta) {
    doc.moveDown(0.1);
    doc
      .font("Helvetica")
      .fontSize(10)
      .fillColor(colors.mutedColor)
      .text(meta, PAGE_MARGIN, doc.y, {
        width: CONTENT_WIDTH,
        align: "left",
      });
  }
}

function writeBodyText(doc: PDFKit.PDFDocument, text: string, textColor: string): void {
  doc
    .font("Helvetica")
    .fontSize(10.6)
    .fillColor(textColor)
    .text(text, PAGE_MARGIN, doc.y, {
      width: CONTENT_WIDTH,
      align: "left",
            lineGap: 2,
    });
}
