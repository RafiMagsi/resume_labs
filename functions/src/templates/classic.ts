
import PDFDocument from "pdfkit";
import https from "https";
import http from "http";
import { ResumeData, formatDate, createPdfBuffer } from "../types";

const PAGE_MARGIN = 36;
const CONTENT_WIDTH = 595.28 - PAGE_MARGIN * 2;

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
  const photoRadius = 35;
  const photoDiameter = photoRadius * 2;
  const imageGap = 10; // Gap between text and image
  const textColumnWidth = resumeData.photoUrl ? CONTENT_WIDTH - photoDiameter - imageGap : CONTENT_WIDTH;
  const photoX = PAGE_MARGIN + CONTENT_WIDTH - photoDiameter;
  const headerStartY = doc.y;

  // Add photo if image was successfully downloaded (circular)
  if (imageBuffer) {
    try {
      const photoY = headerStartY + photoRadius; // Align top of circle with top of title

      // Save state for clipping
      doc.save();

      // Create circular clipping path
      doc.circle(photoX + photoRadius, photoY + photoRadius, photoRadius);
      doc.clip();

      // Draw image inside circular path - fill entire circle
      doc.image(imageBuffer, photoX, photoY, {
        width: photoDiameter,
        height: photoDiameter,
      });

      // Restore state
      doc.restore();

      // Draw circle border
      doc
        .circle(photoX + photoRadius, photoY + photoRadius, photoRadius)
        .stroke("#CBD5E1");
    } catch (error) {
      // Fallback to placeholder if image fails to render
      drawPhotoPlaceholder(doc, photoX, headerStartY + photoRadius, photoDiameter);
    }
  } else if (resumeData.photoUrl) {
    // Show placeholder if URL provided but image failed to download
    drawPhotoPlaceholder(doc, photoX, headerStartY + photoRadius, photoDiameter);
  }

  // Draw title and subtitle in left column only
  doc
    .font("Helvetica-Bold")
    .fontSize(26)
    .fillColor("#111111")
    .text(resumeData.title?.trim() || "Untitled Resume", PAGE_MARGIN, headerStartY, {
      width: textColumnWidth,
      align: "left",
    });

  doc.moveDown(0.2);

  doc
    .font("Helvetica")
    .fontSize(10.5)
    .fillColor("#6B7280")
    .text("Professional Resume", PAGE_MARGIN, doc.y, {
      width: textColumnWidth,
      align: "left",
    });

  // Ensure space below photo circle before next section
  let nextY = doc.y + 14;
  const photoBottomY = resumeData.photoUrl ? headerStartY + photoDiameter + 14 : headerStartY;
  nextY = Math.max(nextY, photoBottomY);

  doc.moveDown(0.55);
  const dividerY = doc.y;
  doc
    .strokeColor("#CBD5E1")
    .lineWidth(1)
    .moveTo(PAGE_MARGIN, dividerY)
    .lineTo(PAGE_MARGIN + CONTENT_WIDTH, dividerY)
    .stroke();

  doc.y = nextY;
}

function drawPhotoPlaceholder(
  doc: PDFKit.PDFDocument,
  x: number,
  y: number,
  size: number,
): void {
  const radius = size / 2;
  doc
    .circle(x + radius, y + radius, radius)
    .stroke("#CBD5E1");

  doc
    .font("Helvetica")
    .fontSize(9)
    .fillColor("#9CA3AF")
    .text("Photo", x, y + radius - 8, {
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

  doc.y = dividerY + 10;
  renderContent();
  doc.moveDown(1.0);
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
      .font("Helvetica-Bold")
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
    .fontSize(10.8)
    .fillColor("#334155")
    .text(text, PAGE_MARGIN, doc.y, {
      width: CONTENT_WIDTH,
      align: "left",
      lineGap: 3,
    });
}
