import fs from 'node:fs';
import path from 'node:path';
import sharp from 'sharp';

type ProductRef = { slug: string; category: string };
type ManifestRow = ProductRef & { file: string; source: string; license: string; credit: string; status: string };

const root = path.resolve(import.meta.dirname, '..', '..');
const seedRoot = path.join(root, 'backend', 'prisma', 'seed', 'catalog');
const assetRoot = path.join(root, 'backend', 'assets', 'products');
const manifestPath = path.join(root, 'tools', 'images', 'manifest.csv');

function slugify(value: string) {
  return value.toLowerCase().trim().replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, '');
}

function csvRows(content: string): string[][] {
  return content.trim().split(/\r?\n/).map(line => line.split(',').map(value => value.trim()));
}

function readManifest(): ManifestRow[] {
  if (!fs.existsSync(manifestPath)) return [];
  const rows = csvRows(fs.readFileSync(manifestPath, 'utf8'));
  const header = rows.shift() || [];
  const index = (name: string) => header.indexOf(name);
  return rows.filter(row => row.length > 1).map(row => ({
    slug: row[index('slug')] || '',
    category: row[index('category')] || '',
    file: row[index('file')] || '',
    source: row[index('source')] || '',
    license: row[index('license')] || '',
    credit: row[index('credit')] || '',
    status: row[index('status')] || '',
  }));
}

function filesUnder(directory: string): string[] {
  if (!fs.existsSync(directory)) return [];
  return fs.readdirSync(directory, { withFileTypes: true }).flatMap(entry => {
    const fullPath = path.join(directory, entry.name);
    return entry.isDirectory() ? filesUnder(fullPath) : [fullPath];
  });
}

function readSeedProducts(): ProductRef[] {
  if (!fs.existsSync(seedRoot)) return [];
  const products: ProductRef[] = [];
  for (const file of filesUnder(seedRoot).filter(item => item.endsWith('.ts'))) {
    const source = fs.readFileSync(file, 'utf8');
    const category = source.match(/category\s*:\s*\{[\s\S]*?slug\s*:\s*['"]([^'"]+)['"]/m)?.[1];
    const productBlock = source.match(/products\s*:\s*\[([\s\S]*?)\]\s*[,}]/m)?.[1] || '';
    for (const objectText of productBlock.split(/\},\s*\{/)) {
      const explicitSlug = objectText.match(/slugOverride\s*:\s*['"]([^'"]+)['"]/)?.[1];
      const name = objectText.match(/nameEn\s*:\s*['"]([^'"]+)['"]/)?.[1];
      if (category && (explicitSlug || name)) products.push({ slug: explicitSlug || slugify(name!), category });
    }
  }
  return products;
}

async function main() {
  const manifest = readManifest();
  const seeded = readSeedProducts();
  const expected = [...seeded, ...manifest.map(({ slug, category }) => ({ slug, category }))]
    .filter((item, index, list) => list.findIndex(other => other.slug === item.slug && other.category === item.category) === index);
  const missingProducts = expected.filter(product => !fs.existsSync(path.join(assetRoot, product.category, `${product.slug}.webp`)));
  const productKeys = new Set(expected.map(product => `${product.category}/${product.slug}`));
  const imageFiles = filesUnder(assetRoot).filter(file => file.endsWith('.webp') && !file.includes(`${path.sep}_placeholders${path.sep}`));
  const filesWithoutProduct = imageFiles.filter(file => {
    const relative = path.relative(assetRoot, file).replaceAll(path.sep, '/');
    const key = relative.replace(/^thumbs\//, '').replace(/\.webp$/, '');
    return !productKeys.has(key);
  });
  const invalidDimensions: string[] = [];
  const oversized: string[] = [];
  for (const file of imageFiles) {
    const metadata = await sharp(file).metadata();
    const isThumb = path.relative(assetRoot, file).replaceAll(path.sep, '/').startsWith('thumbs/');
    const expectedSize = isThumb ? 240 : 800;
    if (metadata.width !== expectedSize || metadata.height !== expectedSize) invalidDimensions.push(`${path.relative(root, file)} (${metadata.width}x${metadata.height})`);
    if (fs.statSync(file).size > 120 * 1024) oversized.push(path.relative(root, file));
  }
  const doneMissing = manifest.filter(row => row.status === 'DONE' && !fs.existsSync(path.join(root, 'backend', row.file)));
  console.log(`Seed products: ${seeded.length}`);
  console.log(`Manifest rows: ${manifest.length}`);
  console.log('Products with no primary file:', missingProducts.length ? missingProducts : 'none');
  console.log('Files with no product:', filesWithoutProduct.length ? filesWithoutProduct.map(file => path.relative(root, file)) : 'none');
  console.log('Wrong dimensions:', invalidDimensions.length ? invalidDimensions : 'none');
  console.log('Files over 120 KB:', oversized.length ? oversized : 'none');
  if (doneMissing.length) {
    console.error('DONE manifest rows with missing files:', doneMissing);
    process.exitCode = 1;
  }
}

main().catch(error => { console.error(error); process.exitCode = 1; });
