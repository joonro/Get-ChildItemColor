function MatchInfo {
    param (
        [Parameter(Mandatory=$True,Position=1)]
        $match
    )

    Write-host $match.RelativePath($pwd) -foregroundcolor $global:PSColor.Match.Path.Color -noNewLine
    Write-host ':' -foregroundcolor $global:PSColor.Match.Default.Color -noNewLine
    Write-host $match.LineNumber -foregroundcolor $global:PSColor.Match.LineNumber.Color -noNewLine
    Write-host ':' -foregroundcolor $global:PSColor.Match.Default.Color -noNewLine
    Write-host $match.Line -foregroundcolor $global:PSColor.Match.Line.Color
}