export interface IterationResult {
  success: boolean;
  message: string;
  nextStep?: string;
  error?: Error;
}

export interface AgentContext {
  cwd: string;
  stateDir: string;
}

export interface AgentAdapter {
  name: string;
  invoke(prompt: string, context: AgentContext): Promise<IterationResult>;
}

export interface AgentConfig {
  name: string;
  type: 'gemini' | 'openai' | 'ollama';
  model?: string;
  endpoint?: string;
}

export interface RalphConfig {
  agents: AgentConfig[];
  defaultAgent: string;
  stateDirectory?: string;
}
