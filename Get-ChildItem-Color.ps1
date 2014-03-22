function Get-ChildItem-Color {
    if ($Args[0] -eq $true) {
        $ifwide = $true
        $Args = $Args[1..($Args.length-1)]
    } else {
        $ifwide = $false
    }

    if (($Args[0] -eq "-a") -or ($Args[0] -eq "--all"))  {
        $Args[0] = "-Force"
    }

    $width =  $host.UI.RawUI.WindowSize.Width
    $cols = 3
    $color_fore = $Host.UI.RawUI.ForegroundColor

    $compressed_list = @(".zip", ".tar", ".gz", ".rar")
    $executable_list = @(".exe", ".bat", ".cmd", ".py", ".pl", ".ps1",
                         ".psm1", ".vbs", ".rb", ".reg", ".fsx")
    $text_files_list = @(".txt", ".cfg", ".conf", ".ini", ".csv", ".lg")
    $dll_pdb_list = @(".dll", ".pdb")
    $configs_list = @(".config", ".conf", ".ini")

    $color_table = @{}
    foreach ($Extension in $compressed_list) {
        $color_table[$Extension] = "yellow"
    }

    foreach ($Extension in $executable_list) {
        $color_table[$Extension] = "blue"
    }

    foreach ($Extension in $text_files_list) {
        $color_table[$Extension] = "cyan"
    }

    foreach ($Extension in $dll_pdb_list) {
        $color_table[$Extension] = "darkgreen"
    }

    foreach ($Extension in $configs_list) {
        $color_table[$Extension] = "cyan"
    }

    $i = 0
    $pad = [int]($width/$cols) - 1
    $nll = $false

    Invoke-Expression ("Get-ChildItem $Args") |
    %{
        if ($_.gettype().name -eq 'directoryinfo') {
            $c = 'green'
        } else {
            $c = $color_table[$_.Extension]

            if ($c -eq $none) {
                $c = $color_fore
            }
        }

        if ($ifwide) {
            if ($i -eq -1) {  # change this to `$i -eq 0` to show DirectoryName
                if ($_.GetType().Name -eq "FileInfo") {
                    $DirectoryName = $_.DirectoryName
                } elseif ($_.GetType().Name -eq "DirectoryInfo") {
                    $DirectoryName = $_.Parent.FullName
                }
                Write-Host ""
                Write-Host -Fore 'Green' ("   Directory: " + $DirectoryName)
                Write-Host ""
            }

            $nnl = ++$i % $cols -ne 0

            $towrite = $_.Name
            if ($towrite.length -gt $pad - 2) {
                $towrite = $towrite.Substring(0, $pad - 5) + "..."
            }

            Write-Host ("{0,-$pad}" -f $towrite) -Fore $c -NoNewLine:$nnl
        } else {
            $Host.UI.RawUI.ForegroundColor = $c
            echo $_
            $Host.UI.RawUI.ForegroundColor = $color_fore
        }
    }
    if ($nnl) {
        Write-Host ""
    }
}
