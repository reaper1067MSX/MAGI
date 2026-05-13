# MAGI Developer Standards & Patterns

## Core Principles

1.  **Language**: **English is the official language** for all code, comments, documentation, and user-facing strings.
2.  **Architecture**: Follow a clean, modular structure. Consolidate logic into specialized folders:
    *   `src/agents/`: Adapters for different AI providers (SDK-based).
    *   `src/cli/`: User interface and registration logic.
    *   `src/engine/`: Core task orchestration and iteration management.
    *   `src/mcp/`: Server implementation using the Model Context Protocol.
3.  **Command Consolidation**: Always prioritize the short `magi` command. Maintain `magi-ai` only as a background alias for legacy support.
4.  **Stability First**: Every change must be covered by unit or integration tests. Run `npm test` before any PR.

## Coding Conventions

*   **TypeScript**: Use explicit types. Avoid `any`. Prefer interfaces for external data structures.
*   **Async/Await**: Use modern async patterns. Avoid callbacks.
*   **MCP Tools**: Keep tool descriptions concise and technical.
*   **Branding**: Use **MAGI** (all caps) in documentation and "magi" in code/commands.

## Workflow

*   Work on feature/fix branches.
*   Submit Pull Requests to `main`.
*   Ensure CI (GitHub Actions) passes before merging.
