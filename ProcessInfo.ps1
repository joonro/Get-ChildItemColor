function Write-Color-Process
{
    param ([string]$color = "white", $file)

    Write-host ("{0,-7} {1,25} {2,10} {3}" -f $file.mode, ([String]::Format("{0,10}  {1,8}", $file.LastWriteTime.ToString("d"), $file.LastWriteTime.ToString("t"))), (Write-FileLength $file.length), $file.name) -foregroundcolor $color
}

function ProcessInfo {
        param (
        [Parameter(Mandatory=$True,Position=1)]
        $process
    )

    if($script:showHeader)
    {
        Write-Host        
        Write-Host 'Handles  NPM(K)    PM(K)      WS(K) VM(M)   CPU(s)     Id ProcessName'
        Write-Host '-------  ------    -----      ----- -----   ------     -- -----------'
        $script:showHeader=$false
    }
    $id = $_.Id
    $owner = (Get-WmiObject -Class Win32_Process -Filter "ProcessId = $id").getowner()

    Write-Host ("{0,7} {1,7} {2,8} {3} {4}" -f $_.Handles, `
        [math]::Round($_.NonpagedSystemMemorySize / 1KB), `
        [math]::Round($_.PagedMemorySize / 1KB),
        $owner.domain,
        $owner.user

        )
}