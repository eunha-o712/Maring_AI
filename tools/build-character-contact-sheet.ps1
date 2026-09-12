$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$projectRoot = Split-Path -Parent $PSScriptRoot
$assetRoot = Join-Path $projectRoot 'maring-frontend\assets\maring'
$outputPath = Join-Path $projectRoot 'docs\maring-2.5d-contact-sheet.png'
$names = @('neutral', 'joy', 'calm', 'sad', 'anxious', 'angry', 'empathy', 'thinking', 'tired')
$labels = @{
    neutral = 'NEUTRAL'; joy = 'JOY'; calm = 'CALM'; sad = 'SAD'; anxious = 'ANXIOUS'
    angry = 'ANGRY'; empathy = 'EMPATHY'; thinking = 'THINKING'; tired = 'TIRED'
}

$sheet = [System.Drawing.Bitmap]::new(1536, 1536, [System.Drawing.Imaging.PixelFormat]::Format24bppRgb)
try {
    $g = [System.Drawing.Graphics]::FromImage($sheet)
    try {
        $g.Clear([System.Drawing.Color]::FromArgb(250, 248, 255))
        $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $font = [System.Drawing.Font]::new('Segoe UI', 23, [System.Drawing.FontStyle]::Bold)
        $brush = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(70, 55, 115))
        $line = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(225, 216, 245), 2)
        try {
            for ($i = 0; $i -lt $names.Count; $i++) {
                $column = $i % 3; $row = [Math]::Floor($i / 3)
                $x = $column * 512; $y = $row * 512
                $g.DrawRectangle($line, $x + 10, $y + 10, 492, 492)
                $image = [System.Drawing.Image]::FromFile((Join-Path $assetRoot "$($names[$i]).png"))
                try { $g.DrawImage($image, $x + 56, $y + 40, 400, 400) } finally { $image.Dispose() }
                $label = $labels[$names[$i]]
                $size = $g.MeasureString($label, $font)
                $g.DrawString($label, $font, $brush, $x + (512 - $size.Width) / 2, $y + 455)
            }
        } finally {
            $line.Dispose(); $brush.Dispose(); $font.Dispose()
        }
    } finally {
        $g.Dispose()
    }
    $sheet.Save($outputPath, [System.Drawing.Imaging.ImageFormat]::Png)
} finally {
    $sheet.Dispose()
}
Write-Output $outputPath
