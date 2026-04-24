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

export async function generateHealthcareTemplate(resumeData: ResumeData): Promise<Buffer> {
  return new Promise(async (resolve, reject) => {
    try {
      const doc = new PDFDocument({ size: "A4", margin: PAGE_MARGIN });
      const accentColor = "#059669";
      const darkColor = "#111111";
      const textColor = "#374151";
      const mutedColor = "#6B7280";
      const dividerColor = "#D1D5DB";

      let imageBuffer: Buffer | null = null;
      if (resumeData.photoUrl) {
        imageBuffer = await downloadImage(resumeData.photoUrl);
      }

      buildHeader(doc, resumeData, imageBuffer, {
        accentColor,
        darkColor,
        mutedColor,
        dividerColor,
      });

      addSection(doc, "Professional Summary", accentColor, dividerColor, () => {
        const summary = resumeData.personalSummary?.trim() || "Healthcare professional committed to patient care.";
        writeBodyText(doc, summary, textColor);
      });

      addSection(doc, "Professional Experience", accentColor, dividerColor, () => {
        if (!resumeData.workExperiences || resumeData.workExperiences.length === 0) {
          writeBodyText(doc, "No experience added.", textColor);
          return;
        }

        resumeData.workExperiences.forEach((exp, index) => {
          writeHealthcareExperience(doc, exp, {
            accentColor,
            darkColor,
            mutedColor,
            textColor,
          });
          if (index < resumeData.workExperiences.length - 1) {
              doc.moveDown(0.5);
          }
        });
      });

      addSection(doc, "Education & Certifications", accentColor, dividerColor, () => {
        if (!resumeData.educations || resumeData.educations.length === 0) {
          writeBodyText(doc, "No education added.", textColor);
          return;
        }

        resumeData.educations.forEach((edu, index) => {
          writeHealthcareEducation(doc, edu, {
            accentColor,
            darkColor,
            mutedColor,
          });
          if (index < resumeData.educations.length - 1) {
              doc.moveDown(0.4);
          }
        });
      });

      addSection(doc, "Clinical Skills & Competencies", accentColor, dividerColor, () => {
        if (!resumeData.skills || resumeData.skills.length === 0) {
          writeBodyText(doc, "No skills added.", textColor);
          return;
        }

        const skillsLine = resumeData.skills
          .map((skill) => {
            const category = skill.category?.trim();
            return category ? `${skill.name} (${category})` : skill.name;
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
    darkColor: string;
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

  // Green accent bar
  doc.rect(PAGE_MARGIN, headerStartY, CONTENT_WIDTH, 3).fill(colors.accentColor);

  const titleY = headerStartY + 12;

  if (hasPhotoSlot) {
    if (imageBuffer) {
      try {
        doc.save();
        doc.circle(photoX + PHOTO_RADIUS, photoY + PHOTO_RADIUS + 4, PHOTO_RADIUS);
        doc.clip();
        doc.image(imageBuffer, photoX, photoY + 4, {
          width: PHOTO_DIAMETER,
          height: PHOTO_DIAMETER,
        });
        doc.restore();

        doc
          .circle(photoX + PHOTO_RADIUS, photoY + PHOTO_RADIUS + 4, PHOTO_RADIUS)
          .lineWidth(1)
          .stroke(colors.accentColor);
      } catch (error) {
        drawPhotoPlaceholder(doc, photoX, photoY + 4, PHOTO_DIAMETER, colors.accentColor);
      }
    } else {
      drawPhotoPlaceholder(doc, photoX, photoY + 4, PHOTO_DIAMETER, colors.accentColor);
    }
  }

  doc
    .font("Helvetica-Bold")
    .fontSize(26)
    .fillColor(colors.accentColor)
    .text(resumeData.title?.trim() || "Healthcare Professional", PAGE_MARGIN, titleY, {
      width: textColumnWidth,
      align: "left",
    });

  const titleBottomY = doc.y;

  doc
    .font("Helvetica")
    .fontSize(10)
    .fillColor(colors.mutedColor)
    .text("Patient Care • Clinical Excellence", PAGE_MARGIN, titleBottomY + 4, {
      width: textColumnWidth,
      align: "left",
    });

  const textBottomY = doc.y;
  const photoBottomY = hasPhotoSlot ? photoY + 4 + PHOTO_DIAMETER : titleY;
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
    .fillAndStroke("#F0FDF4", borderColor)
    .restore();

  doc
    .font("Helvetica")
    .fontSize(9)
    .fillColor("#86EFAC")
    .text("Photo", x, y + radius - 5, {
      width: size,
      align: "center",
    });
}

function addSection(
  doc: PDFKit.PDFDocument,
  title: string,
  titleColor: string,
  dividerColor: string,
  renderContent: () => void,
): void {
  doc
    .font("Helvetica-Bold")
    .fontSize(11)
    .fillColor(titleColor)
    .text(title.toUpperCase(), PAGE_MARGIN, doc.y, {
      width: CONTENT_WIDTH,
      align: "left",
      characterSpacing: 0.9,
    });

  doc.moveDown(0.15);
  const dividerY = doc.y;
  doc
    .strokeColor(dividerColor)
    .lineWidth(0.8)
    .moveTo(PAGE_MARGIN, dividerY)
    .lineTo(PAGE_MARGIN + CONTENT_WIDTH, dividerY)
    .stroke();

    doc.y = dividerY + 10;
  renderContent();
        doc.moveDown(0.2);
}

function writeHealthcareExperience(
  doc: PDFKit.PDFDocument,
  exp: ResumeData["workExperiences"][number],
  colors: {
    accentColor: string;
    darkColor: string;
    mutedColor: string;
    textColor: string;
  },
): void {
  const positionLine = exp.role?.trim() || "Position";

  doc
    .font("Helvetica-Bold")
    .fontSize(12)
    .fillColor(colors.accentColor)
    .text(positionLine, PAGE_MARGIN, doc.y, {
      width: CONTENT_WIDTH,
      align: "left",
    });

  doc.moveDown(0.1);

  const facilityLine = [exp.company?.trim(), exp.location?.trim()]
    .filter(Boolean)
    .join(" • ");

  if (facilityLine) {
    doc
      .font("Helvetica")
      .fontSize(10)
      .fillColor(colors.darkColor)
      .text(facilityLine, PAGE_MARGIN, doc.y, {
        width: CONTENT_WIDTH,
        align: "left",
      });

    doc.moveDown(0.08);
  }

  const start = formatDate(exp.startDate);
  const end = exp.endDate ? formatDate(exp.endDate) : "Present";
  const dateRange = `${start} – ${end}`;

  doc
    .font("Helvetica")
    .fontSize(9)
    .fillColor(colors.mutedColor)
    .text(dateRange, PAGE_MARGIN, doc.y, {
      width: CONTENT_WIDTH,
      align: "left",
    });

  if (exp.bulletPoints && exp.bulletPoints.length > 0) {
    doc.moveDown(0.25);
    exp.bulletPoints.forEach((bullet) => {
      const text = bullet?.trim();
      if (!text) return;

      doc
        .font("Helvetica")
        .fontSize(10)
        .fillColor(colors.textColor)
        .text(`▸ ${text}`, PAGE_MARGIN + 10, doc.y, {
          width: CONTENT_WIDTH - 10,
          align: "left",
        });
    });
  }
}

function writeHealthcareEducation(
  doc: PDFKit.PDFDocument,
  edu: ResumeData["educations"][number],
  colors: {
    accentColor: string;
    darkColor: string;
    mutedColor: string;
  },
): void {
  const degreeLine = [edu.degree?.trim(), edu.field?.trim()]
    .filter(Boolean)
    .join(" in ") || "Certification";

  doc
    .font("Helvetica-Bold")
    .fontSize(11)
    .fillColor(colors.accentColor)
    .text(degreeLine, PAGE_MARGIN, doc.y, {
      width: CONTENT_WIDTH,
      align: "left",
    });

  doc.moveDown(0.08);

  const institutionLine = edu.school?.trim() || "";
  if (institutionLine) {
    doc
      .font("Helvetica")
      .fontSize(10)
      .fillColor(colors.darkColor)
      .text(institutionLine, PAGE_MARGIN, doc.y, {
        width: CONTENT_WIDTH,
        align: "left",
      });

    doc.moveDown(0.08);
  }

  const grad = edu.graduationDate ? formatDate(edu.graduationDate) : "";
  const licenseText = edu.gpa ? `License: ${edu.gpa}` : "";
  const meta = [grad, licenseText].filter(Boolean).join(" • ");

  if (meta) {
    doc
      .font("Helvetica")
      .fontSize(9)
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
    .fontSize(10.3)
    .fillColor(textColor)
    .text(text, PAGE_MARGIN, doc.y, {
      width: CONTENT_WIDTH,
      align: "left",
      lineGap: 3,
    });
}
