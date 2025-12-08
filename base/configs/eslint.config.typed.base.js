// src: shared/configs/eslint.config.typed.base.js
// @(#) : ESLint flat config for TypeScript type checking
//
// Copyright (c) 2025 atsushifx <https://github.com/atsushifx>
//
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT

// -- import
// node
import process from 'node:process';
// plugins
import tseslint from '@typescript-eslint/eslint-plugin';
// parser
import tsparser from '@typescript-eslint/parser';

// -- rules
import typedRules from './eslint.config.rules.typed.js';

/**
 * Create typed ESLint configuration with customizable options
 * @param {Object} options - Configuration options
 * @param {string[]} [options.files] - File patterns to include
 * @param {string[]} [options.ignores] - File patterns to ignore
 * @param {string[]} [options.projectPaths] - TypeScript project paths
 * @param {string} [options.tsconfigRootDir] - Root directory for tsconfig
 * @param {Object} [options.settings] - Additional settings for import resolver
 * @returns {import('eslint').Linter.FlatConfig[]} ESLint configuration
 */
export const createTypedConfig = (options = {}) => {
  const {
    files = [
      'packages/**/*.ts',
      'aggregators/**/*.ts',
    ],
    ignores = [
      '**/dist/**',
      '**/lib/**',
      '**/maps/**',
      '**/module/**',
      '**/node_modules/**',
      '**/.cache/**',
      '**/configs/**',
      '**/*.d.ts',
    ],
    projectPaths = ['./tsconfig.json'],
    tsconfigRootDir = process.cwd(),
    settings = {},
  } = options;

  return [
    {
      ignores,
    },
    {
      files,
      plugins: {
        '@typescript-eslint': tseslint,
      },
      languageOptions: {
        parser: tsparser,
        parserOptions: {
          project: projectPaths,
          tsconfigRootDir,
          sourceType: 'module',
        },
      },
      settings,
      rules: typedRules,
    },
  ];
};

/** @type {import('eslint').Linter.FlatConfig[]} */
export default createTypedConfig();
