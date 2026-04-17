param(
    [Parameter(Mandatory = $true)]
    $xlfFiles,
    [Parameter(Mandatory = $false)]
    [int]$maxConcurrentSends = 50
)


# Function to send translations
function Send-Translations {
    param(
        [array]$translations
    )
    
    $body = $translations | ConvertTo-Json -AsArray
    try {
        $apiUrl = "$($env:APIURL)/newTranslation"

        $headers = @{
            "x-api-key" = $($env:APIKEY)
        }

        Invoke-RestMethod   -Uri $apiUrl `
            -Method Post `
            -Body $body `
            -Headers $headers `
            -ContentType "application/json" `
            -SkipCertificateCheck
    }
    catch {
        Write-Error "Error occurred while calling API for file '$FileName' at URL '$apiUrl': $($_.Exception.Message)"
    }
}

$executionTime = Measure-Command {

    foreach ($file in $xlfFiles) {
        $fileObj = Get-Item $file
        Write-Host "Processing file: $($fileObj.FullName)"
    
        # Check for config.json in the file's directory
        $source = $null
        $configPath = Join-Path $fileObj.DirectoryName "config.json"
        if (Test-Path $configPath) {
            try {
                $config = Get-Content $configPath -Raw | ConvertFrom-Json
                if ($config.source) {
                    $source = $config.source
                }
            }
            catch {
                Write-Warning "Error reading config.json in $($fileObj.DirectoryName): $($_.Exception.Message)"
            }
        }

        # Fallback to name-based source detection if config.json didn't provide a source
        if (-not $source) {
            switch ($fileObj.Name) {
                "*MODUS*" { 
                    $source = "MODUS" 
                }
                default { 
                    $source = "EOS" 
                }
            }
        }
        try {
            # Load XML content
            [xml]$xmlContent = Get-Content $fileObj.FullName

            # Create namespace manager
            $nsManager = New-Object System.Xml.XmlNamespaceManager($xmlContent.NameTable)
            $nsManager.AddNamespace("x", "urn:oasis:names:tc:xliff:document:1.2")
        
            # Get target language from the file element
            $targetLanguage = $xmlContent.xliff.file.GetAttribute("target-language")
            $targetLanguage = ($targetLanguage -split '-')[0]
        
            # Process each trans-unit using proper namespace
            $transUnits = $xmlContent.SelectNodes("//x:trans-unit", $nsManager)
        
            Write-Host "Found $($transUnits.Count) translation units"

            $translations = @()
            foreach ($transUnit in $transUnits) {
                $transId = $transUnit.GetAttribute("id")
            
                # Get text from target if it exists, otherwise from source
                $text = if ($transUnit.SelectSingleNode("x:target", $nsManager)) { 
                    $transUnit.SelectSingleNode("x:target", $nsManager).InnerText 
                }
                else { 
                    $transUnit.SelectSingleNode("x:source", $nsManager).InnerText 
                }

                $translations += @{
                    transID  = $transId
                    language = $targetLanguage
                    text     = $text
                    source   = $source
                    filename = $fileObj.BaseName
                }
            
                # Send translations in batches
                if ($translations.Count -ge $maxConcurrentSends) {                
                    Send-Translations -translations $translations
                    $translations = @() # Clear the array for the next batch
                }
            }
            # Send any remaining translations
            if ($translations.Count -gt 0) {
                Send-Translations -translations $translations
            }
        }
        catch {
            Write-Error "Error processing file: $($fileObj.FullName): $($_.Exception.Message)"
            Write-Error $_.Exception.Message
        }
    }
}

Write-Host "Total execution time: $($executionTime.TotalSeconds) seconds"
