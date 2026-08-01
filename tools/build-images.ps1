<#
    build-images.ps1 - regenerate the site's raster assets.

    Run this after dropping a new photograph at assets/_src/headshot-original.jpg
    (that folder is gitignored; only the generated files in assets/img are
    committed). Everything here uses System.Drawing, which ships with Windows,
    so there is no ImageMagick, Node, or Python dependency.

    Building a fresh Bitmap also discards EXIF, GPS, XMP, ICC profiles, and any
    embedded thumbnails, so the outputs carry no metadata at all.

    NOTE: this file is deliberately pure ASCII. Windows PowerShell 5.1 reads
    .ps1 files as ANSI unless they carry a BOM, so a literal em dash or middle
    dot in the source becomes a parser error. Non-ASCII characters that need to
    appear in output are built with [char] instead.

    Usage:  powershell -ExecutionPolicy Bypass -File tools\build-images.ps1
#>

Add-Type -AssemblyName System.Drawing

$ErrorActionPreference = 'Stop'
$repo = Split-Path -Parent $PSScriptRoot
$img  = Join-Path $repo 'assets\img'
$src  = Join-Path $repo 'assets\_src\headshot-original.jpg'

New-Item -ItemType Directory -Force $img | Out-Null

$Garnet    = [System.Drawing.ColorTranslator]::FromHtml('#73000A')
$Sandstorm = [System.Drawing.ColorTranslator]::FromHtml('#FFFCF8')
$Ink       = [System.Drawing.ColorTranslator]::FromHtml('#14110E')
$Grey      = [System.Drawing.ColorTranslator]::FromHtml('#5C5C5C')
$MiddleDot = [string][char]0x00B7

function Get-JpegCodec {
    [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() |
        Where-Object { $_.MimeType -eq 'image/jpeg' }
}

function New-EncoderParams([int]$Quality) {
    $eps = New-Object System.Drawing.Imaging.EncoderParameters 1
    $eps.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter(
        [System.Drawing.Imaging.Encoder]::Quality, [int64]$Quality)
    $eps
}

function Set-Quality($Graphics) {
    $Graphics.CompositingQuality = 'HighQuality'
    $Graphics.InterpolationMode  = 'HighQualityBicubic'
    $Graphics.SmoothingMode      = 'HighQuality'
    $Graphics.PixelOffsetMode    = 'HighQuality'
    $Graphics.TextRenderingHint  = 'AntiAliasGridFit'
}

# ---------------------------------------------------------------------------
# 1. Headshot variants
# ---------------------------------------------------------------------------
if (Test-Path $src) {
    $codec = Get-JpegCodec
    $eps   = New-EncoderParams 82

    foreach ($w in 176, 352, 528) {
        $orig = [System.Drawing.Image]::FromFile($src)
        if ($orig.Width -lt $w) {
            Write-Host ("skip headshot-{0}.jpg: source is only {1}px wide" -f $w, $orig.Width)
            $orig.Dispose()
            continue
        }
        $h   = [int][Math]::Round($w * $orig.Height / $orig.Width)
        $bmp = New-Object System.Drawing.Bitmap $w, $h
        $bmp.SetResolution(72, 72)
        $g = [System.Drawing.Graphics]::FromImage($bmp)
        Set-Quality $g
        $g.DrawImage($orig, (New-Object System.Drawing.Rectangle 0, 0, $w, $h))
        $g.Dispose()
        $out = Join-Path $img ("headshot-{0}.jpg" -f $w)
        $bmp.Save($out, $codec, $eps)
        $bmp.Dispose()
        $orig.Dispose()
        Write-Host ("wrote headshot-{0}.jpg  {1}x{2}  {3:N0} bytes" -f $w, $w, $h, (Get-Item $out).Length)
    }
} else {
    Write-Host "No assets\_src\headshot-original.jpg found, skipping headshot variants."
    Write-Host "The site renders a monogram placeholder until that file exists."
}

# ---------------------------------------------------------------------------
# 2. Favicons: garnet field, Georgia 'H'
# ---------------------------------------------------------------------------
foreach ($spec in @(@{ n = 'favicon-32.png'; s = 32 }, @{ n = 'apple-touch-icon.png'; s = 180 })) {
    $s   = $spec.s
    $bmp = New-Object System.Drawing.Bitmap $s, $s
    $g   = [System.Drawing.Graphics]::FromImage($bmp)
    Set-Quality $g
    $g.Clear($Garnet)
    $font  = New-Object System.Drawing.Font('Georgia', ($s * 0.62), [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
    $fmt   = New-Object System.Drawing.StringFormat
    $fmt.Alignment     = 'Center'
    $fmt.LineAlignment = 'Center'
    $brush = New-Object System.Drawing.SolidBrush $Sandstorm
    $g.DrawString('H', $font, $brush, (New-Object System.Drawing.RectangleF 0, 0, $s, $s), $fmt)
    $brush.Dispose(); $font.Dispose(); $g.Dispose()
    $out = Join-Path $img $spec.n
    $bmp.Save($out, [System.Drawing.Imaging.ImageFormat]::Png)
    $bmp.Dispose()
    Write-Host ("wrote {0}  {1}x{1}" -f $spec.n, $s)
}

# ---------------------------------------------------------------------------
# 3. Open Graph card: 1200x630, the ratio Twitter and Facebook both accept
# ---------------------------------------------------------------------------
$W = 1200
$H = 630
$bmp = New-Object System.Drawing.Bitmap $W, $H
$g   = [System.Drawing.Graphics]::FromImage($bmp)
Set-Quality $g
$g.Clear($Sandstorm)

$garnetBrush = New-Object System.Drawing.SolidBrush $Garnet
$inkBrush    = New-Object System.Drawing.SolidBrush $Ink
$greyBrush   = New-Object System.Drawing.SolidBrush $Grey

# Garnet bar down the left edge.
$g.FillRectangle($garnetBrush, 0, 0, 24, $H)

$nameFont = New-Object System.Drawing.Font('Georgia', 76, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
$roleFont = New-Object System.Drawing.Font('Arial',   28, [System.Drawing.FontStyle]::Bold,    [System.Drawing.GraphicsUnit]::Pixel)
$subFont  = New-Object System.Drawing.Font('Arial',   28, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)

$g.DrawString('William R. Hauk, Jr.',              $nameFont, $inkBrush,    92, 196)
$g.DrawString('ASSOCIATE PROFESSOR OF ECONOMICS',  $roleFont, $garnetBrush, 98, 320)
$g.DrawString('Darla Moore School of Business',    $subFont,  $greyBrush,   98, 374)
$g.DrawString('University of South Carolina',      $subFont,  $greyBrush,   98, 412)

$interests = 'International trade  {0}  Economic growth  {0}  Political economics' -f $MiddleDot
$g.DrawString($interests, $subFont, $greyBrush, 98, 492)

$nameFont.Dispose(); $roleFont.Dispose(); $subFont.Dispose()
$garnetBrush.Dispose(); $inkBrush.Dispose(); $greyBrush.Dispose()
$g.Dispose()

$out = Join-Path $img 'og-card.png'
$bmp.Save($out, [System.Drawing.Imaging.ImageFormat]::Png)
$bmp.Dispose()
Write-Host ("wrote og-card.png  {0}x{1}  {2:N0} bytes" -f $W, $H, (Get-Item $out).Length)

Write-Host ""
Write-Host "Done."
