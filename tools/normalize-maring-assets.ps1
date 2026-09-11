param(
    [int]$CanvasSize = 1024,
    [int]$CharacterExtent = 900,
    [byte]$AlphaThreshold = 8
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$projectRoot = Split-Path -Parent $PSScriptRoot
$assetRoot = [System.IO.Path]::GetFullPath((Join-Path $projectRoot 'maring-frontend\assets\maring'))
$relativeAssetRoot = [System.IO.Path]::GetRelativePath($projectRoot, $assetRoot).Replace('/', '\')
if ($relativeAssetRoot -ne 'maring-frontend\assets\maring') {
    throw "Unexpected asset root: $assetRoot"
}

function Get-AlphaBounds([System.Drawing.Bitmap]$bitmap) {
    $rect = [System.Drawing.Rectangle]::new(0, 0, $bitmap.Width, $bitmap.Height)
    $data = $bitmap.LockBits($rect, [System.Drawing.Imaging.ImageLockMode]::ReadOnly,
        [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    try {
        $bytes = [byte[]]::new([Math]::Abs($data.Stride) * $bitmap.Height)
        [Runtime.InteropServices.Marshal]::Copy($data.Scan0, $bytes, 0, $bytes.Length)
        $minX = $bitmap.Width; $minY = $bitmap.Height; $maxX = -1; $maxY = -1
        for ($y = 0; $y -lt $bitmap.Height; $y++) {
            $row = $y * [Math]::Abs($data.Stride)
            for ($x = 0; $x -lt $bitmap.Width; $x++) {
                if ($bytes[$row + $x * 4 + 3] -gt $AlphaThreshold) {
                    if ($x -lt $minX) { $minX = $x }
                    if ($x -gt $maxX) { $maxX = $x }
                    if ($y -lt $minY) { $minY = $y }
                    if ($y -gt $maxY) { $maxY = $y }
                }
            }
        }
        if ($maxX -lt $minX -or $maxY -lt $minY) { throw 'Image has no visible pixels.' }
        return [System.Drawing.Rectangle]::FromLTRB($minX, $minY, $maxX + 1, $maxY + 1)
    } finally {
        $bitmap.UnlockBits($data)
    }
}

$results = foreach ($file in Get-ChildItem -LiteralPath $assetRoot -Filter '*.png' -File | Sort-Object Name) {
    $source = [System.Drawing.Bitmap]::new($file.FullName)
    try {
        $bounds = Get-AlphaBounds $source
        $scale = [Math]::Min($CharacterExtent / $bounds.Width, $CharacterExtent / $bounds.Height)
        $width = [Math]::Max(1, [int][Math]::Round($bounds.Width * $scale))
        $height = [Math]::Max(1, [int][Math]::Round($bounds.Height * $scale))
        $left = [int][Math]::Round(($CanvasSize - $width) / 2)
        $top = [int][Math]::Round(($CanvasSize - $height) / 2)

        $output = [System.Drawing.Bitmap]::new($CanvasSize, $CanvasSize,
            [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
        try {
            $graphics = [System.Drawing.Graphics]::FromImage($output)
            try {
                $graphics.Clear([System.Drawing.Color]::Transparent)
                $graphics.CompositingMode = [System.Drawing.Drawing2D.CompositingMode]::SourceCopy
                $graphics.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
                $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
                $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
                $graphics.DrawImage($source,
                    [System.Drawing.Rectangle]::new($left, $top, $width, $height),
                    $bounds, [System.Drawing.GraphicsUnit]::Pixel)
            } finally {
                $graphics.Dispose()
            }
            $temporary = "$($file.FullName).normalized.png"
            $output.Save($temporary, [System.Drawing.Imaging.ImageFormat]::Png)
        } finally {
            $output.Dispose()
        }
    } finally {
        $source.Dispose()
    }

    $verified = [System.Drawing.Bitmap]::new($temporary)
    try {
        if ($verified.Width -ne $CanvasSize -or $verified.Height -ne $CanvasSize -or
            $verified.GetPixel(0, 0).A -ne 0) {
            throw "Normalized image verification failed: $temporary"
        }
    } finally {
        $verified.Dispose()
    }
    Move-Item -LiteralPath $temporary -Destination $file.FullName -Force
    [pscustomobject]@{ Name = $file.Name; Width = $CanvasSize; Height = $CanvasSize; Bytes = $file.Length }
}

$results | Format-Table -AutoSize
