import { copyFile, mkdir } from 'node:fs/promises';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const www = join(root, 'www');
const files = [
  'index.html',
  'manifest.json',
  'icon.svg',
  'sw.js',
  'pwa-64x64.png',
  'pwa-192x192.png',
  'pwa-512x512.png',
  'maskable-icon-512x512.png',
  'apple-touch-icon.png',
];

await mkdir(www, { recursive: true });
for (const file of files) {
  await copyFile(join(root, file), join(www, file));
}
console.log('www/ ready for Android');
