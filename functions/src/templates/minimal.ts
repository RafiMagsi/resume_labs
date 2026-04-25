import { ResumeData } from "../types";
import { generateSingleColumnTemplate } from "./_singleColumn";

export async function generateMinimalTemplate(resumeData: ResumeData): Promise<Buffer> {
  return generateSingleColumnTemplate(resumeData, {
    header: {
      accentColor: "#111111",
      subtitle: "Minimal Resume",
      subtitleColor: "#6B7280",
      dividerColor: "#E5E7EB",
      topAccentBar: false,
      photo: { enabled: true, size: 60, gap: 16, shape: "circle" },
    },
    sectionHeading: {
      titleColor: "#6B7280",
      dividerColor: "#E5E7EB",
      fontSize: 10.5,
      uppercase: true,
      characterSpacing: 1,
      gapAfterDivider: 11,
    },
    bodyTextColor: "#374151",
    bodyTextSize: 10.4,
    mutedTextColor: "#6B7280",
    dividerColor: "#E5E7EB",
    experience: {
      roleColor: "#111111",
      companyColor: "#4B5563",
      dateColor: "#6B7280",
      bodyColor: "#374151",
      bulletMarker: "—",
      bulletMarkerColor: "#6B7280",
    },
    education: {
      degreeColor: "#111111",
      schoolColor: "#4B5563",
      metaColor: "#6B7280",
    },
    sectionTitles: {
      summary: "Summary",
      experience: "Experience",
      education: "Education",
      skills: "Skills",
    },
  });
}
