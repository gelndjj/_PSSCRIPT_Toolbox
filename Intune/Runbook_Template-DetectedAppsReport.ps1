<#
.SYNOPSIS
    Generates a daily report of detected applications per managed device and uploads it to SharePoint.

.DESCRIPTION
    Uses Microsoft Graph (beta) and batching to retrieve apps per device, then uploads the report to a SharePoint document library using Azure Automation Managed Identity.

.REQUIREMENTS
    - Modules:
        • Microsoft.Graph
        • PnP.PowerShell
    - Azure Automation Managed Identity must have:
        • Microsoft Graph: DeviceManagementManagedDevices.Read.All
        • SharePoint: Contributor (or higher) on the target site

.NOTES
    Customize:
    - Tenant-specific SharePoint site URL
    - Target SharePoint folder
#>

# Connect to Microsoft Graph via Managed Identity
Connect-MgGraph -Identity

# Force token cache to avoid batch auth errors
Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/beta/organization" | Out-Null

# Connect to SharePoint
Connect-PnPOnline -Url "https://<YourSharePointSite>.sharepoint.com/sites/<YourSiteName>" -ManagedIdentity
$sharePointFolder = "Shared Documents/Reporting/Intune"

# Define file name
$timestamp = Get-Date -Format "yyyyMMdd_HHmm"
$fileName = "DetectedApps_Report_$timestamp.csv"
$localPath = "$fileName"

# Helper: Batch Graph requests
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

# Step 1: Retrieve all managed devices
Write-Output "📦 Getting all managed devices..."
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
Write-Output "    → Devices found: $($devices.Count)"

# Step 2: Build batch requests
Write-Output "📡 Building Graph batch requests..."
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

# Step 3: Execute batch requests
$responsesList = Send-MgGraphBatchRequests -requests $requests -Apiversion 'beta'
Write-Output "    → Responses received: $($responsesList.Count)"

# Step 4: Process responses
Write-Output "🔍 Processing detected apps data..."
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
        Write-Warning "Error for $deviceName: $($appsResponse.error.message)"
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

# Step 5: Export to CSV
$appRows | Sort-Object UserDisplayName, DeviceName, AppDisplayName | Export-Csv -Path $localPath -NoTypeInformation -Encoding UTF8
Write-Output "CSV created: $localPath"

# Step 6: Upload to SharePoint
Add-PnPFile -Path $localPath -Folder $sharePointFolder
Write-Output "Uploaded to SharePoint: $fileName"
