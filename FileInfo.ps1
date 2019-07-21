
# Helper method to write file length in a more human readable format
function Write-FileLength
{
    param ($length)

    if ($length -eq $null)
    {
        return ""
    }
    elseif ($length -ge 1GB)
    {
        return ($length / 1GB).ToString("F") + 'GB'
    }
    elseif ($length -ge 1MB)
    {
        return ($length / 1MB).ToString("F") + 'MB'
    }
    elseif ($length -ge 1KB)
    {
        return ($length / 1KB).ToString("F") + 'KB'
    }

    return $length.ToString() + '  '
}

# Outputs a line of a DirectoryInfo or FileInfo
function Write-Color-LS
{
    param ([string]$color = "white", $Item)

    Write-host ("{0,-7} {1,25} {2,10} {3}" -f $Item.mode, ([String]::Format("{0,10}  {1,8}", $Item.LastWriteTime.ToString("d"), $Item.LastWriteTime.ToString("t"))), (Write-FileLength $Item.length), $Item.name) -foregroundcolor $color
}

function FileInfo {
    param (
        [Parameter(Mandatory=$True,Position=1)]
        $Item
    )

    if($script:showHeader)
    {
       Write-Host
       Write-Host "    Directory: " -noNewLine
       Write-Host " $(pwd)`n" -foregroundcolor "Green"
       Write-Host "Mode                LastWriteTime     Length Name"
       Write-Host "----                -------------     ------ ----"
       $script:showHeader=$false
    }

    $Color = Get-Color $Item

    Write-Color-LS $Color $Item
}
