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
foreach ($path in $gitDiffOutput) {
    if ($path.Trim() -ne "") {
        # Extract just the filename part from the path
        #$fileName = Split-Path -Path $line -Leaf

        # Filter to include only .xlf files
        if ($path -like "*.xlf") {
            if (Test-Path -Path $path) {              
                $fileNames += $path
            }
        }
    }
}

# Output the processed filenames
Write-Output "Extracted filenames:"
$fileNames | ForEach-Object { Write-Output "- $_" }

$maxConcurrentSends = 300

# Call your function for each filename
./.github/workflows/LoadTranslationScript.ps1 -xlfFiles $fileNames -maxConcurrentSends $maxConcurrentSends