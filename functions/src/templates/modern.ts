import PDFDocument from "pdfkit";
import { ResumeData, formatDate, createPdfBuffer } from "../types";

export async function generateModernTemplate(resumeData: ResumeData): Promise<Buffer> {
  return new Promise((resolve, reject) => {
    try {
      const doc = new PDFDocument({ size: "A4", margin: 40 });
      const primaryColor = "#0066cc";

      // Header with blue accent
      doc.fontSize(28).font("Helvetica-Bold").fillColor(primaryColor);
      doc.text(resumeData.title || "Resume", { align: "center" });

      if (resumeData.personalSummary) {
        doc.moveDown(0.3);
        doc.fontSize(11).fillColor("#666666").font("Helvetica");
        doc.text(resumeData.personalSummary, { align: "center", width: 500 });
      }

      doc.moveDown(0.5);
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
