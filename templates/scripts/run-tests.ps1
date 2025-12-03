# src: /src/run-scripts-tests.ps1
# @(#) : powershell pester test runner
#
# Copyright (c) 2025 Furukawa Atsushi <atsushifx@gmail.com>
# Released under MIT License.

<#
.SYNOPSIS
Runs PowerShell Pester tests for the scripts project.

.PARAMETER Target
Specify which test group to run:
- "unit"    : Run tests in scripts/libs/**/__tests__/*.Tests.ps1
- "ci"      : Run tests in scripts/tests/*.Tests.ps1
- "all"     : Run both

.EXAMPLE
.\run-scripts-tests.ps1 -Target unit
#>

param (
    [ValidateSet("unit", "ci", "all")]
    [string]$Target = "all"
)

. "$PSScriptRoot/common/init.ps1"
Init-ScriptEnvironment

$testTargets = @()

function Get-TestFiles {
    param (
        [string]$Path
    )
    Get-ChildItem -Path $Path -Recurse -Include *.Tests.ps1 -File |
        Where-Object {
            # 除外条件: ディレクトリパス内に '#～' を含まない
            $_.DirectoryName -notmatch '\\#' -and
            $_.Name -notmatch '^#'
        }
}

switch ($Target) {
    "unit" {
        $testTargets += Get-TestFiles -Path "$SCRIPT_ROOT/libs"
        $testTargets += Get-TestFiles -Path "$SCRIPT_ROOT/common"
    }
    "ci" {
        $testTargets += Get-TestFiles -Path "$SCRIPT_ROOT/tests"
    }
    "all" {
        $testTargets += Get-TestFiles -Path "$SCRIPT_ROOT/libs"
        $testTargets += Get-TestFiles -Path "$SCRIPT_ROOT/common"

        $testTargets += Get-TestFiles -Path "$SCRIPT_ROOT/tests"
    }
}

if ($testTargets.Count -eq 0) {
    Write-Host "⚠️  No test files found for target '$Target'."
    exit 1
}

Invoke-Pester -Script $testTargets
