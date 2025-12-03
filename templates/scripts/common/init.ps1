# src: /scripts/common/init.ps1
# @(#) : Common script initializer
#
# Copyright (c) 2025 atsushifx <http://github.com/atsushifx>
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

Set-StrictMode -Version Latest


<##
.SYNOPSIS
.SYNOPSIS
Initializes common constants for PowerShell scripts.

.DESCRIPTION
Defines SCRIPT_ROOT as the base directory for script execution context.
Ensures the variable is only defined once and marked as read-only.

.EXAMPLE
Init-ScriptEnvironment
# Defines $SCRIPT_ROOT if not already defined.

.NOTES
#>
function Init-ScriptEnvironment {
    $scriptRoot = Split-Path -Parent $PSScriptRoot

    if (-not (Get-Variable -Name "SCRIPT_ROOT" -Scope Script -ErrorAction SilentlyContinue)) {
        Set-Variable -Name "SCRIPT_ROOT" `
                     -Value $scriptRoot `
                     -Scope Script `
                     -Option ReadOnly
    }
}

## 初期設定
Init-ScriptEnvironment
. "$SCRIPT_ROOT/common/CommonFunctions.ps1"
