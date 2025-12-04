// src: shared/configs/eslint.rules.typed.js
// @(#) : ESLint rules for TypeScript type checking
//
// Copyright (c) 2025 atsushifx <https://github.com/atsushifx>
//
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT

// rules
/** @type {import('eslint').Linter.FlatConfig[]} */
export default {
  // type check rules
  '@typescript-eslint/prefer-nullish-coalescing': 'warn',
  '@typescript-eslint/prefer-optional-chain': 'warn',
  '@typescript-eslint/explicit-function-return-type': ['warn', {
    allowExpressions: true,
    allowConciseArrowFunctionExpressionsStartingWithVoid: true,
  }],
  '@typescript-eslint/no-unnecessary-type-assertion': 'warn',
  '@typescript-eslint/no-unnecessary-condition': 'warn',
  '@typescript-eslint/restrict-template-expressions': 'warn',
};
