import PDFDocument from "pdfkit";
import https from "https";
import http from "http";
import { ResumeData, formatDate, createPdfBuffer } from "../types";

const PAGE_MARGIN = 40;
const CONTENT_WIDTH = 595.28 - PAGE_MARGIN * 2;
const PHOTO_DIAMETER = 64;
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

export async function generateFinanceTemplate(resumeData: ResumeData): Promise<Buffer> {
  return new Promise(async (resolve, reject) => {
    try {
      const doc = new PDFDocument({ size: "A4", margin: PAGE_MARGIN });
      const accentColor = "#1F2937";
      const goldColor = "#B8860B";
      const textColor = "#374151";
      const mutedColor = "#6B7280";
      const dividerColor = "#D1D5DB";

      let imageBuffer: Buffer | null = null;
      if (resumeData.photoUrl) {
        imageBuffer = await downloadImage(resumeData.photoUrl);
      }

      buildHeader(doc, resumeData, imageBuffer, {
        accentColor,
        goldColor,
        mutedColor,
        dividerColor,
      });

      addSection(doc, "Executive Profile", accentColor, goldColor, dividerColor, () => {
        const summary = resumeData.personalSummary?.trim() || "Finance professional.";
        writeBodyText(doc, summary, textColor);
      });

      addSection(doc, "Professional Experience", accentColor, goldColor, dividerColor, () => {
        if (!resumeData.workExperiences || resumeData.workExperiences.length === 0) {
          writeBodyText(doc, "No experience added.", textColor);
          return;
        }

        resumeData.workExperiences.forEach((exp, index) => {
          writeFinanceExperience(doc, exp, {
            accentColor,
            goldColor,
            mutedColor,
            textColor,
          });
          if (index < resumeData.workExperiences.length - 1) {
              doc.moveDown(0.5);
          }
        });
      });

      addSection(doc, "Education & Credentials", accentColor, goldColor, dividerColor, () => {
        if (!resumeData.educations || resumeData.educations.length === 0) {
          writeBodyText(doc, "No education added.", textColor);
          return;
        }

        resumeData.educations.forEach((edu, index) => {
          writeFinanceEducation(doc, edu, {
            accentColor,
            goldColor,
            mutedColor,
          });
          if (index < resumeData.educations.length - 1) {
              doc.moveDown(0.4);
          }
        });
      });

      addSection(doc, "Financial Expertise", accentColor, goldColor, dividerColor, () => {
        if (!resumeData.skills || resumeData.skills.length === 0) {
          writeBodyText(doc, "No expertise added.", textColor);
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
    goldColor: string;
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
          .lineWidth(1.5)
          .stroke(colors.goldColor);
      } catch (error) {
        drawPhotoPlaceholder(doc, photoX, photoY, PHOTO_DIAMETER, colors.goldColor);
      }
    } else {
      drawPhotoPlaceholder(doc, photoX, photoY, PHOTO_DIAMETER, colors.goldColor);
    }
  }

  doc
    .font("Helvetica-Bold")
    .fontSize(26)
    .fillColor(colors.accentColor)
    .text(resumeData.title?.trim() || "Finance Professional", PAGE_MARGIN, headerStartY, {
      width: textColumnWidth,
      align: "left",
    });

  const titleBottomY = doc.y;

  doc
    .font("Helvetica")
    .fontSize(10)
    .fillColor(colors.goldColor)
    .text("CPA • CFO • Financial Analyst", PAGE_MARGIN, titleBottomY + 4, {
      width: textColumnWidth,
      align: "left",
    });

  const textBottomY = doc.y;
  const photoBottomY = hasPhotoSlot ? photoY + PHOTO_DIAMETER : headerStartY;
  const dividerY = Math.max(textBottomY, photoBottomY) + HEADER_BOTTOM_GAP;

  doc
    .strokeColor(colors.dividerColor)
    .lineWidth(2)
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
    .fillAndStroke("#FFFACD", borderColor)
    .restore();

  doc
    .font("Helvetica")
    .fontSize(8)
    .fillColor("#B8860B")
    .text("Photo", x, y + radius - 4, {
      width: size,
      align: "center",
    });
}

function addSection(
  doc: PDFKit.PDFDocument,
  title: string,
  titleColor: string,
  accentColor: string,
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
      characterSpacing: 0.8,
    });

  doc.moveDown(0.16);
  const dividerY = doc.y;
  doc
    .strokeColor(accentColor)
    .lineWidth(1)
    .moveTo(PAGE_MARGIN, dividerY)
    .lineTo(PAGE_MARGIN + CONTENT_WIDTH, dividerY)
    .stroke();

  doc.y = dividerY + 10;
  renderContent();
        doc.moveDown(0.2);
}

function writeFinanceExperience(
  doc: PDFKit.PDFDocument,
  exp: ResumeData["workExperiences"][number],
  colors: {
    accentColor: string;
    goldColor: string;
    mutedColor: string;
    textColor: string;
  },
): void {
  const titleLine = exp.role?.trim() || "Position";

  doc
    .font("Helvetica-Bold")
    .fontSize(11)
    .fillColor(colors.accentColor)
    .text(titleLine, PAGE_MARGIN, doc.y, {
      width: CONTENT_WIDTH,
      align: "left",
    });

  doc.moveDown(0.1);

  const companyLine = [exp.company?.trim(), exp.location?.trim()]
    .filter(Boolean)
    .join(" • ");

  if (companyLine) {
    doc
      .font("Helvetica")
      .fontSize(10)
      .fillColor(colors.goldColor)
      .text(companyLine, PAGE_MARGIN, doc.y, {
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
    doc.moveDown(0.2);
    exp.bulletPoints.forEach((bullet) => {
      const text = bullet?.trim();
      if (!text) return;

      doc
        .font("Helvetica")
        .fontSize(9.5)
        .fillColor(colors.textColor)
        .text(`→ ${text}`, PAGE_MARGIN + 12, doc.y, {
          width: CONTENT_WIDTH - 12,
          align: "left",
                      lineGap: 3,
        });
    });
  }
}

function writeFinanceEducation(
  doc: PDFKit.PDFDocument,
  edu: ResumeData["educations"][number],
  colors: {
    accentColor: string;
    goldColor: string;
    mutedColor: string;
  },
): void {
  const degreeLine = [edu.degree?.trim(), edu.field?.trim()]
    .filter(Boolean)
    .join(" in ") || "Degree";

  doc
    .font("Helvetica-Bold")
    .fontSize(11)
    .fillColor(colors.accentColor)
    .text(degreeLine, PAGE_MARGIN, doc.y, {
      width: CONTENT_WIDTH,
      align: "left",
    });

  doc.moveDown(0.08);

  const schoolLine = edu.school?.trim() || "";
  if (schoolLine) {
    doc
      .font("Helvetica")
      .fontSize(10)
      .fillColor(colors.goldColor)
      .text(schoolLine, PAGE_MARGIN, doc.y, {
        width: CONTENT_WIDTH,
        align: "left",
      });

    doc.moveDown(0.08);
  }

  const grad = edu.graduationDate ? formatDate(edu.graduationDate) : "";
  const credText = edu.gpa ? `License/Cert: ${edu.gpa}` : "";
  const meta = [grad, credText].filter(Boolean).join(" • ");

  if (meta) {
    doc
      .font("Helvetica")
      .fontSize(9.5)
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
    .fontSize(10.2)
    .fillColor(textColor)
    .text(text, PAGE_MARGIN, doc.y, {
      width: CONTENT_WIDTH,
      align: "left",
                  lineGap: 3,
    });
}
