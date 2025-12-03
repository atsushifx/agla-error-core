# src: /scripts/install-doc-tools.ps1
# @(#) : ドキュメントルールインストールスクリプト
#
# Copyright (c) 2025 Furukawa Atsushi <atsushifx@gmail.com>
# Released under the MIT License.

<#
.SYNOPSIS
    Install textlint, markdownlint, and cspell for writers, and copy config files

.DESCRIPTION
    - Installs common textlint rules, markdownlint-cli2, and cspell
    - Copies .textlintrc.yaml, .markdownlint.yaml, .textlint/, .vscode/ from specified templates directory

.NOTES
    @Version  1.4.2
    @Author   atsushifx <https://github.com/atsushifx>
    @Since    2025-06-12
    @License  MIT https://opensource.org/licenses/MIT
#>

#region Parameters
Param (
    [string]$TemplateDir = "./templates",
    [string]$DestinationDir = "."
)
#endregion

#region Setup
Set-StrictMode -Version Latest

. "$PSScriptRoot/common/init.ps1"
. "$SCRIPT_ROOT/libs/AgInstaller.ps1"
#endregion

#region Functions
# Pure function: ベースディレクトリ取得（VSCode判定を統一）
function Get-BaseDirectory {
    param([string]$RootDir, [string]$Item)
    ($Item -ieq ".vscode") ? $RootDir : (Join-Path $RootDir "configs")
}

# Pure function: パス情報を生成
function New-CopyPathInfo {
    param(
        [string]$Item,
        [string]$TemplateDir,
        [string]$DestinationDir
    )

    $srcBase = Get-BaseDirectory $TemplateDir $Item
    $dstBase = Get-BaseDirectory $DestinationDir $Item

    @{
        Item = $Item
        Source = Join-Path $srcBase $Item
        Destination = Join-Path $dstBase $Item
    }
}

# IO function: ディレクトリコピー実行
function Copy-Directory {
    param($PathInfo)
    Write-Host "📁 Copying directory: $($PathInfo.Item) → $($PathInfo.Destination)"
    robocopy $PathInfo.Source $PathInfo.Destination /E /NFL /NDL /NJH /NJS /NC /NS | Out-Null
    Write-Host "✅ Directory copied: $($PathInfo.Item)"
}

# IO function: ファイルコピー実行
function Copy-File {
    param($PathInfo)
    Copy-Item $PathInfo.Source -Destination $PathInfo.Destination
    Write-Host "📝 Copied file: $($PathInfo.Item) → $($PathInfo.Destination)"
}

# IO function: アイテムコピー実行
function Copy-ConfigItem {
    param($PathInfo)

    if (-not (Test-Path $PathInfo.Source)) {
        Write-Warning "⚠️ Not found in templates: $($PathInfo.Item)"
        return
    }

    if (Test-Path $PathInfo.Destination) {
        Write-Host "🔁 Skipped (exists): $($PathInfo.Item)"
        return
    }

    (Get-Item $PathInfo.Source).PSIsContainer ? (Copy-Directory $PathInfo) : (Copy-File $PathInfo)
}

# Main function: パイプライン処理でコピー実行
function Copy-LinterConfigs {
<#
.SYNOPSIS
    指定された設定ファイル・ディレクトリをテンプレートから `DestinationDir/configs/` にコピーします。
    `.vscode` ディレクトリのみ特例として `DestinationDir/.vscode` にコピーされます。

.PARAMETER Items
    コピー対象のファイル名やディレクトリ名（パイプ/引数可）

.PARAMETER TemplateDir
    テンプレート格納ディレクトリ

.PARAMETER DestinationDir
    コピー先ルート（`.vscode`以外は `/configs` 配下）
#>
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline = $true)]
        [string[]]$Items,

        [string]$TemplateDir = "./templates",
        [string]$DestinationDir = "."
    )

    begin {
        # configs ディレクトリ作成
        $configPath = Join-Path $DestinationDir "configs"
        if (-not (Test-Path $configPath)) {
            New-Item -Path $configPath -ItemType Directory | Out-Null
            Write-Host "📁 Created configs directory: $configPath"
        }
    }

    process {
        $Items `
        | Where-Object { $_ -and ($_ -notmatch '^\s*#') } `
        | ForEach-Object { New-CopyPathInfo $_ $TemplateDir $DestinationDir } `
        | ForEach-Object { Copy-ConfigItem $_ }
    }
}
#endregion

#region Main
function main {
    Write-Host "📦 Installing writer tooling..."

    @(
        # textlint & rules
        "textlint",
        "textlint-filter-rule-allowlist",
        "textlint-filter-rule-comments",
        "textlint-rule-preset-ja-technical-writing",
        "textlint-rule-preset-ja-spacing",
        "@textlint-ja/textlint-rule-preset-ai-writing",
        "textlint-rule-ja-no-orthographic-variants",
        "@textlint-ja/textlint-rule-no-synonyms",
        "sudachi-synonyms-dictionary",
        "@textlint-ja/textlint-rule-morpheme-match",
        "textlint-rule-ja-hiraku",
        "textlint-rule-no-mixed-zenkaku-and-hankaku-alphabet",
        "textlint-rule-common-misspellings",
        "@proofdict/textlint-rule-proofdict",
        "textlint-rule-prh",

        # markdown lint
        "markdownlint-cli2",

        # spell checker
        "cspell"
    ) | Install-PnpmPackages

    if (Test-Path $TemplateDir) {
        @(
            # textlint settings
            "textlintrc.yaml",
            ".textlint",

            # markdownlint
            ".markdownlint.yaml",

            # cSpell
            ".vscode"
        ) | Copy-LinterConfigs -TemplateDir $TemplateDir -DestinationDir $DestinationDir
    } else {
        Write-Host "⚠️ Template directory not found: $TemplateDir. Skipping config copy."
    }

    Write-Host "✅ Writer environment setup completed." -ForegroundColor Green
}
#endregion

main
