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

Export-ModuleMember -Function 'Get-*'
