function Test-LocalChocoPackage {
    param (
        # Name of the package to be tested
        [Parameter(Mandatory, ValueFromPipeline)]
        [string]
        $PackageName
    )

    begin {
        $installedPackages = Get-ChocoInstalledPackages
    }
    process {
        if (-not ($PackageName -in $installedPackages)) {
            return $false
        }
        return $true
    }
}