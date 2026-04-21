import PDFDocument from "pdfkit";
import { ResumeData, formatDate, createPdfBuffer } from "../types";

export async function generateModernSidebarTemplate(resumeData: ResumeData): Promise<Buffer> {
  return new Promise((resolve, reject) => {
    try {
      const doc = new PDFDocument({ size: "A4", margin: 0 });
      const sidebarColor = "#2c3e50";
      const textColor = "#2c3e50";

      // Sidebar (left 150px)
      doc.rect(0, 0, 150, 842).fill(sidebarColor);

      // Header in sidebar area
      doc.fontSize(20).font("Helvetica-Bold").fillColor("#ffffff");
      doc.text(resumeData.title || "RESUME", 15, 40, { width: 120, align: "left" });

      // Skills in sidebar
      if (resumeData.skills && resumeData.skills.length > 0) {
        doc.moveDown(0.5);
        doc.fontSize(10).font("Helvetica-Bold").fillColor("#ffffff");
        doc.text("SKILLS", 15, 150, { width: 120 });
        doc.moveDown(0.2);

        doc.fontSize(8).font("Helvetica").fillColor("#ecf0f1");
        let yPos = 170;
        resumeData.skills.forEach(skill => {
          doc.text(skill.name, 15, yPos, { width: 120 });
          yPos += 15;
        });
      }

      // Main content area (right side)
      // Personal Summary
      if (resumeData.personalSummary) {
        doc.fontSize(10).fillColor(textColor).font("Helvetica");
        doc.text(resumeData.personalSummary, 165, 50, { width: 380 });
      }

      let contentY = resumeData.personalSummary ? 110 : 50;

      // Work Experience
      if (resumeData.workExperiences && resumeData.workExperiences.length > 0) {
        doc.fontSize(12).font("Helvetica-Bold").fillColor(textColor);
        doc.text("EXPERIENCE", 165, contentY, { width: 380 });
        contentY += 25;

        resumeData.workExperiences.forEach((exp, index) => {
          doc.fontSize(11).font("Helvetica-Bold").fillColor(textColor);
          doc.text(`${exp.role}`, 165, contentY, { width: 380 });
          contentY += 15;

          doc.fontSize(9).fillColor("#7f8c8d").font("Helvetica");
          doc.text(`${exp.company} | ${exp.location}`, 165, contentY, { width: 380 });
          contentY += 12;

          doc.fontSize(9).fillColor("#555555");
          const dateRange = `${formatDate(exp.startDate)} – ${exp.endDate ? formatDate(exp.endDate) : "Present"}`;
          doc.text(dateRange, 165, contentY, { width: 380 });
          contentY += 12;

          if (exp.bulletPoints && exp.bulletPoints.length > 0) {
            contentY += 5;
            exp.bulletPoints.forEach(bullet => {
              doc.fontSize(9).fillColor("#333333");
              doc.text(`• ${bullet}`, 175, contentY, { width: 370 });
              contentY += 12;
            });
          }

          contentY += 10;
        });
      }

      // Education
      if (resumeData.educations && resumeData.educations.length > 0) {
        doc.fontSize(12).font("Helvetica-Bold").fillColor(textColor);
        doc.text("EDUCATION", 165, contentY, { width: 380 });
        contentY += 25;

        resumeData.educations.forEach(edu => {
          doc.fontSize(11).font("Helvetica-Bold").fillColor(textColor);
          doc.text(`${edu.degree} in ${edu.field}`, 165, contentY, { width: 380 });
          contentY += 15;

          doc.fontSize(9).fillColor("#7f8c8d").font("Helvetica");
          const gradText = `${edu.school} | ${edu.graduationDate}${edu.gpa ? ` | GPA: ${edu.gpa}` : ""}`;
          doc.text(gradText, 165, contentY, { width: 380 });
          contentY += 15;
        });
      }

      doc.end();
      createPdfBuffer(doc).then(resolve).catch(reject);
    } catch (error) {
      reject(error);
    }
  });
}
