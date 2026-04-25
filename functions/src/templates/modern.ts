import { ResumeData } from "../types";
import { generateSingleColumnTemplate } from "./_singleColumn";

export async function generateModernTemplate(resumeData: ResumeData): Promise<Buffer> {
  return generateSingleColumnTemplate(resumeData, {
    header: {
      accentColor: "#2563EB",
      nameColor: "#111111",
      subtitle: "",
      subtitleColor: "#6B7280",
      dividerColor: "#E2E8F0",
      topAccentBar: true,
      topAccentBarHeight: 4,
      photo: { enabled: true, size: 68, gap: 16, shape: "circle" },
    },
    sectionHeading: {
      titleColor: "#2563EB",
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
      bulletMarkerColor: "#2563EB",
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
