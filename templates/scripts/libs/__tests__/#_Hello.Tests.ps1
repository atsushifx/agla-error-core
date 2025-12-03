# Copyright (c) 2025 Furukawa Atsushi <atsushifx@gmail.com>
#
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

BeforeAll {
    . "$PSScriptRoot/../Hello.ps1"
}

Describe 'Hello, {Name}!' {
    It 'Hello, World!' {
        greeting "World" | Should -Be "Hello, World!"
    }
}
