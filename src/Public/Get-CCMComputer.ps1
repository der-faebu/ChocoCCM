Function Get-CCMComputer {
    <#
    .SYNOPSIS
    Returns information about computers in CCM
    
    .DESCRIPTION
    Query for all, or by computer name/id to retrieve information about the system as reported in Central Management
    
    .PARAMETER Computer
    Returns the specified computer(s)
    
    .PARAMETER Id
    Returns the information for the computer with the specified id
    
    .EXAMPLE
    Get-CCMComputer

    .EXAMPLE
    Get-CCMComputer -Computer web1

    .EXAMPLE
    Get-CCMComputer -Id 13
    
    .NOTES
    
    #>
    [cmdletBinding(DefaultParameterSetName = "All", HelpUri = "https://chocolatey.org/docs/get-ccmcomputer")]
    Param(

        [Parameter(Mandatory, ParameterSetName = "ComputerFQDN")]
        [Alias("Name", "ComputerName")]
        [string[]]
        $ComputerFQDN,

        [Parameter(Mandatory, ParameterSetName = "Id")]
        [int]
        $Id,

        [Parameter(ParameterSetName = "Id")]
        [switch]
        $ForEdit
    )

    begin {
        If (-not $Session) {
            throw "Unauthenticated! Please run Connect-CCMServer first"
        }
    }

    process {

        if (-not $Id) {
            $url = "$($protocol)://$Hostname/api/services/app/Computers/GetAll"
            $records = Invoke-RestMethod -Uri $url -WebSession $Session
        } 

        Switch ($PSCmdlet.ParameterSetName) {

            "ComputerFQDN" {
                Foreach ($c in $ComputerFQDN) {
                    [pscustomobject]$records.result | Where-Object { $_.fqdn -match "$c" } 
                }
            }

            "Id" {
                $url = "$($protocol)://$Hostname/api/services/app/Computers/GetComputerForView?Id=$Id"
                if ($ForEdit) {
                    $url = "$($protocol)://$Hostname/api/services/app/Computers/GetAllPagedByComuterId?Id=$Id"
                }
                $records = Invoke-RestMethod -Uri $url -WebSession $Session

                $records.result
            }

            default {
                $records.result
            }
        }
    }
}