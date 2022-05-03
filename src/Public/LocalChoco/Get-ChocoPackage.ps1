function Get-ChocoPackage{
    $installedPackages = (choco list -l -r) | ForEach-Object { $_.split('|')[0] }
    return $installedPackages

}