function Remove-CCMDeployment {
    <#
    .SYNOPSIS
    Removes a deployment plan
    
    .DESCRIPTION
    Removes the Deployment Plan selected from a Central Management installation
    
    .PARAMETER Deployment
    The Deployment to  delete
    
    .EXAMPLE
    Remove-CCMDeployment -Name 'Super Complex Deployment'

    .EXAMPLE
    Remove-CCMDeployment -Name 'Deployment Alpha' -Confirm:$false
    
    #>
    [cmdletBinding(ConfirmImpact = "High", SupportsShouldProcess,HelpUri="https://chocolatey.org/docs/remove-ccmdeployment")]
    param(
        [parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [ArgumentCompleter(
            {
                param($Command, $Parameter, $WordToComplete, $CommandAst, $FakeBoundParams)
                $r = (Get-CCMDeployment -All).Name
                

                If ($WordToComplete) {
                    $r.Where{ $_ -match "^$WordToComplete" }
                }

                Else {

                    $r
                }
            }
        )]
        [Alias("Deployment")]
        [string[]]
        $Name
    )

    begin {
        if(-not $Session){
            throw "Not authenticated! Please run Connect-CCMServer first!"
        }
        $deployId = [System.Collections.Generic.List[string]]::new() 
        
        $Name | % { $deployId.Add($(Get-CCMDeployment -Name $_ | Select-Object -ExpandProperty Id)) }
    }
    process {
        
        $deployId | ForEach-Object {
            if ($PSCmdlet.ShouldProcess("$Name", "DELETE")) {
                $irmParams = @{
                    Uri = "$($protocol)://$hostname/api/services/app/DeploymentPlans/Delete?Id=$($_)"
                    Method = "DELETE"
                    ContentType = "application/json"
                    WebSession  = $Session
                }
                Invoke-RestMethod @irmParams
            }

        }
        
    }
}