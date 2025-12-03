#!/usr/bin/env bash
# src: ./scripts/prepare-commit-msg.sh
# @(#): Prepare commit message using Codex CLI
#
# @file prepare-commit-msg.sh
# @brief Prepare commit message using Codex CLI
# @description
#   Automatically generates Conventional Commits format messages by analyzing
#   staged changes and recent commit history using Codex CLI.
#
#   Features:
#   - Conventional Commits format compliance
#   - Context-aware message generation from git diff and log
#   - Dual output modes: stdout or Git buffer
#   - Skips generation if existing message found (Git buffer mode)
#
# @example
#   # Output to stdout
#   prepare-commit-msg.sh
#
#   # Output to Git commit buffer
#   prepare-commit-msg.sh --git-buffer
#
#   # Short form for Git buffer
#   prepare-commit-msg.sh --to-buffer
#
# @exitcode 0 Success
# @exitcode 1 Error during message generation
#
# @author atsushifx
# @version 1.0.0
# @license MIT
# src: ./scripts/prepare-commit-msg.sh
# @(#): Prepare commit message using Codex CLI
#
# @file prepare-commit-msg.sh
# @brief Prepare commit message using Codex CLI
# @description
#   Automatically generates Conventional Commits format messages by analyzing
#   staged changes and recent commit history using Codex CLI.
#
#   Features:
#   - Conventional Commits format compliance
#   - Context-aware message generation from git diff and log
#   - Dual output modes: stdout or Git buffer
#   - Skips generation if existing message found (Git buffer mode)
#
# @example
#   # Output to stdout
#   prepare-commit-msg.sh
#
#   # Output to Git commit buffer
#   prepare-commit-msg.sh --git-buffer
#
#   # Short form for Git buffer
#   prepare-commit-msg.sh --to-buffer
#
# @exitcode 0 Success
# @exitcode 1 Error during message generation
#
# @author atsushifx
# @version 1.0.0
# @license MIT
#
# Copyright (c) 2025 atsushifx <https://github.com/atsushifx>
# Released under the MIT License.
# https://opensource.org/licenses/MIT
#

set -euo pipefail
mkdir -p temp

##
# @description Repository root path
REPO_ROOT="$(git rev-parse --show-toplevel)"
readonly REPO_ROOT

##
# @description Git commit message file path
# @default .git/COMMIT_EDITMSG
GIT_COMMIT_MSG=".git/COMMIT_EDITMSG"

##
# @description Output to stdout (true) or Git buffer (false)
# @default true
FLAG_OUTPUT_TO_STDOUT=true

##
# @description AI model name for commit message generation
# @default gpt-5
AI_MODEL="gpt-5"

##
# @description Parse command-line options
# @arg $@ string Command-line arguments to parse
# @option --git-buffer Output to Git commit buffer (.git/COMMIT_EDITMSG)
# @option --to-buffer Short form for --git-buffer
# @option --model MODEL Specify AI model name (default: gpt-5)
# @option --help|-h Display usage information
# @example
#   parse_options "$@"
#   parse_options --model claude-sonnet-4-5 --to-buffer
# @exitcode 0 If parsing succeeds
# @exitcode 1 If unknown option provided or --model without argument
# @see FLAG_OUTPUT_TO_STDOUT
# @see GIT_COMMIT_MSG
# @see AI_MODEL
parse_options() {
  while [[ $# -gt 0 ]]; do
    case $1 in
      --git-buffer|--to-buffer)
        FLAG_OUTPUT_TO_STDOUT=false
        shift
        ;;
      --model)
        if [[ -z "${2:-}" ]]; then
          echo "Error: --model requires a model name argument" >&2
          exit 1
        fi
        AI_MODEL="$2"
        shift 2
        ;;
      --help|-h)
        echo "Usage: $0 [--git-buffer|--to-buffer] [--model MODEL] [commit_msg_file]"
        echo "  --git-buffer, --to-buffer : Output to Git commit buffer"
        echo "  --model MODEL             : Specify AI model (default: gpt-5)"
        echo "                              Supported: gpt-*, o1-*, claude-*, haiku, sonnet, opus"
        echo "  default                    : Output to stdout"
        exit 0
        ;;
      -*)
        echo "Unknown option: $1" >&2
        exit 1
        ;;
      *)
        # Non-option argument treated as commit message file
        GIT_COMMIT_MSG="$1"
        shift
        ;;
    esac
  done
}



##
# @description Check if existing commit message exists in file
# @arg $1 string Path to commit message file
# @example
#   if has_existing_message ".git/COMMIT_EDITMSG"; then
#     echo "Message already exists"
#   fi
# @exitcode 0 If non-comment, non-empty content found
# @exitcode 1 If only comments or empty lines found
has_existing_message() {
  local file="$1"
  grep -vE '^\s*(#|$)' "$file" | grep -q '.'
}

##
# @description Create context block with git logs and diff
# @example
#   context=$(make_context_block)
# @stdout Git logs (last 10 commits) and staged diff with delimiters
# @exitcode 0 Always succeeds
# @see git-log(1)
# @see git-diff(1)
make_context_block() {
  echo "----- GIT LOGS -----"
  git log --oneline -10 || echo "No logs available."
  echo "----- END LOGS -----"
  echo
  echo "----- GIT DIFF -----"
  git diff --cached || echo "No diff available."
  echo "----- END DIFF -----"
}


##
# @description Get CLI command for specified AI model
# @arg $1 string AI model name (default: gpt-5)
#   Supported models:
#   - OpenAI: gpt-*, o1-* → codex exec
#   - Anthropic: claude-*, haiku, sonnet, opus → claude -p
#   - OpenCode: provider/model (e.g., github-copilot/grok-code-fast-1) → opencode run
# @example
#   cmd=$(get_model_command "gpt-5")
#   cmd=$(get_model_command "claude-sonnet-4-5")
#   cmd=$(get_model_command "github-copilot/grok-code-fast-1")
# @stdout CLI command string for the specified model
# @exitcode 0 If model is supported
# @exitcode 1 If model is unsupported
get_model_command() {
  local model="${1:-gpt-5}"
  local cmd=""

  case "$model" in
    # === OpenAI 系モデル ===
    gpt-* | o1-* )
      cmd="codex exec --model ${model}"
      ;;

    # === Anthropic (Claude) 系モデル ===
    claude-* | haiku | sonnet | opus)
      cmd="claude -p --model ${model}"
      ;;

    # === 未対応モデル ===
    *)
      echo "❌ Unsupported model: ${model}" >&2
      return 1
      ;;
  esac

  echo "$cmd"
}


##
# @description Generate commit message using Codex CLI
# @arg $1 string Optional test message (for testing purposes)
# @example
#   commit_msg=$(generate_commit_message)
#   echo "$commit_msg"
# @stdout Generated Conventional Commits format message
# @exitcode 0 If generation succeeds
# @see codex(1)
# @see make_context_block
generate_commit_message() {
  local test_message="${1:-}"

  # Return test message if provided
  if [[ -n "$test_message" ]]; then
    echo "${test_message}"
    return 0
  fi

  # get AI generator command
  local cmd
  cmd=$(get_model_command "${AI_MODEL}") || return 1

  local full_output
  full_output=$({
    cat .claude/agents/commit-message-generator.md
    echo
    make_context_block
  } | eval "$cmd"
  )

  # Extract content between === commit header === and === commit footer ===
  # Get content after ----- END DIFF ----- (or entire output if not found)
  local after_diff
  if echo "$full_output" | grep -q "^----- END DIFF -----$"; then
    after_diff=$(echo "$full_output" | sed -n '/^----- END DIFF -----$/,$p' | sed '1d')
  else
    after_diff="$full_output"
  fi

  # Extract content between header and footer markers
  echo "$after_diff" | \
    sed -n '/^=== commit header ===/,/^=== commit footer ===/p' | \
    sed '1d;$d'
}

##
# @description Output commit message to stdout or file
# @arg $1 string Commit message content
# @arg $2 string Optional output file path (default: GIT_COMMIT_MSG)
# @example
#   output_commit_message "$commit_msg"
#   output_commit_message "$commit_msg" ".git/COMMIT_EDITMSG"
# @stdout Commit message (if FLAG_OUTPUT_TO_STDOUT=true)
# @stderr Success message (if outputting to file)
# @exitcode 0 Always succeeds
# @see FLAG_OUTPUT_TO_STDOUT
# @see GIT_COMMIT_MSG
output_commit_message() {
  local commit_msg="$1"
  local output_file="${2:-$GIT_COMMIT_MSG}"

  if [[ "$FLAG_OUTPUT_TO_STDOUT" == true ]]; then
    # Stdout mode
    echo "$commit_msg"
  else
    # Git buffer mode
    rm -f "${output_file}"
    echo "${commit_msg}" > "${output_file}"
    echo "✦ Commit message written to $output_file" >&2
  fi
}

# ============================================================================
# Main Execution (only when directly executed, not when sourced)
# ============================================================================

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  set -euo pipefail
  mkdir -p temp
  cd "$REPO_ROOT"

  # オプション解析
  parse_options "$@"

  # Gitバッファーモードの場合のみ既存メッセージチェック
  if [[ "$FLAG_OUTPUT_TO_STDOUT" == false && -f "$GIT_COMMIT_MSG" ]]; then
    if has_existing_message "$GIT_COMMIT_MSG"; then
      echo "✦ Detected existing Git-generated commit message. Skipping Codex." >&2
      exit 0
    fi
  fi

  # コミットメッセージ生成
  commit_msg=$( generate_commit_message )

  # コミットメッセージ出力
  output_commit_message "$commit_msg"
fi
