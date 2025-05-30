
#╔════════════════════════════════════════════════════════════════════════════════╗
#║                                                                                ║
#║   EncodeDecode.ps1                                                             ║
#║                                                                                ║
#╟────────────────────────────────────────────────────────────────────────────────╢
#║   Guillaume Plante <codegp@icloud.com>                                         ║
#║   Code licensed under the GNU GPL v3.0. See the LICENSE file for details.      ║
#╚════════════════════════════════════════════════════════════════════════════════╝

. "$PSScriptRoot\FileHeader.ps1"

function Invoke-AutoUpdateProgress_FileUtils {
    [int32]$PercentComplete = (($Script:StepNumber / $Script:TotalSteps) * 100)
    if ($PercentComplete -gt 100) { $PercentComplete = 100 }
    Write-Progress -Activity $Script:ProgressTitle -Status $Script:ProgressMessage -PercentComplete $PercentComplete
    if ($Script:StepNumber -lt $Script:TotalSteps) { $Script:StepNumber++ }
}


function Sort-Lexically {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0, ValueFromPipeline = $true, Mandatory = $true)]
        [object]$InputObject,

        [Parameter(Mandatory = $false)]
        [string]$Property
    )

    begin {
        $items = @()
    }

    process {
        $items += $InputObject
    }

    end {
        $items | Sort-Object {
            $name = if ($Property) { $_.$Property } else { $_ }

            if ($name -match '(\d+)(?=\D*$)') {
                [int]$matches[1] # numeric suffix before non-digits at the end (e.g., .cpp)
            } else {
                $name
            }
        }
    }
}

function Sort-ByFileHeaderId {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0, ValueFromPipeline = $true, Mandatory = $true)]
        [string[]]$Path
    )

    begin {
        $items = @()
    }

    process {
        $items += $Path
    }

    end {
        $items |
        ForEach-Object {
            try {
                $header = Read-FileHeader -Path $_
                [pscustomobject]@{
                    Path = $_
                    PartID = $header.PartID
                }
            } catch {
                Write-Warning "Skipping invalid or corrupt header: $_"
            }
        } |
        Sort-Object PartID |
        Select-Object -ExpandProperty Path
    }
}


function Invoke-SplitDataFile {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [Parameter(Mandatory = $false)]
        [int64]$Newsize = 1MB,
        [Parameter(Mandatory = $false)]
        [string]$OutPath,
        [Parameter(Mandatory = $false)]
        [string]$Extension = "cpp",
        [Parameter(Mandatory = $false)]
        [switch]$AsString
    )

    if ($Newsize -le 0)
    {
        Write-Error "Only positive sizes allowed"
        return
    }

    $FileSize = (Get-Item $Path).Length
    $SyncStopWatch = [System.Diagnostics.Stopwatch]::StartNew()
    $Script:ProgressTitle = "Split Files"
    $TotalTicks = 0
    $Count = [math]::Round($FileSize / $Newsize)
    $Script:StepNumber = 1
    $Script:TotalSteps = $Count + 3
    if ($PSBoundParameters.ContainsKey('OutPath') -eq $False) {
        $OutPath = [IO.Path]::GetDirectoryName($Path)

        Write-Verbose "Using OutPath from Path $Path"
    } else {
        Write-Verbose "Using OutPath $OutPath"
    }
    $OutPath = $OutPath.TrimEnd('\')

    if (-not (Test-Path -Path "$OutPath")) {
        Write-Verbose "CREATING $OutPath"
        $Null = New-Item $OutPath -ItemType Directory -Force -ErrorAction Ignore
    }

    $FILENAME = [IO.Path]::GetFileNameWithoutExtension($Path)


    $MAXVALUE = 1GB # Hard maximum limit for Byte array for 64-Bit .Net 4 = [INT32]::MaxValue - 56, see here https://stackoverflow.com/questions/3944320/maximum-length-of-byte
    # but only around 1.5 GB in 32-Bit environment! So I chose 1 GB just to be safe
    $PASSES = [math]::Floor($Newsize / $MAXVALUE)
    $REMAINDER = $Newsize % $MAXVALUE
    if ($PASSES -gt 0) { $BUFSIZE = $MAXVALUE } else { $BUFSIZE = $REMAINDER }

    $OBJREADER = New-Object System.IO.BinaryReader ([System.IO.File]::Open($Path, 'Open', 'Read', 'Read')) # for reading)
    [Byte[]]$BUFFER = New-Object Byte[] $BUFSIZE
    $NUMFILE = 1

    do {
        $Extension = $Extension.TrimStart('.')
        $NEWNAME = "{0}\{1}{2,2:00}.{3}" -f $OutPath, $FILENAME, $NUMFILE, $Extension
        $Script:ProgressMessage = "Split {0} of {1} files" -f $Script:StepNumber, $Script:TotalSteps
        Invoke-AutoUpdateProgress_FileUtils
        $Script:StepNumber++
        $COUNT = 0
        $OBJWRITER = $NULL
        [int32]$BYTESREAD = 0
        while (($COUNT -lt $PASSES) -and (($BYTESREAD = $OBJREADER.Read($BUFFER, 0, $BUFFER.Length)) -gt 0))
        {
            Write-Verbose "[Invoke-SplitDataFile] Reading $BYTESREAD bytes"
            if ($AsString) {
                $DataString = [convert]::ToBase64String($BUFFER, 0, $BYTESREAD)
                Write-Verbose "[Invoke-SplitDataFile] WRITING DataString to $NEWNAME"
                Set-Content $NEWNAME $DataString
            } else {
                if (!$OBJWRITER)
                {
                    $OBJWRITER = New-Object System.IO.BinaryWriter ([System.IO.File]::Create($NEWNAME))
                    Write-Verbose " + CREATING $NEWNAME"
                }
                Write-Verbose "[Invoke-SplitDataFile] WRITING $BYTESREAD bytes to $NEWNAME"
                $OBJWRITER.Write($BUFFER, 0, $BYTESREAD)
            }
            $COUNT++
        }
        if (($REMAINDER -gt 0) -and (($BYTESREAD = $OBJREADER.Read($BUFFER, 0, $REMAINDER)) -gt 0))
        {
            Write-Verbose "[Invoke-SplitDataFile] Reading $BYTESREAD bytes"
            if ($AsString) {
                $DataString = [convert]::ToBase64String($BUFFER, 0, $BYTESREAD)
                Write-Verbose "[Invoke-SplitDataFile] WRITING DataString to $NEWNAME"
                Set-Content $NEWNAME $DataString
            } else {
                if (!$OBJWRITER)
                {
                    $OBJWRITER = New-Object System.IO.BinaryWriter ([System.IO.File]::Create($NEWNAME))
                    Write-Verbose " + CREATING $NEWNAME"
                }
                Write-Verbose "[Invoke-SplitDataFile] WRITING $BYTESREAD bytes to $NEWNAME"
                $OBJWRITER.Write($BUFFER, 0, $BYTESREAD)
            }
        }

        if ($OBJWRITER) { $OBJWRITER.Close() }
        if ($BYTESREAD) {
            Write-FileHeader -Path $NEWNAME -PartId $NUMFILE
        }

        ++ $NUMFILE
    } while ($BYTESREAD -gt 0)

    $OBJREADER.Close()
}



function Invoke-CombineSplitFiles {

    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Position = 0, Mandatory = $true, HelpMessage = "Path to the folder containing split parts")]
        [string]$Path,
        [Parameter(Position = 1, Mandatory = $true, HelpMessage = "Path of the recombined file")]
        [string]$Destination,
        [Parameter(Mandatory = $false, HelpMessage = "Encoding type")]
        [ValidateSet('base64','raw')]
        [string]$Type='base64'
    )
    [bool]$EncodedAsString = ($Type -eq 'base64')

    $SyncStopWatch = [System.Diagnostics.Stopwatch]::StartNew()
    $Script:ProgressTitle = "Combine Split Files"
    $TotalTicks = 0
    $Basename = ''

    $Path = $Path.TrimEnd('\')
    Write-Verbose "Path is $Path"

    $Files = (Get-ChildItem $Path -File -Filter "$Basename*.cpp").FullName
    try{
       $SortedFiles = $Files | Sort-ByFileHeaderId
    }catch{
        Write-Error "$_"
    }
    $FilesCount = $SortedFiles.Count
    $Script:TotalSteps = $FilesCount
    $Script:StepNumber = 1

    if(![System.IO.File]::Exists("$Destination")){
        New-Item -Path "$Destination" -ItemType File -FOrce -ErrorAction Ignore | Out-Null
    }

    # Open file stream for output
    $FileStream = [System.IO.File]::Open($Destination, 'Create', 'Write', 'Write') # for writing

    [bool]$RecombinedSuccessfully = $True

    try {
        foreach ($f in $SortedFiles) {
            if (-not (Test-Path -Path $f)) {
                throw "missing file: $f"
            }

            $HeaderData = Remove-FileHeader -Path $f

            if ($EncodedAsString) {
                [string]$Base64String = Get-Content -LiteralPath $f -Raw
                [byte[]]$ReadBytes = [Convert]::FromBase64String($Base64String)
                $FileStream.Write($ReadBytes, 0, $ReadBytes.Length)
            } else {
                [byte[]]$ReadBytes = Get-Content -LiteralPath $f -Raw -AsByteStream
                $FileStream.Write($ReadBytes, 0, $ReadBytes.Length)
            }

            $Script:ProgressMessage = "Wrote part $Script:StepNumber of $Script:TotalSteps"
            Invoke-AutoUpdateProgress_FileUtils
        }
    }catch{
        $RecombinedSuccessfully = $False
        Write-Error "Error on $f . $_"
    }finally {
        $FileStream.Close()
    }

    if($RecombinedSuccessfully){
        Write-Host "Recombined Successfully ! Wrote combined file to $Destination"
    }
  
}

