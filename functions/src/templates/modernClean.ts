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

export async function generateModernCleanTemplate(resumeData: ResumeData): Promise<Buffer> {
  return new Promise(async (resolve, reject) => {
    try {
      const doc = new PDFDocument({ size: "A4", margin: 45 });
      const accentColor = "#1a1a1a";

      // Download image if URL provided
      let imageBuffer: Buffer | null = null;
      if (resumeData.photoUrl) {
        imageBuffer = await downloadImage(resumeData.photoUrl);
      }

      // Photo (top right, circular)
      if (imageBuffer) {
        try {
          const photoRadius = 32;
          const photoDiameter = photoRadius * 2;
          const photoX = 550 - photoRadius * 2;
          const photoY = 50 + photoRadius;

          doc.save();
          doc.circle(photoX + photoRadius, photoY + photoRadius, photoRadius);
          doc.clip();
          doc.image(imageBuffer, photoX, photoY, {
            width: photoDiameter,
            height: photoDiameter,
            fit: [photoDiameter, photoDiameter],
          });
          doc.restore();
          doc.circle(photoX + photoRadius, photoY + photoRadius, photoRadius).stroke(accentColor);
        } catch (error) {
          const photoRadius = 32;
          doc.circle(550 - photoRadius, 50 + photoRadius, photoRadius).stroke(accentColor);
        }
      } else if (resumeData.photoUrl) {
        const photoRadius = 32;
        doc.circle(550 - photoRadius, 50 + photoRadius, photoRadius).stroke(accentColor);
      }

      // Header
      doc.fontSize(26).font("Helvetica-Bold").fillColor(accentColor);
      doc.text(resumeData.title || "Resume", { align: "left" });

      if (resumeData.personalSummary) {
        doc.moveDown(0.2);
        doc.fontSize(10).fillColor("#555555").font("Helvetica");
        doc.text(resumeData.personalSummary, { width: 500 });
      }

      doc.moveDown(0.4);

      // Work Experience
      if (resumeData.workExperiences && resumeData.workExperiences.length > 0) {
        doc.fontSize(12).font("Helvetica-Bold").fillColor(accentColor);
        doc.text("PROFESSIONAL EXPERIENCE");
        doc.moveDown(0.2);
        doc.strokeColor("#e0e0e0").lineWidth(0.5).moveTo(45, doc.y).lineTo(550, doc.y).stroke();
        doc.moveDown(0.3);

        resumeData.workExperiences.forEach((exp, index) => {
          doc.fontSize(11).font("Helvetica-Bold").fillColor(accentColor);
          doc.text(`${exp.role}`, { continued: true });
          doc.font("Helvetica").fillColor("#666666");
          doc.text(` · ${exp.company}`);

          doc.fontSize(9).fillColor("#888888").font("Helvetica");
          const dateRange = `${formatDate(exp.startDate)} – ${exp.endDate ? formatDate(exp.endDate) : "Present"} • ${exp.location}`;
          doc.text(dateRange);

          if (exp.bulletPoints && exp.bulletPoints.length > 0) {
            doc.moveDown(0.2);
            exp.bulletPoints.forEach(bullet => {
              doc.fontSize(9.5).fillColor("#444444");
              doc.text(`→ ${bullet}`, { indent: 10 });
            });
          }

          if (index < resumeData.workExperiences.length - 1) {
            doc.moveDown(0.3);
          }
        });

        doc.moveDown(0.4);
      }

      // Education
      if (resumeData.educations && resumeData.educations.length > 0) {
        doc.fontSize(12).font("Helvetica-Bold").fillColor(accentColor);
        doc.text("EDUCATION");
        doc.moveDown(0.2);
        doc.strokeColor("#e0e0e0").lineWidth(0.5).moveTo(45, doc.y).lineTo(550, doc.y).stroke();
        doc.moveDown(0.3);

        resumeData.educations.forEach((edu, index) => {
          doc.fontSize(11).font("Helvetica-Bold").fillColor(accentColor);
          doc.text(`${edu.degree} in ${edu.field}`);

          doc.fontSize(9.5).fillColor("#666666").font("Helvetica");
          const gradText = `${edu.school} | ${edu.graduationDate}${edu.gpa ? ` | GPA: ${edu.gpa}` : ""}`;
          doc.text(gradText);

          if (index < resumeData.educations.length - 1) {
            doc.moveDown(0.2);
          }
        });

        doc.moveDown(0.4);
      }

      // Skills
      if (resumeData.skills && resumeData.skills.length > 0) {
        doc.fontSize(12).font("Helvetica-Bold").fillColor(accentColor);
        doc.text("SKILLS");
        doc.moveDown(0.2);
        doc.strokeColor("#e0e0e0").lineWidth(0.5).moveTo(45, doc.y).lineTo(550, doc.y).stroke();
        doc.moveDown(0.3);

        const skillNames = resumeData.skills.map(s => s.name).join(" • ");
        doc.fontSize(9.5).font("Helvetica").fillColor("#444444");
        doc.text(skillNames, { width: 500 });
      }

      doc.end();
      createPdfBuffer(doc).then(resolve).catch(reject);
    } catch (error) {
      reject(error);
    }
  });
}
