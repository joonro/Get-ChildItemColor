# Outputs a line of a ServiceController
function Write-Color-Service
{
    param ([string]$color = "white", $service)

    Write-host ("{0,-8}" -f $_.Status) -foregroundcolor $color -noNewLine
    Write-host (" {0,-18} {1,-39}" -f (CutString $_.Name 18), (CutString $_.DisplayName 38)) -foregroundcolor "white"
}

function ServiceController {
    param (
        [Parameter(Mandatory=$True,Position=1)]
        $service
    )

    if($script:showHeader)
    {
       Write-Host
       Write-Host "Status   Name               DisplayName"
       $script:showHeader=$false
    }

    if ($service.Status -eq 'Stopped')
    {
        Write-Color-Service $global:PSColor.Service.Stopped.Color $service
    }
    elseif ($service.Status -eq 'Running')
    {
        Write-Color-Service $global:PSColor.Service.Running.Color $service
    }
    else {
        Write-Color-Service $global:PSColor.Service.Default.Color $service
    }
}