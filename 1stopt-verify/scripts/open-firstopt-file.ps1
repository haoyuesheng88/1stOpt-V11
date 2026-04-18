[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$FilePath,
    [string]$ExecutablePath = 'C:\Program Files (x86)\1stOpt 11.0\FirstOpt.exe',
    [int]$WaitSeconds = 3
)

if (-not (Test-Path $FilePath)) {
    throw "File not found: $FilePath"
}

if (-not (Test-Path $ExecutablePath)) {
    throw "1stOpt executable not found: $ExecutablePath"
}

$resolvedFile = (Resolve-Path $FilePath).Path
$resolvedExe = (Resolve-Path $ExecutablePath).Path

$process = Start-Process -FilePath $resolvedExe -ArgumentList ('"{0}"' -f $resolvedFile) -PassThru
Start-Sleep -Seconds $WaitSeconds

[pscustomobject]@{
    ProcessId      = $process.Id
    ExecutablePath = $resolvedExe
    FilePath       = $resolvedFile
}
