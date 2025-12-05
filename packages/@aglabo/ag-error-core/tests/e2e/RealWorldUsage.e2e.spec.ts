// src: tests/e2e/RealWorldUsage.e2e.spec.ts
// @(#): Real-world usage E2E tests (create→chain→serialize→display)
//
// Copyright (c) 2025 atsushifx <http://github.com/atsushifx>
//
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT

// Testing framework
import { describe, expect, it } from 'vitest';

// Type definitions
import { ErrorSeverity } from '../../shared/types/ErrorSeverity.types.js';

// Test utilities
import { TestAglaError } from '../../src/__tests__/helpers/TestAglaError.class.ts';

/**
 * Real-world usage E2E tests
 * Tests complete error lifecycle from creation through chaining to serialization and display
 */
describe('Real World Usage', () => {
  // Complete workflow: demonstrates full error handling lifecycle in realistic scenario
  it('creates, chains, serializes, and prints error', () => {
    const base = new TestAglaError('USER_ACTION_ERROR', 'Failed to process action', {
      code: 'UA_001',
      severity: ErrorSeverity.ERROR,
      context: { user: 'alice', action: 'create-document' },
    });

    const chained = base.chain(new Error('DB unavailable'));
    const json = chained.toJSON();
    const str = chained.toString();

    expect(json).toHaveProperty('errorType', 'USER_ACTION_ERROR');
    expect(json).toHaveProperty('message');
    expect(json).toHaveProperty('code', 'UA_001');
    expect(json).toHaveProperty('severity', ErrorSeverity.ERROR);
    expect(json).toHaveProperty('context');
    expect(str).toContain('USER_ACTION_ERROR');
    expect(str).toContain('DB unavailable');
  });
});
