$OriginalForegroundColor = $Host.UI.RawUI.ForegroundColor

$CompressedList = @(".7z", ".gz", ".rar", ".tar", ".zip")
$ExecutableList = @(".exe", ".bat", ".cmd", ".py", ".pl", ".ps1",
                    ".psm1", ".vbs", ".rb", ".reg", ".fsx", ".sh")
$DllPdbList = @(".dll", ".pdb")
$TextList = @(".csv", ".log", "markdown", ".rst", ".txt")
$ConfigsList = @(".cfg", ".conf", ".config", ".ini", ".json")

$ColorTable = @{}

$ColorTable.Add('Default', $OriginalForegroundColor) 
$ColorTable.Add('Directory', "Green") 

foreach ($Extension in $CompressedList) {
    $ColorTable.Add($Extension, "Yellow")
}

foreach ($Extension in $ExecutableList) {
    $ColorTable.Add($Extension, "Blue")
}

foreach ($Extension in $TextList) {
    $ColorTable.Add($Extension, "Cyan")
}

foreach ($Extension in $DllPdbList) {
    $ColorTable.Add($Extension, "DarkGreen")
}

foreach ($Extension in $ConfigsList) {
    $ColorTable.Add($Extension, "DarkYellow")
}

Function Get-ChildItemColor {
    Param(
        [string]$Path = ""
    )
    $Expression = "Get-ChildItem -Path `"$Path`" $Args"

    $Items = Invoke-Expression $Expression

    ForEach ($Item in $Items) {
        If ($Item.GetType().Name -eq 'DirectoryInfo') {
            $Key = 'Directory'
        } elseif ($Item.GetType().Name -eq 'DictionaryEntry') {
            $Key = 'Default'
        } else {
            If ($ColorTable.ContainsKey($Item.Extension)) {
                $Key = $Item.Extension
            } else {
                $Key = 'Default'
            }
        }

        $Color = $ColorTable[$Key]

        $Host.UI.RawUI.ForegroundColor = $Color
        $Item
        $Host.UI.RawUI.ForegroundColor = $OriginalForegroundColor
    }
}

Function Get-ChildItemColorFormatWide {
    Param(
        [string]$Path = "",
        [switch]$Force
    )

    $nnl = $True

    $Expression = "Get-ChildItem -Path `"$Path`" $Args"

    if ($Force) {$Expression += " -Force"}

    $Items = Invoke-Expression $Expression

    $lnStr = $Items | Select-Object Name | Sort-Object { "$_".Length } -Descending | Select-Object -First 1
    $len = $lnStr.Name.Length
    $width = $Host.UI.RawUI.WindowSize.Width
    $cols = If ($len) {($width + 1) / ($len + 2)} Else {1}
    $cols = [math]::floor($cols)
    if (!$cols) {$cols=1}

    $i = 0
    $pad = [math]::ceiling(($width + 2) / $cols) - 3

    ForEach ($Item in $Items) {
        if ($Item.GetType().Name -eq 'DirectoryInfo') {
            $DirectoryName = $Item.Parent.FullName
            $Key = 'Directory'

        } elseif ($Item.GetType().Name -eq "DictionaryEntry") {
            $DirectoryName = $Item.DirectoryName
            $Key = 'Default'

        } else {
            $DirectoryName = $Item.DirectoryName

            If ($ColorTable.ContainsKey($Item.Extension)) {
                $Key = $Item.Extension
            } else {
                $Key = 'Default'
            }
        }

        $Color = $ColorTable[$Key]

        if ($LastDirectoryName -ne $DirectoryName) {
            if($i -ne 0 -AND $Host.UI.RawUI.CursorPosition.X -ne 0){  # conditionally add an empty line
                Write-Host ""
            }
            Write-Host -Fore $OriginalForegroundColor ("`n   Directory: $DirectoryName`n")
        }

        $nnl = ++$i % $cols -ne 0

        # truncate the item name
        $towrite = $Item.Name
        if ($towrite.length -gt $pad) {
            $towrite = $towrite.Substring(0, $pad - 3) + "..."
        }

        Write-Host ("{0,-$pad}" -f $towrite) -Fore $Color -NoNewLine:$nnl
        if ($nnl) {
            Write-Host "  " -NoNewLine
        }

        $LastDirectoryName = $DirectoryName
    }

    if ($nnl) {  # conditionally add an empty line
        Write-Host ""
        Write-Host ""
    }
}

Export-ModuleMember -Function 'Get-*'
