# src: /scripts/libs/__tests__/AgInstallerWinget.Tests.ps1
# @(#) : WinGetパッケージのインストールパラメータ生成テスト
#
# Copyright (c) 2025 Furukawa Atsushi <atsushifx@gmail.com>
# Released under MIT License

BeforeAll {
. "$PSScriptRoot/../AgInstaller.ps1"
}

Describe "WinGetインストールパラメータ取得" {
    It "パラメータ取得に成功する（id + name → 正しい引数群）" {
        $pkg = "dotenvx, dotenvx.dotenvx"
        $args = AgInstaller-WinGetBuildParams $pkg

        $args | Should -Be @(
            "--id", "dotenvx.dotenvx",
            "--location", "c:/app/develop/utils/dotenvx"
        )
    }
}
