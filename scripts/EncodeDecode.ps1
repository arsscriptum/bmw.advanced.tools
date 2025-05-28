
function Invoke-AutoUpdateProgress_FileUtils {
    [int32]$PercentComplete = (($Script:StepNumber / $Script:TotalSteps) * 100)
    if ($PercentComplete -gt 100) { $PercentComplete = 100 }
    Write-Progress -Activity $Script:ProgressTitle -Status $Script:ProgressMessage -PercentComplete $PercentComplete
    if ($Script:StepNumber -lt $Script:TotalSteps) { $Script:StepNumber++ }
}


function Read-FileHeader {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0, ValueFromPipeline = $true, Mandatory = $true, HelpMessage = 'Path to the file with header')]
        [ValidateScript({ Test-Path $_ -PathType 'Leaf' })]
        [string]$Path
    )

    process {
        $ExpectedMagic = [byte[]](0x42, 0x4D, 0x57, 0x21, 0x2A, 0x4D, 0x53, 0x47)

        $Reader = [System.IO.BinaryReader]::new([System.IO.File]::OpenRead($Path))
        try {
            $MagicStart = $Reader.ReadBytes(8)
            if (-not [System.Linq.Enumerable]::SequenceEqual($MagicStart, $ExpectedMagic)) {
                throw "Invalid or missing header magic number at start of file: $Path"
            }

            $PartID = $Reader.ReadInt32()
            $DataSize = $Reader.ReadInt64()
            $HashBytes = $Reader.ReadBytes(32)

            $MagicEnd = $Reader.ReadBytes(8)
            if (-not [System.Linq.Enumerable]::SequenceEqual($MagicEnd, $ExpectedMagic)) {
                throw "Invalid or missing header magic number at end of header: $Path"
            }
        }
        finally {
            $Reader.Close()
        }

        [pscustomobject]@{
            Path = $Path
            PartID = $PartID
            DataSize = $DataSize
            Hash = ([BitConverter]::ToString($HashBytes) -replace '-', '').ToLower()
        }
    }
}

function Invoke-AesCrypter {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Position = 0, Mandatory = $true, HelpMessage = "Path to the folder containing split parts")]
        [string]$Path,
        [Parameter(Position = 1, Mandatory = $true, HelpMessage = "Path of the recombined file")]
        [ValidateSet('encrypt', 'decrypt')]
        [string]$Mode
    )

    try {
        $LitteralPath = (Resolve-Path $Path).Path

        $AesCrypterExe = Find-program "AesCrypter" -PathOnly
        if ($Mode -eq 'encrypt') {
            & "$AesCrypterExe" '-e' "$LitteralPath"

        }elseif ($Mode -eq 'decrypt') {
            & "$AesCrypterExe" '-d' "$LitteralPath"
        }
    } catch {
        Write-Error "Error"
    }
}


function Remove-FileHeader {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0, ValueFromPipeline = $true, Mandatory = $true, HelpMessage = 'Path to the file with header')]
        [ValidateScript({ Test-Path $_ -PathType 'Leaf' })]
        [string]$Path
    )

    process {
        $Magic = [byte[]](0x42, 0x4D, 0x57, 0x21, 0x2A, 0x4D, 0x53, 0x47) # BMW!*MSG
        $LitteralPath = (Resolve-Path $Path).Path
        $TempPath = "$LitteralPath.raw"

        $Reader = [System.IO.BinaryReader]::new([System.IO.File]::OpenRead($LitteralPath))
        try {
            # Read and validate start magic number
            $MagicStart = $Reader.ReadBytes(8)
            if (-not [System.Linq.Enumerable]::SequenceEqual($MagicStart, $Magic)) {
                throw "Invalid or missing header magic number at start of file: $LitteralPath"
            }

            # Read header
            $PartID = $Reader.ReadInt32()
            $DataSize = $Reader.ReadInt64()
            $HashBytes = $Reader.ReadBytes(32)

            # Read and validate end magic number
            $MagicEnd = $Reader.ReadBytes(8)
            if (-not [System.Linq.Enumerable]::SequenceEqual($MagicEnd, $Magic)) {
                throw "Invalid or missing header magic number at end of header: $LitteralPath"
            }

            # Read actual data
            $RemainingBytes = $Reader.ReadBytes([int]$DataSize)

            # Write payload to new file
            $Writer = [System.IO.BinaryWriter]::new([System.IO.File]::Create($TempPath))
            try {
                $Writer.Write($RemainingBytes, 0, $RemainingBytes.Length)
            }
            finally {
                $Writer.Close()
            }
        }
        finally {
            $Reader.Close()
        }

        # Replace the original file with headerless copy
        Remove-Item -LiteralPath $LitteralPath -Force
        Rename-Item -LiteralPath $TempPath -NewName (Split-Path $LitteralPath -Leaf)

        # Return metadata object
        return [pscustomobject]@{
            Path = $LitteralPath
            PartID = $PartID
            DataSize = $DataSize
            Hash = ([BitConverter]::ToString($HashBytes) -replace '-', '').ToLower()
        }
    }
}

function Write-FileHeader {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0, ValueFromPipeline = $true, Mandatory = $true, HelpMessage = 'Path to the file to add header to')]
        [ValidateScript({ Test-Path $_ -PathType 'Leaf' })]
        [string]$Path,

        [Parameter(Mandatory = $true)]
        [int]$PartID
    )

    process {
        $Magic = [byte[]](0x42, 0x4D, 0x57, 0x21, 0x2A, 0x4D, 0x53, 0x47) # BMW!*MSG
        $Bytes = [System.IO.File]::ReadAllBytes($Path)
        $DataSize = $Bytes.Length
        $Hasher = [System.Security.Cryptography.SHA256]::Create()
        $HashBytes = $Hasher.ComputeHash($Bytes)

        $TempPath = "$Path.tmp"
        $Writer = [System.IO.BinaryWriter]::new([System.IO.File]::Create($TempPath))

        try {
            $Writer.Write($Magic)
            $Writer.Write([int]$PartID)
            $Writer.Write([long]$DataSize)
            $Writer.Write($HashBytes)
            $Writer.Write($Magic)
            $Writer.Write($Bytes, 0, $DataSize)
        }
        finally {
            $Writer.Close()
        }

        Remove-Item -LiteralPath $Path -Force
        Rename-Item -LiteralPath $TempPath -NewName (Split-Path $Path -Leaf)
    }
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
        [Parameter(Mandatory = $false)]
        [switch]$AsString
    )

    $SyncStopWatch = [System.Diagnostics.Stopwatch]::StartNew()
    $Script:ProgressTitle = "Combine Split Files"
    $TotalTicks = 0
    $Basename = ''

    $Path = $Path.TrimEnd('\')
    Write-Verbose "Path is $Path"

    # Identify the base name
    foreach ($f in (Get-ChildItem $Path -File).Name) {
        if ($f -like '*01.cpp') {
            $Basename = $f -replace '01\.cpp$', ''
            break
        }
    }

    Write-Verbose "Basename is $Basename"

    $Files = (Get-ChildItem $Path -File -Filter "$Basename*.cpp").FullName | Sort-ByFileHeaderId
    $FilesCount = $Files.Count
    $Script:TotalSteps = $FilesCount
    $Script:StepNumber = 1

    # Open file stream for output
    $FileStream = [System.IO.File]::Open($Destination, 'Create', 'Write', 'Write') # for writing

    try {
        foreach ($f in $Files) {
            if (-not (Test-Path -Path $f)) {
                Write-Verbose "Skipping missing file: $f"
                continue
            }

            $HeaderData = Remove-FileHeader -Path $f


            if ($AsString) {
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
    }
    finally {
        $FileStream.Close()
    }

    Invoke-AesCrypter -Path "$Destination" -Mode 'decrypt'

    Write-Host "Wrote combined file to $Destination"
}

