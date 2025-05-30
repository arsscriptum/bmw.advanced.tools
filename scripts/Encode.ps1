
. "$PSScriptRoot\EncodeDecode.ps1"

function Invoke-DoEncode {

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
    $Filename = 'bmw_installer_package.rar'
    $EncryptedFilename = $Filename + '.aes'
    $SourcePackagePath = Join-Path $BinSrcPath $Filename
    if($Encrypted){
        Invoke-AesCrypter -Path "$SourcePackagePath" -Mode 'encrypt'
    }  

    [System.IO.Directory]::CreateDirectory($DataCipherPath)

    Invoke-SplitDataFile -Path "$SourcePackagePath" -Newsize 1Mb -OutPath "$DataCipherPath"

}


Invoke-DoEncode -Encrypted