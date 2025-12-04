// src: shared/configs/tsup.config.base.ts
// @(#) : tsup base configuration
//
// Copyright (c) 2025 atsushifx <https://github.com/atsushifx>
//
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT

// libs
import process from 'node:process';
import { dirname } from 'path';
import path from 'path';
import { fileURLToPath } from 'url';

// types
import type { OnResolveArgs, OnResolveResult, Plugin as EsbuildPlugin } from 'esbuild';
import type { Options } from 'tsup';

// plugins
/**
 * 型安全な alias → 相対パス変換 plugin
 */
export function createAliasRewritePlugin(
  aliases: Record<string, string>,
): EsbuildPlugin {
  return {
    name: 'alias-to-relative',
    setup(build) {
      build.onResolve(
        { filter: /.*/ },
        (args: OnResolveArgs): OnResolveResult | null => {
          for (const key of Object.keys(aliases)) {
            if (args.path.startsWith(key)) {
              // 1. 物理パスへマッピング
              const mapped = args.path.replace(key, aliases[key]);

              // 2. 絶対パスを取得
              const absPath = path.resolve(process.cwd(), mapped);

              // 3. importer からの相対パスに換算
              const rel = path.relative(path.dirname(args.importer), absPath);

              return {
                path: rel.startsWith('.') ? rel : `./${rel}`,
              };
            }
          }
          return null;
        },
      );
    },
  };
}

// ✅ __dirname for ESM
const __dirname = dirname(fileURLToPath(import.meta.url));

export const baseConfig: Options = {
  format: ['esm'],
  target: 'es2022',
  clean: true,
  dts: true,
  sourcemap: true,
  minify: false,
  splitting: false,
  shims: false,
  outDir: './lib',
  // overwrite it if sub-packages is necessary
  // entry: [  ],

  // 他の設定ファイルが自由に差し込めるよう空配列にしておく
  esbuildPlugins: [
    // 後で configs/tsup.config.esm.ts 側から上書きする
  ],
};
