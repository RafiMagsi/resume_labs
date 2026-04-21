import * as functions from "firebase-functions";
import express from "express";
import cors from "cors";
import PDFDocument from "pdfkit";

const app = express();
app.use(cors({origin: true}));
app.use(express.json({limit: "50mb"}));

interface ResumeData {
  title: string;
  personalSummary: string;
  photoUrl?: string;
  workExperiences: WorkExperience[];
  educations: Education[];
  skills: Skill[];
}

interface WorkExperience {
  role: string;
  company: string;
  location: string;
  startDate: string;
  endDate?: string;
  bulletPoints: string[];
}

interface Education {
  degree: string;
  field: string;
  school: string;
  graduationDate: string;
  gpa?: number;
}

interface Skill {
  name: string;
}

function generateResumePDF(resumeData: ResumeData, template: string): Promise<Buffer> {
  return new Promise((resolve, reject) => {
    try {
      const doc = new PDFDocument({
        size: "A4",
        margin: 40,
      });

      const chunks: Buffer[] = [];
      doc.on("data", (chunk: Buffer) => chunks.push(chunk));
      doc.on("end", () => resolve(Buffer.concat(chunks)));
      doc.on("error", reject);

      // Colors based on template
      const primaryColor = template === "modern" ? "#0066cc" : "#000000";
      const secondaryColor = template === "modern" ? "#0066cc" : "#333333";

      // Header
      doc.fontSize(28).font("Helvetica-Bold").fillColor(primaryColor);
      doc.text(resumeData.title || "Resume", {align: "center"});

      if (resumeData.personalSummary) {
        doc.moveDown(0.3);
        doc.fontSize(11).fillColor("#666666").font("Helvetica");
        doc.text(resumeData.personalSummary, {align: "center", width: 500});
      }

      doc.moveDown(0.5);
      doc.strokeColor("#cccccc").lineWidth(1).moveTo(40, doc.y).lineTo(555, doc.y).stroke();
      doc.moveDown(0.3);

      // Work Experience
      if (resumeData.workExperiences && resumeData.workExperiences.length > 0) {
        doc.fontSize(14).font("Helvetica-Bold").fillColor(secondaryColor);
        doc.text("Work Experience");
        doc.moveDown(0.2);

        resumeData.workExperiences.forEach((exp, index) => {
          doc.fontSize(12).font("Helvetica-Bold").fillColor("#000000");
          doc.text(`${exp.role} at ${exp.company}`, {underline: false});

          doc.fontSize(10).font("Helvetica").fillColor("#666666");
          const dateRange = `${formatDate(exp.startDate)} – ${exp.endDate ? formatDate(exp.endDate) : "Present"}`;
          doc.text(`${exp.location} | ${dateRange}`);

          if (exp.bulletPoints && exp.bulletPoints.length > 0) {
            doc.moveDown(0.2);
            exp.bulletPoints.forEach(bullet => {
              doc.fontSize(10).fillColor("#333333");
              doc.text(`• ${bullet}`, {indent: 10});
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
        doc.fontSize(14).font("Helvetica-Bold").fillColor(secondaryColor);
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
        doc.fontSize(14).font("Helvetica-Bold").fillColor(secondaryColor);
        doc.text("Skills");
        doc.moveDown(0.2);

        const skillNames = resumeData.skills.map(s => s.name).join(" • ");
        doc.fontSize(10).font("Helvetica").fillColor("#333333");
        doc.text(skillNames, {width: 500});
      }

      doc.end();
    } catch (error) {
      reject(error);
    }
  });
}

function formatDate(dateString: string): string {
  if (!dateString) return "";
  try {
    const date = new Date(dateString);
    return date.toLocaleDateString("en-US", {year: "numeric", month: "short"});
  } catch {
    return dateString;
  }
}

app.post("/", async (req, res) => {
  try {
    const {resumeData, template} = req.body;

    if (!resumeData || !template) {
      return res.status(400).json({error: "Missing resumeData or template"});
    }

    const pdfBuffer = await generateResumePDF(resumeData, template);

    res.set("Content-Type", "application/pdf");
    res.set("Content-Disposition", "attachment; filename=resume.pdf");
    res.send(pdfBuffer);
  } catch (error) {
    console.error("PDF Generation Error:", error);
    res.status(500).json({error: error instanceof Error ? error.message : "Unknown error"});
  }
});

export const generatePdf = functions.https.onRequest(app);
