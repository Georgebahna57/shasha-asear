import { existsSync } from 'node:fs';
import { spawnSync } from 'node:child_process';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const sdk = process.env.ANDROID_HOME || join(process.env.LOCALAPPDATA || '', 'Android', 'Sdk');
process.env.ANDROID_HOME = sdk;
process.env.ANDROID_SDK_ROOT = sdk;

const jdks = [
  process.env.JAVA_HOME,
  'C:\\Program Files\\Microsoft\\jdk-25.0.2.10-hotspot',
  'C:\\Program Files\\Eclipse Adoptium\\jdk-21',
  'C:\\Program Files\\Java\\jdk-21',
].filter(Boolean);

const jdk = jdks.find((dir) => existsSync(join(dir, 'bin', 'java.exe')));
if (jdk) process.env.JAVA_HOME = jdk;

const result = spawnSync(
  join(root, 'android', 'gradlew.bat'),
  ['assembleDebug'],
  { cwd: join(root, 'android'), stdio: 'inherit', env: process.env, shell: false },
);

if (result.status !== 0) {
  process.exit(result.status ?? 1);
}
