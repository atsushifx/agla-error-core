# src: /scripts/common/CommonFunctions.ps1
# @(#) : 共通関数ライブラリ
#
# Copyright (c) 2025 Furukawa Atsushi <atsushifx@gmail.com>
#
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT


function commandExists {
    param (
        [string]$command
    )

    try {
        & $command --version | Out-Null
        return $true
    } catch {
        return $false
    }
}
