import PDFDocument from "pdfkit";
import { createPdfBuffer, ResumeData } from "../types";
import {
  downloadImage,
  readExtraLists,
  renderSectionHeading,
  renderSingleColumnHeader,
  writeBodyText,
  writeEducationBlock,
  writeWorkExperienceBlock,
  DEFAULT_PAGE_MARGIN,
  SectionHeadingStyle,
  HeaderStyle,
  ExperienceStyle,
  EducationStyle,
} from "./_shared";

export interface SingleColumnTemplateStyle {
  pageMargin?: number;

  header: HeaderStyle;
  sectionHeading: SectionHeadingStyle;

  bodyTextColor: string;
  bodyTextSize?: number;
  mutedTextColor: string;
  dividerColor: string;

  experience: Omit<ExperienceStyle, "bullet"> & {
    bulletMarker: string;
    bulletMarkerColor: string;
  };
  education: EducationStyle;

  sectionTitles: {
    summary: string;
    experience: string;
    education: string;
    skills: string;
    projects?: string;
    achievements?: string;
    publications?: string;
    interests?: string;
    languages?: string;
    references?: string;
  };

  skillsInlineSeparator?: string;
}

export async function generateSingleColumnTemplate(
  resumeData: ResumeData,
  style: SingleColumnTemplateStyle,
): Promise<Buffer> {
  const margin = style.pageMargin ?? DEFAULT_PAGE_MARGIN;
  const doc = new PDFDocument({ size: "A4", margin });

  const imageBuffer = await downloadImage(resumeData.photoUrl);
  renderSingleColumnHeader(doc, resumeData, imageBuffer, style.header);

  renderSectionHeading(doc, style.sectionTitles.summary, style.sectionHeading);
  writeBodyText(
    doc,
    resumeData.personalSummary?.trim() || "No personal summary provided.",
    { color: style.bodyTextColor, fontSize: style.bodyTextSize ?? 10.6 },
  );
  doc.moveDown(1.05);

  renderSectionHeading(doc, style.sectionTitles.experience, style.sectionHeading);
  if (!resumeData.workExperiences?.length) {
    writeBodyText(doc, "No work experience added.", { color: style.bodyTextColor });
  } else {
    resumeData.workExperiences.forEach((exp, index) => {
      writeWorkExperienceBlock(doc, exp, {
        roleColor: style.experience.roleColor,
        companyColor: style.experience.companyColor,
        dateColor: style.experience.dateColor,
        bodyColor: style.experience.bodyColor,
        bullet: {
          marker: style.experience.bulletMarker,
          markerColor: style.experience.bulletMarkerColor,
          textColor: style.bodyTextColor,
          fontSize: 10.2,
          lineGap: 3,
          indent: 12,
        },
      });
      if (index < resumeData.workExperiences.length - 1) doc.moveDown(0.9);
    });
  }
  doc.moveDown(1.05);

  renderSectionHeading(doc, style.sectionTitles.education, style.sectionHeading);
  if (!resumeData.educations?.length) {
    writeBodyText(doc, "No education added.", { color: style.bodyTextColor });
  } else {
    resumeData.educations.forEach((edu, index) => {
      writeEducationBlock(doc, edu, style.education);
      if (index < resumeData.educations.length - 1) doc.moveDown(0.8);
    });
  }
  doc.moveDown(1.05);

  const extras = readExtraLists(resumeData);
  const extrasEntries: Array<{ key: keyof typeof extras; title: string }> = [
    { key: "projects", title: style.sectionTitles.projects ?? "Projects" },
    {
      key: "achievements",
      title: style.sectionTitles.achievements ?? "Achievements & Awards",
    },
    { key: "publications", title: style.sectionTitles.publications ?? "Publications" },
    { key: "interests", title: style.sectionTitles.interests ?? "Interests" },
    { key: "languages", title: style.sectionTitles.languages ?? "Languages" },
    { key: "references", title: style.sectionTitles.references ?? "References" },
  ];

  extrasEntries.forEach(({ key, title }) => {
    const items = extras[key];
    if (!items.length) return;
    renderSectionHeading(doc, title, style.sectionHeading);
    items.forEach((line) => {
      writeBodyText(doc, `• ${line}`, { color: style.bodyTextColor, fontSize: 10.2 });
    });
    doc.moveDown(1.05);
  });

  renderSectionHeading(doc, style.sectionTitles.skills, style.sectionHeading);
  if (!resumeData.skills?.length) {
    writeBodyText(doc, "No skills added.", { color: style.bodyTextColor });
  } else {
    const separator = style.skillsInlineSeparator ?? " • ";
    const skillsLine = resumeData.skills
      .map((skill) =>
        skill.category?.trim() ? `${skill.name} - ${skill.category}` : skill.name,
      )
      .join(separator);
    writeBodyText(doc, skillsLine, { color: style.bodyTextColor });
  }

  doc.end();
  return createPdfBuffer(doc);
}

