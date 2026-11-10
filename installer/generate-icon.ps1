param(
    [string]$OutputPath = (Join-Path $PSScriptRoot 'hype.ico')
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Drawing.Common -ErrorAction SilentlyContinue

function New-IconPng([int]$Size) {
    $bitmap = [System.Drawing.Bitmap]::new($Size, $Size, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    try {
        $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
        $graphics.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
        $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
        $graphics.Clear([System.Drawing.Color]::Transparent)

        $scale = $Size / 256.0
        $rect = [System.Drawing.RectangleF]::new(8 * $scale, 8 * $scale, 240 * $scale, 240 * $scale)
        $radius = 52 * $scale
        $path = [System.Drawing.Drawing2D.GraphicsPath]::new()
        try {
            $path.AddArc($rect.X, $rect.Y, $radius, $radius, 180, 90)
            $path.AddArc($rect.Right - $radius, $rect.Y, $radius, $radius, 270, 90)
            $path.AddArc($rect.Right - $radius, $rect.Bottom - $radius, $radius, $radius, 0, 90)
            $path.AddArc($rect.X, $rect.Bottom - $radius, $radius, $radius, 90, 90)
            $path.CloseFigure()
            $background = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(255, 26, 27, 38))
            $border = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(255, 122, 162, 247), [math]::Max(2, 7 * $scale))
            try {
                $graphics.FillPath($background, $path)
                $graphics.DrawPath($border, $path)
            } finally {
                $background.Dispose()
                $border.Dispose()
            }
        } finally {
            $path.Dispose()
        }

        $hPen = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(255, 192, 202, 245), [math]::Max(3, 28 * $scale))
        $hPen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
        $hPen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
        $hPen.LineJoin = [System.Drawing.Drawing2D.LineJoin]::Round
        $accentPen = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(255, 187, 154, 247), [math]::Max(3, 28 * $scale))
        $accentPen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
        $accentPen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
        try {
            $left = 78 * $scale; $right = 178 * $scale; $top = 62 * $scale; $bottom = 194 * $scale; $middle = 128 * $scale
            $graphics.DrawLine($hPen, $left, $top, $left, $bottom)
            $graphics.DrawLine($hPen, $right, $top, $right, $bottom)
            $graphics.DrawLine($accentPen, $left, $middle, $right, $middle)
        } finally {
            $hPen.Dispose()
            $accentPen.Dispose()
        }

        $stream = [System.IO.MemoryStream]::new()
        try {
            $bitmap.Save($stream, [System.Drawing.Imaging.ImageFormat]::Png)
            return $stream.ToArray()
        } finally {
            $stream.Dispose()
        }
    } finally {
        $graphics.Dispose()
        $bitmap.Dispose()
    }
}

$sizes = @(16, 24, 32, 48, 64, 96, 128, 256)
$images = [System.Collections.Generic.List[byte[]]]::new()
foreach ($size in $sizes) { [void]$images.Add((New-IconPng $size)) }
$directoryBytes = 6 + 16 * $images.Count
$totalBytes = $directoryBytes
foreach ($image in $images) { $totalBytes += $image.Length }
$buffer = [System.IO.MemoryStream]::new([int64]$totalBytes)
$writer = [System.IO.BinaryWriter]::new($buffer)
try {
    $writer.Write([uint16]0)
    $writer.Write([uint16]1)
    $writer.Write([uint16]$images.Count)
    $offset = $directoryBytes
    for ($i = 0; $i -lt $images.Count; $i++) {
        $size = $sizes[$i]
        $writer.Write([byte]$(if ($size -eq 256) { 0 } else { $size }))
        $writer.Write([byte]$(if ($size -eq 256) { 0 } else { $size }))
        $writer.Write([byte]0)
        $writer.Write([byte]0)
        $writer.Write([uint16]1)
        $writer.Write([uint16]32)
        $writer.Write([uint32]$images[$i].Length)
        $writer.Write([uint32]$offset)
        $offset += $images[$i].Length
    }
    foreach ($image in $images) { $writer.Write($image) }
    $writer.Flush()
    [System.IO.File]::WriteAllBytes($OutputPath, $buffer.ToArray())
} finally {
    $writer.Dispose()
    $buffer.Dispose()
}
Write-Host "Generated $OutputPath"
