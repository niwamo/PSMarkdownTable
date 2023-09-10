Write-Output "`r`nImporting Module...`r`n"
Import-Module "./PSMarkdownTable.psm1"

# To Table, As Parameter
Write-Output "Testing conversion from PowerShell objects to Markdown Table:`r`n"
$json_data = Get-Content "./test-data.json" | ConvertFrom-Json
ConvertTo-MdTable -InputObject $json_data

# To Table, As Pipeline
Write-Output "`r`n`r`nTesting conversion when received from pipeline:`r`n"
Get-Content "./test-data.json" | ConvertFrom-Json | ConvertTo-MdTable

# From Table, As Parameter
Write-Output "`r`n`r`nTesting conversion from Markdown Table to PowerShell objects:"
$md_data = Get-Content "./test-data.md"
# by default, PowerShell will 'flatten' the array of hashtables for display, so we do some formatting
ConvertFrom-MdTable -InputObject $md_data 

# From Table, As Pipeline
Write-Output "`r`n`r`nTesting conversion when received from pipeline:`r`n"
Get-Content "./test-data.md" | ConvertFrom-MdTable | Format-Table

# From Table --> To Table
Write-Output "`r`n`r`nTesting 'from table to table':`r`n"
Get-Content "./test-data.md" | ConvertFrom-MdTable | ConvertTo-MdTable

# To Table --> From Table
Write-Output "`r`n`r`nTesting 'to table from table':`r`n"
Get-Content "./test-data.json" | ConvertFrom-Json | ConvertTo-MdTable | ConvertFrom-MdTable | Format-Table