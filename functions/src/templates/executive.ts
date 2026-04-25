import { ResumeData } from "../types";
import { generateSingleColumnTemplate } from "./_singleColumn";

export async function generateExecutiveTemplate(resumeData: ResumeData): Promise<Buffer> {
  return generateSingleColumnTemplate(resumeData, {
    header: {
      accentColor: "#1E3A8A",
      nameColor: "#111111",
      subtitle: "",
      subtitleColor: "#6B7280",
      dividerColor: "#E2E8F0",
      topAccentBar: true,
      topAccentBarHeight: 4,
      photo: { enabled: true, size: 68, gap: 16, shape: "circle" },
    },
    sectionHeading: {
      titleColor: "#1E3A8A",
      dividerColor: "#E2E8F0",
      fontSize: 11,
      uppercase: true,
      characterSpacing: 1.1,
      gapAfterDivider: 12,
    },
    bodyTextColor: "#334155",
    mutedTextColor: "#6B7280",
    dividerColor: "#E2E8F0",
    experience: {
      roleColor: "#111111",
      companyColor: "#4B5563",
      dateColor: "#6B7280",
      bodyColor: "#334155",
      bulletMarker: "•",
      bulletMarkerColor: "#1E3A8A",
    },
    education: {
      degreeColor: "#111111",
      schoolColor: "#4B5563",
      metaColor: "#6B7280",
    },
    sectionTitles: {
      summary: "Executive Summary",
      experience: "Professional Experience",
      education: "Education",
      skills: "Core Competencies",
      achievements: "Leadership Highlights",
    },
  });
}
