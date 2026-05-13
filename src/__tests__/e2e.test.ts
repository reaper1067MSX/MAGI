import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
import { spawn, ChildProcess } from 'node:child_process';
import * as path from 'node:path';

describe('MAGI MCP E2E', () => {
  let serverProcess: ChildProcess;

  it('should respond to list tools request over stdio', async () => {
    const serverPath = path.resolve(process.cwd(), 'dist/index.js');
    
    serverProcess = spawn('node', [serverPath], {
      stdio: ['pipe', 'pipe', 'inherit']
    });

    const listToolsRequest = {
      jsonrpc: '2.0',
      id: 1,
      method: 'tools/list',
      params: {}
    };

    return new Promise<void>((resolve, reject) => {
      serverProcess.stdout?.on('data', (data) => {
        const response = JSON.parse(data.toString());
        expect(response.id).toBe(1);
        expect(response.result.tools).toBeDefined();
        expect(response.result.tools.some((t: any) => t.name === 'run_magi_iteration')).toBe(true);
        
        serverProcess.kill();
        resolve();
      });

      serverProcess.stdin?.write(JSON.stringify(listToolsRequest) + '\n');
      
      setTimeout(() => {
        serverProcess.kill();
        reject(new Error('E2E Timeout: Server did not respond to tools/list'));
      }, 5000);
    });
  });
});
