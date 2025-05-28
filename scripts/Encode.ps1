
. "$PSScriptRoot\EncodeDecode.ps1"

function Invoke-DoEncode {

    [CmdletBinding(SupportsShouldProcess)]
    param()


    $RootPath = (Resolve-Path -Path "$PSScriptRoot\..").Path
    $DataCipherPath = Join-Path $RootPath 'data'
    $BinSrcPath = Join-Path $RootPath 'binsrc'
    $SourcePackagePath = Join-Path $BinSrcPath 'bmw_installer_package.rar.aes'
    $RecombinedPackagePath = Join-Path $BinSrcPath 'recombined.rar.aes'

    [System.IO.Directory]::CreateDirectory($DataCipherPath)

    Invoke-SplitDataFile -Path "$SourcePackagePath" -Newsize 1Mb -OutPath "$DataCipherPath" -AsString

}


Invoke-DoEncode