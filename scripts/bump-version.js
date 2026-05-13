import fs from 'node:fs';
import path from 'node:path';

const packageJsonPath = path.resolve(process.cwd(), 'package.json');
const srcIndexPath = path.resolve(process.cwd(), 'src/index.ts');

const pkg = JSON.parse(fs.readFileSync(packageJsonPath, 'utf8'));
const currentVersion = pkg.version;

// Logic: 1.1.x -> 1.1.x+1. If x+1 == 10 -> 1.2.0
const parts = currentVersion.split('.').map(Number);
let [major, minor, patch] = parts;

patch++;
if (patch >= 10) {
  patch = 0;
  minor++;
}

const newVersion = `${major}.${minor}.${patch}`;

console.log(`Bumping version: ${currentVersion} -> ${newVersion}`);

// Update package.json
pkg.version = newVersion;
fs.writeFileSync(packageJsonPath, JSON.stringify(pkg, null, 2) + '\n');

// Sync src/index.ts
let indexContent = fs.readFileSync(srcIndexPath, 'utf8');
indexContent = indexContent.replace(/\.version\('[^']+'\)/, `.version('${newVersion}')`);
fs.writeFileSync(srcIndexPath, indexContent);

console.log('✅ Version bumped and synced successfully.');
