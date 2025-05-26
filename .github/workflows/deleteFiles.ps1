function CallAPIFileName {
    param(
        [Parameter(Mandatory=$true)]
        [string]$FileName
    )
    
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Content-Type", "application/json")

    $body = "{`"FileName`": `"$FileName`"}"
    
    $apiUrl = "$($env:APIURL)/deleteFile"

    $response = Invoke-RestMethod $apiUrl -Method 'POST' -Headers $headers -Body $body
    $response | ConvertTo-Json
}

# Execute git command to get the list of changed files
$gitDiffOutput = git --no-pager diff --name-only dbversion HEAD

# Check if git command was successful
if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed to execute git diff command. Make sure you're in a git repository."
    return
}

# Array to store just the filenames (without paths)
$fileNames = @()

# Process each line of git diff output
foreach ($line in $gitDiffOutput) {
    if ($line.Trim() -ne "") {
        # Extract just the filename part from the path
        $fileName = Split-Path -Path $line -Leaf

        # Filter to include only .xlf files
        if ($fileName -like "*.xlf") {
            $fileNames += $fileName
        }
    }
}

# Output the processed filenames
Write-Output "Extracted filenames:"
$fileNames | ForEach-Object { Write-Output "- $_" }

# Call your function for each filename
foreach ($fileName in $fileNames) {
    CallAPIFileName -FileName $fileName
    Write-Output "Translations removed for file: $fileName"
}