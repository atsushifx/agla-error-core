# src: scripts/libs/AgDevMode.ps1
# @(#): 開発者モード 設定/取得ライブラリ
#
# Copyright (c) 2025 Furukawa Atsushi <atsushifx@gmail.com>
# Released under MIT License.

## 定数定義
Set-Variable -Name "DEVMODE_REGPATH" -Option Constant -Value "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock"
Set-Variable -Name "DEVMODE_VALUE_NAME" -Option Constant -Value "AllowDevelopmentWithoutDevLicense"

## レジストリ値取得（純粋関数的アプローチ）
function Get-DevModeRegistryValue {
<#
.SYNOPSIS
    開発者モードのレジストリ値を安全に取得します（純粋関数）

.DESCRIPTION
    レジストリから値を取得し、エラー時は $null を返します。
#>
    try {
        (Get-ItemProperty -Path $DEVMODE_REGPATH -Name $DEVMODE_VALUE_NAME -ErrorAction Stop).$DEVMODE_VALUE_NAME
    } catch {
        $null
    }
}

## モード取得
function AgDevMode-GetMode {
<#
.SYNOPSIS
    Windowsの開発者モードの有効/無効状態を取得します。

.DESCRIPTION
    レジストリ "AppModelUnlock" キーの "AllowDevelopmentWithoutDevLicense" 値を参照して、
    開発者モードが有効かどうかをブール値で返します。

.EXAMPLE
    PS> AgDevMode-GetMode
    True

.NOTES
    定数: $DEVMODE_REGPATH, $DEVMODE_VALUE_NAME を使用
#>
    $value = Get-DevModeRegistryValue
    ($null -ne $value) -and ($value -eq 1)
}

## レジストリキー確保（副作用関数）
function Ensure-DevModeRegistryPath {
<#
.SYNOPSIS
    開発者モード用のレジストリキーが存在することを保証します
#>
    if (-not (Test-Path $DEVMODE_REGPATH)) {
        New-Item -Path $DEVMODE_REGPATH -Force | Out-Null
    }
}

## モード設定
function AgDevMode-SetMode {
<#
.SYNOPSIS
    Windowsの開発者モードを有効または無効に設定します。

.DESCRIPTION
    レジストリ "AppModelUnlock" キーの "AllowDevelopmentWithoutDevLicense" を 1 または 0 に設定します。
    必要に応じてレジストリキーの新規作成も行います。

.PARAMETER Enable
    開発者モードを有効にするには -Enable を指定してください。
    指定しない場合、既定で有効になります。無効化するには -Enable:$false を指定します。

.EXAMPLE
    PS> AgDevMode-SetMode -Enable:$false

.NOTES
    定数: $DEVMODE_REGPATH, $DEVMODE_VALUE_NAME を使用
#>
    param([switch]$Enable = $true)

    Ensure-DevModeRegistryPath
    $value = $Enable ? 1 : 0
    Set-ItemProperty -Path $DEVMODE_REGPATH -Name $DEVMODE_VALUE_NAME -Value $value -ErrorAction Stop
}
