// src: shared/common/configs/vitest.config.functional.ts
// @(#) : Vitest functional test configuration for @aglabo/agla-error-core
//
// Copyright (c) 2025 atsushifx <https://github.com/atsushifx>
//
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT

// libs for base directory
import path, { dirname } from 'path';
import { fileURLToPath } from 'url';
// base directory
const __dirname = dirname(fileURLToPath(import.meta.url));
const __rootDir = path.resolve(__dirname, '../');

// system config
import { mergeConfig } from 'vitest/config';

// shared base config
import baseConfig from '../../../../base/configs/vitest.config.base.ts';

// config
export default mergeConfig(baseConfig, {
  test: {
    include: [
      // Functional Test - single feature complete behavior verification
      'src/**/__tests__/functional/**/*.spec.ts',
      'src/**/__tests__/functional/**/*.test.ts',
    ],
    exclude: [
      'src/**/__tests__/units/**/*',
      'src/**/__tests__/runtime/**/*',
      'tests/**/*',
    ],
    cacheDir: path.resolve(__rootDir, '.cache/vitest-cache/functional/'),
    // sequential test execution to avoid singleton state conflicts in functional tests
    sequence: {
      concurrent: false,
    },
    //
    coverage: {
      provider: 'v8',
      reporter: ['json', 'lcov'],
      reportsDirectory: path.resolve(__rootDir, 'coverage/functional'),
    },
  },
});
