import { Server } from '@modelcontextprotocol/sdk/server/index.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import {
  CallToolRequestSchema,
  ListToolsRequestSchema,
} from '@modelcontextprotocol/sdk/types.js';
import { RalphEngine } from '../engine/RalphEngine.js';
import { loadConfig } from '../config/index.js';
import { GeminiAgent } from '../agents/GeminiAgent.js';
import { OpenAIAgent, OllamaAgent } from '../agents/OpenAIAgent.js';
import type { AgentAdapter } from '../types/index.js';
import chalk from 'chalk';

export async function startMcpServer() {
  const config = await loadConfig('ralph-config.json');
  const engine = new RalphEngine(config);
  
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
    'openai': new OpenAIAgent(),
    'ollama': new OllamaAgent(),
  };

  server.setRequestHandler(ListToolsRequestSchema, async () => ({
    tools: [
      {
        name: 'run_ralph_iteration',
        description: 'Run a single MAGI iteration for a task',
        inputSchema: {
          type: 'object',
          properties: {
            taskName: { type: 'string' },
            agentName: { type: 'string' },
          },
          required: ['taskName'],
        },
      },
      {
        name: 'get_ralph_status',
        description: 'Get current status of MAGI engine',
        inputSchema: { type: 'object', properties: {} },
      },
    ],
  }));

  server.setRequestHandler(CallToolRequestSchema, async (request) => {
    switch (request.params.name) {
      case 'run_ralph_iteration': {
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
      case 'get_ralph_status': {
        return {
          content: [
            {
              type: 'text',
              text: `MAGI Engine Active. State Dir: ${engine.getStateDir()}`,
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
