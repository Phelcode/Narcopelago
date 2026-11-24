#Requires -Version 5.1
<#
.SYNOPSIS
    Builds schedule_I.apworld from worlds\Schedule_I in this repository.

.DESCRIPTION
    A .apworld is a zip of the world folder. The Archipelago launcher validates it before
    installing (worlds/LauncherComponents.py in ArchipelagoMW/Archipelago): the zip root must
    contain exactly one directory, that directory's name must appear in the file name
    (case-sensitive), entry paths must use forward slashes, and schedule_I/__init__.py must
    exist. Hence the output file is named schedule_I.apworld and the root folder inside the
    zip is schedule_I (first letter lowercased from Schedule_I).

    Can be run from any directory; the repo root is taken from this script's location.
    Output: schedule_I.apworld next to this script. Install it with the AP launcher's
    "Install APWorld" button (or drop it into the custom_worlds folder), or attach it to
    a GitHub release as schedule_I.apworld.

.NOTES
    Do not build this with Compress-Archive -Path worlds\Schedule_I\* : the \* flattens the
    root folder, and some zip tools write \ path separators. Both fail the launcher check.
#>
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.IO.Compression.FileSystem

$repoRoot = $PSScriptRoot
$src = Join-Path $repoRoot 'worlds\Schedule_I'
$out = Join-Path $repoRoot 'schedule_I.apworld'
if (Test-Path $out) { Remove-Item $out -Force }

$zip = [System.IO.Compression.ZipFile]::Open($out, [System.IO.Compression.ZipArchiveMode]::Create)
try {
    $prefix = $src.Length + 1
    Get-ChildItem -Path $src -Recurse -File -Force | ForEach-Object {
        if ($_.FullName -match '__pycache__') { return }
        if ($_.Extension -in '.pyc', '.pyd', '.so', '.dll') { return }
        $entryName = 'schedule_I/' + $_.FullName.Substring($prefix).Replace('\', '/')
        $entry = $zip.CreateEntry($entryName, [System.IO.Compression.CompressionLevel]::Optimal)
        $stream = $entry.Open()
        try {
            $file = [System.IO.File]::OpenRead($_.FullName)
            try { $file.CopyTo($stream) } finally { $file.Dispose() }
        } finally { $stream.Dispose() }
    }
} finally {
    $zip.Dispose()
}

Write-Host "Built $out"

# Optional sanity check mirroring the launcher's validation (python ships with Archipelago).
$py = Get-Command python -ErrorAction SilentlyContinue
if ($py) {
    Push-Location $repoRoot
    try {
        & python -c "import zipfile,pathlib; p='schedule_I.apworld'; z=zipfile.ZipFile(p); d=[f.name for f in zipfile.Path(z).iterdir() if f.is_dir()]; s=pathlib.Path(p).stem; assert len(d)==1 and d[0] in s, d; z.open(d[0]+'/__init__.py'); print('OK:', s, d)"
    } finally {
        Pop-Location
    }
}
