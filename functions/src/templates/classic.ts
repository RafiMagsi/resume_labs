import { ResumeData } from "../types";
import { generateSingleColumnTemplate } from "./_singleColumn";

export async function generateClassicTemplate(resumeData: ResumeData): Promise<Buffer> {
  return generateSingleColumnTemplate(resumeData, {
    header: {
      accentColor: "#111111",
      subtitle: "Professional Resume",
      subtitleColor: "#6B7280",
      dividerColor: "#CBD5E1",
      topAccentBar: false,
      photo: { enabled: true, size: 68, gap: 16, shape: "circle" },
    },
    sectionHeading: {
      titleColor: "#374151",
      dividerColor: "#CBD5E1",
      fontSize: 11,
      uppercase: true,
      characterSpacing: 1.1,
      gapAfterDivider: 12,
    },
    bodyTextColor: "#334155",
    mutedTextColor: "#6B7280",
    dividerColor: "#CBD5E1",
    experience: {
      roleColor: "#111111",
      companyColor: "#4B5563",
      dateColor: "#6B7280",
      bodyColor: "#334155",
      bulletMarker: "•",
      bulletMarkerColor: "#111111",
    },
    education: {
      degreeColor: "#111111",
      schoolColor: "#4B5563",
      metaColor: "#6B7280",
    },
    sectionTitles: {
      summary: "Professional Summary",
      experience: "Work Experience",
      education: "Education",
      skills: "Skills",
    },
  });
}
