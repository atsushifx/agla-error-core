# src: /scripts/libs/__tests__/AgDevMode.Tests.ps1
# @(#) : 開発車モード 設定／取得テスト
#
# Copyright (c) 2025 Furukawa Atsushi <atsushifx@gmail.com>
#
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

BeforeAll {
    . "$PSScriptRoot/../AgDevMode.ps1"
}

Describe '開発車モードテスト' {
    It 'モード取得' {
        AgDevMode-GetMode | Should -BeTrue
    }

    # 用 sudo
    #It "モード設定" {
    ##    AgDevMode-SetMode $true
    #    AgDevMode-GetMode | Should -BeTrue
    #}
}
