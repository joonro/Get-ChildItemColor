$OriginalForegroundColor = $Host.UI.RawUI.ForegroundColor
if ([System.Enum]::IsDefined([System.ConsoleColor], 1) -eq "False") { $OriginalForegroundColor = "Gray" }

$Global:GetChildItemColorVerticalSpace = 1

. "$PSScriptRoot\Get-ChildItemColorTable.ps1"

Function Get-FileColor($Item) {
    $Key = 'Default'

    if ([bool]($Item.Attributes -band [IO.FileAttributes]::ReparsePoint)) {
        $Key = 'Symlink'
    } Else {
        If ($Item.GetType().Name -eq 'DirectoryInfo') {
            $Key = 'Directory'
        } Else {
           If ($Item.PSobject.Properties.Name -contains "Extension") {
               If ($GetChildItemColorTable.File.ContainsKey($Item.Extension)) {
                    $Key = $Item.Extension
                }
            }
        }
    }

    $Color = $GetChildItemColorTable.File[$Key]
    Return $Color
}

Function Get-ChildItemColor {
    Param(
        [string]$Path = ""
    )
    $Expression = "Get-ChildItem -Path `"$Path`" $Args"

    $Items = Invoke-Expression $Expression

    ForEach ($Item in $Items) {
        $Color = Get-FileColor $Item

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

    $lnStr = $Items | Select-Object Name | Sort-Object { $Host.UI.RawUI.LengthInBufferCells("$_") } -Descending | Select-Object -First 1
    $len = $Host.UI.RawUI.LengthInBufferCells($lnStr.Name)
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

        If ($LastParentName -ne $ParentName) {
            If ($i -ne 0 -AND $Host.UI.RawUI.CursorPosition.X -ne 0){  # conditionally add an empty line
                Write-Host ""
            }

            For ($l=1; $l -le $GetChildItemColorVerticalSpace; $l++) {
                Write-Host ""
            }

            Write-Host -Fore $OriginalForegroundColor "   $($ParentType):" -NoNewline

            $Color = $GetChildItemColorTable.File['Directory']
            Write-Host -Fore $Color " $ParentName"

            For ($l=1; $l -le $GetChildItemColorVerticalSpace; $l++) {
                Write-Host ""
            }

        }

        $nnl = ++$i % $cols -ne 0

        # truncate the item name
        $toWrite = $Item.Name
        If ($Host.UI.RawUI.LengthInBufferCells($toWrite) -gt $pad) {
            $toWrite = (CutString $toWrite $pad)
        }

        $Color = Get-FileColor $Item
        $widePad = $pad - ($Host.UI.RawUI.LengthInBufferCells($toWrite) - $toWrite.Length)
        Write-Host ("{0,-$widePad}" -f $toWrite) -Fore $Color -NoNewLine:$nnl

        If ($nnl) {
            Write-Host "  " -NoNewLine
        }

        $LastParentName = $ParentName
    }

    For ($l=1; $l -lt $GetChildItemColorVerticalSpace; $l++) {
        Write-Host ""
    }

    If ($nnl) {  # conditionally add an empty line
        Write-Host ""
    }
}

Add-Type -assemblyname System.ServiceProcess

. "$PSScriptRoot\PSColorHelper.ps1"
. "$PSScriptRoot\FileInfo.ps1"
. "$PSScriptRoot\ServiceController.ps1"
. "$PSScriptRoot\MatchInfo.ps1"
. "$PSScriptRoot\ProcessInfo.ps1"

$script:showHeader=$true

function Out-Default {
    [CmdletBinding(HelpUri='http://go.microsoft.com/fwlink/?LinkID=113362', RemotingCapability='None')]
    param(
        [switch]
        ${Transcript},

        [Parameter(Position=0, ValueFromPipeline=$true)]
        [psobject]
        ${InputObject})

    begin
    {
        try {
            For ($l=1; $l -lt $GetChildItemColorVerticalSpace; $l++) {
                Write-Host ""
            }

            $outBuffer = $null
            if ($PSBoundParameters.TryGetValue('OutBuffer', [ref]$outBuffer))
            {
                $PSBoundParameters['OutBuffer'] = 1
            }
            $wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand('Microsoft.PowerShell.Core\Out-Default', [System.Management.Automation.CommandTypes]::Cmdlet)
            $scriptCmd = {& $wrappedCmd @PSBoundParameters }

            $steppablePipeline = $scriptCmd.GetSteppablePipeline()
            $steppablePipeline.Begin($PSCmdlet)
        } catch {
            throw
        }
    }

    process
    {
        try {
            if(($_ -is [System.IO.DirectoryInfo]) -or ($_ -is [System.IO.FileInfo]))
            {
                FileInfo $_
                $_ = $null
            }

            elseif($_ -is [System.ServiceProcess.ServiceController])
            {
                ServiceController $_
                $_ = $null
            }

            elseif($_ -is [Microsoft.Powershell.Commands.MatchInfo])
            {
                MatchInfo $_
                $_ = $null
            }
            else {
                $steppablePipeline.Process($_)
            }
        } catch {
            throw
        }
    }

    end
    {
        try {
            For ($l=1; $l -le $GetChildItemColorVerticalSpace; $l++) {
                Write-Host ""
            }

            $script:showHeader=$true
            $steppablePipeline.End()
        } catch {
            throw
        }
    }
    <#

    .ForwardHelpTargetName Out-Default
    .ForwardHelpCategory Function

    #>
}

Export-ModuleMember -Function Out-Default, 'Get-*'
