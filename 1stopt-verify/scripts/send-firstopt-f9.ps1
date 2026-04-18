[CmdletBinding()]
param(
    [int]$ProcessId,
    [string]$TitleContains,
    [int]$DelayMilliseconds = 700
)

Add-Type -AssemblyName System.Windows.Forms
$shell = New-Object -ComObject WScript.Shell

if ($ProcessId) {
    $process = Get-Process -Id $ProcessId -ErrorAction Stop
} else {
    $process = Get-Process -ErrorAction SilentlyContinue | Where-Object {
        $_.ProcessName -eq 'FirstOpt' -and $_.MainWindowTitle
    } | Sort-Object Id -Descending | Select-Object -First 1
}

if (-not $process) {
    throw 'No visible FirstOpt window was found.'
}

$targetTitle = if ($TitleContains) {
    $candidate = Get-Process -ErrorAction SilentlyContinue | Where-Object {
        $_.ProcessName -eq 'FirstOpt' -and $_.MainWindowTitle -like "*$TitleContains*"
    } | Select-Object -First 1
    if (-not $candidate) {
        throw "No 1stOpt window title matched: $TitleContains"
    }
    $process = $candidate
    $candidate.MainWindowTitle
} else {
    $process.MainWindowTitle
}

$null = $shell.AppActivate($targetTitle)
Start-Sleep -Milliseconds $DelayMilliseconds
[System.Windows.Forms.SendKeys]::SendWait('{F9}')

[pscustomobject]@{
    ProcessId       = $process.Id
    MainWindowTitle = $process.MainWindowTitle
    SentKey         = 'F9'
}
