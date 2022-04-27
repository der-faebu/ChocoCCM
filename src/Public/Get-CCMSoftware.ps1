Function Get-CCMSoftware {
    <#
    .SYNOPSIS
    Returns information about software tracked inside of CCM
    
    .DESCRIPTION
    Return information about each piece of software managed across all of your estate inside Central Management
    
    .PARAMETER Software
    Return information about a specific piece of software by friendly name

    .PARAMETER Package
    Return information about a specific package
    
    .PARAMETER Id
    Return information about a specific piece of software by id
    
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
        [string]
        $Software,
        
        [Parameter(Mandatory, ParameterSetName = "Package")]
        [string]
        $Package,

        [Parameter(Mandatory, ParameterSetName = "Id")]
        [int]
        $Id

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
                $softwareId = $records.result | Where-Object { $_.name -eq "$Software" } | Select-Object -ExpandProperty Id
                $softwareId | ForEach-Object {
                    $irmParams = @{
                        WebSession = $Session
                        Uri        = "$($protocol)://$Hostname/api/services/app/ComputerSoftware/GetAllPagedBySoftwareId?filter=&softwareId=$($_)&skipCount=0&maxResultCount=500"
                    }
                
                    $records = Invoke-RestMethod @irmParams
                    $records.result
                }

            }

            "Package" {
                $packageId = $records.result | Where-Object { $_.packageId -eq "$Package" } | Select-Object -ExpandProperty id

                $packageId | ForEach-Object {
                    $irmParams = @{
                        WebSession = $Session
                        Uri        = "$($protocol)://$Hostname/api/services/app/ComputerSoftware/GetAllPagedBySoftwareId?filter=&softwareId=$($_)&skipCount=0&maxResultCount=500"
                    }
                
                    $records = Invoke-RestMethod @irmParams
                    $records.result
                }
            }

            "Id" {

                $irmParams = @{
                    WebSession = $Session
                    Uri        = "$($protocol)://$Hostname/api/services/app/ComputerSoftware/GetAllPagedBySoftwareId?filter=&softwareId=$Id&skipCount=0&maxResultCount=500"
                }
                $records = Invoke-RestMethod @irmParams
                $records.result
            }

            default {
                $records.result
            }

        }
       
    }
}
