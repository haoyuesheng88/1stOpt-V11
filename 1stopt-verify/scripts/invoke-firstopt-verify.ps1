[CmdletBinding()]
param(
    [string]$OutputDirectory = (Get-Location).Path,
    [string]$ExecutablePath = 'C:\Program Files (x86)\1stOpt 11.0\FirstOpt.exe',
    [string]$VariableList = 'x',
    [string]$Expression = 'x^2-4=0',
    [switch]$CaptureAfterRun
)

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$mffPath = Join-Path $OutputDirectory '1stopt_verify_x2_minus_4.mff'

$generated = & (Join-Path $scriptRoot 'new-1stopt-verify-mff.ps1') `
    -OutputPath $mffPath `
    -VariableList $VariableList `
    -Expression $Expression

$opened = & (Join-Path $scriptRoot 'open-firstopt-file.ps1') `
    -FilePath $generated.OutputPath `
    -ExecutablePath $ExecutablePath

$run = & (Join-Path $scriptRoot 'send-firstopt-f9.ps1') `
    -ProcessId $opened.ProcessId

$capture = $null
if ($CaptureAfterRun) {
    Start-Sleep -Milliseconds 1200
    $capture = & (Join-Path $scriptRoot 'capture-firstopt-window.ps1') `
        -ProcessId $opened.ProcessId `
        -OutputPath (Join-Path $OutputDirectory 'firstopt_verify_after_f9.png')
}

[pscustomobject]@{
    VerificationFile = $generated.OutputPath
    Payload          = $generated.Payload
    ProcessId        = $opened.ProcessId
    MainWindowTitle  = $run.MainWindowTitle
    RunShortcut      = $run.SentKey
    CapturePath      = if ($capture) { $capture.OutputPath } else { $null }
}
