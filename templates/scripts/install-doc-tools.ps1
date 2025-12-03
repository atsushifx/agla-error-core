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
        [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [string[]]$Items,

        [string]$TemplateDir = "./templates",
        [string]$DestinationDir = "."
    )

    begin {
        $targets = @()
    }

    process {
        foreach ($i in $Items) {
            if ($i -and ($i -notmatch '^\s*#')) {
                $targets += $i
            }
        }
    }

    end {
        # create configs directory if needed
        $configPath = Join-Path $DestinationDir "configs"
        if (-not (Test-Path $configPath)) {
            New-Item -Path $configPath -ItemType Directory | Out-Null
            Write-Host "📁 Created configs directory: $configPath"
        }

        # Copy configs
        foreach ($item in $targets) {
            $src = Join-Path $TemplateDir $item

            $dstBase = if ($item -ieq ".vscode") {
                $DestinationDir  # 直下にコピー
            } else {
                Join-Path $DestinationDir "configs"
            }

            $dst = Join-Path $dstBase $item

            if (Test-Path $src) {
                if (-not (Test-Path $dst)) {
                    if ((Get-Item $src).PSIsContainer) {
                        Write-Host "📁 Copying directory: $item → $dst"
                        robocopy $src $dst /E /NFL /NDL /NJH /NJS /NC /NS | Out-Null
                        Write-Host "✅ Directory copied: $item"
                    } else {
                        Copy-Item $src -Destination $dst
                        Write-Host "📝 Copied file: $item → $dst"
                    }
                } else {
                    Write-Host "🔁 Skipped (exists): $item"
                }
            } else {
                Write-Warning "⚠️ Not found in templates: $item"
            }
        }
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
            ".textlintrc.yaml",
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
