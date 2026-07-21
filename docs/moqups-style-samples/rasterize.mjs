import fs from 'node:fs';
import path from 'node:path';
import sharp from 'sharp';

const dir = path.dirname(new URL(import.meta.url).pathname).replace(/^\/(.:)/, '$1');
const files = fs.readdirSync(dir).filter((file) => file.endsWith('.svg'));

for (const file of files) {
  await sharp(path.join(dir, file), { density: 96 })
    .resize(1024, 1024)
    .png()
    .toFile(path.join(dir, file.replace(/\.svg$/, '.png')));
}

console.log(`Rasterized ${files.length} drafts.`);
