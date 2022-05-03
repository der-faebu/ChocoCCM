function Test-LocalChocoPackage {
    param (
        # Name of the package to be tested
        [Parameter(Mandatory)]
        [string]
        $PackageName
    )

    $installedPackages = (choco list -l -r) | ForEach-Object { $_.split('|')[0] }
    if (-not ($PackageName -in $installedPackages)) {
        return $false
    }
    return $true
}