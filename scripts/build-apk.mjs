import { copyFileSync, existsSync } from 'node:fs';
import { spawnSync } from 'node:child_process';
import { platform } from 'node:os';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const win = platform() === 'win32';
const sdk = process.env.ANDROID_HOME || process.env.ANDROID_SDK_ROOT ||
  join(process.env.LOCALAPPDATA || '', 'Android', 'Sdk');
process.env.ANDROID_HOME = sdk;
process.env.ANDROID_SDK_ROOT = sdk;

const jdks = [
  process.env.JAVA_HOME,
  'C:\\Program Files\\Microsoft\\jdk-25.0.2.10-hotspot',
  'C:\\Program Files\\Eclipse Adoptium\\jdk-21',
  'C:\\Program Files\\Java\\jdk-21',
].filter(Boolean);

const jdk = jdks.find((dir) => existsSync(join(dir, 'bin', win ? 'java.exe' : 'java')));
if (jdk) process.env.JAVA_HOME = jdk;

const result = spawnSync(
  join(root, 'android', win ? 'gradlew.bat' : 'gradlew'),
  ['assembleDebug'],
  { cwd: join(root, 'android'), stdio: 'inherit', env: process.env, shell: win },
);

if (result.status !== 0) {
  process.exit(result.status ?? 1);
}

const built = join(root, 'android', 'app', 'build', 'outputs', 'apk', 'debug', 'app-debug.apk');
copyFileSync(built, join(root, 'ShashaAsear-debug.apk'));
console.log('Wrote ShashaAsear-debug.apk');
