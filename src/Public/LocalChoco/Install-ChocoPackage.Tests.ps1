BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')
}

Mock
Describe "Install Choco-Package" {
    It "Throws if unknown repo is given." {
        {Install-ChocoPackage -PackageName 'pdf24' -SourceName 'myDummySource'} | Should -Throw
    }
    It "Appends the source argument to the choco command." {
        { Install-ChocoPackage -PackageName 'pdf24' -SourceName '' } | Should -Throw
    }
}
 