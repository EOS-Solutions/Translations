function Get-TranslationApiFile {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [string]$Revision
    )

    if ($Path -notmatch '\.xlf$' -or $Path -match '\.g\.xlf$') {
        return
    }

    $languages = @{
        'it-IT' = @('it-IT', 0)
        'de-DE' = @('de-DE', 0)
        'fr-FR' = @('fr-FR', 0)
        'es-ES' = @('es-ES', 0)
        'es' = @('es-ES', 1)
        'es-ES_tradnl' = @('es-ES', 2)
        'en-EN' = @('en-EN', 0)
        'en-US' = @('en-EN', 1)
        'en-GB' = @('en-EN', 2)
    }

    $fullPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Path)
    $reader = $null
    try {
        if ($Revision) {
            $previousEncoding = [Console]::OutputEncoding
            try {
                [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
                $content = git show "${Revision}:$($Path.Replace('\', '/'))"
                if ($LASTEXITCODE -ne 0) {
                    throw "Cannot read '$Path' at revision '$Revision'."
                }
            }
            finally {
                [Console]::OutputEncoding = $previousEncoding
            }
            $content = ($content -join "`n").TrimStart([char]0xFEFF)
            $reader = [System.Xml.XmlReader]::Create([System.IO.StringReader]::new($content))
        }
        else {
            $reader = [System.Xml.XmlReader]::Create($fullPath)
        }

        while ($reader.Read()) {
            if ($reader.NodeType -ne [System.Xml.XmlNodeType]::Element -or
                $reader.LocalName -ne 'file' -or
                $reader.NamespaceURI -ne 'urn:oasis:names:tc:xliff:document:1.2') {
                continue
            }

            $targetLanguage = $reader.GetAttribute('target-language')
            if (-not $targetLanguage -or -not $languages.ContainsKey($targetLanguage)) {
                return
            }

            $language = $languages[$targetLanguage]
            $fileName = [System.IO.Path]::GetFileNameWithoutExtension($fullPath)
            $applicationName = $fileName -replace '\.[a-zA-Z]{2,3}(?:[-_][a-zA-Z0-9]+)*$', ''
            $directory = [System.IO.Path]::GetDirectoryName($fullPath)

            return [PSCustomObject]@{
                Path = $fullPath
                FileName = $fileName
                Directory = $directory
                Language = $language[0]
                Priority = $language[1]
                GroupKey = "$directory|$applicationName|$($language[0])"
            }
        }

        throw "No XLIFF 1.2 file element found in '$Path'."
    }
    finally {
        if ($reader) {
            $reader.Dispose()
        }
    }
}

function Select-TranslationApiFiles {
    param(
        [AllowEmptyCollection()]
        [array]$Files
    )

    $Files | Group-Object GroupKey | ForEach-Object {
        $_.Group | Sort-Object Priority, Path | Select-Object -First 1
    }
}

function Get-TranslationApiPlan {
    param(
        [string]$BaseRevision = 'dbversion'
    )

    $changes = git -c core.quotepath=false diff --name-status --no-renames $BaseRevision HEAD -- '*.xlf'
    if ($LASTEXITCODE -ne 0) {
        throw "Cannot compare '$BaseRevision' with HEAD."
    }

    $affectedFiles = @(
        foreach ($change in $changes) {
            $status, $path = $change -split "`t", 2
            if ($status -ne 'D') {
                Get-TranslationApiFile -Path $path
            }
            if ($status -ne 'A') {
                Get-TranslationApiFile -Path $path -Revision $BaseRevision
            }
        }
    )

    $affectedGroups = @{}
    foreach ($file in $affectedFiles) {
        $affectedGroups[$file.GroupKey] = $true
    }

    $candidates = @(
        foreach ($directory in ($affectedFiles.Directory | Sort-Object -Unique)) {
            if (-not (Test-Path -LiteralPath $directory -PathType Container)) {
                continue
            }
            foreach ($file in (Get-ChildItem -LiteralPath $directory -Filter '*.xlf' -File)) {
                $candidate = Get-TranslationApiFile -Path $file.FullName
                if ($candidate -and $affectedGroups.ContainsKey($candidate.GroupKey)) {
                    $candidate
                }
            }
        }
    )

    [PSCustomObject]@{
        FilesToDelete = @(@($affectedFiles.FileName) + @($candidates.FileName) | Where-Object { $_ } | Sort-Object -Unique)
        FilesToUpload = @(Select-TranslationApiFiles -Files $candidates)
    }
}