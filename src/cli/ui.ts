import chalk from 'chalk';
import ora, { Ora } from 'ora';
import boxen from 'boxen';

export class UI {
  private spinner: Ora | null = null;

  // Log user input or general clean text
  logUser(text: string) {
    this.stopSpinner();
    console.log(chalk.bold.blue('You: ') + text);
  }

  // Log agent reasoning/thought process (dim/italic)
  logReasoning(agentName: string, text: string) {
    this.stopSpinner();
    console.log(chalk.dim.italic(`[${agentName} thinking] ${text}`));
  }

  // Start a loading spinner for an action
  startAction(text: string) {
    this.stopSpinner();
    this.spinner = ora({
      text: chalk.yellow(text),
      spinner: 'dots'
    }).start();
  }

  // Succeed the current spinner
  succeedAction(text?: string) {
    if (this.spinner) {
      this.spinner.succeed(text ? chalk.green(text) : undefined);
      this.spinner = null;
    }
  }

  // Fail the current spinner
  failAction(text?: string) {
    if (this.spinner) {
      this.spinner.fail(text ? chalk.red(text) : undefined);
      this.spinner = null;
    }
  }

  // Stop spinner without status
  stopSpinner() {
    if (this.spinner) {
      this.spinner.stop();
      this.spinner = null;
    }
  }

  // Display a prominent system message or result
  logSystem(title: string, message: string) {
    this.stopSpinner();
    console.log(
      boxen(message, {
        title: chalk.bold.cyan(title),
        padding: 1,
        margin: { top: 1, bottom: 1 },
        borderStyle: 'round',
        borderColor: 'cyan'
      })
    );
  }

  // Display an error prominently
  logError(title: string, error: Error | string) {
    this.stopSpinner();
    const msg = error instanceof Error ? error.message : error;
    console.log(
      boxen(chalk.red(msg), {
        title: chalk.bold.red(`Error: ${title}`),
        padding: 1,
        margin: { top: 1, bottom: 1 },
        borderStyle: 'double',
        borderColor: 'red'
      })
    );
  }
}
