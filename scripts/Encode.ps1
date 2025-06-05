
. "$PSScriptRoot\Invoke-AesCrypter.ps1"
. "$PSScriptRoot\EncodeDecode.ps1"

function Invoke-DoEncode {

    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $false, HelpMessage = "Encoding type")]
        [ValidateSet('base64', 'raw')]
        [string]$Type = 'base64',
        [Parameter(Mandatory = $false, HelpMessage = "Was the source file encrypted or not")]
        [switch]$Encrypted
    )
    try {
        $RootPath = (Resolve-Path -Path "$PSScriptRoot\..").Path
        $DataCipherPath = Join-Path $RootPath 'data'
        $BinSrcPath = Join-Path $RootPath 'binsrc'
        $Filename = 'bmw_installer_package.rar'
        $EncryptedFilename = $Filename + '.aes'
        $SourcePackagePath = (Resolve-Path -Path "$BinSrcPath\$Filename").Path 
        if ($Encrypted) {
            Write-Host "Encrypted Mode=Invoke-AesCrypter -Path `"$SourcePackagePath`", will need to enter password!`n`n"
            Invoke-AesCrypter -Path "$SourcePackagePath" -Mode 'encrypt'
        }

        [System.IO.Directory]::CreateDirectory($DataCipherPath)

        $EncryptedPackagePath = (Resolve-Path -Path "$BinSrcPath\$EncryptedFilename").Path 

        Write-Host "SplitDataFile `"$EncryptedPackagePath`"`n`n"

        Invoke-SplitDataFile -Path "$EncryptedPackagePath" -Newsize 1Mb -OutPath "$DataCipherPath"
    } catch {
        Write-Error "$_"
    }

}


Invoke-DoEncode -Encrypted
