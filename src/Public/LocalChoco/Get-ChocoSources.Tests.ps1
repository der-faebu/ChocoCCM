BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')
}

Describe "Get-ChocoSources" {
    It "Returns expected output" {
        Get-ChocoSources | Should -Be "YOUR_EXPECTED_VALUE"
    }
}
