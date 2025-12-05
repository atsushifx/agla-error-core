// src: src/__tests__/unit/AglaError.chain-patterns.spec.ts
// @(#) : AglaError chain usage patterns tests (inheritance vs non-inheritance)
//
// Copyright (c) 2025 atsushifx <http://github.com/atsushifx>
//
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT

// Test framework
import { describe, expect, it } from 'vitest';

// Type definitions
import { ErrorSeverity } from '../../../shared/types/ErrorSeverity.types.ts';
import { BasicAglaError, TestAglaError } from '../helpers/TestAglaError.class.ts';

// Test cases
/**
 * AglaError Chain Usage Patterns Tests
 *
 * Tests different usage patterns for the chain method:
 * - Non-inheritance pattern (recommended): Using basic AglaError without method overrides
 * - Inheritance pattern (advanced): Using subclass with method overrides
 *
 * This ensures both usage patterns work correctly and developers can choose
 * the appropriate approach for their use case.
 */
describe('Given different AglaError usage patterns', () => {
  /**
   * Non-Inheritance Pattern Tests
   *
   * Tests using AglaError directly without method overrides.
   * This is the recommended approach for most use cases.
   */
  describe('When using non-inheritance pattern (recommended)', () => {
    // Test: Basic chain functionality without overrides
    it('Then should chain errors with standard message formatting', () => {
      const originalError = new BasicAglaError('BASIC_ERROR', 'Original message');
      const causeError = new Error('Root cause');

      const chainedError = originalError.chain(causeError);

      // 標準的なメッセージフォーマット
      expect(chainedError.message).toBe('Original message (caused by: Root cause)');

      // 基本プロパティの確認
      expect(chainedError.errorType).toBe('BASIC_ERROR');
      expect(chainedError).toBe(originalError); // 同じインスタンス
      expect(chainedError).toBeInstanceOf(BasicAglaError);
    });

    // Test: Multiple chaining without custom formatting
    it('Then should handle multiple chaining with standard formatting', () => {
      const originalError = new BasicAglaError('MULTI_BASIC', 'Base message');

      const level1 = originalError.chain(new Error('Level 1'));
      const level1Message = level1.message; // level1時点の状態をキャプチャ

      const level2 = level1.chain(new Error('Level 2'));
      const level2Message = level2.message; // level2時点の状態をキャプチャ

      // 各レベルでの標準フォーマット
      expect(level1Message).toBe('Base message (caused by: Level 1)');
      expect(level2Message).toBe('Base message (caused by: Level 1) (caused by: Level 2)');

      // 同じインスタンスであることを確認
      expect(level2).toBe(originalError);
      expect(level2).toBeInstanceOf(BasicAglaError);
    });

    // Test: Context merging with non-inheritance pattern
    it('Then should merge context correctly without custom logic', () => {
      const originalContext = { userId: '123', operation: 'basic-test' };
      const originalError = new BasicAglaError('CONTEXT_BASIC', 'Context message', {
        context: originalContext,
        severity: ErrorSeverity.WARNING,
      });
      const causeError = new Error('Context cause');

      const chainedError = originalError.chain(causeError);

      // 標準的なコンテキストマージ
      expect(chainedError.context).toHaveProperty('userId', '123');
      expect(chainedError.context).toHaveProperty('operation', 'basic-test');
      expect(chainedError.context).toHaveProperty('cause', 'Context cause');
      expect(chainedError.context).toHaveProperty('originalError');

      // その他のプロパティも保持
      expect(chainedError.severity).toBe(ErrorSeverity.WARNING);
    });
  });

  /**
   * Inheritance Pattern Tests
   *
   * Tests using AglaError with method overrides for advanced use cases.
   * This pattern should be used only when custom behavior is specifically needed.
   */
  describe('When using inheritance pattern (advanced)', () => {
    // Test: Custom formatting through inheritance
    it('Then should apply custom formatting via method override', () => {
      const originalError = new TestAglaError('CUSTOM_ERROR', 'Custom message');
      const causeError = new Error('Custom cause');

      const chainedError = originalError.chain(causeError);

      // カスタムフォーマット（[TEST]プレフィックス）が適用される
      expect(chainedError.message).toBe('[TEST] Custom message (caused by: Custom cause)');

      // 基本プロパティの確認
      expect(chainedError.errorType).toBe('CUSTOM_ERROR');
      expect(chainedError).toBe(originalError); // 同じインスタンス
      expect(chainedError).toBeInstanceOf(TestAglaError);
    });

    // Test: Multiple chaining with custom formatting
    it('Then should handle multiple chaining with custom formatting accumulation', () => {
      const originalError = new TestAglaError('MULTI_CUSTOM', 'Base message');

      const level1 = originalError.chain(new Error('Level 1'));
      const level1Message = level1.message; // level1時点の状態をキャプチャ

      const level2 = level1.chain(new Error('Level 2'));
      const level2Message = level2.message; // level2時点の状態をキャプチャ

      // 各レベルでのカスタムフォーマット（プレフィックス累積）
      expect(level1Message).toBe('[TEST] Base message (caused by: Level 1)');
      expect(level2Message).toBe('[TEST] [TEST] Base message (caused by: Level 1) (caused by: Level 2)');

      // 同じインスタンスであることを確認
      expect(level2).toBe(originalError);
      expect(level2).toBeInstanceOf(TestAglaError);
    });
  });

  /**
   * Pattern Comparison Tests
   *
   * Tests comparing the behavior between inheritance and non-inheritance patterns
   * to ensure both approaches work as expected and developers can choose appropriately.
   */
  describe('When comparing usage patterns', () => {
    // Test: Both patterns preserve core functionality
    it('Then both patterns should preserve core AglaError functionality', () => {
      const basicError = new BasicAglaError('BASIC', 'Basic message');
      const customError = new TestAglaError('CUSTOM', 'Custom message');

      const basicChained = basicError.chain(new Error('Basic cause'));
      const customChained = customError.chain(new Error('Custom cause'));

      // 両方とも基本機能を保持
      expect(basicChained.errorType).toBe('BASIC');
      expect(customChained.errorType).toBe('CUSTOM');

      expect(typeof basicChained.toJSON).toBe('function');
      expect(typeof customChained.toJSON).toBe('function');

      expect(typeof basicChained.toString).toBe('function');
      expect(typeof customChained.toString).toBe('function');
    });

    // Test: Serialization works for both patterns
    it('Then both patterns should serialize correctly', () => {
      const basicError = new BasicAglaError('SERIAL_BASIC', 'Basic serial', {
        code: 'B001',
        severity: ErrorSeverity.INFO,
      });
      const customError = new TestAglaError('SERIAL_CUSTOM', 'Custom serial', {
        code: 'C001',
        severity: ErrorSeverity.ERROR,
      });

      const basicChained = basicError.chain(new Error('Basic cause'));
      const customChained = customError.chain(new Error('Custom cause'));

      const basicJson = basicChained.toJSON();
      const customJson = customChained.toJSON();

      // 両方とも正しくシリアライズされる
      expect(basicJson.errorType).toBe('SERIAL_BASIC');
      expect(basicJson.code).toBe('B001');
      expect(basicJson.message).toBe('Basic serial (caused by: Basic cause)');

      expect(customJson.errorType).toBe('SERIAL_CUSTOM');
      expect(customJson.code).toBe('C001');
      expect(customJson.message).toBe('[TEST] Custom serial (caused by: Custom cause)');
    });
  });
});
