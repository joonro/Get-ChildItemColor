function MatchInfo {
    param (
        [Parameter(Mandatory=$True, Position=1)]
        $Match
    )

    Write-host $Match.RelativePath($pwd) -ForegroundColor $Global:GetChildItemColorTable.Match["Path"] -noNewLine
    Write-host ':' -ForegroundColor $Global:GetChildItemColorTable.Match["Default"] -noNewLine
    Write-host $Match.LineNumber -ForegroundColor $global:GetChildItemColorTable.Match["Line"] -noNewLine
    Write-host ':' -ForegroundColor $Global:GetChildItemColorTable.Match["Default"] -noNewLine
    Write-host $Match.Line -ForegroundColor $Global:GetChildItemColorTable.Match["Line"]
}
