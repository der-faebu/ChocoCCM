BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')
}

Describe "ConvertTo-ChocoPackage" {
    $matchingList = @(
        @{
            "LocalName"     = "pdf24-creator"
            "CommunityName" = "pdf24"
            "migrate"       = $true            
            "uninstall"     = $false
        },
        @{
            "LocalName"     = "npcap"
            "CommunityName" = $null
            "migrate"       = $false
            "uninstall"     = $false
        },
        @{
            "LocalName"     = "adobe-flash-player-npapi"
            "CommunityName" = $null
            "migrate"       = $false
            "uninstall"     = $true
        }

    )
    It "Correctly matches packages" {
        ConvertTo-ChocoPackage -PackageName 'pdf21-creator' -CommunityPackageName 'pdf24' -SoftDelete -UseInChocoDeployemnt
    }
}

