[CmdletBinding()]
param(
    [string]$ProcessName = "FirstOpt",
    [switch]$IncludeInvisible
)

Add-Type @"
using System;
using System.Runtime.InteropServices;
using System.Text;
public static class Win32FindFirstOpt {
    [DllImport("user32.dll", CharSet = CharSet.Unicode)]
    public static extern int GetClassName(IntPtr hWnd, StringBuilder lpClassName, int nMaxCount);
}
"@

$processes = Get-Process -ErrorAction SilentlyContinue | Where-Object {
    $_.ProcessName -eq $ProcessName -or $_.MainWindowTitle -match '1stOpt'
}

$rows = foreach ($process in $processes) {
    if (-not $IncludeInvisible -and ($process.MainWindowHandle -eq 0 -or [string]::IsNullOrWhiteSpace($process.MainWindowTitle))) {
        continue
    }

    $className = New-Object System.Text.StringBuilder 256
    [void][Win32FindFirstOpt]::GetClassName([IntPtr]$process.MainWindowHandle, $className, $className.Capacity)

    [pscustomobject]@{
        ProcessId        = $process.Id
        ProcessName      = $process.ProcessName
        MainWindowTitle  = $process.MainWindowTitle
        MainWindowHandle = $process.MainWindowHandle
        MainWindowHex    = ('0x{0:X}' -f $process.MainWindowHandle)
        WindowClass      = $className.ToString()
    }
}

$rows | Sort-Object ProcessId
