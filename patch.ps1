Add-Type -AssemblyName System.Windows.Forms

$expectedSubPath = "portable_config\webmods\Theme"

# --- Ask user to select Stremio Kai folder ---
Write-Host "Select your Stremio Kai folder:"
$folderDialog = New-Object System.Windows.Forms.FolderBrowserDialog
$folderDialog.Description = "Select your Stremio Kai folder"

if ($folderDialog.ShowDialog() -ne "OK") {
    Write-Host "ERROR: No folder selected." -ForegroundColor Red
    exit
}

$rootDir = $folderDialog.SelectedPath
$themeDir = Join-Path $rootDir $expectedSubPath
$mainCss = Join-Path $themeDir "Main.css"
$fixCssSrc = "THEME-FIX.css"
$fixCssDst = Join-Path $themeDir $fixCssSrc
$mpvConf = Join-Path $rootDir "portable_config\mpv.conf"
$importLine = "@import url('$fixCssSrc');"

Write-Host "Selected folder:" -ForegroundColor Cyan
Write-Host ">" $rootDir
Write-Host ""

# --- Validate Theme directory ---
if (-not (Test-Path $themeDir)) {
    Write-Host "ERROR: Invalid Stremio Kai folder selected." -ForegroundColor Red
    exit
}

# =========================
# THEME PATCH
# =========================

# --- Resolve source CSS file path ---
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$fixCssSrcFull = Join-Path $scriptDir $fixCssSrc
$fixCssDstFull = $fixCssDst

if (-not (Test-Path $fixCssSrcFull)) {
    Write-Host "ERROR: Source $fixCssSrc not found at $fixCssSrcFull" -ForegroundColor Red
    exit
}

# --- Check/update CSS file using LastWriteTime ---
$copyNeeded = $true
if (Test-Path $fixCssDstFull) {
    $srcInfo = Get-Item $fixCssSrcFull
    $dstInfo = Get-Item $fixCssDstFull

    # Remove read-only attribute if set
    if ($dstInfo.Attributes -band [System.IO.FileAttributes]::ReadOnly) {
        $dstInfo.Attributes = 'Normal'
    }

    # Copy only if source is newer
    if ($srcInfo.LastWriteTime -le $dstInfo.LastWriteTime) {
        $copyNeeded = $false
    }
}

if ($copyNeeded) {
    Copy-Item $fixCssSrcFull $fixCssDstFull -Force
    Write-Host "Updated $fixCssSrc" -ForegroundColor Green
}
else {
    Write-Host "$fixCssSrc is up to date." -ForegroundColor Yellow
}

# --- Check/insert import in Main.css ---
$lines = Get-Content $mainCss
$importExists = $lines -match [regex]::Escape($importLine)

if (-not $importExists) {
    $output = @()
    $inserted = $false
    foreach ($line in $lines) {
        $output += $line
        if (-not $inserted -and $line -match '^\s*@import') {
            $output += $importLine
            $inserted = $true
        }
    }
    Set-Content $mainCss $output -Encoding UTF8
    Write-Host "Imported $fixCssSrc." -ForegroundColor Green
}
else {
    Write-Host "$fixCssSrc is already imported." -ForegroundColor Yellow
}

# =========================
# MPV CONF PATCH
# =========================

if (-not (Test-Path $mpvConf)) {
    Write-Host "ERROR: mpv.conf not found." -ForegroundColor Red
    exit
}

$mpvLines = Get-Content $mpvConf -Raw

$subsReplacement = @"
sub-font='Arial'
sub-font-size=1
sub-ass-override=no
sub-shadow-offset=2.0
sub-blur=0.5
sub-scale-by-window=no
sub-outline-size=5
"@

# Replace ONLY content between header and next #####
$pattern = "(########\r?\n# Subs #\r?\n########\r?\n)([\s\S]*?)(?=\r?\n#+)"

# Idempotency check
if ($mpvLines -match "sub-font='Arial'") {
    Write-Host "mpv.conf is already patched." -ForegroundColor Yellow
}
elseif ($mpvLines -match $pattern) {
    $mpvLines = [regex]::Replace(
        $mpvLines,
        $pattern,
        "`$1`n$subsReplacement"
    )

    Set-Content $mpvConf $mpvLines -Encoding UTF8
    Write-Host "Updated mpv.conf subtitle settings." -ForegroundColor Green
}
else {
    Write-Host "WARNING: Subs section not found or format unexpected." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "All patches applied successfully." -ForegroundColor Green
