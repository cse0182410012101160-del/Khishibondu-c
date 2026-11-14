const fs = require('fs');
const path = require('path');

const productsRoot = path.join(__dirname, '../../assets/products');

function productImageUrl({ categorySlug, productSlug }) {
  const relative = `${categorySlug}/${productSlug}.webp`;
  const productPath = path.join(productsRoot, relative);
  const categoryPlaceholder = `_placeholders/${categorySlug}.webp`;
  const served = fs.existsSync(productPath)
    ? relative
    : fs.existsSync(path.join(productsRoot, categoryPlaceholder))
      ? categoryPlaceholder
      : '_placeholders/_default.webp';
  return `/static/products/${served.replaceAll(path.sep, '/')}`;
}

module.exports = { productImageUrl };