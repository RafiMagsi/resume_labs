import PDFDocument from "pdfkit";
import { ResumeData, formatDate, createPdfBuffer } from "../types";

export async function generateModernCleanTemplate(resumeData: ResumeData): Promise<Buffer> {
  return new Promise((resolve, reject) => {
    try {
      const doc = new PDFDocument({ size: "A4", margin: 45 });
      const accentColor = "#1a1a1a";

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
