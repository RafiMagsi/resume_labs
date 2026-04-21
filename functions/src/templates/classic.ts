import PDFDocument from "pdfkit";
import https from "https";
import http from "http";
import { ResumeData, formatDate, createPdfBuffer } from "../types";

const PAGE_MARGIN = 36;
const CONTENT_WIDTH = 595.28 - PAGE_MARGIN * 2;
const PHOTO_DIAMETER = 68;
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

export async function generateClassicTemplate(
  resumeData: ResumeData,
): Promise<Buffer> {
  return new Promise(async (resolve, reject) => {
    try {
      const doc = new PDFDocument({
        size: "A4",
        margin: PAGE_MARGIN,
      });

      // Download image if URL provided
      let imageBuffer: Buffer | null = null;
      if (resumeData.photoUrl) {
        imageBuffer = await downloadImage(resumeData.photoUrl);
      }

      buildHeader(doc, resumeData, imageBuffer);
      addSection(doc, "Professional Summary", () => {
        const summary = resumeData.personalSummary?.trim() || "No personal summary provided.";
        writeBodyText(doc, summary);
      });

      addSection(doc, "Work Experience", () => {
        if (!resumeData.workExperiences || resumeData.workExperiences.length === 0) {
          writeBodyText(doc, "No work experience added.");
          return;
        }

        resumeData.workExperiences.forEach((exp, index) => {
          writeWorkExperience(doc, exp);
          if (index < resumeData.workExperiences.length - 1) {
            doc.moveDown(0.9);
          }
        });
      });

      addSection(doc, "Education", () => {
        if (!resumeData.educations || resumeData.educations.length === 0) {
          writeBodyText(doc, "No education added.");
          return;
        }

        resumeData.educations.forEach((edu, index) => {
          writeEducation(doc, edu);
          if (index < resumeData.educations.length - 1) {
            doc.moveDown(0.8);
          }
        });
      });

      addSection(doc, "Skills", () => {
        if (!resumeData.skills || resumeData.skills.length === 0) {
          writeBodyText(doc, "No skills added.");
          return;
        }

        const skillsLine = resumeData.skills
          .map((skill) => {
            const name = skill.name?.trim() || '';
            const category = skill.category?.trim();
            return category ? `${name} - ${category}` : name;
          })
          .join(" • ");

        writeBodyText(doc, skillsLine);
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
          .stroke("#CBD5E1");
      } catch (error) {
        drawPhotoPlaceholder(doc, photoX, photoY, PHOTO_DIAMETER);
      }
    } else {
      drawPhotoPlaceholder(doc, photoX, photoY, PHOTO_DIAMETER);
    }
  }

  doc
    .font("Helvetica-Bold")
    .fontSize(25)
    .fillColor("#111111")
    .text(resumeData.title?.trim() || "Untitled Resume", PAGE_MARGIN, headerStartY, {
      width: textColumnWidth,
      align: "left",
    });

  const titleBottomY = doc.y;

  doc
    .font("Helvetica")
    .fontSize(10.5)
    .fillColor("#6B7280")
    .text("Professional Resume", PAGE_MARGIN, titleBottomY + 4, {
      width: textColumnWidth,
      align: "left",
    });

  const textBottomY = doc.y;
  const photoBottomY = hasPhotoSlot ? photoY + PHOTO_DIAMETER : headerStartY;
  const dividerY = Math.max(textBottomY, photoBottomY) + HEADER_BOTTOM_GAP;

  doc
    .strokeColor("#CBD5E1")
    .lineWidth(1)
    .moveTo(PAGE_MARGIN, dividerY)
    .lineTo(PAGE_MARGIN + CONTENT_WIDTH, dividerY)
    .stroke();

  doc.y = dividerY + 16;
}

function drawPhotoPlaceholder(
  doc: PDFKit.PDFDocument,
  x: number,
  y: number,
  size: number,
): void {
  const radius = size / 2;

  doc
    .save()
    .circle(x + radius, y + radius, radius)
    .fillAndStroke("#F8FAFC", "#CBD5E1")
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
  renderContent: () => void,
): void {
  doc
    .font("Helvetica-Bold")
    .fontSize(11)
    .fillColor("#374151")
    .text(title.toUpperCase(), PAGE_MARGIN, doc.y, {
      width: CONTENT_WIDTH,
      align: "left",
      characterSpacing: 1.1,
    });

  doc.moveDown(0.18);
  const dividerY = doc.y;
  doc
    .strokeColor("#E2E8F0")
    .lineWidth(1)
    .moveTo(PAGE_MARGIN, dividerY)
    .lineTo(PAGE_MARGIN + CONTENT_WIDTH, dividerY)
    .stroke();

  doc.y = dividerY + 12;
  renderContent();
  doc.moveDown(1.1);
}

function writeWorkExperience(
  doc: PDFKit.PDFDocument,
  exp: ResumeData["workExperiences"][number],
): void {
  const roleLine = exp.role?.trim() || "Untitled Role";
  doc
    .font("Helvetica-Bold")
    .fontSize(12.5)
    .fillColor("#111111")
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
    .fillColor("#6B7280")
    .text(dateRange, PAGE_MARGIN, doc.y, {
      width: CONTENT_WIDTH,
      align: "left",
    });

  if (exp.bulletPoints && exp.bulletPoints.length > 0) {
    doc.moveDown(0.3);
    exp.bulletPoints.forEach((bullet) => {
      const text = bullet?.trim();
      if (!text) return;

      const bulletX = PAGE_MARGIN;
      const textX = PAGE_MARGIN + 12;
      const currentY = doc.y;

      doc
        .font("Helvetica")
        .fontSize(10.5)
        .fillColor("#111111")
        .text("•", bulletX, currentY, {
          width: 8,
          align: "left",
        });

      doc
        .font("Helvetica")
        .fontSize(10.5)
        .fillColor("#334155")
        .text(text, textX, currentY, {
          width: CONTENT_WIDTH - 12,
          align: "left",
          lineGap: 2,
        });
    });
  }
}

function writeEducation(
  doc: PDFKit.PDFDocument,
  edu: ResumeData["educations"][number],
): void {
  const degreeLine = [edu.degree?.trim(), edu.field?.trim()]
    .filter(Boolean)
    .join(" in ") || "Education";

  doc
    .font("Helvetica-Bold")
    .fontSize(12)
    .fillColor("#111111")
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
      .fillColor("#6B7280")
      .text(meta, PAGE_MARGIN, doc.y, {
        width: CONTENT_WIDTH,
        align: "left",
      });
  }
}

function writeBodyText(doc: PDFKit.PDFDocument, text: string): void {
  doc
    .font("Helvetica")
    .fontSize(10.6)
    .fillColor("#334155")
    .text(text, PAGE_MARGIN, doc.y, {
      width: CONTENT_WIDTH,
      align: "left",
      lineGap: 4,
    });
}
