function Get-ChildItem-Color {
    if ($Args[0] -eq $true) {
        $ifwide = $true

        if ($Args.Length -gt 1) {
            $Args = $Args[1..($Args.length - 1)]
        } else {
            $Args = @()
        }
    } else {
        $ifwide = $false
    }

    if (($Args[0] -eq "-a") -or ($Args[0] -eq "--all")) {
        $Args[0] = "-Force"
    }

    $width =  $host.UI.RawUI.WindowSize.Width
    $cols = 3
    $color_fore = $Host.UI.RawUI.ForegroundColor

    $compressed_list = @(".zip", ".tar", ".gz", ".rar")
    $executable_list = @(".exe", ".bat", ".cmd", ".py", ".pl", ".ps1",
                         ".psm1", ".vbs", ".rb", ".reg", ".fsx")
    $dll_pdb_list = @(".dll", ".pdb")
    $text_files_list = @(".txt", ".csv", ".lg")
    $configs_list = @(".cfg", ".config", ".conf", ".ini")

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
        $color_table[$Extension] = "Yellow"
    }

    $i = 0
    $pad = [int]($width / $cols) - 1
    $nll = $false

    Invoke-Expression ("Get-ChildItem $Args") |
    %{
        if ($_.GetType().Name -eq 'DirectoryInfo') {
            $c = 'Green'
        } else {
            $c = $color_table[$_.Extension]

            if ($c -eq $none) {
                $c = $color_fore
            }
        }

        if ($ifwide) {
            if ($i -eq -1) {  # change this to `-eq 0` to show DirectoryName
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

function Get-ChildItem-Format-Wide {
    $New_Args = @($true)
    $New_Args += $Args
    Invoke-Expression ("Get-ChildItem-Color $New_Args")
}

