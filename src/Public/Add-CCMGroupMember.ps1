function Add-CCMGroupMember {
    <#
    .SYNOPSIS
    Adds a member to an existing Group in Central Management
    
    .DESCRIPTION
    Add new computers and groups to existing Central Management Groups
    
    .PARAMETER Name
    The group to edit
    
    .PARAMETER Computer
    The FQDN of the computer(s) to add
    
    .PARAMETER Group
    The group(s) to add
    
    .EXAMPLE
    Add-CCMGroupMember -Group 'Newly Imaged' -Computer Lab1,Lab2,Lab3
    
    #>
    [cmdletBinding(HelpUri = "https://chocolatey.org/docs/add-ccmgroup-member")]
    param(
        [parameter(Mandatory = $true)]
        [parameter(ParameterSetName = "Computer")]
        [parameter(ParameterSetName = "Group")]
        [ArgumentCompleter(
            {
                param($Command, $Parameter, $WordToComplete, $CommandAst, $FakeBoundParams)
                $r = (Get-CCMGroup).Name
                

                If ($WordToComplete) {
                    $r.Where{ $_ -match "^$WordToComplete" }
                }

                Else {

                    $r
                }
            }
        )]
        [string]
        $Name,
        
        [parameter(Mandatory = $true, ParameterSetName = "Computer")]
        [Parameter(ParameterSetName = 'Group')]
        [Alias('FQDN', 'ComputerFQDN')]
        [ValidateScript({
                $_ -match '(.+\.){2}(.+){1}'
            }
        )]
        [string[]]
        $Computer,

        [parameter(Mandatory = $true , ParameterSetName = "Group")]
        [string[]]
        $Group
    )

    begin {
        
        if (-not $Session) {
            throw "Not authenticated! Please run Connect-CCMServer first!"
        }
        
        $allComputers = Get-CCMComputer
        $allGroups = Get-CCMGroup
    
        $ComputerCollection = [System.Collections.Generic.List[psobject]]::new()
        $GroupCollection = [System.Collections.Generic.List[psobject]]::new()

        $id = Get-CCMGroup -Group $name | Select-Object -ExpandProperty Id

        $currentGroupObject = Get-CCMGroup -Id $id | Select-Object *
        $currentGroupObject.computers | ForEach-Object { $ComputerCollection.Add([pscustomobject]@{computerId = "$($_.computerId)" }) }
        $currentSubgroups = $currentGroupObject.groups.subGroupName

    }

    process {
        switch ($PSCmdlet.ParameterSetName) {
            { $Computer } {
                $allComputersToAdd = $Computer
                foreach ($compToAdd in $allComputersToAdd) {
                    if ($compToAdd -in $currentGroupObject.computers.FQDN) {
                        Write-Warning "Skipping $($compToAdd.FQDN), already exists."
                    }
                    else {
                        $CompObjectToAdd = $allComputers | Where-Object { $_.FQDN -eq "$compToAdd" } | Select-Object  Id
                        $ComputerCollection.Add([pscustomobject]@{computerId = "$($CompObjectToAdd.Id)" })
                    }
                }
                $processedComputers = $ComputerCollection
            }

            'Group' {
                $allGroupsToAdd = $Group
                foreach ($groupToAdd in $allGroupsToAdd) {
                    if ($groupToAdd -in $currentSubgroups) {
                        Write-Warning "Skipping $groupToAdd, already exists"
                    }
                    else {
                        $groupObjectToAdd = $allGroups | Where-Object { $_.Name -eq "$groupToAdd" }
                        $GroupCollection += ([pscustomobject]@{
                                subGroupId               = $groupObjectToAdd.Id
                                subGroupName             = $groupObjectToAdd.Name
                            })
                    }
                }

                $processedGroups = $GroupCollection
            }
        }
        
        $body = @{
            Name        = $Name
            Id          = ($allGroups | Where-Object { $_.name -eq "$Name" } | Select-Object  -ExpandProperty Id)
        } 
        
        if($processedGroups.Count -ne 0){
            $body['Groups'] = $processedGroups
        }
        if ($processedComputers.Count -ne 0) {
            $body['Computers'] = $processedComputers
        }
        $jsonBody = $body | ConvertTo-Json -Depth 3

        Write-Verbose $body
        $irmParams = @{
            Uri         = "$($protocol)://$hostname/api/services/app/Groups/CreateOrEdit"
            Method      = "post"
            ContentType = "application/json"
            Body        = $jsonBody
            WebSession  = $Session
        }

        try {
            $null = Invoke-RestMethod @irmParams -ErrorAction Stop
            $successGroup = Get-CCMGroupMember -Group $Name

            [pscustomobject]@{
                Name        = $Name
                Description = $successGroup.Description
                Groups      = $successGroup.Groups.subGroupName
                Computers   = $successGroup.Computers.computerName
            }
        }

        catch {
            throw $_.Exception.Message
        }
    }
}