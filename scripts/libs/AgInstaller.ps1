# src: /scripts/libs/AgInstaller.ps1
# @(#) : パッケージインストーラーライブラリ
#
# Copyright (c) 2025 Furukawa Atsushi <atsushifx@gmail.com>
# Released under the MIT License.

<#
.SYNOPSIS
    カンマ区切り文字列をパースして名前とIDを返します（純粋関数）

.DESCRIPTION
    "name,value"形式の文字列を受け取り、トリム済みの配列 @(name, value) を返します。
#>
function Split-PackageSpec {
    param([string]$Package)
    $Package.Split(",").Trim()
}

<#
.SYNOPSIS
    eget用パラメータを生成します。

.DESCRIPTION
    "name,repo"形式の文字列を受け取り、egetに渡すパラメータ（--to, リポジトリ名, --asset）を返します。
#>
function AgInstaller-EgetBuildParams {
    param([string]$Package)
    $name, $repo = Split-PackageSpec $Package
    @("--to", "c:/app/$name.exe", $repo, "--asset", '".xz"')
}

<#
.SYNOPSIS
    winget用パラメータを生成します。

.DESCRIPTION
    "name,id"形式の文字列を受け取り、winget installに渡す `--id` と `--location` を返します。
#>
function AgInstaller-WinGetBuildParams {
    param([string]$Package)
    $name, $id = Split-PackageSpec $Package
    @("--id", $id, "--location", "c:/app/develop/utils/$name")
}

<#
.SYNOPSIS
    有効なパッケージ行のみをフィルタします（純粋関数）
#>
function Filter-ValidPackages {
    [CmdletBinding()]
    param([Parameter(ValueFromPipeline = $true)][string]$Package)
    process {
        ($Package -and ($Package -notmatch '^\s*#')) ? $Package : $null
    }
}

<#
.SYNOPSIS
    winget経由でパッケージを一括インストールします。

.DESCRIPTION
    "name,id"形式のパッケージを、パイプまたは引数で受け取り、wingetで順にインストールします。

.PARAMETER Packages
    パッケージ名とwinget IDのペア文字列（例: "git,Git.Git"）

.EXAMPLE
    Install-WinGetPackages -Packages @("git,Git.Git")
.EXAMPLE
    "7zip,7zip.7zip" | Install-WinGetPackages
#>
function Install-WinGetPackages {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline = $true)]
        [string[]]$Packages
    )

    begin {
        $pkgList = @()
        $hasPackages = $false
    }
    process {
        $validPkgs = $Packages | Filter-ValidPackages
        if ($validPkgs) {
            $pkgList += $validPkgs
            $hasPackages = $true
        }
    }
    end {
        if (-not $hasPackages) {
            Write-Warning "📭 No valid packages to install via winget."
            return
        }

        $pkgList | ForEach-Object {
            $args = AgInstaller-WinGetBuildParams $_
            Write-Host "🔧 Installing $_ → winget $($args -join ' ')" -ForegroundColor Cyan
            try {
                Start-Process "winget" -ArgumentList (@("install") + $args) -Wait -NoNewWindow -ErrorAction Stop
            } catch {
                Write-Warning "❌ インストールに失敗しました: $_"
            }
        }
        Write-Host "✅ winget packages installed." -ForegroundColor Green
    }
}

<#
.SYNOPSIS
    Scoopでツールをインストールします。

.DESCRIPTION
    引数またはパイプで渡されたツール名を Scoop 経由でインストールします。
    コメント行（#）はスキップされます。

.PARAMETER Tools
    インストール対象のツール名

.EXAMPLE
    Install-ScoopPackages -Tools @("git", "dprint")
.EXAMPLE
    "gitleaks" | Install-ScoopPackages
#>
function Install-ScoopPackages {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline = $true)]
        [string[]]$Tools
    )

    begin {
        $toolList = @()
        $hasTools = $false
    }
    process {
        $validTools = $Tools | Filter-ValidPackages
        if ($validTools) {
            $toolList += $validTools
            $hasTools = $true
        }
    }
    end {
        if (-not $hasTools) {
            Write-Warning "📭 No valid tools to install via scoop."
            return
        }

        $toolList | ForEach-Object {
            Write-Host "🔧 Installing: $_" -ForegroundColor Cyan
            scoop install $_
        }
        Write-Host "✅ Scoop tools installed." -ForegroundColor Green
    }
}

<#
.SYNOPSIS
    pnpmで開発用パッケージをグローバルにインストールします。

.DESCRIPTION
    コメント除去後のパッケージを `pnpm add --global` で一括インストールします。

.PARAMETER Packages
    パッケージ名の文字列または配列

.EXAMPLE
    Install-PnpmPackages -Packages @("cspell", "secretlint")
.EXAMPLE
    "cspell" | Install-PnpmPackages
#>
function Install-PnpmPackages {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline = $true)]
        [string[]]$Packages
    )

    begin {
        $pkgList = @()
        $hasPackages = $false
    }
    process {
        $validPkgs = $Packages | Filter-ValidPackages
        if ($validPkgs) {
            $pkgList += $validPkgs
            $hasPackages = $true
        }
    }
    end {
        if (-not $hasPackages) {
            Write-Warning "📭 No valid packages to install."
            return
        }

        $cmd = "pnpm add --global $($pkgList -join ' ')"
        Write-Host "📦 Installing via pnpm: $cmd" -ForegroundColor Cyan
        Invoke-Expression $cmd
        Write-Host "✅ pnpm packages installed." -ForegroundColor Green
    }
}

<#
.SYNOPSIS
    egetでGitHubリリースからバイナリを取得してインストールします。

.DESCRIPTION
    "name,repo"形式のパッケージをパイプまたは引数で渡し、egetを使って `.exe` をDL・保存します。

.PARAMETER Packages
    パッケージ名とGitHubリポジトリ名のペア（例: "codegpt,appleboy/codegpt"）

.EXAMPLE
    Install-EgetPackages -Packages @("dprint,dprint/dprint")
.EXAMPLE
    "pnpm,pnpm/pnpm" | Install-EgetPackages
#>
function Install-EgetPackages {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline = $true)]
        [string[]]$Packages
    )

    begin {
        $pkgList = @()
        $hasPackages = $false
    }
    process {
        $validPkgs = $Packages | Filter-ValidPackages
        if ($validPkgs) {
            $pkgList += $validPkgs
            $hasPackages = $true
        }
    }
    end {
        if (-not $hasPackages) {
            Write-Warning "📭 No valid packages to install via eget."
            return
        }

        $pkgList | ForEach-Object {
            $args = AgInstaller-EgetBuildParams $_
            Write-Host "🔧 Installing $_ → eget $($args -join ' ')" -ForegroundColor Cyan
            try {
                Start-Process "eget" -ArgumentList $args -Wait -NoNewWindow -ErrorAction Stop
            } catch {
                Write-Warning "❌ インストールに失敗しました: $_"
            }
        }
        Write-Host "✅ eget packages installed." -ForegroundColor Green
    }
}
