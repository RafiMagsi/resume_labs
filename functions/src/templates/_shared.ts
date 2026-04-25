import https from "https";
import http from "http";
import PDFDocument from "pdfkit";
import { formatDate, ResumeData } from "../types";

export const DEFAULT_PAGE_MARGIN = 36; // within 32–40pt safe margin rule

export type PhotoShape = "circle" | "square";

export interface Frame {
  x: number;
  width: number;
}

export function getContentFrame(doc: PDFKit.PDFDocument): Frame {
  const x = doc.page.margins.left;
  const width = doc.page.width - doc.page.margins.left - doc.page.margins.right;
  return { x, width };
}

export function getBottomLimit(doc: PDFKit.PDFDocument): number {
  return doc.page.height - doc.page.margins.bottom;
}

export function ensureSpace(doc: PDFKit.PDFDocument, neededHeight: number): void {
  const bottomLimit = getBottomLimit(doc);
  if (doc.y + neededHeight > bottomLimit) {
    doc.addPage();
  }
}

export async function downloadImage(url?: string): Promise<Buffer | null> {
  return new Promise((resolve) => {
    if (!url) {
      resolve(null);
      return;
    }

    try {
      const protocol = url.startsWith("https") ? https : http;
      const timeout = setTimeout(() => resolve(null), 8000);

      protocol
        .get(url, { timeout: 8000 }, (response) => {
          clearTimeout(timeout);
          if (response.statusCode !== 200) {
            resolve(null);
            return;
          }

          const chunks: Buffer[] = [];
          response.on("data", (chunk) => chunks.push(chunk));
          response.on("end", () => resolve(Buffer.concat(chunks)));
          response.on("error", () => resolve(null));
        })
        .on("error", () => resolve(null));
    } catch {
      resolve(null);
    }
  });
}

export function drawDivider(
  doc: PDFKit.PDFDocument,
  x: number,
  y: number,
  width: number,
  color: string,
  thickness = 1,
): void {
  doc
    .strokeColor(color)
    .lineWidth(thickness)
    .moveTo(x, y)
    .lineTo(x + width, y)
    .stroke();
}

export function drawPhotoPlaceholder(
  doc: PDFKit.PDFDocument,
  x: number,
  y: number,
  size: number,
  shape: PhotoShape,
  backgroundColor: string,
  borderColor: string,
  textColor: string,
): void {
  doc.save();
  if (shape === "circle") {
    const radius = size / 2;
    doc.circle(x + radius, y + radius, radius).fillAndStroke(backgroundColor, borderColor);
  } else {
    doc.roundedRect(x, y, size, size, 8).fillAndStroke(backgroundColor, borderColor);
  }
  doc.restore();

  doc
    .font("Helvetica")
    .fontSize(9)
    .fillColor(textColor)
    .text("Photo", x, y + size / 2 - 5, { width: size, align: "center" });
}

export function renderPhoto(
  doc: PDFKit.PDFDocument,
  imageBuffer: Buffer | null,
  x: number,
  y: number,
  size: number,
  shape: PhotoShape,
  borderColor: string,
  placeholderBackground: string,
  placeholderText: string,
): void {
  if (!imageBuffer) {
    drawPhotoPlaceholder(
      doc,
      x,
      y,
      size,
      shape,
      placeholderBackground,
      borderColor,
      placeholderText,
    );
    return;
  }

  try {
    doc.save();
    if (shape === "circle") {
      const radius = size / 2;
      doc.circle(x + radius, y + radius, radius);
    } else {
      doc.roundedRect(x, y, size, size, 8);
    }
    doc.clip();
    doc.image(imageBuffer, x, y, { width: size, height: size });
    doc.restore();

    if (shape === "circle") {
      const radius = size / 2;
      doc.circle(x + radius, y + radius, radius).lineWidth(1).stroke(borderColor);
    } else {
      doc.roundedRect(x, y, size, size, 8).lineWidth(1).stroke(borderColor);
    }
  } catch {
    drawPhotoPlaceholder(
      doc,
      x,
      y,
      size,
      shape,
      placeholderBackground,
      borderColor,
      placeholderText,
    );
  }
}

export interface HeaderStyle {
  accentColor: string;
  nameColor?: string;
  subtitle: string;
  subtitleColor: string;
  dividerColor: string;
  topAccentBar?: boolean;
  topAccentBarHeight?: number;
  headerBottomGap?: number;
  contentGapAfterDivider?: number;
  nameFontSize?: number;
  subtitleFontSize?: number;
  photo?: {
    enabled: boolean;
    size: number;
    gap: number;
    shape: PhotoShape;
  };
}

export function renderSingleColumnHeader(
  doc: PDFKit.PDFDocument,
  resumeData: ResumeData,
  imageBuffer: Buffer | null,
  style: HeaderStyle,
): void {
  const frame = getContentFrame(doc);
  const headerStartY = doc.y;
  const headerBottomGap = style.headerBottomGap ?? 18;
  const contentGapAfterDivider = style.contentGapAfterDivider ?? 16;

  const photoEnabled = Boolean(style.photo?.enabled && resumeData.photoUrl);
  const photoSize = style.photo?.size ?? 68;
  const photoGap = style.photo?.gap ?? 16;
  const photoShape = style.photo?.shape ?? "circle";

  const textColumnWidth = photoEnabled ? frame.width - photoSize - photoGap : frame.width;

  if (style.topAccentBar) {
    const barHeight = style.topAccentBarHeight ?? 4;
    const barWidth = photoEnabled ? Math.max(0, textColumnWidth) : frame.width;
    doc.rect(frame.x, headerStartY, barWidth, barHeight).fill(style.accentColor);
  }

  const titleY = headerStartY + (style.topAccentBar ? 14 : 0);

  if (photoEnabled) {
    const photoX = frame.x + frame.width - photoSize;
    const photoY = headerStartY;
    renderPhoto(
      doc,
      imageBuffer,
      photoX,
      photoY,
      photoSize,
      photoShape,
      style.dividerColor,
      "#F8FAFC",
      style.subtitleColor,
    );
  }

  const nameSize = style.nameFontSize ?? 25;
  const subtitleSize = style.subtitleFontSize ?? 10.5;
  doc
    .font("Helvetica-Bold")
    .fontSize(nameSize)
    .fillColor(style.nameColor ?? style.accentColor)
    .text(resumeData.title?.trim() || "Untitled Resume", frame.x, titleY, {
      width: textColumnWidth,
      align: "left",
    });

  const nameBottom = doc.y;
  doc
    .font("Helvetica")
    .fontSize(subtitleSize)
    .fillColor(style.subtitleColor)
    .text(style.subtitle, frame.x, nameBottom + 4, { width: textColumnWidth, align: "left" });

  const headerBottom = Math.max(
    doc.y,
    photoEnabled ? headerStartY + photoSize : titleY,
  );
  const dividerY = headerBottom + headerBottomGap;
  drawDivider(doc, frame.x, dividerY, frame.width, style.dividerColor, 1);
  doc.y = dividerY + contentGapAfterDivider;
}

export interface SectionHeadingStyle {
  titleColor: string;
  dividerColor: string;
  fontSize?: number;
  uppercase?: boolean;
  characterSpacing?: number;
  gapAfterDivider?: number;
}

export function renderSectionHeading(
  doc: PDFKit.PDFDocument,
  title: string,
  style: SectionHeadingStyle,
  frame?: Frame,
): void {
  const usedFrame = frame ?? getContentFrame(doc);
  ensureSpace(doc, 34);

  const text = style.uppercase === false ? title : title.toUpperCase();
  doc
    .font("Helvetica-Bold")
    .fontSize(style.fontSize ?? 11)
    .fillColor(style.titleColor)
    .text(text, usedFrame.x, doc.y, {
      width: usedFrame.width,
      characterSpacing: style.characterSpacing ?? 1.1,
    });

  doc.moveDown(0.18);
  const dividerY = doc.y;
  drawDivider(doc, usedFrame.x, dividerY, usedFrame.width, style.dividerColor, 1);
  doc.y = dividerY + (style.gapAfterDivider ?? 12);
}

export interface BodyTextStyle {
  color: string;
  fontSize?: number;
  lineGap?: number;
}

export function writeBodyText(
  doc: PDFKit.PDFDocument,
  text: string,
  style: BodyTextStyle,
  frame?: Frame,
): void {
  const usedFrame = frame ?? getContentFrame(doc);
  doc
    .font("Helvetica")
    .fontSize(style.fontSize ?? 10.6)
    .fillColor(style.color)
    .text(text, usedFrame.x, doc.y, {
      width: usedFrame.width,
      lineGap: style.lineGap ?? 4,
    });
}

export interface BulletStyle {
  marker: string;
  markerColor: string;
  textColor: string;
  fontSize?: number;
  lineGap?: number;
  indent?: number;
}

export function writeBullets(
  doc: PDFKit.PDFDocument,
  items: string[],
  style: BulletStyle,
  frame?: Frame,
): void {
  const usedFrame = frame ?? getContentFrame(doc);
  const indent = style.indent ?? 12;

  items.forEach((raw) => {
    const text = raw?.trim();
    if (!text) return;
    ensureSpace(doc, 18);

    const bulletY = doc.y;
    doc
      .font("Helvetica")
      .fontSize(style.fontSize ?? 10.2)
      .fillColor(style.markerColor)
      .text(style.marker, usedFrame.x, bulletY, { width: 8 });

    doc
      .font("Helvetica")
      .fontSize(style.fontSize ?? 10.2)
      .fillColor(style.textColor)
      .text(text, usedFrame.x + indent, bulletY, {
        width: usedFrame.width - indent,
        lineGap: style.lineGap ?? 3,
      });
  });
}

export interface TwoColumnListStyle {
  color: string;
  fontSize?: number;
  lineGap?: number;
  columnGap?: number;
  bulletMarker?: string;
  bulletMarkerColor?: string;
}

export function writeTwoColumnList(
  doc: PDFKit.PDFDocument,
  items: string[],
  style: TwoColumnListStyle,
  frame?: Frame,
): void {
  const usedFrame = frame ?? getContentFrame(doc);
  const columnGap = style.columnGap ?? 16;
  const columnWidth = (usedFrame.width - columnGap) / 2;

  const rows = Math.ceil(items.length / 2);
  const fontSize = style.fontSize ?? 10.2;
  const lineGap = style.lineGap ?? 3;
  const marker = style.bulletMarker ?? "";

  for (let row = 0; row < rows; row++) {
    const left = items[row * 2]?.trim();
    const right = items[row * 2 + 1]?.trim();
    if (!left && !right) continue;

    ensureSpace(doc, 18);
    const startY = doc.y;

    let leftHeight = 0;
    let rightHeight = 0;

    if (left) {
      doc.font("Helvetica").fontSize(fontSize);
      leftHeight = doc.heightOfString(marker ? `${marker} ${left}` : left, {
        width: columnWidth,
        lineGap,
      });
    }

    if (right) {
      doc.font("Helvetica").fontSize(fontSize);
      rightHeight = doc.heightOfString(marker ? `${marker} ${right}` : right, {
        width: columnWidth,
        lineGap,
      });
    }

    const rowHeight = Math.max(leftHeight, rightHeight);
    if (left) {
      const x = usedFrame.x;
      doc
        .font("Helvetica")
        .fontSize(fontSize)
        .fillColor(style.color)
        .text(marker ? `${marker} ${left}` : left, x, startY, {
          width: columnWidth,
          lineGap,
        });
    }

    if (right) {
      const rightX = usedFrame.x + columnWidth + columnGap;
      doc
        .font("Helvetica")
        .fontSize(fontSize)
        .fillColor(style.color)
        .text(marker ? `${marker} ${right}` : right, rightX, startY, {
          width: columnWidth,
          lineGap,
        });
    }

    doc.y = startY + rowHeight + 2;
  }
}

export interface ExperienceStyle {
  roleColor: string;
  companyColor: string;
  dateColor: string;
  bodyColor: string;
  bullet: BulletStyle;
}

export function writeWorkExperienceBlock(
  doc: PDFKit.PDFDocument,
  exp: ResumeData["workExperiences"][number],
  style: ExperienceStyle,
  frame?: Frame,
): void {
  const usedFrame = frame ?? getContentFrame(doc);
  ensureSpace(doc, 54);

  doc
    .font("Helvetica-Bold")
    .fontSize(12.2)
    .fillColor(style.roleColor)
    .text(exp.role?.trim() || "Untitled Role", usedFrame.x, doc.y, {
      width: usedFrame.width,
    });

  const companyLocation = [exp.company?.trim(), exp.location?.trim()]
    .filter(Boolean)
    .join(" - ");
  if (companyLocation) {
    doc.moveDown(0.12);
    doc
      .font("Helvetica")
      .fontSize(10.3)
      .fillColor(style.companyColor)
      .text(companyLocation, usedFrame.x, doc.y, { width: usedFrame.width });
  }

  const start = formatDate(exp.startDate);
  const end = exp.endDate ? formatDate(exp.endDate) : "Present";
  const range = [start, end].filter(Boolean).join(" - ");
  if (range) {
    doc.moveDown(0.1);
    doc
      .font("Helvetica")
      .fontSize(9.8)
      .fillColor(style.dateColor)
      .text(range, usedFrame.x, doc.y, { width: usedFrame.width });
  }

  if (exp.bulletPoints?.length) {
    doc.moveDown(0.3);
    writeBullets(doc, exp.bulletPoints, style.bullet, usedFrame);
  }
}

export interface ExperienceDateRightStyle {
  roleColor: string;
  companyColor: string;
  dateColor: string;
  bodyColor: string;
  bullet: BulletStyle;
  dateWidth?: number;
  gap?: number;
}

export function writeWorkExperienceBlockDateRight(
  doc: PDFKit.PDFDocument,
  exp: ResumeData["workExperiences"][number],
  style: ExperienceDateRightStyle,
  frame?: Frame,
): void {
  const usedFrame = frame ?? getContentFrame(doc);
  const dateWidth = style.dateWidth ?? 120;
  const gap = style.gap ?? 12;
  const leftWidth = usedFrame.width - dateWidth - gap;
  ensureSpace(doc, 56);

  const startY = doc.y;
  const start = formatDate(exp.startDate);
  const end = exp.endDate ? formatDate(exp.endDate) : "Present";
  const range = [start, end].filter(Boolean).join(" - ");

  doc
    .font("Helvetica-Bold")
    .fontSize(12.2)
    .fillColor(style.roleColor)
    .text(exp.role?.trim() || "Untitled Role", usedFrame.x, startY, {
      width: leftWidth,
    });

  doc
    .font("Helvetica")
    .fontSize(9.6)
    .fillColor(style.dateColor)
    .text(range, usedFrame.x + leftWidth + gap, startY + 2, {
      width: dateWidth,
      align: "right",
    });

  let currentY = Math.max(doc.y, startY + 14) + 2;
  const companyLocation = [exp.company?.trim(), exp.location?.trim()]
    .filter(Boolean)
    .join(" - ");
  if (companyLocation) {
    doc
      .font("Helvetica")
      .fontSize(10.3)
      .fillColor(style.companyColor)
      .text(companyLocation, usedFrame.x, currentY, { width: usedFrame.width });
    currentY = doc.y + 3;
  }

  if (exp.bulletPoints?.length) {
    doc.y = currentY;
    writeBullets(doc, exp.bulletPoints, style.bullet, usedFrame);
  } else {
    doc.y = currentY;
  }
}

export interface EducationStyle {
  degreeColor: string;
  schoolColor: string;
  metaColor: string;
}

export function writeEducationBlock(
  doc: PDFKit.PDFDocument,
  edu: ResumeData["educations"][number],
  style: EducationStyle,
  frame?: Frame,
): void {
  const usedFrame = frame ?? getContentFrame(doc);
  ensureSpace(doc, 44);

  const degreeLine =
    [edu.degree?.trim(), edu.field?.trim()].filter(Boolean).join(" in ") || "Education";

  doc
    .font("Helvetica-Bold")
    .fontSize(11.8)
    .fillColor(style.degreeColor)
    .text(degreeLine, usedFrame.x, doc.y, { width: usedFrame.width });

  const schoolLine = edu.school?.trim();
  if (schoolLine) {
    doc.moveDown(0.12);
    doc
      .font("Helvetica")
      .fontSize(10.3)
      .fillColor(style.schoolColor)
      .text(schoolLine, usedFrame.x, doc.y, { width: usedFrame.width });
  }

  const grad = edu.graduationDate ? formatDate(edu.graduationDate) : "";
  const meta = [
    grad ? `Graduation: ${grad}` : null,
    edu.gpa ? `GPA: ${edu.gpa}` : null,
  ]
    .filter(Boolean)
    .join(" - ");

  if (meta) {
    doc.moveDown(0.1);
    doc
      .font("Helvetica")
      .fontSize(9.8)
      .fillColor(style.metaColor)
      .text(meta, usedFrame.x, doc.y, { width: usedFrame.width });
  }
}

export interface EducationDateRightStyle {
  degreeColor: string;
  schoolColor: string;
  metaColor: string;
  dateColor?: string;
  dateWidth?: number;
  gap?: number;
}

export function writeEducationBlockDateRight(
  doc: PDFKit.PDFDocument,
  edu: ResumeData["educations"][number],
  style: EducationDateRightStyle,
  frame?: Frame,
): void {
  const usedFrame = frame ?? getContentFrame(doc);
  const dateWidth = style.dateWidth ?? 120;
  const gap = style.gap ?? 12;
  const leftWidth = usedFrame.width - dateWidth - gap;
  ensureSpace(doc, 44);

  const degreeLine =
    [edu.degree?.trim(), edu.field?.trim()].filter(Boolean).join(" in ") || "Education";
  const grad = edu.graduationDate ? formatDate(edu.graduationDate) : "";

  const startY = doc.y;
  doc
    .font("Helvetica-Bold")
    .fontSize(11.8)
    .fillColor(style.degreeColor)
    .text(degreeLine, usedFrame.x, startY, { width: leftWidth });

  if (grad) {
    doc
      .font("Helvetica")
      .fontSize(9.6)
      .fillColor(style.dateColor ?? style.metaColor)
      .text(grad, usedFrame.x + leftWidth + gap, startY + 2, {
        width: dateWidth,
        align: "right",
      });
  }

  let currentY = Math.max(doc.y, startY + 14) + 2;
  const schoolLine = edu.school?.trim();
  if (schoolLine) {
    doc
      .font("Helvetica")
      .fontSize(10.3)
      .fillColor(style.schoolColor)
      .text(schoolLine, usedFrame.x, currentY, { width: usedFrame.width });
    currentY = doc.y + 2;
  }

  const meta = [edu.gpa ? `GPA: ${edu.gpa}` : null].filter(Boolean).join(" - ");
  if (meta) {
    doc
      .font("Helvetica")
      .fontSize(9.8)
      .fillColor(style.metaColor)
      .text(meta, usedFrame.x, currentY, { width: usedFrame.width });
    currentY = doc.y;
  }

  doc.y = currentY;
}

export function normalizeListItem(item: unknown): string | null {
  if (!item) return null;
  if (typeof item === "string") return item.trim() || null;
  if (typeof item === "number") return String(item);
  if (typeof item === "object") {
    const maybe = item as any;
    const text =
      maybe.name ??
      maybe.title ??
      maybe.label ??
      maybe.text ??
      maybe.description ??
      maybe.value;
    if (typeof text === "string") return text.trim() || null;
    return JSON.stringify(item);
  }
  return String(item);
}

export function readStringList(value: unknown): string[] {
  if (!Array.isArray(value)) return [];
  return value.map(normalizeListItem).filter((v): v is string => Boolean(v));
}

export function readExtraLists(resumeData: ResumeData): Record<string, string[]> {
  const extra = resumeData as any;
  return {
    projects: readStringList(extra.projects),
    achievements: readStringList(extra.achievements ?? extra.awards),
    publications: readStringList(extra.publications),
    interests: readStringList(extra.interests),
    languages: readStringList(extra.languages),
    references: readStringList(extra.references ?? extra.reference),
  };
}
