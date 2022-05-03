function Install-ChocoPackage {
    [CmdletBinding()]
    param (
        # Name of the choco package
        [Parameter(Mandatory)]
        [string]
        $PackageName,
        
        [Parameter()]
        [string]
        $SourceName,

        [Parameter()]
        [switch]
        $Force
    )
    
    begin {
        if ($null -ne $SourceName) {
            $sources = (choco source -list -r) | foreach-object { $_.split('|')[0] }
            if (-not ($SourceName -in $sources)) {
                throw "The given source $SourceName was not found."
            }
        }
    }
    
    process {
        $sb = [System.Text.StringBuilder]::new()
        $sb.Append("choco install $PackageName ")
        if ($SourceName) {
            $sb.Append("-s $SourceName")
        }
    }
    
    end {
        
    }
}