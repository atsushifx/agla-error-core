// src: types/AglaError.types.ts
// @(#) : Base Error Classes for unified error handling across all packages
//
// Copyright (c) 2025 atsushifx <http://github.com/atsushifx>
//
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT

// Internal type definitions
import type { ErrorSeverity } from './ErrorSeverity.types.js';

/**
 * Context information type for AglaError instances.
 * Replaces generic Record<string, unknown> with structured context type.
 */
export type AglaErrorContext = {
  [key: string]: unknown;
};

/**
 * Validates if a value is a valid AglaErrorContext.
 * @param value - The value to validate
 * @returns true if value is valid AglaErrorContext, false otherwise
 */

export const isValidAglaErrorContext = (value: unknown): value is AglaErrorContext =>
  typeof value === 'object' && value !== null;

/**
 * Type guard function that validates and returns AglaErrorContext.
 * @param value - The value to guard
 * @returns The validated AglaErrorContext
 * @throws Error if value is not valid AglaErrorContext
 */
export const guardAglaErrorContext = (value: unknown): AglaErrorContext => {
  if (!isValidAglaErrorContext(value)) {
    throw new Error('Invalid AglaErrorContext: expected object, got ' + typeof value);
  }
  return value;
};

/**
 * Options for creating AglaError instances with extended functionality.
 */
export type AglaErrorOptions = {
  /** The error code for identification and categorization */
  readonly code?: string;
  /** The severity level of this error */
  readonly severity?: ErrorSeverity;
  /** The timestamp when this error was created */
  readonly timestamp?: Date;
  /** Optional context information for debugging */
  readonly context?: AglaErrorContext;
  /** The underlying cause of this error */
  readonly cause?: string;
};

/**
 * Constructor type for AglaError and its subclasses.
 * Used for creating instances with proper type safety in factory methods.
 */
export type AglaErrorConstructor = new(
  errorType: string,
  message: string,
  options?: AglaErrorOptions | AglaErrorContext,
) => AglaError;

/**
 * Internal options class for managing AglaError properties.
 * Handles both new-style options objects and legacy context-only parameters.
 */
class _AglaErrorOptions {
  readonly errorType: string;
  readonly code?: string;
  readonly severity?: ErrorSeverity;
  readonly timestamp?: Date;
  context?: AglaErrorContext; // overwrite context, if error chain
  readonly cause?: string;

  /**
   * Creates internal options object from constructor parameters.
   * @param errorType - The error type identifying the specific type of error
   * @param options - Optional configuration or legacy context object
   */
  constructor(
    errorType: string,
    options?: AglaErrorOptions | AglaErrorContext,
  ) {
    this.errorType = errorType;

    if (
      options
      && (('code' in options) || ('severity' in options) || ('timestamp' in options) || ('context' in options)
        || ('cause' in options))
    ) {
      const opts = options as AglaErrorOptions;
      this.code = opts.code;
      this.severity = opts.severity;
      this.timestamp = opts.timestamp;
      this.context = opts.context;
      this.cause = opts.cause;
    } else {
      // Legacy compatibility: third parameter was just context
      this.context = options as AglaErrorContext | undefined;
    }
  }
}

/**
 * Abstract base error class for unified error handling across all packages.
 * Provides structured error handling with error codes, severity levels, and context information.
 */
export abstract class AglaError extends Error {
  /** Internal options containing all error properties */
  private _options: _AglaErrorOptions;

  /** Gets the error type identifying the specific type of error. */
  get errorType(): string {
    return this._options.errorType;
  }

  /** Gets the error code for identification and categorization */
  get code(): string | undefined {
    return this._options.code;
  }

  /** Gets the severity level of this error */
  get severity(): ErrorSeverity | undefined {
    return this._options.severity;
  }

  /** Gets the timestamp when this error was created */
  get timestamp(): Date | undefined {
    return this._options.timestamp;
  }

  /** Gets the optional context information providing additional details about the error. */
  get context(): AglaErrorContext | undefined {
    return this._options.context;
  }

  set context(context: AglaErrorContext) {
    this._options.context = context;
  }

  /**
   * Creates a new AglaError instance.
   *
   * @param errorType - The error type identifying the specific type of error
   * @param message - The human-readable error message
   * @param options - Optional configuration including code, severity, timestamp, and context
   */
  constructor(
    errorType: string,
    message: string,
    options?: AglaErrorOptions | AglaErrorContext,
  ) {
    super(message);

    this._options = new _AglaErrorOptions(errorType, options);
    this.name = this.constructor.name;

    // NOTE: Do not change - Error.captureStackTrace check is intentional for Node.js compatibility
    if (typeof Error.captureStackTrace === 'function') {
      Error.captureStackTrace(this, this.constructor);
    }
  }

  /**
   * Returns a string representation of the error including error type, message, and context.
   *
   * @returns A formatted string containing the error type, message, and context (if present)
   */
  toString(): string {
    let contextStr = '';
    if (this.context) {
      contextStr = JSON.stringify(this.context);
    }
    return `${this.errorType}: ${this.message}${contextStr ? ` ${contextStr}` : ''}`;
  }

  /**
   * Serializes the error to a JSON object containing all error information.
   *
   * @returns Object representation of the error with all relevant fields
   */
  toJSON(): {
    errorType: string;
    message: string;
    code?: string;
    severity?: ErrorSeverity;
    timestamp?: string;
    context?: unknown;
  } {
    return {
      errorType: this.errorType,
      message: this.message,
      ...(this.code && { code: this.code }),
      ...(this.severity && { severity: this.severity }),
      ...(this.timestamp && { timestamp: this.timestamp.toISOString() }),
      ...(this.context && { context: this.context }),
    };
  }

  /**
   * Creates a new AglaError that chains this error with a causing error.
   * Combines error messages and preserves context information.
   *
   * @param cause - The error that caused this error
   * @returns this AglaError instance with chained error information
   */
  chain(cause: Error): this {
    this.message = `${this.message} (caused by: ${cause.message})`;
    this.context = {
      ...this.context,
      cause: cause.message,
      originalError: {
        name: cause.name,
        message: cause.message,
        stack: cause.stack,
      },
    };
    return this;
  }
}
