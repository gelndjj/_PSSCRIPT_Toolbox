<#
.SYNOPSIS
    Generates a daily snapshot of all Dynamic Distribution Lists (DDLs) in Exchange Online, including recipient filters.

.DESCRIPTION
    This runbook connects to Exchange Online using Managed Identity, retrieves all Dynamic Distribution Lists and their filters,
    formats them into a readable report, and uploads the result to a SharePoint document library.

.REQUIREMENTS
    - ExchangeOnlineManagement module
    - PnP.PowerShell module
    - Azure Automation Managed Identity must be:
        • Exchange Admin
        • SharePoint Site Contributor (or higher) on the target SharePoint site

.NOTES
    Customize the SharePoint site URL and folder path below before running.

#>

# Connect to Exchange Online via Managed Identity
Connect-ExchangeOnline -ManagedIdentity -Organization "<YourTenant>.onmicrosoft.com"

# Get current date and define output filenames
$date = Get-Date -Format "yyyy-MM-dd"
$fileName = "DynamicDL_RecipientFilters_$date.csv"
$localPath = "$fileName"

# Fetch Dynamic Distribution Lists and extract filter logic
$report = @()
$DDLs = Get-DynamicDistributionGroup -ResultSize Unlimited

foreach ($ddl in $DDLs) {
    $filter = $ddl.RecipientFilter
    $IncludeFilters = @()
    $ExcludeFilters = @()

    if ($filter -match "City -eq '([^\']+)'") {
        $cities = [regex]::Matches($filter, "City -eq '([^\']+)'") | ForEach-Object { $_.Groups[1].Value }
        $IncludeFilters += "City is " + ($cities -join " or ")
    }

    if ($filter -match "Department -eq '([^\']+)'") {
        $departments = [regex]::Matches($filter, "Department -eq '([^\']+)'") | ForEach-Object { $_.Groups[1].Value }
        $IncludeFilters += "Department is " + ($departments -join " or ")
    }

    if ($filter -match "Company -eq '([^\']+)'") {
        $companies = [regex]::Matches($filter, "Company -eq '([^\']+)'") | ForEach-Object { $_.Groups[1].Value }
        $IncludeFilters += "Company is " + ($companies -join " or ")
    }

    if ($filter -match "ExchangeUserAccountControl -ne 'AccountDisabled'") {
        $IncludeFilters += "Only enabled accounts"
    }

    if ($filter -match "ResourceType -ne 'Room'") {
        $ExcludeFilters += "Exclude ResourceType 'Room'"
    }

    if ($filter -match "RecipientTypeDetails -ne 'RoomMailbox'") {
        $ExcludeFilters += "Exclude Room Mailboxes"
    }

    if ($filter -match "Name -like 'SystemMailbox{\*'") {
        $ExcludeFilters += "Exclude System Mailboxes"
    }

    if ($filter -match "RecipientTypeDetailsValue -eq '([^\']+)'") {
        $excludedTypes = [regex]::Matches($filter, "RecipientTypeDetailsValue -eq '([^\']+)'") | ForEach-Object { $_.Groups[1].Value }
        $ExcludeFilters += "Exclude: " + ($excludedTypes -join ", ")
    }

    $report += [PSCustomObject]@{
        "Display Name"    = $ddl.DisplayName
        "Email Address"   = $ddl.PrimarySmtpAddress
        "Raw Filter"      = $filter
        "Include Filters" = ($IncludeFilters -join " | ")
        "Exclude Filters" = ($ExcludeFilters -join " | ")
    }
}

# Export to local CSV file
$report | Export-Csv -Path $localPath -NoTypeInformation -Encoding UTF8

# Disconnect Exchange Online
Disconnect-ExchangeOnline -Confirm:$false

# Upload to SharePoint
# Make sure your Managed Identity has at least "Contributor" rights to this site
Connect-PnPOnline -Url "https://<YourSharePointSite>.sharepoint.com/sites/<YourSiteName>" -ManagedIdentity

$sharePointFolder = "Shared Documents/Reporting/Exchange"
Add-PnPFile -Path $localPath -Folder $sharePointFolder

Write-Output "DDL Filter Report uploaded to SharePoint as: $fileName"
