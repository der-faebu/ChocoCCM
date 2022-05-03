Function Get-CCMSoftware {
    <#
    .SYNOPSIS
    Returns information about software tracked inside of CCM
    
    .DESCRIPTION
    Return information about each piece of software managed across all of your estate inside Central Management
    
    .PARAMETER SoftwareName
    Return information about a specific piece of software by friendly name

    .PARAMETER PackageName
    Return information about a specific package
    
    .PARAMETER PackageId
    Return information about a specific piece of software by id

    .PARAMETER ComputerId
    Returns a list of software installed on a given computer
    
    .EXAMPLE
    Get-CCMSoftware

    .EXAMPLE
    Get-CCMSoftware -Software 'VLC Media Player'

    .EXAMPLE
    Get-CCMSoftware -Package vlc

    .EXAMPLE
    Get-CCMSoftware -Id 37
    
    .NOTES
    #>
    [cmdletBinding(DefaultParameterSetname = "All", HelpUri = "https://chocolatey.org/docs/get-ccmsoftware")]
    Param(
            
        [Parameter(Mandatory, ParameterSetName = "Software")]
        [Alias("Software")]
        [string]
        $SoftwareName,
        
        [Parameter(Mandatory, ParameterSetName = "Package")]
        [Alias("Package")]
        [string]
        $PackageName,

        [Parameter(Mandatory, ParameterSetName = "Id")]
        [Alias("Id")]
        [int]
        $PackageId,
        
        [Parameter(Mandatory, ParameterSetName = "ComputerId")]
        [int]
        $ComputerId

    )

    begin {
        if (-not $Session) {
            throw "Not authenticated! Please run Connect-CCMServer first!"
        }
    }

    process {

        if (-not $Id -and -not $Software -and -not $Package) {
            $records = Invoke-RestMethod -Uri "$($protocol)://$Hostname/api/services/app/Software/GetAllWithoutFilter" -WebSession $Session -UseBasicParsing
        } 
        
        Switch ($PSCmdlet.ParameterSetName) {

            "Software" {
                $softwareId = $records.result | Where-Object { $_.name -eq "$SoftwareName" } | Select-Object -ExpandProperty Id
                $softwareId | ForEach-Object {
                    $irmParams = @{
                        WebSession = $Session
                        Uri        = "$($protocol)://$Hostname/api/services/app/ComputerSoftware/GetAllPagedBySoftwareId?filter=&softwareId=$($_)&skipCount=0&maxResultCount=500"
                    }
                
                    $records = Invoke-RestMethod @irmParams
                    $records.result.items
                }

            }

            "Package" {
                $packageId = $records.result | Where-Object { $_.packageId -eq "$PackageName" } | Select-Object -ExpandProperty id

                $packageId | ForEach-Object {
                    $irmParams = @{
                        WebSession = $Session
                        Uri        = "$($protocol)://$Hostname/api/services/app/ComputerSoftware/GetAllPagedBySoftwareId?filter=&softwareId=$($_)&skipCount=0&maxResultCount=500"
                    }
                
                    $records = Invoke-RestMethod @irmParams
                    $records.result.items
                }
            }

            "Id" {

                $irmParams = @{
                    WebSession = $Session
                    Uri        = "$($protocol)://$Hostname/api/services/app/ComputerSoftware/GetAllPagedBySoftwareId?filter=&softwareId=$PackageId&skipCount=0&maxResultCount=500"
                }
                $records = Invoke-RestMethod @irmParams
                $records.result.items
            }

            "ComputerId" {

                $irmParams = @{
                    WebSession = $Session
                    Uri        = "$($protocol)://$Hostname/api/services/app/ComputerSoftware/GetAllPagedByComputerId?filter=&computerId=$ComputerId&maxResultCount=500"
                }
                $records = Invoke-RestMethod @irmParams
                $records.result.items
            }

            default {
                $records.result
            }

        }
    }
}
