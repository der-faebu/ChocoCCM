function Remove-LocalChocoPackage {
    [CmdletBinding()]
    param (
        # Name of the package to be removed
        [Parameter(Mandatory, ValueFromPipeline)]
        [string]
        $PackageName,

        [Parameter()]
        [switch]
        $SoftDelete,

        [Parameter()]
        [switch]
        $FailOnError, 

        [Parameter()]
        [string[]]
        $ExcludeList,

        [Parameter()]
        [switch]
        $SkipAutoUninstaller
    )
    
    begin {
        $exitCodes = @()
    }
    
    process {
        if ((Test-LocalChocoPackage $PackageName) -and (-not ($PackageName -in $ExcludeList))) {
            Write-Output "Removing $PackageName"

            $sb = [System.Text.StringBuilder]::new()
            $sb.Append('choco uninstall -y --no-progress --run-actual ')
            $sb.Append("$PackageName ")

            if ($SkipAutoUninstaller) {
                Write-Information "Skipping autouninstaller. The Package will reappear during the next local sync."
                $sb.Append('--skip-autouninstaller ')
            }

            $command = $sb.ToString()
            Write-Debug "Running Command '$command'"
            Invoke-Expression $command

            $exitCodes += ${
                Package = $PackageName
                ExitCode = $LASTEXITCODE
            }
        }
        else {
            Write-Information "Package $PackageName does not seem to be installed. Skipping."
        }
    }
    
    end {
        $exitSum = 0
        $exitCodes.ExitCode | foreach-object { $exitSum += $_ }

        if ($exitCodes -eq 0) {
            Write-Debug "Success, exiting with code 0"
            Exit 0
        }
        elseif ($FailOnError) {
            Write-Debug "At leat one package did not correctly uninstall. Throwing as FailOnError is set." 
            throw "At leat one package did not correctly uninstall. Throwing as FailOnError is set." 
            Exit 1
        }
        else {
            $exitCodes | Where-Object ExitCode -ne 0
            Write-Debug "At leat one package did not correctly uninstall. Deployement will not fail." 
            Write-Debug "Failed packages: "
            Exit 95
        }
    }
}