$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$projectRoot = Split-Path -Parent $PSScriptRoot
$assetRoot = Join-Path $projectRoot 'maring-frontend\assets\maring\growth'
$outputPath = Join-Path $projectRoot 'docs\maring-growth-contact-sheet.png'
$stages = @(
    @{ File = 'stage-1-seed.png'; Name = 'SEED'; Color = [Drawing.Color]::FromArgb(236, 232, 255) },
    @{ File = 'stage-2-sprout.png'; Name = 'SPROUT'; Color = [Drawing.Color]::FromArgb(255, 225, 240) },
    @{ File = 'stage-3-bloom.png'; Name = 'BLOOM'; Color = [Drawing.Color]::FromArgb(227, 216, 255) },
    @{ File = 'stage-4-companion.png'; Name = 'COMPANION'; Color = [Drawing.Color]::FromArgb(213, 200, 255) },
    @{ File = 'stage-5-guardian.png'; Name = 'GUARDIAN'; Color = [Drawing.Color]::FromArgb(255, 220, 168) }
)

$sheet = [Drawing.Bitmap]::new(1800, 640, [Drawing.Imaging.PixelFormat]::Format24bppRgb)
try {
    $graphics = [Drawing.Graphics]::FromImage($sheet)
    try {
        $graphics.Clear([Drawing.Color]::FromArgb(250, 248, 255))
        $graphics.InterpolationMode = [Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $graphics.SmoothingMode = [Drawing.Drawing2D.SmoothingMode]::AntiAlias
        $titleFont = [Drawing.Font]::new('Segoe UI', 19, [Drawing.FontStyle]::Bold)
        $stageFont = [Drawing.Font]::new('Segoe UI', 13, [Drawing.FontStyle]::Regular)
        $titleBrush = [Drawing.SolidBrush]::new([Drawing.Color]::FromArgb(65, 49, 108))
        $stageBrush = [Drawing.SolidBrush]::new([Drawing.Color]::FromArgb(120, 102, 150))
        $cardBrush = [Drawing.SolidBrush]::new([Drawing.Color]::White)
        $border = [Drawing.Pen]::new([Drawing.Color]::FromArgb(228, 220, 244), 2)
        try {
            for ($i = 0; $i -lt $stages.Count; $i++) {
                $x = $i * 360
                $graphics.FillRectangle($cardBrush, $x + 10, 10, 340, 620)
                $graphics.DrawRectangle($border, $x + 10, 10, 340, 620)
                $graphics.DrawString("STAGE $($i + 1)", $stageFont, $stageBrush, $x + 28, 28)
                $graphics.DrawString($stages[$i].Name, $titleFont, $titleBrush, $x + 28, 56)

                $image = [Drawing.Image]::FromFile((Join-Path $assetRoot $stages[$i].File))
                try {
                    $graphics.DrawImage($image, $x + 30, 105, 300, 300)
                } finally {
                    $image.Dispose()
                }

                $swatch = [Drawing.SolidBrush]::new($stages[$i].Color)
                try {
                    $graphics.FillEllipse($swatch, $x + 145, 465, 70, 70)
                } finally {
                    $swatch.Dispose()
                }
                $graphics.DrawEllipse($border, $x + 145, 465, 70, 70)
            }
        } finally {
            $border.Dispose()
            $cardBrush.Dispose()
            $stageBrush.Dispose()
            $titleBrush.Dispose()
            $stageFont.Dispose()
            $titleFont.Dispose()
        }
    } finally {
        $graphics.Dispose()
    }
    $sheet.Save($outputPath, [Drawing.Imaging.ImageFormat]::Png)
} finally {
    $sheet.Dispose()
}

Write-Output $outputPath
