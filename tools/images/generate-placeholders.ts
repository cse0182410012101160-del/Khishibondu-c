import fs from 'node:fs';
import path from 'node:path';
import sharp from 'sharp';

const categories = process.argv.slice(2);
if (!categories.length) {
  console.error('Usage: tsx tools/images/generate-placeholders.ts <category-slug> ...');
  process.exit(1);
}

const root = path.resolve(import.meta.dirname, '..', '..');
const placeholderDir = path.join(root, 'backend', 'assets', 'products', '_placeholders');
fs.mkdirSync(placeholderDir, { recursive: true });

async function main() {
  for (const category of categories) {
    const svg = `<svg xmlns="http://www.w3.org/2000/svg" width="800" height="800"><rect width="100%" height="100%" fill="#e8f1e8"/><circle cx="400" cy="340" r="120" fill="#2e7d32" opacity=".18"/><path d="M400 520c-80-130-20-230 0-270 20 40 80 140 0 270z" fill="#2e7d32"/><text x="400" y="650" text-anchor="middle" font-family="sans-serif" font-size="42" fill="#1b5e20">${category}</text></svg>`;
    await sharp(Buffer.from(svg)).webp({ quality: 82 }).toFile(path.join(placeholderDir, `${category}.webp`));
  }
}

main().catch(error => { console.error(error); process.exitCode = 1; });
