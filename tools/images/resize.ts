import fs from 'node:fs';
import path from 'node:path';
import sharp from 'sharp';

const inputDir = process.argv[2];
const category = process.argv[3];
if (!inputDir || !category) {
  console.error('Usage: npm run images:resize -- <input-folder> <category-slug>');
  process.exit(1);
}

const root = path.resolve(import.meta.dirname, '..', '..');
const outputDir = path.join(root, 'backend', 'assets', 'products', category);
const thumbDir = path.join(outputDir, 'thumbs');
fs.mkdirSync(outputDir, { recursive: true });
fs.mkdirSync(thumbDir, { recursive: true });

function slugify(value: string) {
  return value.toLowerCase().replace(/\.[^.]+$/, '').trim().replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, '');
}

async function main() {
  const files = fs.readdirSync(path.resolve(inputDir)).filter(file => /\.(jpe?g|png)$/i.test(file));
  await Promise.all(files.map(async file => {
    const slug = slugify(file);
    const source = path.join(path.resolve(inputDir), file);
    await sharp(source).resize(800, 800, { fit: 'cover' }).webp({ quality: 82 }).toFile(path.join(outputDir, `${slug}.webp`));
    await sharp(source).resize(240, 240, { fit: 'cover' }).webp({ quality: 78 }).toFile(path.join(thumbDir, `${slug}.webp`));
    console.log(`Created ${category}/${slug}.webp and thumbs/${slug}.webp`);
  }));
}

main().catch(error => { console.error(error); process.exitCode = 1; });
