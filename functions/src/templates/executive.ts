import PDFDocument from "pdfkit";
import { ResumeData, formatDate, createPdfBuffer } from "../types";

export async function generateExecutiveTemplate(resumeData: ResumeData): Promise<Buffer> {
  return new Promise((resolve, reject) => {
    try {
      const doc = new PDFDocument({ size: "A4", margin: 50 });
      const primaryColor = "#1e3a8a";
      const accentColor = "#0f172a";

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
