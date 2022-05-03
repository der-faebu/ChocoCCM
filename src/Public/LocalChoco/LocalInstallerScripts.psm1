Get-ChildItem "$PSScriptRoot\*.ps1" | Where-Object { $_.Fullname -notmatch "\.Tests" } |  ForEach-Object { . $_.FullName }
