# src: /scripts/libs/AgInstaller.ps1
# @(#) : パッケージインストーラーライブラリ
#
# Copyright (c) 2025 Furukawa Atsushi <atsushifx@gmail.com>
# Released under the MIT License.

<#
.SYNOPSIS
    eget用パラメータを生成します。

.DESCRIPTION
    "name,repo"形式の文字列を受け取り、egetに渡すパラメータ（--to, リポジトリ名, --asset）を返します。
#>
function AgInstaller-EgetBuildParams {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Package
    )
    ($name, $repo) = $Package.Split(",").trim()
    return @("--to", "c:/app/$name.exe", $repo, "--asset", '".xz"')
}

<#
.SYNOPSIS
    winget用パラメータを生成します。

.DESCRIPTION
    "name,id"形式の文字列を受け取り、winget installに渡す `--id` と `--location` を返します。
#>
function AgInstaller-WinGetBuildParams {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Package
    )
    ($name, $id) = $Package.Split(",").trim()
    return @("--id", $id, "--location", "c:/app/develop/utils/$name")
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

    begin { $pkgList = @() }
    process {
        foreach ($pkg in $Packages) {
            if ($pkg -and ($pkg -notmatch '^\s*#')) {
                $pkgList += $pkg
            }
        }
    }
    end {
        if ($pkgList.Count -eq 0) {
            Write-Warning "📭 No valid packages to install via winget."
            return
        }

        foreach ($pkg in $pkgList) {
            $args = AgInstaller-WinGetBuildParams -Package $pkg
            Write-Host "🔧 Installing $pkg → winget $($args -join ' ')" -ForegroundColor Cyan
            $args2 = @("install") + $args
            try {
                Start-Process "winget" -ArgumentList $args2 -Wait -NoNewWindow -ErrorAction Stop
            } catch {
                Write-Warning "❌ インストールに失敗しました: $pkg"
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

    begin { $toolList = @() }
    process {
        foreach ($tool in $Tools) {
            if ($tool -and ($tool -notmatch '^\s*#')) {
                $toolList += $tool
            }
        }
    }
    end {
        if ($toolList.Count -eq 0) {
            Write-Warning "📭 No valid tools to install via scoop."
            return
        }

        foreach ($tool in $toolList) {
            Write-Host "🔧 Installing: $tool" -ForegroundColor Cyan
            scoop install $tool
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

    begin { $pkgList = @() }
    process {
        foreach ($pkg in $Packages) {
            if ($pkg -and ($pkg -notmatch '^\s*#')) {
                $pkgList += $pkg
            }
        }
    }
    end {
        if ($pkgList.Count -eq 0) {
            Write-Warning "📭 No valid packages to install."
            return
        }

        $cmd = "pnpm add --global " + ($pkgList -join " ")
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

    begin { $pkgList = @() }
    process {
        foreach ($pkg in $Packages) {
            if ($pkg -and ($pkg -notmatch '^\s*#')) {
                $pkgList += $pkg
            }
        }
    }
    end {
        if ($pkgList.Count -eq 0) {
            Write-Warning "📭 No valid packages to install via eget."
            return
        }

        foreach ($pkg in $pkgList) {
            $args = AgInstaller-EgetBuildParams -Package $pkg
            Write-Host "🔧 Installing $pkg → eget $($args -join ' ')" -ForegroundColor Cyan
            try {
                Start-Process "eget" -ArgumentList $args -Wait -NoNewWindow -ErrorAction Stop
            } catch {
                Write-Warning "❌ インストールに失敗しました: $pkg"
            }
        }
        Write-Host "✅ eget packages installed." -ForegroundColor Green
    }
}
