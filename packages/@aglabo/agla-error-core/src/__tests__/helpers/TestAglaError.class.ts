// src: src/__tests__/helpers/TestAglaError.class.ts
// @(#) : Test utility class for AglaError testing
//
// Copyright (c) 2025 atsushifx <http://github.com/atsushifx>
//
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT

// Type definitions
import { AglaError, type AglaErrorOptions } from '../../../shared/types/AglaError.types';

/**
 * Test utility class extending AglaError for testing purposes.
 * Provides concrete implementation of the abstract AglaError class with test-specific functionality.
 */
export class TestAglaError extends AglaError {
  /**
   * Creates a new TestAglaError instance for testing.
   * @param errorType - The error type identifying the specific type of error
   * @param message - The human-readable error message
   * @param options - Optional configuration including code, severity, timestamp, and context
   */
  constructor(
    errorType: string,
    message: string,
    options?: AglaErrorOptions,
  ) {
    super(errorType, message, options);
  }

  /**
   * Overrides chain method to add custom message formatting.
   * Adds "[TEST]" prefix to demonstrate inheritance type safety.
   */
  chain(cause: Error): this {
    // 親クラスのchain処理を先に呼び出し（cause部分を追加）
    super.chain(cause);
    // その後でカスタムフォーマットを適用
    this.message = `[TEST] ${this.message}`;
    return this;
  }
}

/**
 * Basic implementation of AglaError without method overrides.
 * Used to test the base chain functionality without inheritance customization.
 */
export class BasicAglaError extends AglaError {
  /**
   * Creates a new BasicAglaError instance without any customization.
   * This demonstrates using AglaError directly without overriding methods.
   */
  constructor(
    errorType: string,
    message: string,
    options?: AglaErrorOptions,
  ) {
    super(errorType, message, options);
  }

  // 継承のみ、メソッドのオーバーライドなし
}
