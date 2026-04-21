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

export async function generateExecutiveTemplate(resumeData: ResumeData): Promise<Buffer> {
  return new Promise(async (resolve, reject) => {
    try {
      const doc = new PDFDocument({ size: "A4", margin: 50 });
      const primaryColor = "#1e3a8a";
      const accentColor = "#0f172a";

      // Download image if URL provided
      let imageBuffer: Buffer | null = null;
      if (resumeData.photoUrl) {
        imageBuffer = await downloadImage(resumeData.photoUrl);
      }

      // Photo (top right, circular)
      if (imageBuffer) {
        try {
          const photoRadius = 35;
          const photoDiameter = photoRadius * 2;
          const photoX = 495;
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
          doc.circle(photoX + photoRadius, photoY + photoRadius, photoRadius).stroke(primaryColor).lineWidth(2);
        } catch (error) {
          const photoRadius = 35;
          doc.circle(495 + photoRadius, 50 + photoRadius, photoRadius).stroke(primaryColor).lineWidth(2);
        }
      } else if (resumeData.photoUrl) {
        const photoRadius = 35;
        doc.circle(495 + photoRadius, 50 + photoRadius, photoRadius).stroke(primaryColor).lineWidth(2);
      }

      // Header with top border
      doc.rect(50, 50, 495, 3).fill(primaryColor);
      doc.moveDown(0.3);

      doc.fontSize(32).font("Helvetica-Bold").fillColor(accentColor);
      doc.text(resumeData.title || "RESUME", { align: "center" });

      if (resumeData.personalSummary) {
        doc.moveDown(0.3);
        doc.fontSize(11).fillColor("#374151").font("Helvetica");
        doc.text(resumeData.personalSummary, { align: "center", width: 495 });
      }

      doc.moveDown(0.6);
      doc.rect(50, doc.y, 495, 2).fill(primaryColor);
      doc.moveDown(0.4);

      // Work Experience
      if (resumeData.workExperiences && resumeData.workExperiences.length > 0) {
        doc.fontSize(13).font("Helvetica-Bold").fillColor(primaryColor);
        doc.text("PROFESSIONAL EXPERIENCE", { underline: false });
        doc.moveDown(0.3);

        resumeData.workExperiences.forEach((exp, index) => {
          // Company and role header
          doc.fontSize(12).font("Helvetica-Bold").fillColor(accentColor);
          doc.text(`${exp.company}`, { continued: true });
          doc.fontSize(11).fillColor("#666666");
          doc.text(` — ${exp.role}`);

          // Date and location
          doc.fontSize(10).fillColor("#888888").font("Helvetica");
          const dateRange = `${formatDate(exp.startDate)} – ${exp.endDate ? formatDate(exp.endDate) : "Present"} | ${exp.location}`;
          doc.text(dateRange);

          // Bullet points
          if (exp.bulletPoints && exp.bulletPoints.length > 0) {
            doc.moveDown(0.2);
            exp.bulletPoints.forEach(bullet => {
              doc.fontSize(10).fillColor("#374151");
              doc.text(`◆ ${bullet}`, { indent: 10 });
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
        doc.fontSize(13).font("Helvetica-Bold").fillColor(primaryColor);
        doc.text("EDUCATION");
        doc.moveDown(0.3);

        resumeData.educations.forEach((edu, index) => {
          doc.fontSize(11).font("Helvetica-Bold").fillColor(accentColor);
          doc.text(`${edu.degree} in ${edu.field}`);

          doc.fontSize(10).fillColor("#666666").font("Helvetica");
          const gradText = `${edu.school} • ${edu.graduationDate}${edu.gpa ? ` • GPA: ${edu.gpa}` : ""}`;
          doc.text(gradText);

          if (index < resumeData.educations.length - 1) {
            doc.moveDown(0.2);
          }
        });

        doc.moveDown(0.4);
      }

      // Skills
      if (resumeData.skills && resumeData.skills.length > 0) {
        doc.fontSize(13).font("Helvetica-Bold").fillColor(primaryColor);
        doc.text("CORE COMPETENCIES");
        doc.moveDown(0.3);

        const skillNames = resumeData.skills.map(s => s.name).join(" • ");
        doc.fontSize(10).font("Helvetica").fillColor("#374151");
        doc.text(skillNames, { width: 495 });
      }

      doc.end();
      createPdfBuffer(doc).then(resolve).catch(reject);
    } catch (error) {
      reject(error);
    }
  });
}
