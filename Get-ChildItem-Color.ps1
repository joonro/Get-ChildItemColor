function Get-ChildItem-Color {

    if ($Args[0] -eq $true) {
        $ifwide = $true
    } else {
        $ifwide = $false
    }

    if ($ifwide) {
        if($Args.Length -le 1) {
            $Args = @()
        }
        else {
            $Args = $Args[1..($Args.length - 1)]
        }
    }
    
    $width = $host.UI.RawUI.WindowSize.Width
   
    $items = Invoke-Expression "Get-ChildItem $Args"
    
    $lnStr = $items | select-object Name | sort-object { "$_".length } -descending | select-object -first 1
    $len = $lnStr.name.length
    $cols = If ($len) {($width+1)/($len+2)} Else {1};
    $cols = [math]::floor($cols);
    if(!$cols){ $cols=1;}

    $color_fore = $Host.UI.RawUI.ForegroundColor

    $compressed_list = @(".7z", ".gz", ".rar", ".tar", ".zip")
    $executable_list = @(".exe", ".bat", ".cmd", ".py", ".pl", ".ps1",
                         ".psm1", ".vbs", ".rb", ".reg", ".fsx", ".sh", ".cmd")
    $dll_pdb_list = @(".dll", ".pdb")
    $text_files_list = @(".csv", ".lg", "markdown", ".rst", ".txt", ".log")
    $configs_list = @(".cfg", ".config", ".conf", ".ini", ".json")

    $color_table = @{}
    foreach ($Extension in $compressed_list) {
        $color_table[$Extension] = "Yellow"
    }

    foreach ($Extension in $executable_list) {
        $color_table[$Extension] = "Blue"
    }

    foreach ($Extension in $text_files_list) {
        $color_table[$Extension] = "Cyan"
    }

    foreach ($Extension in $dll_pdb_list) {
        $color_table[$Extension] = "Darkgreen"
    }

    foreach ($Extension in $configs_list) {
        $color_table[$Extension] = "DarkYellow"
    }

    $i = 0
    $pad = [math]::ceiling(($width+2) / $cols) - 3
    $nnl = $false

    $items |
    %{
        if ($_.GetType().Name -eq 'DirectoryInfo') {
            $c = 'Green'
            $length = ""
        } else {
            $c = $color_table[$_.Extension]

            if ($c -eq $none) {
                $c = $color_fore
            }

            $length = $_.length
        }

        # get the directory name
        if ($_.GetType().Name -eq "FileInfo") {
            $DirectoryName = $_.DirectoryName
        } elseif ($_.GetType().Name -eq "DirectoryInfo") {
            $DirectoryName = $_.Parent.FullName
        }
        
        if ($ifwide) {  # Wide (ls)
            if ($LastDirectoryName -ne $DirectoryName) {  # change this to `$LastDirectoryName -ne $DirectoryName` to show DirectoryName
                if($i -ne 0 -AND $host.ui.rawui.CursorPosition.X -ne 0){ # conditionally add an empty line
                    write-host ""
                }
                Write-Host -Fore $color_fore ("`n   Directory: $DirectoryName`n")
            }

            $nnl = ++$i % $cols -ne 0

            # truncate the item name
            $towrite = $_.Name
            if ($towrite.length -gt $pad) {
                $towrite = $towrite.Substring(0, $pad - 3) + "..."
            }

            Write-Host ("{0,-$pad}" -f $towrite) -Fore $c -NoNewLine:$nnl
            if($nnl){
                write-host "  " -NoNewLine
            }
        } else {
            If ($LastDirectoryName -ne $DirectoryName) {  # first item - print out the header
                Write-Host "`n    Directory: $DirectoryName`n"
                Write-Host "Mode                LastWriteTime     Length Name"
                Write-Host "----                -------------     ------ ----"
            }
            $Host.UI.RawUI.ForegroundColor = $c

            Write-Host ("{0,-7} {1,25} {2,10} {3}" -f $_.mode,
                        ([String]::Format("{0,10}  {1,8}",
                                          $_.LastWriteTime.ToString("d"),
                                          $_.LastWriteTime.ToString("t"))),
                        $length, $_.name)
           
            $Host.UI.RawUI.ForegroundColor = $color_fore

            ++$i  # increase the counter
        }
        $LastDirectoryName = $DirectoryName
    }

    if ($nnl) {  # conditionally add an empty line
        Write-Host ""
    }
}

function Get-ChildItem-Format-Wide {
    $New_Args = @($true)
    $New_Args += $Args
    Invoke-Expression "Get-ChildItem-Color $New_Args"
}
