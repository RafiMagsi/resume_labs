import PDFDocument from "pdfkit";
import { ResumeData, formatDate, createPdfBuffer } from "../types";

export async function generateMinimalTemplate(resumeData: ResumeData): Promise<Buffer> {
  return new Promise((resolve, reject) => {
    try {
      const doc = new PDFDocument({ size: "A4", margin: 40 });

      // Header - minimal styling
      doc.fontSize(24).font("Helvetica-Bold").fillColor("#000000");
      doc.text(resumeData.title || "Resume", { align: "left" });

      if (resumeData.personalSummary) {
        doc.moveDown(0.2);
        doc.fontSize(10).fillColor("#666666").font("Helvetica");
        doc.text(resumeData.personalSummary, { align: "left", width: 515 });
      }

      doc.moveDown(0.4);

      // Work Experience
      if (resumeData.workExperiences && resumeData.workExperiences.length > 0) {
        doc.fontSize(11).font("Helvetica-Bold").fillColor("#000000");
        doc.text("EXPERIENCE");
        doc.moveDown(0.15);

        resumeData.workExperiences.forEach((exp, index) => {
          doc.fontSize(11).font("Helvetica-Bold").fillColor("#000000");
          doc.text(`${exp.role}`, { continued: true });
          doc.font("Helvetica").fillColor("#666666");
          doc.text(` — ${exp.company}`, { continued: true });
          doc.text(` | ${formatDate(exp.startDate)} – ${exp.endDate ? formatDate(exp.endDate) : "Present"}`);

          if (exp.bulletPoints && exp.bulletPoints.length > 0) {
            doc.moveDown(0.1);
            exp.bulletPoints.forEach(bullet => {
              doc.fontSize(9.5).fillColor("#333333");
              doc.text(bullet, { indent: 10 });
            });
          }

          if (index < resumeData.workExperiences.length - 1) {
            doc.moveDown(0.2);
          }
        });

        doc.moveDown(0.3);
      }

      // Education
      if (resumeData.educations && resumeData.educations.length > 0) {
        doc.fontSize(11).font("Helvetica-Bold").fillColor("#000000");
        doc.text("EDUCATION");
        doc.moveDown(0.15);

        resumeData.educations.forEach((edu, index) => {
          doc.fontSize(10.5).font("Helvetica-Bold").fillColor("#000000");
          doc.text(`${edu.degree} in ${edu.field}`, { continued: true });
          doc.font("Helvetica").fillColor("#666666");
          const gradText = ` | ${edu.school} | ${edu.graduationDate}${edu.gpa ? ` | GPA: ${edu.gpa}` : ""}`;
          doc.text(gradText);

          if (index < resumeData.educations.length - 1) {
            doc.moveDown(0.15);
          }
        });

        doc.moveDown(0.3);
      }

      // Skills
      if (resumeData.skills && resumeData.skills.length > 0) {
        doc.fontSize(11).font("Helvetica-Bold").fillColor("#000000");
        doc.text("SKILLS");
        doc.moveDown(0.15);

        const skillNames = resumeData.skills.map(s => s.name).join(" · ");
        doc.fontSize(9.5).font("Helvetica").fillColor("#333333");
        doc.text(skillNames, { width: 500 });
      }

      doc.end();
      createPdfBuffer(doc).then(resolve).catch(reject);
    } catch (error) {
      reject(error);
    }
  });
}
