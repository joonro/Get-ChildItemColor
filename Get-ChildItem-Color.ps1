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

    $regex_opts = ([System.Text.RegularExpressions.RegexOptions]::IgnoreCase `
    -bor [System.Text.RegularExpressions.RegexOptions]::Compiled)
     
    $re_compressed = New-Object System.Text.RegularExpressions.Regex(
    '\.(zip|tar|gz|rar)$', $regex_opts)
    $re_executable = New-Object System.Text.RegularExpressions.Regex(
    '\.(exe|bat|cmd|py|pl|ps1|psm1|vbs|rb|reg|fsx)$', $regex_opts)
    $re_dll_pdb = New-Object System.Text.RegularExpressions.Regex(
    '\.(dll|pdb)$', $regex_opts)
    $re_configs = New-Object System.Text.RegularExpressions.Regex(
    '\.(config|conf|ini)$', $regex_opts)
    $re_text_files = New-Object System.Text.RegularExpressions.Regex(
    '\.(txt|cfg|conf|ini|csv|log)$', $regex_opts)

    $i = 0
    $pad = [int]($width/$cols) - 1
    $nll = $false
 
    Invoke-Expression ("Get-ChildItem $Args") | 
    %{ 
        $c = $color_fore
        if ($_.GetType().Name -eq 'DirectoryInfo') {
            $c = 'Green'
        } elseif ($re_compressed.IsMatch($_.Extension)) {
            $c = 'Yellow'
        } elseif ($re_executable.IsMatch($_.Extension)) {
            $c = 'Blue'
        } elseif ($re_text_files.IsMatch($_.Extension)) {
            $c = 'Cyan'
        } elseif ($re_dll_pdb.IsMatch($_.Extension)) {
            $c = 'DarkGreen'
        } elseif ($re_configs.IsMatch($_.Extension)) {
            $c = 'Yellow'
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
