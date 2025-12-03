# src: /scripts/libs/__tests__/AdInstallerEget.Tests.ps1
# @(#) : Egetパッケージインストーラーのパラメータ生成テスト
#
# Copyright (c) 2025 Furukawa Atsushi <atsushifx@gmail.com>
#
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

BeforeAll {
    . "$PSScriptRoot/../AgInstaller.ps1"
}

Describe "Eget パラメータ生成" {
    It "パラメータ取得に成功する（name, repo)" {
        $pkg = "codegpt, appleboy/codegpt"
        $args = AgInstaller-EgetBuildParams $pkg

        $args | Should -Be @(
            "--to", "c:/app/codegpt.exe",
            "appleboy/codegpt",
            "--asset", ".exe"
        )
    }
}
