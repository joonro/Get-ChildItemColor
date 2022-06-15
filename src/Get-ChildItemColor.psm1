$OriginalForegroundColor = $Host.UI.RawUI.ForegroundColor
if ([System.Enum]::IsDefined([System.ConsoleColor], 1) -eq "False") { $OriginalForegroundColor = "Gray" }

$Global:GetChildItemColorVerticalSpace = 1

. "$PSScriptRoot\Get-ChildItemColorTable.ps1"

function Get-FileColor($item) {
    $key = 'Default'

    # check if in OneDrive
    if ($item.PSobject.Properties.Name -contains "PSParentPath") {
        $inOneDrive = ($item.PSParentPath.Contains($env:OneDrive) `
            -or $item.PSParentPath.Contains($env:OneDriveConsumerOneDrive) `
            -or $item.PSParentPath.Contains($env:OneDriveCommercial))
    } else {
        $inOneDrive = $false
    }

    if ([bool]($item.Attributes -band [IO.FileAttributes]::ReparsePoint) -and (-not $inOneDrive)) {
        $key = 'Symlink'
    } elseif ($item.GetType().Name -eq 'DirectoryInfo') {
        $key = 'Directory'
    } elseif ($item.PSobject.Properties.Name -contains "Extension") {
        If ($GetChildItemColorTable.File.ContainsKey($item.Extension)) {
            $key = $item.Extension
        }
    }

    $Color = $GetChildItemColorTable.File[$key]
    return $Color
}

function Get-ChildItemColorFormatWide {
[CmdletBinding(DefaultParameterSetName='Items', HelpUri='https://go.microsoft.com/fwlink/?LinkID=2096492')]

    param(
        [Parameter(ParameterSetName='Items', Position=0, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
        [string[]]
        ${Path},
        [switch]$Force,
        [switch]$HideHeader,
        [switch]$TrailingSlashDirectory
    )

    $nnl = $True

    $Expression = "Get-ChildItem -Path `"$Path`" $Args"

    if ($Force) {$Expression += " -Force"}

    $items = Invoke-Expression $Expression

    $ifPipeline = $PSCmdlet.MyInvocation.Line -Match '\|'

    if ($ifPipeline) {
        $items
    } else {
        $lnStr = $items | Select-Object Name | Sort-Object { LengthInBufferCells("$_") } -Descending | Select-Object -First 1
        $len = LengthInBufferCells($lnStr.Name)
        $width = $Host.UI.RawUI.WindowSize.Width
        $cols = if ($len) {[math]::Floor(($width + 1) / ($len + 2))} else {1}
        if (!$cols) {$cols = 1}

        $i = 0
        $pad = [math]::Ceiling(($width + 2) / $cols) - 3

        foreach ($item in $items) {
            if ($item.PSobject.Properties.Name -contains "PSParentPath") {
                if ($item.PSParentPath -match "FileSystem") {
                    $ParentType = "Directory"
                    $ParentName = $item.PSParentPath.Replace("Microsoft.PowerShell.Core\FileSystem::", "")
                } elseif ($item.PSParentPath -match "Registry") {
                    $ParentType = "Hive"
                    $ParentName = $item.PSParentPath.Replace("Microsoft.PowerShell.Core\Registry::", "")
                }
            } else {
                $ParentType = ""
                $ParentName = ""
                $LastParentName = $ParentName
            }

            if ($i -eq 0 -and $HideHeader) {
                    Write-Host ""
            }

            # write header
            if ($LastParentName -ne $ParentName -and -not $HideHeader) {
                if ($i -ne 0 -AND $Host.UI.RawUI.CursorPosition.X -ne 0){  # conditionally add an empty line
                    Write-Host ""
                }

                for ($l=1; $l -le $GetChildItemColorVerticalSpace; $l++) {
                    Write-Host ""
                }

                Write-Host -Fore $OriginalForegroundColor "   $($ParentType):" -NoNewline

                $Color = $GetChildItemColorTable.File['Directory']
                Write-Host -Fore $Color " $ParentName"

                for ($l=1; $l -le $GetChildItemColorVerticalSpace; $l++) {
                    Write-Host ""
                }
            }

            $nnl = ++$i % $cols -ne 0

            # truncate the item name
            $toWrite = $item.Name

            if ($TrailingSlashDirectory -and $item.GetType().Name -eq 'DirectoryInfo') {
                $toWrite += '\'
            }

            $itemLength = LengthInBufferCells($toWrite)
            if ($itemLength -gt $pad) {
                $toWrite = (CutString $toWrite $pad)
                $itemLength = LengthInBufferCells($toWrite)
            }

            $color = Get-FileColor $item
            $widePad = $pad - ($itemLength - $toWrite.Length)
            Write-Host ("{0,-$widePad}" -f $toWrite) -Fore $color -NoNewLine:$nnl

            if ($nnl) {
                Write-Host "  " -NoNewLine
            }

            $LastParentName = $ParentName
        }

        for ($l=1; $l -lt $GetChildItemColorVerticalSpace; $l++) {
            Write-Host ""
        }

        if ($nnl) {  # conditionally add an empty line
            Write-Host ""
        }
    }
}

Add-Type -assemblyname System.ServiceProcess

. "$PSScriptRoot\PSColorHelper.ps1"
. "$PSScriptRoot\FileInfo.ps1"
. "$PSScriptRoot\ServiceController.ps1"
. "$PSScriptRoot\MatchInfo.ps1"
. "$PSScriptRoot\ProcessInfo.ps1"

$script:ShowHeader=$True

function Out-ChildItemColor {
    [CmdletBinding(HelpUri='http://go.microsoft.com/fwlink/?LinkID=113362', RemotingCapability='None')]
    param(
        [switch] ${Transcript},
        [Parameter(Position=0, ValueFromPipeline=$True)]  [psobject]  ${InputObject}
    )

    begin {
        try {
            for ($l=1; $l -lt $GetChildItemColorVerticalSpace; $l++) {
                Write-Host ""
            }

            $outBuffer = $null
            if ($PSBoundParameters.TryGetValue('OutBuffer', [ref]$outBuffer)) {
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

    process {
        try {
            if (($_ -is [System.IO.DirectoryInfo]) -or ($_ -is [System.IO.FileInfo])) {
                FileInfo $_
                $_ = $Null
            }

            elseif ($_ -is [System.ServiceProcess.ServiceController]) {
                ServiceController $_
                $_ = $Null
            }

            elseif ($_ -is [Microsoft.Powershell.Commands.MatchInfo]) {
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

    end {
        try {
            for ($l=1; $l -le $GetChildItemColorVerticalSpace; $l++) {
                Write-Host ""
            }

            $script:ShowHeader=$true
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

function Get-ChildItemColor {
[CmdletBinding(DefaultParameterSetName='Items', HelpUri='https://go.microsoft.com/fwlink/?LinkID=2096492')]
param(
    [Parameter(ParameterSetName='Items', Position=0, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
    [string[]]
    ${Path},

    [Parameter(ParameterSetName='LiteralItems', Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
    [Alias('PSPath','LP')]
    [string[]]
    ${LiteralPath},

    [Parameter(Position=1)]
    [string]
    ${Filter},

    [string[]]
    ${Include},

    [string[]]
    ${Exclude},

    [Alias('s')]
    [switch]
    ${Recurse},

    [uint32]
    ${Depth},

    [switch]
    ${Force},

    [switch]
    ${Name})


dynamicparam
{
    try {
        $targetCmd = $ExecutionContext.InvokeCommand.GetCommand('Microsoft.PowerShell.Management\Get-ChildItem', [System.Management.Automation.CommandTypes]::Cmdlet, $PSBoundParameters)
        $dynamicParams = @($targetCmd.Parameters.GetEnumerator() | Microsoft.PowerShell.Core\Where-Object { $_.Value.IsDynamic })
        if ($dynamicParams.Length -gt 0)
        {
            $paramDictionary = [Management.Automation.RuntimeDefinedParameterDictionary]::new()
            foreach ($param in $dynamicParams)
            {
                $param = $param.Value

                if(-not $MyInvocation.MyCommand.Parameters.ContainsKey($param.Name))
                {
                    $dynParam = [Management.Automation.RuntimeDefinedParameter]::new($param.Name, $param.ParameterType, $param.Attributes)
                    $paramDictionary.Add($param.Name, $dynParam)
                }
            }

            return $paramDictionary
        }
    } catch {
        throw
    }
}

begin
{
    try {
        $outBuffer = $null
        if ($PSBoundParameters.TryGetValue('OutBuffer', [ref]$outBuffer))
        {
            $PSBoundParameters['OutBuffer'] = 1
        }

        $wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand('Microsoft.PowerShell.Management\Get-ChildItem', [System.Management.Automation.CommandTypes]::Cmdlet)
        $scriptCmd = {& $wrappedCmd @PSBoundParameters }

        $ifPipeline = $PSCmdlet.MyInvocation.Line -Match '\|'

        if ($ifPipeline) {
            $steppablePipeline = $scriptCmd.GetSteppablePipeline($myInvocation.CommandOrigin)
            $steppablePipeline.Begin($PSCmdlet)
        }

    } catch {
        throw
    }
}

process
{
    try {
        $items = $scriptCmd.invoke()

        if ($ifPipeline) {
            $steppablePipeline.Process($_)
        } else {
            $items | Out-ChildItemColor
        }
    } catch {
        throw
    }
}

end
{
    try {
        if ($ifPipeline) {
            $steppablePipeline.End()
        }
    } catch {
        throw
    }
}
}
