import { Server } from '@modelcontextprotocol/sdk/server/index.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import {
  CallToolRequestSchema,
  ListToolsRequestSchema,
} from '@modelcontextprotocol/sdk/types.js';
import { MagiEngine } from '../engine/MagiEngine.js';
import { loadConfig } from '../config/index.js';
import { GeminiAgent } from '../agents/GeminiAgent.js';
import { ClaudeAgent } from '../agents/ClaudeAgent.js';
import { OpenAIAgent, OllamaAgent } from '../agents/OpenAIAgent.js';
import type { AgentAdapter } from '../types/index.js';
import chalk from 'chalk';

export async function startMcpServer() {
  const config = await loadConfig('magi-config.json');
  const engine = new MagiEngine(config);
  
  const server = new Server(
    {
      name: 'magi-mcp-server',
      version: '1.0.0',
    },
    {
      capabilities: {
        tools: {},
      },
    }
  );

  const agents: Record<string, AgentAdapter> = {
    'gemini-cli': new GeminiAgent(),
    'claude': new ClaudeAgent(),
    'openai': new OpenAIAgent(),
    'ollama': new OllamaAgent(),
  };

  server.setRequestHandler(ListToolsRequestSchema, async () => ({
    tools: [
      {
        name: 'run_magi_iteration',
        description: 'Execute one MAGI iteration for a task using `agentName` when provided, otherwise the configured default agent.',
        inputSchema: {
          type: 'object',
          properties: {
            taskName: { type: 'string', description: 'Name of the task to run' },
            agentName: { type: 'string', description: 'Optional agent adapter name (gemini-cli, claude, openai, ollama)' },
          },
          required: ['taskName'],
        },
      },
      {
        name: 'get_magi_status',
        description: 'Retrieve MAGI runtime status, default agent, available agent adapters, and resolved state directory.',
        inputSchema: { type: 'object', properties: {} },
      },
    ],
  }));

  server.setRequestHandler(CallToolRequestSchema, async (request) => {
    switch (request.params.name) {
      case 'run_magi_iteration': {
        const taskName = request.params.arguments?.taskName as string;
        const agentName = (request.params.arguments?.agentName as string) || config.defaultAgent;
        const agent = agents[agentName] || agents[config.defaultAgent];

        const result = await engine.runIteration(agent, taskName);
        return {
          content: [
            {
              type: 'text',
              text: JSON.stringify(result, null, 2),
            },
          ],
        };
      }
      case 'get_magi_status': {
        const status = {
          status: 'active',
          defaultAgent: config.defaultAgent,
          availableAgents: Object.keys(agents),
          stateDirectory: engine.getStateDir(),
        };
        return {
          content: [
            {
              type: 'text',
              text: JSON.stringify(status, null, 2),
            },
          ],
        };
      }
      default:
        throw new Error('Tool not found');
    }
  });

  const transport = new StdioServerTransport();
  await server.connect(transport);
  
  // Use console.error for logging so it doesn't interfere with stdio JSON-RPC
  console.error(chalk.green('✓'), chalk.bold('MAGI MCP Server running on stdio'));
}
