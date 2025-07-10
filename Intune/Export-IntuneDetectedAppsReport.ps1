# Connect to Microsoft Graph (beta required for detectedApps)
Connect-MgGraph -Scopes "DeviceManagementManagedDevices.Read.All"

# Function to batch Graph requests
function Send-MgGraphBatchRequests {
    param (
        [Parameter(Mandatory)] $requests,
        [Parameter()] [ValidateSet('beta','v1.0')] $Apiversion = 'v1.0',
        [int] $batchSize = 20
    )

    $batches = [System.Collections.Generic.List[pscustomobject]]::new()
    $responses = [System.Collections.Concurrent.ConcurrentBag[System.Object]]::new()

    for ($i = 0; $i -lt $requests.Count; $i += $batchSize) {
        $end = [math]::Min($i + $batchSize - 1, $requests.Count - 1)
        $batches.Add(@{
            'Method'      = 'Post'
            'Uri'         = "https://graph.microsoft.com/$Apiversion/`$batch"
            'ContentType' = 'application/json'
            'Body'        = @{ 'requests' = @($requests[$i..$end]) } | ConvertTo-Json -Depth 5
        })
    }

    $batches | ForEach-Object {
        $result = Invoke-MgGraphRequest @_ 
        foreach ($r in $result.responses) {
            $responses.Add([pscustomobject]@{
                requestid   = $r.id
                body        = $r.body
                error       = $r.error
            })
        }
    }

    return $responses
}

# Start timer
$scriptStart = Get-Date
$timer = [System.Diagnostics.Stopwatch]::StartNew()

Write-Host "[+] Retrieving all devices..."
$devices = Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/beta/deviceManagement/managedDevices?`$select=id,deviceName" -OutputType PSObject
$allDevices = @()
do {
    $allDevices += $devices.value
    $next = $devices.'@odata.nextLink'
    if ($next) {
        $devices = Invoke-MgGraphRequest -Uri $next -Method GET -OutputType PSObject
    }
} while ($next)
$devices = $allDevices
Write-Host "    → Retrieved $($devices.Count) devices."

# Build batch requests for detectedApps + userDisplayName
Write-Host "[+] Building batch requests..."
$requests = [System.Collections.Generic.List[object]]::new()
foreach ($device in $devices) {
    $requests.Add(@{
        id     = "$($device.Id)_apps"
        method = "GET"
        url    = "/deviceManagement/managedDevices/$($device.Id)/detectedApps"
    })
    $requests.Add(@{
        id     = "$($device.Id)_user"
        method = "GET"
        url    = "/deviceManagement/managedDevices/$($device.Id)?`$select=userDisplayName"
    })
}

Write-Host "[+] Sending batched requests..."
$responsesList = Send-MgGraphBatchRequests -requests $requests -Apiversion 'beta'
Write-Host "    → Received $($responsesList.Count) responses."

Write-Host "[+] Processing data..."
$appRows = foreach ($device in $devices) {
    $deviceId = $device.Id
    $deviceName = $device.deviceName

    $appsResponse = $responsesList | Where-Object { $_.requestid -eq "$deviceId`_apps" }
    $userResponse = $responsesList | Where-Object { $_.requestid -eq "$deviceId`_user" }

    $userDisplayName = if ($userResponse -and $userResponse.body.userDisplayName) {
        $userResponse.body.userDisplayName
    } else {
        "N/A"
    }

    if ($appsResponse.error) {
        Write-Warning "Error for $deviceName $($appsResponse.error.message)"
        continue
    }

    foreach ($app in $appsResponse.body.value) {
        [PSCustomObject]@{
            UserDisplayName = $userDisplayName
            DeviceName      = $deviceName
            AppDisplayName  = $app.displayName
            Version         = $app.version
            Publisher       = $app.publisher
            Platform        = $app.platform
            AppId           = $app.id
        }
    }
}

# Export to CSV
$outputPath = "DetectedApps_Report_{0:yyyyMMdd_HHmm}.csv" -f (Get-Date)
$appRows | Sort-Object UserDisplayName, DeviceName, AppDisplayName | Export-Csv -Path $outputPath -NoTypeInformation -Encoding UTF8

# Stop timer and output summary
$timer.Stop()
$scriptEnd = Get-Date
Write-Host "✔ Done. Report saved to: $outputPath"
Write-Host "🕒 Total execution time: $($timer.Elapsed.ToString())"
