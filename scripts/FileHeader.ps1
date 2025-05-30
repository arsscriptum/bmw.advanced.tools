

#╔════════════════════════════════════════════════════════════════════════════════╗
#║                                                                                ║
#║   FileHeader.ps1                                                               ║
#║                                                                                ║
#╟────────────────────────────────────────────────────────────────────────────────╢
#║   Guillaume Plante <codegp@icloud.com>                                         ║
#║   Code licensed under the GNU GPL v3.0. See the LICENSE file for details.      ║
#╚════════════════════════════════════════════════════════════════════════════════╝


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
