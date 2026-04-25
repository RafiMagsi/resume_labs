import PDFDocument from "pdfkit";
import { createPdfBuffer, ResumeData } from "../types";
import {
  DEFAULT_PAGE_MARGIN,
  downloadImage,
  getContentFrame,
  readExtraLists,
  renderSectionHeading,
  renderSingleColumnHeader,
  writeBodyText,
  writeBullets,
  writeEducationBlockDateRight,
  writeTwoColumnList,
  writeWorkExperienceBlock,
} from "./_shared";

const ACCENT = "#1F2937";
const TEXT = "#334155";
const MUTED = "#6B7280";
const DIVIDER = "#CBD5E1";

export async function generateAcademicTemplate(resumeData: ResumeData): Promise<Buffer> {
  const doc = new PDFDocument({ size: "A4", margin: DEFAULT_PAGE_MARGIN });
  const frame = getContentFrame(doc);
  const imageBuffer = await downloadImage(resumeData.photoUrl);

  renderSingleColumnHeader(doc, resumeData, imageBuffer, {
    accentColor: ACCENT,
    nameColor: "#111111",
    subtitle: "",
    subtitleColor: MUTED,
    dividerColor: DIVIDER,
    topAccentBar: false,
    photo: { enabled: true, size: 64, gap: 16, shape: "square" },
    headerBottomGap: 20,
  });

  const heading = {
    titleColor: ACCENT,
    dividerColor: DIVIDER,
    fontSize: 11,
    uppercase: true,
    characterSpacing: 1.1,
    gapAfterDivider: 12,
  } as const;

  const extras = readExtraLists(resumeData);

  renderSectionHeading(doc, "Research Summary", heading, frame);
  writeBodyText(doc, resumeData.personalSummary?.trim() || "No personal summary provided.", { color: TEXT }, frame);
  doc.moveDown(1.0);

  renderSectionHeading(doc, "Education", heading, frame);
  if (!resumeData.educations?.length) {
    writeBodyText(doc, "No education added.", { color: TEXT }, frame);
  } else {
    resumeData.educations.forEach((edu, index) => {
      writeEducationBlockDateRight(
        doc,
        edu,
        { degreeColor: "#111111", schoolColor: "#4B5563", metaColor: MUTED, dateColor: MUTED, dateWidth: 140, gap: 12 },
        frame,
      );
      if (index < resumeData.educations.length - 1) doc.moveDown(0.8);
    });
  }
  doc.moveDown(1.0);

  if (extras.publications.length) {
    renderSectionHeading(doc, "Publications", heading, frame);
    writeBullets(
      doc,
      extras.publications,
      { marker: "•", markerColor: ACCENT, textColor: TEXT, fontSize: 10.0, lineGap: 3, indent: 12 },
      frame,
    );
    doc.moveDown(1.0);
  }

  renderSectionHeading(doc, "Research Experience", heading, frame);
  if (!resumeData.workExperiences?.length) {
    writeBodyText(doc, "No research experience added.", { color: TEXT }, frame);
  } else {
    resumeData.workExperiences.forEach((exp, index) => {
      writeWorkExperienceBlock(
        doc,
        exp,
        {
          roleColor: "#111111",
          companyColor: "#4B5563",
          dateColor: MUTED,
          bodyColor: TEXT,
          bullet: { marker: "•", markerColor: ACCENT, textColor: TEXT, fontSize: 10.2, lineGap: 3, indent: 12 },
        },
        frame,
      );
      if (index < resumeData.workExperiences.length - 1) doc.moveDown(0.9);
    });
  }
  doc.moveDown(1.0);

  if (extras.achievements.length) {
    renderSectionHeading(doc, "Awards & Recognition", heading, frame);
    writeBullets(
      doc,
      extras.achievements,
      { marker: "•", markerColor: ACCENT, textColor: TEXT, fontSize: 10.2, lineGap: 3, indent: 12 },
      frame,
    );
    doc.moveDown(1.0);
  }

  renderSectionHeading(doc, "Skills", heading, frame);
  if (!resumeData.skills?.length) {
    writeBodyText(doc, "No skills added.", { color: TEXT }, frame);
  } else {
    const skillLines = resumeData.skills
      .map((s) => (s.category?.trim() ? `${s.name} - ${s.category}` : s.name))
      .filter((s) => s.trim());
    writeTwoColumnList(doc, skillLines, { color: TEXT, fontSize: 10.1, columnGap: 18, bulletMarker: "•" }, frame);
  }

  doc.end();
  return createPdfBuffer(doc);
}
