
. "$PSScriptRoot\EncodeDecode.ps1"

function Test-SplitDataFile {

    [CmdletBinding(SupportsShouldProcess)]
    param()


    $RootPath = (Resolve-Path -Path "$PSScriptRoot\..").Path
    $DataCipherPath = Join-Path $RootPath 'data'
    $BinSrcPath = Join-Path $RootPath 'binsrc'
    $SourcePackagePath = Join-Path $BinSrcPath 'bmw_installer_package.rar'
    $RecombinedPackagePath = Join-Path $BinSrcPath 'recombined.rar'

    [System.IO.Directory]::CreateDirectory($DataCipherPath)

    Invoke-SplitDataFile -Path "$SourcePackagePath" -Newsize 1Mb -OutPath "$DataCipherPath" -AsString

    Invoke-CombineSplitFiles $DataCipherPath $RecombinedPackagePath -AsString



    $Hash1 = (Get-FileHash -Algorithm SHA1 -Path "$SourcePackagePath").Hash
    $Hash2 = (Get-FileHash -Algorithm SHA1 -Path "$RecombinedPackagePath").Hash
    $Equals = $Hash1 -eq $Hash2
    $Col2 = [System.ConsoleColor]::DarkCyan
    if (!$Equals) {
        $Col2 = [System.ConsoleColor]::DarkRed
    }
    Write-Host "[$Hash1] $SourcePackagePath" -f DarkCyan
    Write-Host "[$Hash2] $RecombinedPackagePath" -f $Col2

}


Test-SplitDataFile