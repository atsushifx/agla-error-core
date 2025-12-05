// src: types/ErrorSeverity.types.ts
// @(#) : Error Severity Types for unified error handling across all packages
//
// Copyright (c) 2025 atsushifx <http://github.com/atsushifx>
//
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT

/**
 * Error severity levels for categorizing error importance.
 * Used across the entire monorepo for consistent error handling.
 */
export enum ErrorSeverity {
  /** Critical system failures that require immediate attention and may cause system shutdown */
  FATAL = 'fatal',
  /** Runtime errors that prevent normal operation but allow system to continue */
  ERROR = 'error',
  /** Potential issues that don't prevent operation but should be investigated */
  WARNING = 'warning',
  /** Informational messages about error conditions for debugging purposes */
  INFO = 'info',
}

/**
 * Type guard to check if a value is a valid ErrorSeverity
 * @param value - Value to validate
 * @returns True if value is a valid ErrorSeverity
 */
export const isValidErrorSeverity = function(value: unknown): value is ErrorSeverity {
  return typeof value === 'string'
    && Object.values(ErrorSeverity).includes(value as ErrorSeverity);
};
