import { ResumeData, TemplateGenerator } from "../types";
import { generateClassicTemplate } from "./classic";
import { generateModernTemplate } from "./modern";
import { generateMinimalTemplate } from "./minimal";
import { generateModernCleanTemplate } from "./modernClean";
import { generateModernSidebarTemplate } from "./modernSidebar";
import { generateExecutiveTemplate } from "./executive";
import { generateCreativeTemplate } from "./creative";
import { generateAcademicTemplate } from "./academic";
import { generateHealthcareTemplate } from "./healthcare";
import { generateSalesTemplate } from "./sales";
import { generateFinanceTemplate } from "./finance";
import { generateMarketingTemplate } from "./marketing";
import { generateDataScienceTemplate } from "./datascience";
import { generateStartupTemplate } from "./startup";

export enum ProfessionCategory {
  TECH = "Tech & IT",
  AI_DATA = "AI & Data Science",
  SALES = "Sales & Business Development",
  MARKETING = "Marketing & Communications",
  FINANCE = "Finance & Accounting",
  BUSINESS = "Business & Management",
  CREATIVE = "Creative & Design",
  ACADEMIC = "Academic & Research",
  HEALTHCARE = "Healthcare & Medical",
  STARTUP = "Startup & Entrepreneurship",
}

export interface TemplateInfo {
  id: string;
  name: string;
  profession: string;
  description: string;
  category: ProfessionCategory;
}

export const TEMPLATE_REGISTRY: TemplateInfo[] = [
  // Tech & IT (3 templates)
  {
    id: "modernClean",
    name: "Modern Clean",
    profession: "Software Engineer, Full Stack Developer",
    description: "Clean, structured design with organized layout",
    category: ProfessionCategory.TECH,
  },
  {
    id: "modern",
    name: "Modern",
    profession: "Tech Lead, DevOps Engineer",
    description: "Contemporary design with modern accent colors",
    category: ProfessionCategory.TECH,
  },
  {
    id: "minimal",
    name: "Minimal",
    profession: "Backend Engineer, Systems Engineer",
    description: "Minimalist approach emphasizing technical clarity",
    category: ProfessionCategory.TECH,
  },

  // AI & Data Science (1 template)
  {
    id: "datascience",
    name: "Data Science",
    profession: "Data Scientist, AI Engineer, ML Specialist",
    description: "Technical layout perfect for data-driven professionals",
    category: ProfessionCategory.AI_DATA,
  },

  // Sales & Business Development (1 template)
  {
    id: "sales",
    name: "Sales",
    profession: "Sales Executive, Account Manager, Business Development",
    description: "Results-focused design highlighting achievements",
    category: ProfessionCategory.SALES,
  },

  // Marketing & Communications (1 template)
  {
    id: "marketing",
    name: "Marketing",
    profession: "Marketing Manager, Digital Marketer, Content Strategist",
    description: "Engaging design for creative marketing professionals",
    category: ProfessionCategory.MARKETING,
  },

  // Finance & Accounting (1 template)
  {
    id: "finance",
    name: "Finance",
    profession: "CPA, Financial Analyst, CFO, Accountant",
    description: "Professional design with gold accents for finance roles",
    category: ProfessionCategory.FINANCE,
  },

  // Business & Management (3 templates)
  {
    id: "executive",
    name: "Executive",
    profession: "Director, Manager, VP, C-Suite Executive",
    description: "Formal, authoritative design for executive leadership",
    category: ProfessionCategory.BUSINESS,
  },
  {
    id: "modernSidebar",
    name: "Modern Sidebar",
    profession: "Consultant, Business Analyst, Project Manager",
    description: "Two-column layout highlighting skills and experience",
    category: ProfessionCategory.BUSINESS,
  },
  {
    id: "classic",
    name: "Classic",
    profession: "Manager, Operations Manager, Administrator",
    description: "Timeless, trusted professional design",
    category: ProfessionCategory.BUSINESS,
  },

  // Creative & Design (1 template)
  {
    id: "creative",
    name: "Creative",
    profession: "UX/UI Designer, Graphic Designer, Creative Director",
    description: "Vibrant, visually engaging design with creative flair",
    category: ProfessionCategory.CREATIVE,
  },

  // Academic & Research (1 template)
  {
    id: "academic",
    name: "Academic",
    profession: "Professor, Researcher, PhD, Educator",
    description: "Formal CV style with institutional focus",
    category: ProfessionCategory.ACADEMIC,
  },

  // Healthcare & Medical (1 template)
  {
    id: "healthcare",
    name: "Healthcare",
    profession: "Doctor, Nurse, Medical Professional, Healthcare Admin",
    description: "Professional design with clinical focus",
    category: ProfessionCategory.HEALTHCARE,
  },

  // Startup & Entrepreneurship (1 template)
  {
    id: "startup",
    name: "Startup",
    profession: "Founder, CEO, Entrepreneur, Startup Leader",
    description: "Dynamic design for innovative founders and entrepreneurs",
    category: ProfessionCategory.STARTUP,
  },
];

const templates: Record<string, TemplateGenerator> = {
  classic: generateClassicTemplate,
  modern: generateModernTemplate,
  modernClean: generateModernCleanTemplate,
  modernSidebar: generateModernSidebarTemplate,
  minimal: generateMinimalTemplate,
  executive: generateExecutiveTemplate,
  creative: generateCreativeTemplate,
  academic: generateAcademicTemplate,
  healthcare: generateHealthcareTemplate,
  sales: generateSalesTemplate,
  finance: generateFinanceTemplate,
  marketing: generateMarketingTemplate,
  datascience: generateDataScienceTemplate,
  startup: generateStartupTemplate,
};

export async function generateResumePDF(
  resumeData: ResumeData,
  template: string
): Promise<Buffer> {
  const generator = templates[template] || templates.classic;
  return generator(resumeData);
}

export function getTemplatesByProfession(
  category: ProfessionCategory
): TemplateInfo[] {
  return TEMPLATE_REGISTRY.filter((t) => t.category === category);
}

export function getAllTemplates(): TemplateInfo[] {
  return TEMPLATE_REGISTRY;
}

export function getCategoryList(): ProfessionCategory[] {
  return Object.values(ProfessionCategory);
}
