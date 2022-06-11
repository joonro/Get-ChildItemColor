function MatchInfo {
    param (
        [Parameter(Mandatory=$True, Position=1)]
        $match
    )

    Write-host $match.RelativePath($pwd) -ForegroundColor $global:GetChildItemColorTable.Match["Path"] -noNewLine
    Write-host ':' -ForegroundColor $global:GetChildItemColorTable.Match["Default"] -noNewLine
    Write-host $match.LineNumber -ForegroundColor $global:GetChildItemColorTable.Match["Line"] -noNewLine
    Write-host ':' -ForegroundColor $global:GetChildItemColorTable.Match["Default"] -noNewLine
    Write-host $match.Line -ForegroundColor $global:GetChildItemColorTable.Match["Line"]
}
