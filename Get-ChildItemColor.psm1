$ForegroundColor = $Host.UI.RawUI.ForegroundColor

$compressed_list = @(".7z", ".gz", ".rar", ".tar", ".zip")
$executable_list = @(".exe", ".bat", ".cmd", ".py", ".pl", ".ps1",
                        ".psm1", ".vbs", ".rb", ".reg", ".fsx", ".sh", ".cmd")
$dll_pdb_list = @(".dll", ".pdb")
$text_files_list = @(".csv", ".log", "markdown", ".rst", ".txt")
$configs_list = @(".cfg", ".conf", ".config", ".ini", ".json")

$ColorTable = @{}
foreach ($Extension in $compressed_list) {
    $ColorTable[$Extension] = "Yellow"
}

foreach ($Extension in $executable_list) {
    $ColorTable[$Extension] = "Blue"
}

foreach ($Extension in $text_files_list) {
    $ColorTable[$Extension] = "Cyan"
}

foreach ($Extension in $dll_pdb_list) {
    $ColorTable[$Extension] = "Darkgreen"
}

foreach ($Extension in $configs_list) {
    $ColorTable[$Extension] = "DarkYellow"
}

Function Get-ChildItemColor {
    Param(
        [string]$Path = "",
        [switch]$Force
    )
    $expression = "Get-ChildItem -Path `"$Path`" $Args"

    if ($Force) {$expression += " -Force"}

    $items = Invoke-Expression $expression

    if ($items[0].GetType().Name -eq "DictionaryEntry") {
        Return $items
    }
    
    $i = 0
    $nnl = $false

    $items | %{
        if ($_.GetType().Name -eq 'DirectoryInfo') {
            $DirectoryName = $_.Parent.FullName
            $Color = 'Green'
            $Length = ""
        } else {
            $DirectoryName = $_.DirectoryName
            $Color = $ColorTable[$_.Extension]

            if ($Color -eq $None) {
                $Color = $ForegroundColor
            }

            $Length = $_.Length
        }

        If ($LastDirectoryName -ne $DirectoryName) {  # first item - print out the header
            Write-Host "`n    Directory: $DirectoryName`n"
            Write-Host "Mode                LastWriteTime     Length Name"
            Write-Host "----                -------------     ------ ----"
        }
        $Host.UI.RawUI.ForegroundColor = $Color

        Write-Host ("{0,-7} {1,25} {2,10} {3}" -f $_.mode,
                    ([String]::Format("{0,10}  {1,8}",
                                        $_.LastWriteTime.ToString("d"),
                                        $_.LastWriteTime.ToString("t"))),
                    $Length, $_.Name)

        $Host.UI.RawUI.ForegroundColor = $ForegroundColor

        ++$i  # increase the counter

        $LastDirectoryName = $DirectoryName
    }

    if ($nnl) {  # conditionally add an empty line
        Write-Host ""
    }
}

Function Get-ChildItemColorFormatWide {
    Param(
        [string]$Path = "",
        [switch]$Force
    )
    $expression = "Get-ChildItem -Path `"$Path`" $Args"

    if ($Force) {$expression += " -Force"}

    $items = Invoke-Expression $expression

    if ($items[0].GetType().Name -eq "DictionaryEntry") {
        Return $items
    }
    
    $lnStr = $items | select-object Name | sort-object { "$_".length } -descending | select-object -first 1
    $len = $lnStr.name.length
    $width = $host.UI.RawUI.WindowSize.Width
    $cols = If ($len) {($width + 1) / ($len + 2)} Else {1}
    $cols = [math]::floor($cols)
    if (!$cols) {$cols=1}

    $i = 0
    $pad = [math]::ceiling(($width + 2) / $cols) - 3
    $nnl = $false

    $items | %{
        if ($_.GetType().Name -eq 'DirectoryInfo') {
            $DirectoryName = $_.Parent.FullName

            $Color = 'Green'
            $Color = $ForegroundColor
        } else {
            $DirectoryName = $_.DirectoryName

            $Color = $ColorTable[$_.Extension]

            if ($Color -eq $None) {
                $Color = $ForegroundColor
            }
        }

        if ($LastDirectoryName -ne $DirectoryName) {
            if($i -ne 0 -AND $host.ui.rawui.CursorPosition.X -ne 0){  # conditionally add an empty line
                Write-Host ""
            }
            Write-Host -Fore $ForegroundColor ("`n   Directory: $DirectoryName`n")
        }

        $nnl = ++$i % $cols -ne 0

        # truncate the item name
        $towrite = $_.Name
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
    }
}

Export-ModuleMember -Function 'Get-*'
