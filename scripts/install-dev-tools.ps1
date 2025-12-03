# src: /scripts/install-dev-tools.ps1
# @(#) : 開発ツールインストールスクリプト
#
# Copyright (c) 2025 Furukawa Atsushi <atsushifx@gmail.com>
# Released under the MIT License.

<#
.SYNOPSIS
    開発支援ツール を一括インストールするスクリプト

.DESCRIPTION
    このスクリプトは、scoop・pnpm・eget などのツールを用いて、
    複数の開発支援ツールを一括で導入します。

.NOTES
    @Version  1.3.2
    @Since    2025-06-12
    @Author   atsushifx
    @License  MIT
#>

#region Setup
Set-StrictMode -Version Latest

. "$PSScriptRoot/common/init.ps1"
. "$SCRIPT_ROOT/libs/AgInstaller.ps1"
#endregion

#region ツールリスト

$WinGetPackages = @(
    #  環境変数マネージャー
    "dotenvx, dotenvx.dotenvx"
)

$ScoopPackages = @(
    # Gitフックマネージャー
    "lefthook",
    # フォーマッター
    "dprint",
    # 機密情報スキャン
    "gitleaks"
)

$PnpmPackages = @(
    # コミットメッセージチェック
    "commitlint",
    "@commitlint/cli",
    "@commitlint/config-conventional",
    "@commitlint/types",

    # 機密情報の漏洩チェック
    "secretlint",
    "@secretlint/secretlint-rule-preset-recommend",

    # スペルチェック
    "cspell",

    # AIエージェント
    "@anthropic/claude-code",
    "@openai/codex",
)

$EgetPackages = @(
    "codegpt, appleboy/codegpt"
)

#endregion

#region Main
function main {
    if (!(commandExists "eget")) {
        Write-Warning "eget is not installed."
        install-WinGetPackages "eget,ZacharyYedidia.Eget"
    }

    #/ 各種開発ツールのインストール
    $WinGetPackages | Install-WinGetPackages
    $ScoopPackages | Install-ScoopPackages
    $PnpmPackages | Install-PnpmPackages
    $EgetPackages | Install-EgetPackages
}
#endregion

## main

Write-Host "▶ Starting development tool setup..."
main
Write-Host "📦 Done."
