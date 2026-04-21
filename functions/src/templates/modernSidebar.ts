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

export async function generateModernSidebarTemplate(resumeData: ResumeData): Promise<Buffer> {
  return new Promise(async (resolve, reject) => {
    try {
      const doc = new PDFDocument({ size: "A4", margin: 0 });
      const sidebarColor = "#2c3e50";
      const textColor = "#2c3e50";

      // Sidebar (left 150px)
      doc.rect(0, 0, 150, 842).fill(sidebarColor);

      // Download image if URL provided
      let imageBuffer: Buffer | null = null;
      if (resumeData.photoUrl) {
        imageBuffer = await downloadImage(resumeData.photoUrl);
      }

      // Photo in sidebar (circular)
      if (imageBuffer) {
        try {
          const photoRadius = 40;
          const photoDiameter = photoRadius * 2;
          const photoX = 35 - photoRadius;
          const photoY = 40;

          doc.save();
          doc.circle(photoX + photoRadius, photoY + photoRadius, photoRadius);
          doc.clip();
          doc.image(imageBuffer, photoX, photoY, {
            width: photoDiameter,
            height: photoDiameter,
          });
          doc.restore();
          doc.circle(photoX + photoRadius, photoY + photoRadius, photoRadius).stroke("#ffffff");
        } catch (error) {
          const photoRadius = 40;
          doc.circle(35 + photoRadius, 40 + photoRadius, photoRadius).stroke("#ffffff");
        }
      } else if (resumeData.photoUrl) {
        const photoRadius = 40;
        doc.circle(35 + photoRadius, 40 + photoRadius, photoRadius).stroke("#ffffff");
      }

      // Header in sidebar area
      doc.fontSize(20).font("Helvetica-Bold").fillColor("#ffffff");
      doc.text(resumeData.title || "RESUME", 15, 130, { width: 120, align: "left" });

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
      // Ensure content starts below photo height (photo radius 40, diameter 80, positioned at Y=40-120)
      const photoHeight = 80;
      const photoEndY = 40 + photoHeight + 20; // 20pt margin
      let contentY = Math.max(50, photoEndY);

      // Personal Summary
      if (resumeData.personalSummary) {
        doc.fontSize(10).fillColor(textColor).font("Helvetica");
        doc.text(resumeData.personalSummary, 165, contentY, { width: 380 });
        contentY = doc.y + 20;
      } else {
        contentY = photoEndY;
      }

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
