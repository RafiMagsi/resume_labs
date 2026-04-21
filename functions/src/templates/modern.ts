import PDFDocument from "pdfkit";
import https from "https";
import http from "http";
import { ResumeData, formatDate, createPdfBuffer } from "../types";

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

export async function generateModernTemplate(resumeData: ResumeData): Promise<Buffer> {
  return new Promise(async (resolve, reject) => {
    try {
      const doc = new PDFDocument({ size: "A4", margin: 40 });
      const primaryColor = "#0066cc";

      // Download image if URL provided
      let imageBuffer: Buffer | null = null;
      if (resumeData.photoUrl) {
        imageBuffer = await downloadImage(resumeData.photoUrl);
      }

      // Photo (top right, circular)
      if (imageBuffer) {
        try {
          const photoRadius = 30;
          const photoDiameter = photoRadius * 2;
          const photoX = 495 - photoRadius;
          const photoY = 40 + photoRadius;

          doc.save();
          doc.circle(photoX + photoRadius, photoY + photoRadius, photoRadius);
          doc.clip();
          doc.image(imageBuffer, photoX, photoY, {
            width: photoDiameter,
            height: photoDiameter,
          });
          doc.restore();
          doc.circle(photoX + photoRadius, photoY + photoRadius, photoRadius).stroke(primaryColor);
        } catch (error) {
          // Fallback to placeholder
          const photoRadius = 30;
          doc.circle(495 + photoRadius, 40 + photoRadius, photoRadius).stroke(primaryColor);
        }
      } else if (resumeData.photoUrl) {
        const photoRadius = 30;
        doc.circle(495 + photoRadius, 40 + photoRadius, photoRadius).stroke(primaryColor);
      }

      // Calculate layout with image column
      const photoRadius = 30;
      const photoDiameter = photoRadius * 2;
      const imageGap = 10;
      const textColumnWidth = resumeData.photoUrl ? 500 - photoDiameter - imageGap : 500;
      const headerStartY = doc.y;

      // Header with blue accent
      doc.fontSize(28).font("Helvetica-Bold").fillColor(primaryColor);
      doc.text(resumeData.title || "Resume", 40, headerStartY, {
        align: "left",
        width: textColumnWidth,
      });

      if (resumeData.personalSummary) {
        doc.moveDown(0.3);
        doc.fontSize(11).fillColor("#666666").font("Helvetica");
        doc.text(resumeData.personalSummary, 40, doc.y, {
          width: textColumnWidth,
          align: "left",
        });
      }

      // Ensure space below photo
      let nextY = doc.y + 14;
      const photoBottomY = resumeData.photoUrl ? headerStartY + photoDiameter + 14 : headerStartY;
      nextY = Math.max(nextY, photoBottomY);
      doc.y = nextY;

      doc.moveDown(0.3);
      doc.strokeColor(primaryColor).lineWidth(2).moveTo(40, doc.y).lineTo(555, doc.y).stroke();
      doc.moveDown(0.3);

      // Work Experience
      if (resumeData.workExperiences && resumeData.workExperiences.length > 0) {
        doc.fontSize(14).font("Helvetica-Bold").fillColor(primaryColor);
        doc.text("Work Experience");
        doc.moveDown(0.2);

        resumeData.workExperiences.forEach((exp, index) => {
          doc.fontSize(12).font("Helvetica-Bold").fillColor("#000000");
          doc.text(`${exp.role} at ${exp.company}`);

          doc.fontSize(10).font("Helvetica").fillColor("#666666");
          const dateRange = `${formatDate(exp.startDate)} – ${exp.endDate ? formatDate(exp.endDate) : "Present"}`;
          doc.text(`${exp.location} | ${dateRange}`);

          if (exp.bulletPoints && exp.bulletPoints.length > 0) {
            doc.moveDown(0.2);
            exp.bulletPoints.forEach(bullet => {
              doc.fontSize(10).fillColor("#333333");
              doc.text(`◆ ${bullet}`, { indent: 10 });
            });
          }

          if (index < resumeData.workExperiences.length - 1) {
            doc.moveDown(0.3);
          }
        });

        doc.moveDown(0.3);
      }

      // Education
      if (resumeData.educations && resumeData.educations.length > 0) {
        doc.fontSize(14).font("Helvetica-Bold").fillColor(primaryColor);
        doc.text("Education");
        doc.moveDown(0.2);

        resumeData.educations.forEach((edu, index) => {
          doc.fontSize(12).font("Helvetica-Bold").fillColor("#000000");
          doc.text(`${edu.degree} in ${edu.field}`);

          doc.fontSize(10).font("Helvetica").fillColor("#666666");
          const gradText = `${edu.school} | ${edu.graduationDate}${edu.gpa ? ` | GPA: ${edu.gpa}` : ""}`;
          doc.text(gradText);

          if (index < resumeData.educations.length - 1) {
            doc.moveDown(0.2);
          }
        });

        doc.moveDown(0.3);
      }

      // Skills
      if (resumeData.skills && resumeData.skills.length > 0) {
        doc.fontSize(14).font("Helvetica-Bold").fillColor(primaryColor);
        doc.text("Skills");
        doc.moveDown(0.2);

        const skillNames = resumeData.skills.map(s => s.name).join(" • ");
        doc.fontSize(10).font("Helvetica").fillColor("#333333");
        doc.text(skillNames, { width: 500 });
      }

      doc.end();
      createPdfBuffer(doc).then(resolve).catch(reject);
    } catch (error) {
      reject(error);
    }
  });
}
