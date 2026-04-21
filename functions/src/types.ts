export interface ResumeData {
  title: string;
  personalSummary: string;
  photoUrl?: string;
  workExperiences: WorkExperience[];
  educations: Education[];
  skills: Skill[];
}

export interface WorkExperience {
  role: string;
  company: string;
  location: string;
  startDate: string;
  endDate?: string;
  bulletPoints: string[];
}

export interface Education {
  degree: string;
  field: string;
  school: string;
  graduationDate: string;
  gpa?: number;
}

export interface Skill {
  name: string;
  category?: string;
}

export type TemplateGenerator = (resumeData: ResumeData) => Promise<Buffer>;

export function formatDate(dateString: string): string {
  if (!dateString) return "";
  try {
    const date = new Date(dateString);
    return date.toLocaleDateString("en-US", { year: "numeric", month: "short" });
  } catch {
    return dateString;
  }
}

export function createPdfBuffer(doc: any): Promise<Buffer> {
  return new Promise((resolve, reject) => {
    const chunks: Buffer[] = [];
    doc.on("data", (chunk: Buffer) => chunks.push(chunk));
    doc.on("end", () => resolve(Buffer.concat(chunks)));
    doc.on("error", reject);
  });
}
