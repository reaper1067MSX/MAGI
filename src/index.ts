import { Command } from 'commander';
import chalk from 'chalk';
import { startMcpServer } from './mcp/server.js';
import { runSetup } from './cli/setup.js';
import { runInteractive } from './cli/run.js';

const program = new Command();

program
  .name('magi')
  .description('MAGI (formerly Ralph) - Task-based AI orchestrator and MCP server')
  .version('1.0.0');

// Default command: Start MCP Server
program
  .command('serve', { isDefault: true })
  .description('Start the MAGI MCP server (default)')
  .action(async () => {
    try {
      await startMcpServer();
    } catch (error) {
      console.error(chalk.red('Fatal error starting MCP server:'), error);
      process.exit(1);
    }
  });

program
  .command('setup')
  .description('Auto-register MAGI in popular AI clients (Gemini CLI, Claude Desktop)')
  .action(async () => {
    await runSetup();
  });

program
  .command('run <task>')
  .description('Execute a MAGI task iteration interactively')
  .action(async (task) => {
    await runInteractive(task);
  });

program.parse(process.argv);
