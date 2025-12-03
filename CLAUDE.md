# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is an **OSS Project Starter Template** designed to help quickly launch modern open source projects with best practices and essential tools pre-configured. It focuses on providing a lightweight development environment with Git hooks for security and code quality.

## Commit Message Generation System

This repository uses an **automated commit message generation system** powered by AI. Understanding this system is critical for working in this codebase.

### Automatic Generation via Git Hooks

The `prepare-commit-msg` hook automatically generates Conventional Commits format messages when no message is provided:

```bash
# Hook is triggered automatically by lefthook
# Configured in: lefthook.yml
scripts/prepare-commit-msg.sh --to-buffer
```

### Manual Generation

To generate a commit message manually (outputs to stdout):

```bash
bash scripts/prepare-commit-msg.sh
```

### Commit Message Format (Conventional Commits)

All commit messages follow this **strict format** with character limits enforced by commitlint:

```text
type(scope): summary                    # ← Header: MAX 72 characters, lowercase start

- file1.ext:
  Description of changes                # ← Body lines: MAX 100 characters each
- file2.ext:
  Description of changes
```

**Character Limits (commitlint rules):**

- Header line (`type(scope): summary`): **72 characters maximum**
- Body lines: **100 characters maximum**
- Subject must start with **lowercase** (not uppercase or PascalCase)

**Commit Types:**

- `feat`: New feature
- `fix`: Bug fix
- `chore`: Routine task, maintenance
- `docs`: Documentation only
- `test`: Adding or updating tests
- `refactor`: Code change without fixing bugs or adding features
- `perf`: Performance improvement
- `ci`: CI/CD related changes
- `config`: Configuration changes
- `release`: Release-related commits
- `merge`: Merge commits (especially with conflict resolution)
- `build`: Build system or external dependencies
- `style`: Non-functional code style changes (formatting, linting)
- `deps`: Updating third-party dependencies

**Scope Guidelines:**

- Configuration files (`config/`, `*.yaml`, `*.json`): `config`
- Scripts (`scripts/`, `*.sh`): `scripts`
- Documentation (`docs/`, `*.md`): `docs`
- Tests (`__tests__/`, `tests/`): `test`

### AI Model Selection

The commit message generator supports multiple AI models via `--model` option:

```bash
# OpenAI models (via codex CLI)
scripts/prepare-commit-msg.sh --model gpt-5
scripts/prepare-commit-msg.sh --model o1-mini

# Anthropic models (via claude CLI)
scripts/prepare-commit-msg.sh --model claude-sonnet-4-5
scripts/prepare-commit-msg.sh --model haiku
scripts/prepare-commit-msg.sh --model sonnet
scripts/prepare-commit-msg.sh --model opus
```

Default model: `gpt-5`

### Agent Configuration

The commit message generation logic is defined in:

- **Agent file**: `.claude/agents/commit-message-generator.md`
- **Script implementation**: `scripts/prepare-commit-msg.sh`

The agent analyzes:

1. Last 10 commits (`git log --oneline -10`) for project conventions
2. Staged changes (`git diff --cached`) for actual modifications
3. File-by-file changes with detailed descriptions

## Git Hooks and Security

This repository uses **lefthook** to manage Git hooks with parallel execution for performance.

### Pre-commit Hooks (Security Scanning)

Both tools run in parallel to detect secrets before commits:

```bash
# Gitleaks - detects secrets in staged files
gitleaks protect --config ./configs/gitleaks.toml --staged

# Secretlint - static analysis for secrets
secretlint --secretlintrc ./configs/secretlint.config.yaml \
  --secretlintignore .gitignore --maskSecrets "{staged_files}"
```

**Configuration files:**

- `configs/gitleaks.toml`
- `configs/secretlint.config.yaml`

### Commit-msg Hook (Message Validation)

Validates commit messages against Conventional Commits format:

```bash
commitlint --config ./configs/commitlint.config.cjs --edit
```

**Configuration:** `configs/commitlint.config.js` (ES module format, uses `.cjs` extension)

### Hook Configuration

All hooks are configured in `lefthook.yml`. To install hooks after cloning:

```bash
lefthook install
```

## Development Tools

Tools are **not bundled** with the repository. Install independently using Scoop (Windows) or package managers:

| Tool       | Purpose                   | Installation                      |
| ---------- | ------------------------- | --------------------------------- |
| lefthook   | Git hook manager          | `scoop install lefthook`          |
| delta      | Visual Git diff viewer    | `scoop install delta`             |
| commitlint | Commit message linting    | `pnpm install -g @commitlint/cli` |
| gitleaks   | Secret detection          | `scoop install gitleaks`          |
| secretlint | Secret static analysis    | `pnpm install -g secretlint`      |
| cspell     | Spell checker             | `pnpm install -g cspell`          |
| dprint     | Code formatter (optional) | `scoop install dprint`            |

## Working with Claude Code in This Repository

### Creating Commits

When creating commits in this repository:

1. **Stage your changes** as usual:
   ```bash
   git add <files>
   ```

2. **Do NOT manually write commit messages**. The prepare-commit-msg hook will auto-generate them:
   ```bash
   git commit
   # Message is automatically generated by scripts/prepare-commit-msg.sh
   ```

3. **Review and edit** the generated message if needed before finalizing the commit.

### Character Limit Awareness

When generating or suggesting commit messages, always enforce:

- **Header**: 72 characters max
- **Body lines**: 100 characters max
- **Subject case**: Start with lowercase

If changes are too complex for these limits, suggest splitting into multiple commits.

### File-by-file Descriptions

Commit messages should describe changes **per file**, not as a generic summary:

**Good:**

```
feat(scripts): add automatic commit message generation

- scripts/prepare-commit-msg.sh:
  Implement Codex CLI integration for commit message generation
- lefthook.yml:
  Add prepare-commit-msg hook configuration
```

**Bad:**

```
feat: add new feature

Added commit message generation functionality
```

## Repository Structure

```
.
├── .claude/              # Local Claude Code configuration (repository-specific)
│   ├── agents/           # AI agent configurations
│   │   └── commit-message-generator.md
│   └── commands/         # Custom Claude Code commands (if any)
├── configs/              # Tool configurations
│   ├── commitlint.config.js
│   ├── gitleaks.toml
│   └── secretlint.config.yaml
├── scripts/              # Development scripts
│   └── prepare-commit-msg.sh  # Commit message generator
├── temp/                 # Temporary files (gitignored)
├── .editorconfig         # Editor configuration
├── .gitignore           # Git ignore patterns
├── lefthook.yml         # Git hooks configuration
└── LICENSE              # MIT License
```

### Claude Code Directory Structure

This repository uses both **local** (repository-specific) and **global** (user-wide) Claude Code configurations:

**Local Configuration** (`.claude/` in repository):

- **Purpose**: Project-specific agents and commands
- **Location**: `<repository>/.claude/`
- **Version Control**: Committed to git, shared with all users
- **Contents**:
  - `agents/` - Custom AI agent configurations for this project
  - `commands/` - Project-specific slash commands

**Global Configuration** (`~/.claude/plugins/` in user home):

- **Purpose**: Reusable plugins shared across all projects
- **Location**: `~/.claude/plugins/marketplaces/`
- **Version Control**: User-specific, NOT committed to repositories
- **Contents**:
  - Plugin packages (e.g., `claude-idd-framework-marketplace/`)
  - Shared libraries and utilities
  - Global slash commands

**Plugin Directory Structure:**

```
~/.claude/
└── plugins/
    └── marketplaces/
        └── claude-idd-framework-marketplace/    # Example plugin
            ├── .claude/
            │   ├── agents/                       # Global agents
            │   └── commands/
            │       ├── _libs/                    # Shared libraries
            │       │   ├── filename-utils.lib.sh
            │       │   ├── idd-session.lib.sh
            │       │   ├── prereq-check.lib.sh
            │       │   └── io-utils.lib.sh
            │       └── *.md                      # Slash commands
            └── plugin.json                       # Plugin metadata
```

## Claude Code Plugin Integration

This repository integrates with the **claude-idd-framework** plugin to provide enhanced development workflows.

### Plugin Installation

The claude-idd-framework plugin should be installed in the **global** plugins directory:

```bash
# Plugin installation location
~/.claude/plugins/marketplaces/claude-idd-framework-marketplace/
```

**Note**: This is a user-wide installation. The plugin is NOT included in the repository and must be installed separately by each developer.

### Plugin vs Local Configuration

Understanding the distinction between global plugins and local configurations:

| Aspect           | Global Plugin (`~/.claude/plugins/`) | Local Config (`.claude/`)   |
| ---------------- | ------------------------------------ | --------------------------- |
| **Scope**        | All projects for the user            | This repository only        |
| **Installation** | Installed once per user              | Committed to git            |
| **Examples**     | claude-idd-framework libraries       | commit-message-generator.md |
| **Purpose**      | Reusable utilities and commands      | Project-specific agents     |
| **Sharing**      | User maintains their own copy        | Shared via git repository   |

### Referencing Global Plugin Libraries

Libraries and utilities are referenced from the global plugin directory:

```bash
# Library path used in scripts
PLUGIN_DIR="$HOME/.claude/plugins/marketplaces/claude-idd-framework-marketplace"
FRAMEWORK_LIBS="$PLUGIN_DIR/.claude/commands/_libs"
```

### Available Libraries

When writing bash scripts for this repository, you can source these shared libraries:

```bash
# Load libraries from plugin
PLUGIN_DIR="$HOME/.claude/plugins/marketplaces/claude-idd-framework-marketplace"
FRAMEWORK_LIBS="$PLUGIN_DIR/.claude/commands/_libs"

source "$FRAMEWORK_LIBS/filename-utils.lib.sh"   # Slug generation, filename utilities
source "$FRAMEWORK_LIBS/idd-session.lib.sh"      # Session management
source "$FRAMEWORK_LIBS/prereq-check.lib.sh"     # Prerequisite checking
source "$FRAMEWORK_LIBS/io-utils.lib.sh"         # I/O utilities (error_print, etc.)
```

### Key Library Functions

- **filename-utils.lib.sh**: `generate_slug()` - Convert titles to URL-safe slugs
- **idd-session.lib.sh**: `_load_session()`, `_save_session()` - Session file management
- **prereq-check.lib.sh**: `validate_git_full()` - Git environment validation
- **io-utils.lib.sh**: `error_print()` - Standardized error messages

### Plugin Commands

The plugin provides slash commands available in this repository:

- `/claude-idd-framework:\idd\issue:branch` - Git branch management from issues
- `/claude-idd-framework:idd-commit-message` - Commit message generation
- `/claude-idd-framework:idd-pr` - Pull request generation
- Other IDD (Issue-Driven Development) workflow commands

Refer to `~/.claude/plugins/marketplaces/claude-idd-framework-marketplace/.claude/commands/` for full command documentation.

## Important Notes

- **No package.json**: This is a template repository, not a Node.js project. Tools are installed system-wide.
- **Windows-focused**: Setup scripts and tools are optimized for Windows with Scoop/pnpm.
- **Template usage**: When creating a new repository from this template, customize the LICENSE file with your GitHub handle.
- **Hook installation**: After cloning or forking, run `lefthook install` to activate Git hooks.
- **Plugin dependency**: Some scripts may reference libraries from `~/.claude/plugins/marketplaces/claude-idd-framework-marketplace/`.
