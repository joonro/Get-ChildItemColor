# Helper method to write file length in a more human readable format
function Write-FileLength {
    Param ($Length)

    If ($Length -eq $null) {
        Return ""
    } ElseIf ($Length -ge 1GB) {
        Return ($Length / 1GB).ToString("F") + 'GB'
    } ElseIf ($Length -ge 1MB) {
        Return ($Length / 1MB).ToString("F") + 'MB'
    } ElseIf ($Length -ge 1KB) {
        Return ($Length / 1KB).ToString("F") + 'KB'
    }

    Return $Length.ToString() + '  '
}

# Outputs a line of a DirectoryInfo or FileInfo
function Write-Color-LS {
    param ([string]$Color = "White", $Item)

    Write-host ("{0,-7} {1,25} {2,10} {3}" -f $Item.mode, ([String]::Format("{0,10}  {1,8}", $Item.LastWriteTime.ToString("d"), $Item.LastWriteTime.ToString("t"))), (Write-FileLength $Item.length), $Item.name) -ForegroundColor $Color
}

function FileInfo {
    param (
        [Parameter(Mandatory=$True, Position=1)]
        $Item
    )

    $ParentName = $Item.PSParentPath.Replace("Microsoft.PowerShell.Core\FileSystem::", "")

    If ($Script:LastParentName -ne $ParentName -or $Script:ShowHeader) {
       $Color = $GetChildItemColorTable.File['Directory']

       Write-Host
       Write-Host "    Directory: " -noNewLine
       Write-Host " $($ParentName)`n" -ForegroundColor $Color

       For ($l=1; $l -lt $GetChildItemColorVerticalSpace; $l++) {
           Write-Host ""
       }

       Write-Host "Mode                LastWriteTime     Length Name"
       Write-Host "----                -------------     ------ ----"

       $Script:ShowHeader = $False
    }

    $Color = Get-FileColor $Item

    Write-Color-LS $Color $Item

    $Script:LastParentName = $ParentName
}
