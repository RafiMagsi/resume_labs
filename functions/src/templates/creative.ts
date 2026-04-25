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
  writeEducationBlock,
  writeTwoColumnList,
  writeWorkExperienceBlock,
} from "./_shared";

const ACCENT = "#D946EF";
const TEXT = "#334155";
const MUTED = "#6B7280";
const DIVIDER = "#E5E7EB";

export async function generateCreativeTemplate(resumeData: ResumeData): Promise<Buffer> {
  const doc = new PDFDocument({ size: "A4", margin: DEFAULT_PAGE_MARGIN });
  const frame = getContentFrame(doc);
  const imageBuffer = await downloadImage(resumeData.photoUrl);

  renderSingleColumnHeader(doc, resumeData, imageBuffer, {
    accentColor: ACCENT,
    nameColor: "#111111",
    subtitle: "Creative Resume",
    subtitleColor: MUTED,
    dividerColor: DIVIDER,
    topAccentBar: false,
    headerBottomGap: 22,
    contentGapAfterDivider: 18,
    nameFontSize: 27,
    photo: { enabled: true, size: 70, gap: 18, shape: "square" },
  });

  const heading = {
    titleColor: "#111111",
    dividerColor: DIVIDER,
    fontSize: 12,
    uppercase: false,
    characterSpacing: 0.2,
    gapAfterDivider: 10,
  } as const;

  renderSectionHeading(doc, "Creative Summary", { ...heading, titleColor: ACCENT }, frame);
  writeBodyText(doc, resumeData.personalSummary?.trim() || "No personal summary provided.", { color: TEXT, fontSize: 10.6 }, frame);
  doc.moveDown(0.95);

  const extras = readExtraLists(resumeData);
  if (extras.projects.length) {
    renderSectionHeading(doc, "Selected Projects", { ...heading, titleColor: ACCENT }, frame);
    writeBullets(
      doc,
      extras.projects.slice(0, 8),
      { marker: "•", markerColor: ACCENT, textColor: TEXT, fontSize: 10.2, lineGap: 3, indent: 12 },
      frame,
    );
    doc.moveDown(0.95);
  }

  renderSectionHeading(doc, "Experience", { ...heading, titleColor: ACCENT }, frame);
  if (!resumeData.workExperiences?.length) {
    writeBodyText(doc, "No work experience added.", { color: TEXT }, frame);
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
  doc.moveDown(0.95);

  renderSectionHeading(doc, "Tools & Skills", { ...heading, titleColor: ACCENT }, frame);
  if (!resumeData.skills?.length) {
    writeBodyText(doc, "No skills added.", { color: TEXT }, frame);
  } else {
    const tools = resumeData.skills
      .map((s) => (s.category?.trim() ? `${s.name} - ${s.category}` : s.name))
      .filter((s) => s.trim());
    writeTwoColumnList(doc, tools, { color: TEXT, fontSize: 10.1, columnGap: 18, bulletMarker: "•" }, frame);
  }
  doc.moveDown(0.95);

  renderSectionHeading(doc, "Education", { ...heading, titleColor: ACCENT }, frame);
  if (!resumeData.educations?.length) {
    writeBodyText(doc, "No education added.", { color: TEXT }, frame);
  } else {
    resumeData.educations.forEach((edu, index) => {
      writeEducationBlock(doc, edu, { degreeColor: "#111111", schoolColor: "#4B5563", metaColor: MUTED }, frame);
      if (index < resumeData.educations.length - 1) doc.moveDown(0.8);
    });
  }

  doc.end();
  return createPdfBuffer(doc);
}

