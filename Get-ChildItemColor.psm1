$OriginalForegroundColor = $Host.UI.RawUI.ForegroundColor
if ([System.Enum]::IsDefined([System.ConsoleColor], 1) -eq "False") { $OriginalForegroundColor = "Gray" }

$global:GetChildItemColorExtensions = @{
    CompressedList = @(".7z", ".gz", ".rar", ".tar", ".zip")
    ExecutableList = @(".exe", ".bat", ".cmd", ".py", ".pl", ".ps1",
                        ".psm1", ".vbs", ".rb", ".reg", ".fsx", ".sh")
    DllPdbList = @(".dll", ".pdb")
    TextList = @(".csv", ".log", ".markdown", ".rst", ".txt")
    ConfigsList = @(".cfg", ".conf", ".config", ".ini", ".json")
}

$global:GetChildItemColorTable = @{
    Default = $OriginalForegroundColor
    Directory = "Green"
}

ForEach ($Extension in $GetChildItemColorExtensions.CompressedList) {
    $GetChildItemColorTable.Add($Extension, "Yellow")
}

ForEach ($Extension in $GetChildItemColorExtensions.ExecutableList) {
    $GetChildItemColorTable.Add($Extension, "Blue")
}

ForEach ($Extension in $GetChildItemColorExtensions.TextList) {
    $GetChildItemColorTable.Add($Extension, "Cyan")
}

ForEach ($Extension in $GetChildItemColorExtensions.DllPdbList) {
    $GetChildItemColorTable.Add($Extension, "DarkGreen")
}

ForEach ($Extension in $GetChildItemColorExtensions.ConfigsList) {
    $GetChildItemColorTable.Add($Extension, "DarkYellow")
}


Function Get-Color($Item) {
    $Key = 'Default'

    If ($Item.GetType().Name -eq 'DirectoryInfo') {
        $Key = 'Directory'
    } Else {
        If ($Item.PSobject.Properties.Name -contains "Extension") {
            If ($GetChildItemColorTable.ContainsKey($Item.Extension)) {
                $Key = $Item.Extension
            }
        }
    }

    $Color = $GetChildItemColorTable[$Key]
    Return $Color
}


Function Get-ChildItemColor {
    Param(
        [string]$Path = ""
    )
    $Expression = "Get-ChildItem -Path `"$Path`" $Args"

    $Items = Invoke-Expression $Expression

    ForEach ($Item in $Items) {
        $Color = Get-Color $Item

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
    $cols = If ($len) {[math]::Floor(($width + 1) / ($len + 2))} Else {1}
    if (!$cols) {$cols = 1}

    $i = 0
    $pad = [math]::Ceiling(($width + 2) / $cols) - 3

    ForEach ($Item in $Items) {
        If ($Item.PSobject.Properties.Name -contains "PSParentPath") {
            If ($Item.PSParentPath -match "FileSystem") {
                $ParentType = "Directory"
                $ParentName = $Item.PSParentPath.Replace("Microsoft.PowerShell.Core\FileSystem::", "")
            }
            ElseIf ($Item.PSParentPath -match "Registry") {
                $ParentType = "Hive"
                $ParentName = $Item.PSParentPath.Replace("Microsoft.PowerShell.Core\Registry::", "")
            }
        } Else {
            $ParentType = ""
            $ParentName = ""
            $LastParentName = $ParentName
        }

        $Color = Get-Color $Item

        If ($LastParentName -ne $ParentName) {
            If($i -ne 0 -AND $Host.UI.RawUI.CursorPosition.X -ne 0){  # conditionally add an empty line
                Write-Host ""
            }
            Write-Host -Fore $OriginalForegroundColor ("`n   $($ParentType): $ParentName`n")
        }

        $nnl = ++$i % $cols -ne 0

        # truncate the item name
        $toWrite = $Item.Name
        If ($toWrite.length -gt $pad) {
            $toWrite = $toWrite.Substring(0, $pad - 3) + "..."
        }

        Write-Host ("{0,-$pad}" -f $toWrite) -Fore $Color -NoNewLine:$nnl

        If ($nnl) {
            Write-Host "  " -NoNewLine
        }

        $LastParentName = $ParentName
    }

    If ($nnl) {  # conditionally add an empty line
        Write-Host ""
        Write-Host ""
    }
}

Export-ModuleMember -Function 'Get-*'
