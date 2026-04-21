import * as functions from "firebase-functions";
import express from "express";
import cors from "cors";
import { ResumeData } from "./types";
import { generateResumePDF } from "./templates";

const app = express();
app.use(cors({origin: true}));
app.use(express.json({limit: "50mb"}));

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
