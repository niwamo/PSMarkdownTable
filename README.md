# PSMarkdownTable

## Purpose

Simple utility module for: 
1. converting Markdown tables (input as a string or array of strings) to PowerShell objects
2. converting PowerShell objects into Markdown tables

Inspired by PowerShell's native `ConvertFrom-Json` and `ConvertTo-Json` functions.

## Testing

To test module functionality, pull down the repo and run `./Test-Module.ps1` from the repo
directory. It will convert the data in test-data.json into a Markdown table (output as a string),
then convert the data in test-data.md into PowerShell objects (and pretty print them as a table).

## Potential Improvements

 - Input Validation (partially implemented on `ConvertFrom-MdTable`)