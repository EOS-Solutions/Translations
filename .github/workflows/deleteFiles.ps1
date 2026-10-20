param(
    [Parameter(Mandatory=$false)]
    [string]$FileName
)

function CallAPIFileName {
    param(
        [Parameter(Mandatory=$true)]
        [string]$FileName,
        [switch]$ThrowOnError
    )

    $body = @{ FileName = $FileName } | ConvertTo-Json -Compress
    $apiUrl = "$($env:APIURL)/deleteFile"
    $headers = @{
        "x-api-key" = $($env:APIKEY)
    }

    try {
        Invoke-RestMethod   -Uri $apiUrl `
                            -Method Post `
                            -Body $body `
                            -Headers $headers `
                            -ContentType "application/json" `
                            -SkipCertificateCheck
    }
    catch {
        $errorMessage = "Error occurred while calling API for file '$FileName' at URL '$apiUrl': $($_.Exception.Message)"
        if ($ThrowOnError) {
            throw $errorMessage
        }
        Write-Error $errorMessage
    }
}

if ($PSBoundParameters.ContainsKey('FileName')) {
    if ([string]::IsNullOrWhiteSpace($FileName) -or
        $FileName -match '[\\/:*?"<>|\r\n]' -or
        [System.IO.Path]::GetFileName($FileName) -ne $FileName -or
        $FileName -notmatch '\.xlf$') {
        throw "FileName must be a single XLIFF filename without a directory path."
    }

    CallAPIFileName -FileName $FileName -ThrowOnError
    Write-Output "Translations removed for file: $FileName"
    return
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

        # Include translated XLF files for any culture, excluding generic source files.
        if ($fileName -match '\.xlf$' -and $fileName -notmatch '\.g\.xlf$') {
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