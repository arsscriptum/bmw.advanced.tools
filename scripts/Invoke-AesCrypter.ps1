
#╔════════════════════════════════════════════════════════════════════════════════╗
#║                                                                                ║
#║   Invoke-AesCrypter.ps1                                                        ║
#║                                                                                ║
#╟────────────────────────────────────────────────────────────────────────────────╢
#║   Guillaume Plante <codegp@icloud.com>                                         ║
#║   Code licensed under the GNU GPL v3.0. See the LICENSE file for details.      ║
#╚════════════════════════════════════════════════════════════════════════════════╝


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

