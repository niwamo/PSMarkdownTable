Write-Output "`r`nImporting Module...`r`n"
Import-Module "./PSMarkdownTable.psm1"

Write-Output "Testing conversion from PowerShell objects to Markdown Table:`r`n"
$json_data = Get-Content "./test-data.json" | ConvertFrom-Json
ConvertTo-MdTable -InputObject $json_data

Write-Output "`r`n`r`nTesting conversion from Markdown Table to PowerShell objects:"
$md_data = Get-Content "./test-data.md"
# by default, PowerShell will 'flatten' the array of hashtables for display, so we do some formatting
ConvertFrom-MdTable -InputObject $md_data | ForEach-Object {[PSCustomObject]$_} | Format-Table