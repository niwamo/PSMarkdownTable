function ConvertFrom-MdTable {
    param (
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true
        )]$InputObject
    )

    # get fields from each row
    $rows = @()
    foreach ($row in $InputObject -split "\n") {
        $innerArray = @()
        $fields = $row.trim("|").split("|") | ForEach-Object {$_.trim()}
        foreach ($field in $fields) {
            $innerArray += $field
        }
        $rows += @(,$innerArray)
    }

    # make sure all rows have the same number of fields
    $uniformLength = $true
    $numUniqueLengths = ($rows | ForEach-Object {$_.length} | Select-Object -Unique | Measure-Object).count
    if ($numUniqueLengths -gt 1) {
        $uniformLength = $false
    }

    # make sure there's a 'separator' row between the table header and the rows
    $headerSeparator = $true
    $divider = [string]::Join('',$rows[1])
    if (($divider.toCharArray() | Get-Unique) -ne "-") {
        $headerSeparator = $false
    }

    # input validation
    if (!($uniformLength -and $headerSeparator)) {
        Write-Output "Invalid input object"
        return
    }

    # Process into array of hashtables
    $headers = $rows[0]
    $entries = $rows[2..($rows.length - 1)]
    $output = @()

    foreach ($row in $entries) {
        $rowArray = $row.trim("|").split("|")
        $rowOutput = @{}
        foreach ($idx in 0..($rowArray.length - 1)) {
            $rowOutput.add($headers[$idx], $rowArray[$idx].trim())
        }
        $output = $output + $rowOutput
    }

    return $output
}

function ConvertTo-MdTable {
    param (
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true
        )]$InputObject
    )
    # TODO: Input Validation
    $pTable = $InputObject | ForEach-Object {[PSCustomObject]$_} | Format-Table | Out-String
    $rows = @($pTable.trim("`r`n") -split "`r`n|`n")
    $headers = $rows[0]
    $columnIndices = (@(0, ($headers.length)) + [regex]::Matches($headers, '(?<=\s)\S').Index) | Sort-Object
    $numfields = $columnIndices.length - 1
    $outStrings = @()
    foreach ($idx in 0..($rows.length - 1)) {
        $row = $rows[$idx]
        $rowString = '|'
        foreach ($fieldIDX in 1..$numfields) {
            $start = $columnIndices[$fieldIDX-1]
            $end = $columnIndices[$fieldIDX]
            $length = $end - $start
            $rowString += ' '
            $rowString += $row.Substring($start, $length)
            $rowString += ' |'
        }
        if ($idx -eq 1) {
            $rowString = $rowString -replace " ","-"
        }
        $outStrings += $rowString
    }
    return $outStrings
}
