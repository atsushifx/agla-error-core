// src: src/__tests__/unit/AglaError.chaining.spec.ts
// @(#): AglaError chain method unit tests
//
// Copyright (c) 2025 atsushifx <http://github.com/atsushifx>
//
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT

// Testing framework
import { describe, expect, it } from 'vitest';

// Test utilities
import { TestAglaError } from '../helpers/TestAglaError.class.ts';

// Test cases
/**
 * AglaError Chain Method Unit Tests
 *
 * Tests error chaining functionality including message combination,
 * property preservation, context merging, and edge case handling.
 */
describe('Given AglaError method chaining', () => {
  /**
   * Normal Error Chaining Tests
   *
   * Tests standard error chaining with valid Error objects,
   * focusing on message combination and context preservation.
   */
  describe('When chaining with cause error', () => {
    // Test: Message combination with standard format
    it('Then should combine messages and preserve properties', () => {
      const originalError = new TestAglaError('TEST_ERROR', 'Original message');
      const causeError = new Error('Cause message');
      const chainedError = originalError.chain(causeError);

      expect(chainedError.message).toBe('[TEST] Original message (caused by: Cause message)');
      expect(chainedError.errorType).toBe('TEST_ERROR');
      expect(chainedError).toBe(originalError);
      expect(chainedError).toBeInstanceOf(TestAglaError);
    });

    // Test: Context merging with cause information
    it('Then should merge context with cause information', () => {
      const originalContext = { userId: '123', operation: 'test' };
      const originalError = new TestAglaError('TEST_ERROR', 'Original message', { context: originalContext });
      const causeError = new Error('Cause message');
      const chainedError = originalError.chain(causeError);

      expect(chainedError.context).toHaveProperty('userId', '123');
      expect(chainedError.context).toHaveProperty('operation', 'test');
      expect(chainedError.context).toHaveProperty('cause', 'Cause message');
      expect(chainedError.context).toHaveProperty('originalError');
      expect(chainedError.context?.originalError).toEqual({
        name: 'Error',
        message: 'Cause message',
        stack: causeError.stack,
      });
    });

    // Test: Immutability - returns new instance
    it('Then 正常系：should return same error instance', () => {
      const originalError = new TestAglaError('TEST_ERROR', 'Original message');
      const causeError = new Error('Cause message');
      const chainedError = originalError.chain(causeError);
      expect(chainedError).toBe(originalError);
      expect(chainedError).toBeInstanceOf(TestAglaError);
    });
  });

  /**
   * Edge Case Error Chaining Tests
   *
   * Tests error chaining with invalid or non-Error cause parameters,
   * including null, undefined, string, and object causes.
   */
  describe('When chaining with invalid or non-Error causes', () => {
    // Test: Null cause handling with error throwing
    it('Then 異常系：should handle null cause gracefully', () => {
      const originalError = new TestAglaError('TEST_ERROR', 'Original message');
      const nullCause = null as unknown as Error;
      expect(() => originalError.chain(nullCause)).toThrow();
    });

    // Test: Undefined cause handling with error throwing
    it('Then 異常系：should handle undefined cause gracefully', () => {
      const originalError = new TestAglaError('TEST_ERROR', 'Original message');
      const undefinedCause = undefined as unknown as Error;
      expect(() => originalError.chain(undefinedCause)).toThrow();
    });

    // Test: String cause handling via message property access
    it('Then 正常系：should handle string cause by accessing message property', () => {
      const originalError = new TestAglaError('TEST_ERROR', 'Original message');
      const stringCause = 'string error' as unknown as Error;
      const stringChainedError = originalError.chain(stringCause);
      expect(stringChainedError.message).toBe('[TEST] Original message (caused by: undefined)');
    });

    // Test: Object cause handling via message property extraction
    it('Then エッジケース：should handle object cause by accessing message property', () => {
      const originalError = new TestAglaError('TEST_ERROR', 'Original message');
      const objectCause = { message: 'object error message' } as unknown as Error;
      const chainedError = originalError.chain(objectCause);
      expect(chainedError.message).toBe('[TEST] Original message (caused by: object error message)');
    });
  });
});
