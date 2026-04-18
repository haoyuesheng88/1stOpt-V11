[CmdletBinding()]
param(
    [string]$OutputPath = (Join-Path (Get-Location) '1stopt_verify_x2_minus_4.mff'),
    [string]$VariableList = 'x',
    [string]$Expression = 'x^2-4=0'
)

$ascii = [System.Text.Encoding]::ASCII

$payload = @(
    'NewCodeBlock;'
    "ComplexPar $VariableList;"
    "Function $Expression;"
    ''
) -join "`r`n"

$prefix = [byte[]](
    0x20,0x20,0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x03,0x00,0x00,0x00,
    0x0C,0x00,0x61,0x75,0x74,0x6F,0x32,0x66,0x69,0x74,0x66,0x69,0x6C,0x65
)

$suffix = New-Object System.Collections.Generic.List[byte]
$suffix.AddRange([byte[]](0x08,0x00))
$suffix.AddRange($ascii.GetBytes('headfile'))
$suffix.AddRange([System.BitConverter]::GetBytes([int]25))
$suffix.AddRange($ascii.GetBytes("1stOpt File`r`nVersion 11`r`n"))
$suffix.AddRange([byte[]](0x0C,0x00))
$suffix.AddRange($ascii.GetBytes('sheetlistbox'))
$suffix.AddRange([System.BitConverter]::GetBytes([int]36))
$suffix.AddRange($ascii.GetBytes("CodeSheet1`r`nCodeSheet2`r`nCodeSheet3`r`n"))

$payloadBytes = $ascii.GetBytes($payload)
$lengthBytes = [System.BitConverter]::GetBytes([int]$payloadBytes.Length)

$buffer = New-Object byte[] ($prefix.Length + $lengthBytes.Length + $payloadBytes.Length + $suffix.Count)
[Array]::Copy($prefix, 0, $buffer, 0, $prefix.Length)
[Array]::Copy($lengthBytes, 0, $buffer, $prefix.Length, $lengthBytes.Length)
[Array]::Copy($payloadBytes, 0, $buffer, $prefix.Length + $lengthBytes.Length, $payloadBytes.Length)
[Array]::Copy($suffix.ToArray(), 0, $buffer, $prefix.Length + $lengthBytes.Length + $payloadBytes.Length, $suffix.Count)

$parent = Split-Path -Parent $OutputPath
if ($parent) {
    New-Item -ItemType Directory -Force -Path $parent | Out-Null
}

[System.IO.File]::WriteAllBytes($OutputPath, $buffer)

[pscustomobject]@{
    OutputPath      = (Resolve-Path $OutputPath).Path
    Payload         = $payload
    PayloadByteSize = $payloadBytes.Length
}
