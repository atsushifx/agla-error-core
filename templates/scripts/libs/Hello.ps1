# src: /scripts/libs/Hello.ps1
# @(#) : Hello, <Name>! for pester execution tester
#
# Copyright (c) 2025 Furukawa Atsushi <atsushifx@gmail.com>
#
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

function greeting([string]$name = "World") {
    return "Hello, ${name}!"
}
