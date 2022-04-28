function Get-CCMGroupMember {
    <#
    .SYNOPSIS
    Returns information about a CCM group's members
    
    .DESCRIPTION
    Return detailed group information from Chocolatey Central Management
    
    .PARAMETER Group
    The Group to query
    
    .EXAMPLE
    Get-CCMGroupMember -Group "WebServers"
    
    #>
    [cmdletBinding(HelpUri = "https://chocolatey.org/docs/get-ccmgroup-member")]
    param(
        [parameter(Mandatory)]
        [ArgumentCompleter(
            {
                param($Command, $Parameter, $WordToComplete, $CommandAst, $FakeBoundParams)
                $r = (Get-CCMGroup -All).Name
                

                If ($WordToComplete) {
                    $r.Where{ $_ -match "^$WordToComplete" }
                }

                Else {

                    $r
                }
            }
        )]
        [string]
        $Group,

        [switch]
        $Recurse
    )

    begin {
        if (-not $Session) {
            throw "Not authenticated! Please run Connect-CCMServer first!"
        }
    }
    process {
        $Id = (Get-CCMGroup -Group $Group).Id
        $irmParams = @{
            Uri         = "$($protocol)://$hostname/api/services/app/Groups/GetGroupForEdit?id=$Id"
            Method      = "GET"
            ContentType = "application/json"
            WebSession  = $Session
        }

        try {
            $record = Invoke-RestMethod @irmParams -ErrorAction Stop
        }
        catch {
            throw $_.Exception.Message
        }

        
        $cCollection = [System.Collections.Generic.List[psobject]]::new()
        $gCollection = [System.Collections.Generic.List[psobject]]::new()


        if ($record.result.groups -ne -0) {
            
            foreach ($gr in $record.result.groups) {
                $gCollection.Add($gr)
                $computers = (Get-CCMGroupMember -Group $gr.subGroupName).Computers
                if ($computers.Count) {
                    $cCollection.Add($computers)
                }
            }
        } 
        else {
            $record.result.computers | ForEach-Object {
                $cCollection.Add($_)
            }
        }

        [pscustomobject]@{
            Name        = $record.result.Name
            Description = $record.result.Description
            Groups      = @($gCollection)
            Computers   = @($cCollection)
            CanDeploy   = $record.result.isEligibleForDeployments
        } 

        
    }
}