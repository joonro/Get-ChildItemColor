# Helper method to write file length in a more human readable format
# Will output the length in B, KB, MB, or GB
# Similar to the `ls -lh` command in Unix, it'll truncate any trailing zeros after the decimal point
function Write-FileLength {
    Param ($Length)

    If ($null -eq $Length) {
        Return ""
    } ElseIf ($Length -ge 1GB) {
        Return ($Length / 1GB).ToString("#0.#") + 'G'
    } ElseIf ($Length -ge 1MB) {
        Return ($Length / 1MB).ToString("#0.#") + 'M'
    } ElseIf ($Length -ge 1KB) {
        Return ($Length / 1KB).ToString("#0.#") + 'K'
    }

    Return $Length.ToString()
}

# Outputs a line of a DirectoryInfo or FileInfo
function Write-Color-LS {
    param ([string]$color = "White", [bool]$humanReadable, $item)

    Write-host ("{0,-7} " -f $item.mode) -NoNewline
    Write-host ("{0,25} " -f ([String]::Format("{0,10}  {1,8}", $item.LastWriteTime.ToString("d"), $item.LastWriteTime.ToString("t")))) -NoNewline
    # Do not write length 1 for directories
    if ($item.PSIsContainer) {
        Write-host ("{0,10} " -f " ") -NoNewLine
    } else {
        # Write length in human readable format if the switch is set
        if ($humanReadable) {
            Write-host ("{0,10} " -f (Write-FileLength $item.length)) -NoNewline
        } else {
        Write-host ("{0,10} " -f $item.length) -NoNewline
        }
    }
    Write-host ("{0}" -f $item.name) -ForegroundColor $color
}

function FileInfo {
    param (
        [Parameter(Mandatory=$True, Position=1)]
        $item,
        [switch]$HumanReadableSize

    )

    $parentName = $item.PSParentPath.Replace("Microsoft.PowerShell.Core\FileSystem::", "")

    if ($script:LastParentName -ne $ParentName -or $script:ShowHeader) {
       $color = $GetChildItemColorTable.File['Directory']

       Write-Host
       Write-Host "    Directory: " -noNewLine
       Write-Host " $($parentName)`n" -ForegroundColor $color

       For ($l=1; $l -lt $GetChildItemColorVerticalSpace; $l++) {
           Write-Host ""
       }

       Write-Host "Mode                LastWriteTime     Length Name"
       Write-Host "----                -------------     ------ ----"

       $script:ShowHeader = $False
    }

    $color = Get-FileColor $item

    Write-Color-LS $color $HumanReadableSize $item

    $Script:LastParentName = $parentName
}
