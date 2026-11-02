. "$PSScriptRoot/TranslationSelection.ps1"

$plan = Get-TranslationApiPlan
$fileNames = @($plan.FilesToUpload | ForEach-Object Path)

# Output the processed filenames
Write-Output "Extracted filenames:"
$fileNames | ForEach-Object { Write-Output "- $_" }

$maxConcurrentSends = 300

# Call your function for each filename
if ($fileNames.Count -gt 0) {
    & "$PSScriptRoot/LoadTranslationScript.ps1" -xlfFiles $fileNames -maxConcurrentSends $maxConcurrentSends
}