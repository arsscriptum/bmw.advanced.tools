
. "$PSScriptRoot\EncodeDecode.ps1"

. "$PSScriptRoot\Invoke-AesCrypter.ps1"


function Invoke-DoDecode {

    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $false, HelpMessage = "Encoding type")]
        [ValidateSet('base64','raw')]
        [string]$Type='base64',
        [Parameter(Mandatory = $false, HelpMessage = "Was the source file encrypted or not")]
        [switch]$Encrypted
    )


    $RootPath = (Resolve-Path -Path "$PSScriptRoot\..").Path
    $DataCipherPath = Join-Path $RootPath 'data'
    $BinSrcPath = Join-Path $RootPath 'binsrc'
    $Filename = 'recombined.rar'
    $EncryptedFilename = $Filename + '.aes'


    $SourcePackagePath = Join-Path $BinSrcPath $Filename
    $RecombinedEncryptedPackagePath = Join-Path $BinSrcPath $EncryptedFilename

    Invoke-CombineSplitFiles $DataCipherPath $RecombinedEncryptedPackagePath -Type 'base64'

    if($Encrypted){
        Invoke-AesCrypter -Path "$RecombinedEncryptedPackagePath" -Mode 'decrypt'
    }  
    if ([System.IO.File]::Exists("$SourcePackagePath")) {
        $Hash2 = (Get-FileHash -Algorithm SHA1 -Path "$SourcePackagePath").Hash
        Write-Host "[$Hash2] $SourcePackagePath" -f DarkCyan
    }
}

Invoke-DoDecode -Type 'base64' -Encrypted
