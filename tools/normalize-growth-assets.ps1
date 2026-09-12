param(
    [int]$CanvasSize = 1024,
    [byte]$AlphaThreshold = 8
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$projectRoot = Split-Path -Parent $PSScriptRoot
$sourceRoot = [IO.Path]::GetFullPath((Join-Path $projectRoot 'maring_img\growth'))
$outputRoot = [IO.Path]::GetFullPath((Join-Path $projectRoot 'maring-frontend\assets\maring\growth'))
$sourceRelative = [IO.Path]::GetRelativePath($projectRoot, $sourceRoot).Replace('/', '\')
$outputRelative = [IO.Path]::GetRelativePath($projectRoot, $outputRoot).Replace('/', '\')
if ($sourceRelative -ne 'maring_img\growth' -or
    $outputRelative -ne 'maring-frontend\assets\maring\growth') {
    throw "Unexpected growth asset paths: $sourceRoot -> $outputRoot"
}

$stages = @(
    @{ Source = 'stage-1-seed-master.png'; Output = 'stage-1-seed.png'; Extent = 380 },
    @{ Source = 'stage-2-sprout-master.png'; Output = 'stage-2-sprout.png'; Extent = 510 },
    @{ Source = 'stage-3-bloom-master.png'; Output = 'stage-3-bloom.png'; Extent = 640 },
    @{ Source = 'stage-4-companion-master.png'; Output = 'stage-4-companion.png'; Extent = 770 },
    @{ Source = 'stage-5-guardian-master.png'; Output = 'stage-5-guardian.png'; Extent = 900 }
)

function Get-AlphaBounds([Drawing.Bitmap]$bitmap) {
    $rect = [Drawing.Rectangle]::new(0, 0, $bitmap.Width, $bitmap.Height)
    $data = $bitmap.LockBits(
        $rect,
        [Drawing.Imaging.ImageLockMode]::ReadOnly,
        [Drawing.Imaging.PixelFormat]::Format32bppArgb
    )
    try {
        $stride = [Math]::Abs($data.Stride)
        $bytes = [byte[]]::new($stride * $bitmap.Height)
        [Runtime.InteropServices.Marshal]::Copy($data.Scan0, $bytes, 0, $bytes.Length)
        $minX = $bitmap.Width
        $minY = $bitmap.Height
        $maxX = -1
        $maxY = -1
        for ($y = 0; $y -lt $bitmap.Height; $y++) {
            $row = $y * $stride
            for ($x = 0; $x -lt $bitmap.Width; $x++) {
                if ($bytes[$row + $x * 4 + 3] -gt $AlphaThreshold) {
                    if ($x -lt $minX) { $minX = $x }
                    if ($x -gt $maxX) { $maxX = $x }
                    if ($y -lt $minY) { $minY = $y }
                    if ($y -gt $maxY) { $maxY = $y }
                }
            }
        }
        if ($maxX -lt $minX -or $maxY -lt $minY) {
            throw 'Image has no visible pixels.'
        }
        return [Drawing.Rectangle]::FromLTRB($minX, $minY, $maxX + 1, $maxY + 1)
    } finally {
        $bitmap.UnlockBits($data)
    }
}

New-Item -ItemType Directory -Path $outputRoot -Force | Out-Null
$results = foreach ($stage in $stages) {
    $sourcePath = Join-Path $sourceRoot $stage.Source
    $outputPath = Join-Path $outputRoot $stage.Output
    $source = [Drawing.Bitmap]::new($sourcePath)
    try {
        $bounds = Get-AlphaBounds $source
        $scale = [Math]::Min($stage.Extent / $bounds.Width, $stage.Extent / $bounds.Height)
        $width = [Math]::Max(1, [int][Math]::Round($bounds.Width * $scale))
        $height = [Math]::Max(1, [int][Math]::Round($bounds.Height * $scale))
        $left = [int][Math]::Round(($CanvasSize - $width) / 2)
        $top = [int][Math]::Round(($CanvasSize - $height) / 2)

        $output = [Drawing.Bitmap]::new(
            $CanvasSize,
            $CanvasSize,
            [Drawing.Imaging.PixelFormat]::Format32bppArgb
        )
        try {
            $graphics = [Drawing.Graphics]::FromImage($output)
            try {
                $graphics.Clear([Drawing.Color]::Transparent)
                $graphics.CompositingMode = [Drawing.Drawing2D.CompositingMode]::SourceCopy
                $graphics.CompositingQuality = [Drawing.Drawing2D.CompositingQuality]::HighQuality
                $graphics.InterpolationMode = [Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
                $graphics.PixelOffsetMode = [Drawing.Drawing2D.PixelOffsetMode]::HighQuality
                $graphics.DrawImage(
                    $source,
                    [Drawing.Rectangle]::new($left, $top, $width, $height),
                    $bounds,
                    [Drawing.GraphicsUnit]::Pixel
                )
            } finally {
                $graphics.Dispose()
            }
            $output.Save($outputPath, [Drawing.Imaging.ImageFormat]::Png)
        } finally {
            $output.Dispose()
        }
    } finally {
        $source.Dispose()
    }

    $verified = [Drawing.Bitmap]::new($outputPath)
    try {
        $visible = Get-AlphaBounds $verified
        if ($verified.Width -ne $CanvasSize -or
            $verified.Height -ne $CanvasSize -or
            $verified.GetPixel(0, 0).A -ne 0) {
            throw "Growth image verification failed: $outputPath"
        }
        [pscustomobject]@{
            Name = $stage.Output
            Canvas = "$CanvasSize x $CanvasSize"
            Visible = "$($visible.Width) x $($visible.Height)"
            Bytes = (Get-Item -LiteralPath $outputPath).Length
        }
    } finally {
        $verified.Dispose()
    }
}

$results | Format-Table -AutoSize
