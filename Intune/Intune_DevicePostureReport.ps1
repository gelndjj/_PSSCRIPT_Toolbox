# Requires: PowerShell 7+, Microsoft.Graph
Connect-MgGraph -Scopes "DeviceManagementManagedDevices.Read.All"

$startTime = Get-Date
Write-Host "⏱️ Script started at $startTime"
Write-Host "🔄 Fetching managed devices list from Microsoft Graph..."

$baseUri = "https://graph.microsoft.com/beta/deviceManagement/managedDevices"
$deviceList = @()
$nextLink = $baseUri

# Gather all device IDs from paginated results
while ($nextLink) {
    $page = Invoke-MgGraphRequest -Uri $nextLink -Method GET
    $deviceList += $page.value
    $nextLink = $page.'@odata.nextLink'
}

Write-Host "📦 Total devices to process: $($deviceList.Count)"
Write-Host "🚀 Fetching full device details in parallel..."

# Parallel block to process each device in parallel
$results = $deviceList | ForEach-Object -Parallel {

    # Load the Microsoft.Graph module in each thread
    Import-Module Microsoft.Graph -Force

    # Auth is passed via parent session
    $id = $_.id
    $baseUri = "https://graph.microsoft.com/beta/deviceManagement/managedDevices"

    # Fetch full device object
    $fullDevice = Invoke-MgGraphRequest -Uri "$baseUri/$id" -Method GET

    # Most recent logon
    $logon = $fullDevice.usersLoggedOn |
             Sort-Object -Property lastLogOnDateTime -Descending |
             Select-Object -First 1

    # Most recent action
    $action = $fullDevice.deviceActionResults |
              Sort-Object -Property startDateTime -Descending |
              Select-Object -First 1

    # Build output row
    [PSCustomObject]@{
        Id                             = $fullDevice.id
        DeviceName                     = $fullDevice.deviceName
        SerialNumber                   = $fullDevice.serialNumber
        Model                          = $fullDevice.model
        Manufacturer                   = $fullDevice.manufacturer
        OperatingSystem                = $fullDevice.operatingSystem
        OSVersion                      = $fullDevice.osVersion
        DeviceType                     = $fullDevice.deviceType
        JoinType                       = $fullDevice.joinType
        AADRegistered                  = [bool]$fullDevice.aadRegistered
        AzureADDeviceId                = $fullDevice.azureADDeviceId
        EnrollmentType                 = $fullDevice.deviceEnrollmentType
        RegistrationState              = $fullDevice.deviceRegistrationState
        AutopilotEnrolled              = [bool]$fullDevice.autopilotEnrolled
        ManagedDeviceOwnerType         = $fullDevice.managedDeviceOwnerType
        ManagementState                = $fullDevice.managementState
        ManagementAgent                = $fullDevice.managementAgent
        IsEncrypted                    = [bool]$fullDevice.isEncrypted
        JailBroken                     = $fullDevice.jailBroken
        ComplianceState                = $fullDevice.complianceState
        LastSyncDateTime               = $fullDevice.lastSyncDateTime
        EnrolledDateTime               = $fullDevice.enrolledDateTime
        LastLogOnDateTime              = $logon.lastLogOnDateTime
        LastActionName                 = $action.actionName
        LastActionStart                = $action.startDateTime
        LastActionState                = $action.actionState
        EmailAddress                   = $fullDevice.emailAddress
        UserPrincipalName              = $fullDevice.userPrincipalName
        UserDisplayName                = $fullDevice.userDisplayName
        ManagedDeviceName              = $fullDevice.managedDeviceName
        WiFiMacAddress                 = $fullDevice.wiFiMacAddress
        EthernetMacAddress             = $fullDevice.ethernetMacAddress
        TotalStorageGB                 = [math]::Round(($fullDevice.totalStorageSpaceInBytes / 1GB), 2)
        FreeStorageGB                  = [math]::Round(($fullDevice.freeStorageSpaceInBytes / 1GB), 2)
        PartnerReportedThreatState     = $fullDevice.partnerReportedThreatState
        WindowsActiveMalwareCount      = $fullDevice.windowsActiveMalwareCount
        WindowsRemediatedMalwareCount  = $fullDevice.windowsRemediatedMalwareCount
        ChassisType                    = $fullDevice.chassisType
        IsSupervised                   = [bool]$fullDevice.isSupervised
        RetireAfterDateTime            = if ($fullDevice.retireAfterDateTime -eq '0001-01-01T00:00:00Z') { $null } else { $fullDevice.retireAfterDateTime }
        ManagementCertificateExpiry    = $fullDevice.managementCertificateExpirationDate
        Notes                          = $fullDevice.notes
    }

} -ThrottleLimit 10 -AsJob | Receive-Job -Wait

# Export to CSV
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$outputPath = ".\IntuneDevices_Report_$timestamp.csv"
$results | Export-Csv -Path $outputPath -NoTypeInformation -Encoding UTF8

# Timer summary
$endTime = Get-Date
$duration = $endTime - $startTime
Write-Host "`n✅ Export complete: $outputPath"
Write-Host "⏱️ Total duration: $($duration.ToString())"
