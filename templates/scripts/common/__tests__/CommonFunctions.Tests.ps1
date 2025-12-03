# src: /scripts/common/__tests__/CommonFunctions.Tests.ps1
# @(#) : 共通関数のユニットテスト
#
# Copyright (c) 2025 Furukawa Atsushi <atsushifx@gmail.com>
#
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

beforeAll {
    . "$PSScriptRoot/../CommonFunctions.ps1"
}


Describe "コマンド存在チェック" {
    It "eget存在チェック" {
        commandExists "eget" | Should -Be $true
    }
}
