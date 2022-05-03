function ConvertTo-ChocoPackage {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]
        $PackageName,

        [Parameter(Mandatory)]
        [string]
        $CommunityPackageName, 

        [Parameter(Mandatory)]
        [switch]
        $SkipAutoUninstall,

        [Parameter()]
        [switch]
        $UseInChocoDeployemnt
    )

    process {
        $packages = Get-ChocoPackage
        $sb = [System.Text.StringBuilder]::new()
        $sb.Append("choco install $CommunityPackage -y --no-progress --run-actual")
        if ($SoftDelete) {
            $chocoUninstallCommand += "--skip-autouninstall"
        }
        if ($PackageName -in $installedPackages) {
            try {
                choco uninstall $PackageName -y
                $chocoExitCode = $LASTEXITCODE
                if ($chocoExitCode -ne 0) {
                    throw "Error uninstalling $PackageName"
                }
                choco install $CommunityPackage -y --no-progress --run-actual
                if ($chocoExitCode -ne 0) {
                    throw "Error installing $CommunityPackage"
                }
            }
            catch {
                "Server: $env:COMPUTERNAME - Could not migrate $PackageName to $CommunityPackage"
            }
        }
        else {
            Write-Output "Package is not installed. Skipping."
            $chocoExitCode = 0
        }
    }

    end {
        Write-Output $chocoExitCode
        if ($UseInChocoDeployemnt) {
            Exit $chocoExitCode
        }
    }
}