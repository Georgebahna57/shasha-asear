import { mkdir, readFile, writeFile } from 'node:fs/promises';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import sharp from 'sharp';

const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const svg = await readFile(join(root, 'icon.svg'));

async function png(size, file, padding = 0) {
  const inner = Math.round(size * (1 - padding * 2));
  const icon = await sharp(svg).resize(inner, inner).png().toBuffer();
  await sharp({
    create: {
      width: size,
      height: size,
      channels: 4,
      background: '#070b16',
    },
  })
    .composite([{ input: icon, gravity: 'centre' }])
    .png({ compressionLevel: 9 })
    .toFile(join(root, file));
}

await mkdir(root, { recursive: true });
await png(64, 'pwa-64x64.png');
await png(192, 'pwa-192x192.png');
await png(180, 'apple-touch-icon.png');
await png(512, 'pwa-512x512.png');
await png(512, 'maskable-icon-512x512.png', 0.12);

const mipmap = [
  ['mdpi', 48, 108],
  ['hdpi', 72, 162],
  ['xhdpi', 96, 216],
  ['xxhdpi', 144, 324],
  ['xxxhdpi', 192, 432],
];

for (const [density, launcher, foreground] of mipmap) {
  const dir = join(root, 'android', 'app', 'src', 'main', 'res', `mipmap-${density}`);
  try {
    await mkdir(dir, { recursive: true });
    await png(launcher, join('android', 'app', 'src', 'main', 'res', `mipmap-${density}`, 'ic_launcher.png'));
    await png(launcher, join('android', 'app', 'src', 'main', 'res', `mipmap-${density}`, 'ic_launcher_round.png'));
    await png(foreground, join('android', 'app', 'src', 'main', 'res', `mipmap-${density}`, 'ic_launcher_foreground.png'), 0.12);
  } catch {
    // Android folder is created after `npx cap add android`
  }
}

console.log('Android / PWA icons generated');
