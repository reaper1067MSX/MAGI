import { describe, it, expect } from 'vitest';
import { execSync } from 'node:child_process';
import * as path from 'node:path';
import { readFileSync } from 'node:fs';

describe('MAGI CLI', () => {
  const binPath = path.resolve(process.cwd(), 'bin/magi-mcp.js');
  const pkg = JSON.parse(readFileSync(path.resolve(process.cwd(), 'package.json'), 'utf8'));

  it('should display version correctly', () => {
    const output = execSync(`node ${binPath} --version`).toString().trim();
    expect(output).toBe(pkg.version);
  });

  it('should display help message', () => {
    const output = execSync(`node ${binPath} --help`).toString();
    expect(output).toContain('Usage: magi');
    expect(output).toContain('Autonomous task orchestrator');
  });

  it('should respond to setup command (dry run/help)', () => {
    const output = execSync(`node ${binPath} setup --help`).toString();
    expect(output).toContain('Auto-register MAGI');
  });
});
