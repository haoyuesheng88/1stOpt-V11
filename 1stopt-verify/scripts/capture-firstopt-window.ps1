[CmdletBinding()]
param(
    [int]$ProcessId,
    [string]$OutputPath = (Join-Path (Get-Location) 'firstopt_capture.png')
)

Add-Type -AssemblyName System.Drawing
Add-Type @"
using System;
using System.Runtime.InteropServices;
public static class Win32CaptureFirstOpt {
    [StructLayout(LayoutKind.Sequential)]
    public struct RECT {
        public int Left;
        public int Top;
        public int Right;
        public int Bottom;
    }

    [DllImport("user32.dll")]
    public static extern bool GetWindowRect(IntPtr hWnd, out RECT lpRect);

    [DllImport("user32.dll")]
    public static extern bool PrintWindow(IntPtr hwnd, IntPtr hDC, uint nFlags);
}
"@

$process = if ($ProcessId) {
    Get-Process -Id $ProcessId -ErrorAction Stop
} else {
    Get-Process -ErrorAction SilentlyContinue | Where-Object {
        $_.ProcessName -eq 'FirstOpt' -and $_.MainWindowTitle
    } | Sort-Object Id -Descending | Select-Object -First 1
}

if (-not $process) {
    throw 'No visible FirstOpt window was found.'
}

$rect = New-Object Win32CaptureFirstOpt+RECT
[void][Win32CaptureFirstOpt]::GetWindowRect([IntPtr]$process.MainWindowHandle, [ref]$rect)

$width = $rect.Right - $rect.Left
$height = $rect.Bottom - $rect.Top

$bitmap = New-Object System.Drawing.Bitmap $width, $height
$graphics = [System.Drawing.Graphics]::FromImage($bitmap)
$hdc = $graphics.GetHdc()
[void][Win32CaptureFirstOpt]::PrintWindow([IntPtr]$process.MainWindowHandle, $hdc, 0)
$graphics.ReleaseHdc($hdc)

$parent = Split-Path -Parent $OutputPath
if ($parent) {
    New-Item -ItemType Directory -Force -Path $parent | Out-Null
}

$resolvedOutput = if ([System.IO.Path]::IsPathRooted($OutputPath)) {
    $OutputPath
} else {
    Join-Path (Get-Location) $OutputPath
}

$bitmap.Save($resolvedOutput, [System.Drawing.Imaging.ImageFormat]::Png)
$graphics.Dispose()
$bitmap.Dispose()

[pscustomobject]@{
    ProcessId       = $process.Id
    MainWindowTitle = $process.MainWindowTitle
    OutputPath      = $resolvedOutput
}
