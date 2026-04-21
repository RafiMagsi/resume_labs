import * as functions from "firebase-functions";
import express from "express";
import cors from "cors";
import puppeteer from "puppeteer";

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

function generateResumeHTML(resumeData: ResumeData, template: string): string {
  const {title, personalSummary, photoUrl, workExperiences, educations, skills} = resumeData;

  return `
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="UTF-8">
      <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
          font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
          line-height: 1.6;
          color: #333;
          background: white;
        }
        .container { max-width: 8.5in; margin: 0 auto; padding: 0.5in; background: white; }
        .header {
          text-align: center;
          margin-bottom: 0.3in;
          padding-bottom: 0.2in;
          border-bottom: ${template === "modern" ? "3px solid #0066cc" : "1px solid #ccc"};
        }
        .header h1 {
          margin: 0 0 0.1in 0;
          font-size: 28px;
          font-weight: 700;
          color: ${template === "modern" ? "#0066cc" : "#000"};
        }
        .header p { margin: 0.05in 0; font-size: 11px; color: #666; }
        .section {
          margin-bottom: 0.25in;
          page-break-inside: avoid;
        }
        .section-title {
          font-size: 13px;
          font-weight: 700;
          border-bottom: 1px solid #ccc;
          padding-bottom: 0.05in;
          margin-bottom: 0.1in;
          color: ${template === "modern" ? "#0066cc" : "#000"};
        }
        .entry { margin-bottom: 0.15in; page-break-inside: avoid; }
        .entry-title { font-weight: 700; font-size: 12px; margin: 0; }
        .entry-subtitle { font-size: 11px; color: #666; font-style: italic; margin: 0.02in 0; }
        .entry-text { font-size: 10px; margin: 0.05in 0 0 0; line-height: 1.4; }
        .entry-bullet { font-size: 10px; margin: 0.02in 0 0 0.15in; }
        .skills-list { display: flex; flex-wrap: wrap; gap: 0.08in; }
        .skill-tag {
          background-color: ${template === "modern" ? "#e8f4f8" : "#f0f0f0"};
          padding: 0.04in 0.08in;
          border-radius: 3px;
          font-size: 10px;
          color: ${template === "modern" ? "#0066cc" : "#333"};
        }
        .photo { width: 0.8in; height: 0.8in; border-radius: 50%; margin-bottom: 0.1in; object-fit: cover; }
        @media print { body { margin: 0; padding: 0; } .container { padding: 0.5in; } }
      </style>
    </head>
    <body>
      <div class="container">
        <!-- Header -->
        <div class="header">
          ${photoUrl ? `<img src="${photoUrl}" alt="Photo" class="photo" onerror="this.style.display='none'">` : ""}
          <h1>${escapeHtml(title || "Resume")}</h1>
          ${personalSummary ? `<p>${escapeHtml(personalSummary)}</p>` : ""}
        </div>

        <!-- Work Experience -->
        ${workExperiences && workExperiences.length > 0 ? `
          <div class="section">
            <h2 class="section-title">Work Experience</h2>
            ${workExperiences.map(exp => `
              <div class="entry">
                <p class="entry-title">${escapeHtml(exp.role || "")} at ${escapeHtml(exp.company || "")}</p>
                <p class="entry-subtitle">${escapeHtml(exp.location || "")} | ${formatDate(exp.startDate)} – ${exp.endDate ? formatDate(exp.endDate) : "Present"}</p>
                ${exp.bulletPoints && exp.bulletPoints.length > 0 ? exp.bulletPoints.map(bullet => `
                  <p class="entry-bullet">• ${escapeHtml(bullet)}</p>
                `).join("") : ""}
              </div>
            `).join("")}
          </div>
        ` : ""}

        <!-- Education -->
        ${educations && educations.length > 0 ? `
          <div class="section">
            <h2 class="section-title">Education</h2>
            ${educations.map(edu => `
              <div class="entry">
                <p class="entry-title">${escapeHtml(edu.degree || "")} in ${escapeHtml(edu.field || "")}</p>
                <p class="entry-subtitle">${escapeHtml(edu.school || "")}</p>
                <p class="entry-text">${escapeHtml(edu.graduationDate || "")}${edu.gpa ? ` • GPA: ${edu.gpa}` : ""}</p>
              </div>
            `).join("")}
          </div>
        ` : ""}

        <!-- Skills -->
        ${skills && skills.length > 0 ? `
          <div class="section">
            <h2 class="section-title">Skills</h2>
            <div class="skills-list">
              ${skills.map(skill => `<span class="skill-tag">${escapeHtml(skill.name || "")}</span>`).join("")}
            </div>
          </div>
        ` : ""}
      </div>
    </body>
    </html>
  `;
}

function escapeHtml(text: string): string {
  if (!text) return "";
  const map: {[key: string]: string} = {
    "&": "&amp;",
    "<": "&lt;",
    ">": "&gt;",
    '"': "&quot;",
    "'": "&#039;",
  };
  return text.replace(/[&<>"']/g, (m) => map[m]);
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

    // Generate HTML from resume data
    const html = generateResumeHTML(resumeData, template);

    // Launch Puppeteer browser
    const browser = await puppeteer.launch({
      headless: "new",
      args: [
        "--no-sandbox",
        "--disable-setuid-sandbox",
        "--disable-dev-shm-usage",
      ],
    });

    const page = await browser.newPage();
    await page.setContent(html, {waitUntil: "networkidle0"});

    // Generate PDF (unlimited pages)
    const pdfBuffer = await page.pdf({
      format: "A4",
      margin: {top: "0.5in", bottom: "0.5in", left: "0.5in", right: "0.5in"},
      printBackground: true,
    });

    await browser.close();

    // Return PDF
    res.set("Content-Type", "application/pdf");
    res.set("Content-Disposition", "attachment; filename=resume.pdf");
    res.send(pdfBuffer);
  } catch (error) {
    console.error("PDF Generation Error:", error);
    res.status(500).json({error: error instanceof Error ? error.message : "Unknown error"});
  }
});

export const generatePdf = functions.https.onRequest(app);
