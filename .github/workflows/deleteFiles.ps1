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

    $FileName = $FileName -replace '\.xlf$', ''
    if ([string]::IsNullOrWhiteSpace($FileName) -or
        $FileName -in @('.', '..') -or
        $FileName -match '[\\/:*?"<>|\r\n]' -or
        [System.IO.Path]::GetFileName($FileName) -ne $FileName) {
        throw "FileName must be a single database filename without a directory path (.xlf is optional)."
    }

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
    CallAPIFileName -FileName $FileName -ThrowOnError
    Write-Output "Translations removed for file: $FileName"
    return
}

. "$PSScriptRoot/TranslationSelection.ps1"

$plan = Get-TranslationApiPlan
$fileNames = $plan.FilesToDelete

# Output the processed filenames
Write-Output "Extracted filenames:"
$fileNames | ForEach-Object { Write-Output "- $_" }

# Call your function for each filename
foreach ($fileName in $fileNames) {
    CallAPIFileName -FileName $fileName -ThrowOnError
    Write-Output "Translations removed for file: $fileName"
}