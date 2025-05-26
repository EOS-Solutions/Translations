param(
    [Parameter(Mandatory=$true)]
    $xlfFiles,
    [Parameter(Mandatory=$false)]
    [int]$maxConcurrentSends = 50
)


# Function to send translations
function Send-Translations {
    param(
        [array]$translations
    )
    
    $body = $translations | ConvertTo-Json
    try {
        #$apiUrl = "$($env:APIURL)/newTranslation"
        $apiUrl = "https://gordon-translationapi-hmg8cpctcjaxa5g0.italynorth-01.azurewebsites.net/newTranslation"

        Invoke-RestMethod -Uri $apiUrl `
                                    -Method Post `
                                      -Body $body `
                                      -ContentType "application/json" `
                                      -SkipCertificateCheck
    }
    catch {
        Write-Error "Error processing batch of translations"
        Write-Error $_.Exception.Message
        #$_ | Out-File -FilePath "C:/Dati/_Git_LabsTools/GordonLoadTranslationScript/ErrorLog.txt" -Append
    }
}

$executionTime = Measure-Command {

foreach ($file in $xlfFiles) {
    $fileObj = Get-Item $file
    Write-Host "Processing file: $($fileObj.FullName)"
    
    switch ($fileObj.Name) {
        "*MODUS*" { 
            $source = "MODUS" 
        }
        default { 
            $source = "EOS" 
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
        
        # Process each trans-unit using proper namespace
        $transUnits = $xmlContent.SelectNodes("//x:trans-unit", $nsManager)
        
        Write-Host "Found $($transUnits.Count) translation units"

        $translations = @()
        foreach ($transUnit in $transUnits) {
            $transId = $transUnit.GetAttribute("id")
            
            # Get text from target if it exists, otherwise from source
            $text = if ($transUnit.SelectSingleNode("x:target", $nsManager)) { 
                $transUnit.SelectSingleNode("x:target", $nsManager).InnerText 
            } else { 
                $transUnit.SelectSingleNode("x:source", $nsManager).InnerText 
            }

            $translations += @{
                transID = $transId
                language = $targetLanguage
                text = $text
                source = $source
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
        Write-Error "Error processing file: $($fileObj.FullName)"
        Write-Error $_.Exception.Message
    }
}
}

Write-Host "Total execution time: $($executionTime.TotalSeconds) seconds"