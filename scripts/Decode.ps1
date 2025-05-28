
. "$PSScriptRoot\EncodeDecode.ps1"

function Invoke-DoDecode {

    [CmdletBinding(SupportsShouldProcess)]
    param()


    $RootPath = (Resolve-Path -Path "$PSScriptRoot\..").Path
    $DataCipherPath = Join-Path $RootPath 'data'
    $BinSrcPath = Join-Path $RootPath 'binsrc'

    $SourcePackagePath = Join-Path $BinSrcPath 'bmw_installer_package.rar.aes'
    $RecombinedPackagePath = Join-Path $BinSrcPath 'recombined.rar.aes'

    Invoke-CombineSplitFiles $DataCipherPath $RecombinedPackagePath -AsString

    if ([System.IO.File]::Exists("$SourcePackagePath")) {
        $Hash1 = (Get-FileHash -Algorithm SHA1 -Path "$SourcePackagePath").Hash
        $Hash2 = (Get-FileHash -Algorithm SHA1 -Path "$RecombinedPackagePath").Hash
        $Equals = $Hash1 -eq $Hash2
        $Col2 = [System.ConsoleColor]::DarkCyan
        if (!$Equals) {
            $Col2 = [System.ConsoleColor]::DarkRed
        }
        Write-Host "[$Hash1] $SourcePackagePath" -f DarkCyan
        Write-Host "[$Hash2] $RecombinedPackagePath" -f $Col2
    } else {

        $Hash2 = (Get-FileHash -Algorithm SHA1 -Path "$RecombinedPackagePath").Hash

        Write-Host "[$Hash2] $RecombinedPackagePath" -f $Col2
    }
}


Invoke-DoDecode
