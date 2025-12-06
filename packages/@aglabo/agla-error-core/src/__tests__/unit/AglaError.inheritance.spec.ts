// src: src/__tests__/unit/AglaError.inheritance.spec.ts
// @(#) : AglaError inheritance and subclass override tests
//
// Copyright (c) 2025 atsushifx <http://github.com/atsushifx>
//
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT

// Test framework
import { describe, expect, it } from 'vitest';

// Type definitions
import { ErrorSeverity } from '../../../shared/types/ErrorSeverity.types';
import { TestAglaError } from '../helpers/TestAglaError.class.ts';

// Test cases
/**
 * AglaError Inheritance and Subclass Override Tests
 *
 * Tests inheritance behavior, method overriding, and type safety
 * when subclasses override the chain method with custom behavior.
 */
describe('Given AglaError inheritance and method overriding', () => {
  /**
   * Chain Method Override Tests
   *
   * Tests that subclasses can safely override the chain method
   * while maintaining type safety and proper inheritance behavior.
   */
  describe('When TestAglaError overrides chain method', () => {
    // Test: Custom message formatting in overridden chain method
    it('Then should apply custom message formatting and maintain type safety', () => {
      const originalError = new TestAglaError('INHERITANCE_TEST', 'Original message');
      const causeError = new Error('Root cause');

      const chainedError = originalError.chain(causeError);

      // カスタムフォーマットが適用されているかチェック
      expect(chainedError.message).toBe('[TEST] Original message (caused by: Root cause)');

      // 型安全性の確認：戻り値はTestAglaError型
      expect(chainedError).toBe(originalError);
      expect(chainedError).toBeInstanceOf(TestAglaError);

      // 基本プロパティが保持されているか
      expect(chainedError.errorType).toBe('INHERITANCE_TEST');
    });

    // Test: Context merging still works with overridden method
    it('Then should preserve context merging from parent implementation', () => {
      const originalContext = { userId: '123', operation: 'inheritance-test' };
      const originalError = new TestAglaError('CONTEXT_TEST', 'Context test', {
        context: originalContext,
        severity: ErrorSeverity.ERROR,
      });
      const causeError = new Error('Context cause');

      const chainedError = originalError.chain(causeError);

      // カスタムメッセージフォーマット
      expect(chainedError.message).toBe('[TEST] Context test (caused by: Context cause)');

      // コンテキストマージが正常に動作
      expect(chainedError.context).toHaveProperty('userId', '123');
      expect(chainedError.context).toHaveProperty('operation', 'inheritance-test');
      expect(chainedError.context).toHaveProperty('cause', 'Context cause');
      expect(chainedError.context).toHaveProperty('originalError');

      // その他のプロパティも保持
      expect(chainedError.severity).toBe(ErrorSeverity.ERROR);
    });

    // Test: Multiple chaining with overridden method
    it('Then should handle multiple chaining correctly with custom formatting', () => {
      const originalError = new TestAglaError('MULTI_CHAIN', 'Base message');

      const level1 = originalError.chain(new Error('Level 1'));
      // level1時点でのメッセージ状態をキャプチャ（mutable動作のため）
      const level1Message = level1.message;

      const level2 = level1.chain(new Error('Level 2'));
      // level2時点でのメッセージ状態をキャプチャ
      const level2Message = level2.message;

      // 各チェーンでカスタムフォーマットが適用される
      expect(level1Message).toBe('[TEST] Base message (caused by: Level 1)');
      expect(level2Message).toBe('[TEST] [TEST] Base message (caused by: Level 1) (caused by: Level 2)');

      // 型安全性が維持される
      expect(level2).toBe(originalError);
      expect(level2).toBeInstanceOf(TestAglaError);
      expect(level2.errorType).toBe('MULTI_CHAIN');
    });

    // Test: JSON serialization works with overridden chain
    it('Then should serialize correctly after chaining with custom formatting', () => {
      const error = new TestAglaError('SERIALIZATION_TEST', 'Serialization message', {
        code: 'SER_001',
        severity: ErrorSeverity.WARNING,
      });

      const chainedError = error.chain(new Error('Serialization cause'));
      const json = chainedError.toJSON();

      expect(json).toEqual({
        errorType: 'SERIALIZATION_TEST',
        message: '[TEST] Serialization message (caused by: Serialization cause)',
        code: 'SER_001',
        severity: ErrorSeverity.WARNING,
        context: {
          cause: 'Serialization cause',
          originalError: {
            name: 'Error',
            message: 'Serialization cause',
            stack: expect.any(String),
          },
        },
      });
    });

    // Test: toString method works with overridden chain
    it('Then should format string correctly with custom message formatting', () => {
      const error = new TestAglaError('STRING_TEST', 'String message', {
        context: { operation: 'toString-test' },
      });

      const chainedError = error.chain(new Error('String cause'));
      const stringOutput = chainedError.toString();

      expect(stringOutput).toContain('STRING_TEST');
      expect(stringOutput).toContain('[TEST] String message (caused by: String cause)');
      expect(stringOutput).toContain('toString-test');
    });
  });

  /**
   * Type Safety Verification Tests
   *
   * Tests that TypeScript type system correctly handles subclass
   * method overrides and maintains compile-time type safety.
   */
  describe('When verifying TypeScript type safety', () => {
    // Test: Method chaining maintains correct types
    it('Then should maintain type information through method chaining', () => {
      const error = new TestAglaError('TYPE_SAFETY', 'Type test');

      // メソッドチェーンでも型が保持される
      const chained = error.chain(new Error('Type cause'));

      // TypeScriptコンパイラレベルでの型安全性確認
      const typedError: TestAglaError = chained;
      expect(typedError).toBe(error);
      expect(typedError).toBeInstanceOf(TestAglaError);

      // TestAglaError特有のメソッドへのアクセス確認
      expect(typeof chained.chain).toBe('function');
      expect(typeof chained.toJSON).toBe('function');
      expect(typeof chained.toString).toBe('function');
    });
  });
});
