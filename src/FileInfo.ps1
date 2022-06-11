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
    param ([string]$color = "White", $item)

    Write-host ("{0,-7} " -f $item.mode) -NoNewline
    Write-host ("{0,25} " -f ([String]::Format("{0,10}  {1,8}", $item.LastWriteTime.ToString("d"), $item.LastWriteTime.ToString("t")))) -NoNewline
    Write-host ("{0,10} " -f (Write-FileLength $item.length)) -NoNewline
    Write-host ("{0}" -f $item.name) -ForegroundColor $color
}

function FileInfo {
    param (
        [Parameter(Mandatory=$True, Position=1)]
        $item
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

    Write-Color-LS $color $item

    $Script:LastParentName = $parentName
}
