import { ResumeData, TemplateGenerator } from "../types";
import { generateClassicTemplate } from "./classic";
import { generateModernTemplate } from "./modern";
import { generateMinimalTemplate } from "./minimal";
import { generateModernCleanTemplate } from "./modernClean";
import { generateModernSidebarTemplate } from "./modernSidebar";
import { generateExecutiveTemplate } from "./executive";

const templates: Record<string, TemplateGenerator> = {
  classic: generateClassicTemplate,
  modern: generateModernTemplate,
  modernClean: generateModernCleanTemplate,
  modernSidebar: generateModernSidebarTemplate,
  minimal: generateMinimalTemplate,
  executive: generateExecutiveTemplate,
};

export async function generateResumePDF(
  resumeData: ResumeData,
  template: string
): Promise<Buffer> {
  const generator = templates[template] || templates.classic;
  return generator(resumeData);
}
