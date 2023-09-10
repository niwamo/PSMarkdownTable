function ConvertFrom-MdTable {
    param (
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true
        )]$InputObject
    )

    begin {
        # initialize empty generic list
        $all = @()
    }
  
    process {
        # add incoming pipeline object to list:
        foreach($input in $InputObject) {
            $all += $input
        }
    }

    end {
        # get fields from each row
        $rows = @()
        foreach ($row in $all -split "`n") {
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
            $rowOutput = New-Object -TypeName PSObject 
            foreach ($idx in 0..($rowArray.length - 1)) {
                Add-Member -InputObject $rowOutput -MemberType NoteProperty `
                    -Name $headers[$idx] -Value $rowArray[$idx].trim()
                #$rowOutput.add($headers[$idx], $rowArray[$idx].trim())
            }
            $output = $output + $rowOutput
        }

        return $output
    }
}

function ConvertTo-MdTable {
    param (
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true
        )]$InputObject
    )
    # TODO: Input Validation

    begin {
        $all = @()
    }

    process {
        foreach($input in $InputObject) {
            $all += $input
        }
    }

    end {
        # ensure we're handling PSObjects regardless of input type
        $all = $all | ForEach-Object {[PSCustomObject]$_}
        # need to calculate the width of the table to prevent PS from truncating values
        $props = ($all | Get-Member | Where MemberType -match "Property").name
        # account for the extra spaces and punctuation
        $length = 1 + 2*$props.length
        foreach ($prop in $props) {
            $fieldLen = 0
            foreach ($item in $all) {
                $fieldLen = [math]::Max($item.$prop.length, $fieldLen)
            }
            $length += $fieldLen
        }
        # leverage format-table to get us 90% of the way there
        $pTable = $all | Format-Table -Property * -Expand Both -AutoSize | Out-String -Width $length
        $rows = @($pTable.trim("`r`n") -split "`r`n|`n")
        $underlines = $rows[1]
        $columnIndices = (@(0, ($underlines.length)) + [regex]::Matches($underlines, '(?<=\s)\S').Index) | Sort-Object
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
}
