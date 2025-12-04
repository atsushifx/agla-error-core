// src: shared/configs/vitest.config.base.ts
// @(#) : vitest base configuration
//
// Copyright (c) 2025 atsushifx <https://github.com/atsushifx>
//
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT

// vitest
import tsconfigPaths from 'vite-tsconfig-paths';
import { defineConfig } from 'vitest/config';

// configs
export default defineConfig({
  plugins: [tsconfigPaths()],
  test: {
    globals: true,
    environment: 'node',
    passWithNoTests: true, // set no test is not failure
    include: [
      // NOTE: DO NOT ENABLE THESE HERE unless you want ALL tests to run in every subpackage.
      // Recommended: define test.include in each sub-package's vitest.config.*
      // Examples:
      //   - For unit tests only: 'src/**/*.spec.ts'
      //   - For CI-wide tests: 'tests/**/*.spec.ts'
      //
      // Unit Test (develop test) : set these sub-packages vitest.config.unit.ts
      // 'src/**/*.test.ts',
      // 'src/**/*.spec.ts',
      // CI Tests (integration test) : set these sub-packages vitest.config.ci.ts
      // 'tests/**/*.test.ts',
      // 'tests/**/*.spec.ts',
    ],
    exclude: [
      'node_modules/**',
      // output directories
      'dist/**',
      'lib/**',
      'module/**',
      // cache
      '.cache/**',
      // exclude test files
      `**/#*.ts`,
      `**/#*tests*`,
    ],
    // coverage: moved to individual test configs to avoid conflicts
  },
  resolve: {
    // set on sub-packages configs
    alias: {},
  },
});
