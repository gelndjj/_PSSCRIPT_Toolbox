# Requires Exchange Online Management Module

function Show-Menu {
    Clear-Host
    Write-Host "===============================" -ForegroundColor Yellow
    Write-Host "  Dynamic DL Filter Updater"
    Write-Host "===============================" -ForegroundColor Yellow
    Write-Host "0. Generate DDL Filter Report"
    Write-Host "1. Upload Report CSV and Apply Filters"
    Write-Host "2. Upload Report CSV DryRun (Preview Members per Filter)"
    Write-Host "3. Exit"
    Write-Host ""
}

function Generate-DDLReport {
    Connect-ExchangeOnline -ShowProgress $true

    $date = Get-Date -Format "yyyy-MM-dd"
    $outputPath = ".\\DynamicDL_RecipientFilters_$date.csv"
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

    $report | Export-Csv -Path $outputPath -NoTypeInformation -Encoding UTF8
    Write-Host "✔ Report saved to: $outputPath" -ForegroundColor Green

    Disconnect-ExchangeOnline -Confirm:$false
    Pause
}

function Upload-And-ApplyFilters {
    Add-Type -AssemblyName System.Windows.Forms
    $fileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $fileDialog.InitialDirectory = [Environment]::GetFolderPath('Desktop')
    $fileDialog.Filter = "CSV files (*.csv)|*.csv"

    if ($fileDialog.ShowDialog() -eq "OK") {
        $CSVPath = $fileDialog.FileName
        Connect-ExchangeOnline -ShowProgress $true
        $updates = Import-Csv -Path $CSVPath

        foreach ($entry in $updates) {
            $name = $entry.'Display Name'
            $filter = $entry.'Raw Filter'

            Write-Host "Updating DDL: $name" -ForegroundColor Cyan

            try {
                Set-DynamicDistributionGroup -Identity $name -RecipientFilter $filter
                Write-Host "✔ Successfully updated: $name" -ForegroundColor Green
            } catch {
                Write-Warning "Failed to update $name $_"
            }
        }

        Disconnect-ExchangeOnline -Confirm:$false
    } else {
        Write-Warning "⚠ No file selected. Operation cancelled."
    }
    Pause
}

function Upload-And-DryRunFilters {
    Add-Type -AssemblyName System.Windows.Forms
    $fileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $fileDialog.InitialDirectory = [Environment]::GetFolderPath('Desktop')
    $fileDialog.Filter = "CSV files (*.csv)|*.csv"

    if ($fileDialog.ShowDialog() -eq "OK") {
        $CSVPath = $fileDialog.FileName
        Connect-ExchangeOnline -ShowProgress $true

        $updates = Import-Csv -Path $CSVPath
        $outputFolder = ".\\DryRun_Results"
        if (!(Test-Path $outputFolder)) { New-Item -ItemType Directory -Path $outputFolder | Out-Null }

        foreach ($entry in $updates) {
            $name = $entry.'Display Name'
            $filter = $entry.'Raw Filter'

            Write-Host "🔍 Simulating filter for: $name" -ForegroundColor Cyan

            try {
                $recipients = Get-Recipient -RecipientPreviewFilter $filter | Select-Object DisplayName,
                    @{Name="UserPrincipalName"; Expression={ if ($_.UserPrincipalName) { $_.UserPrincipalName } else { $_.PrimarySmtpAddress } }}

                $outputPath = Join-Path $outputFolder "$($name -replace '[^a-zA-Z0-9_-]', '_').csv"

                if ($recipients.Count -eq 0) {
                    Write-Warning "⚠ No matching recipients for $name"
                } else {
                    $recipients | Export-Csv -Path $outputPath -NoTypeInformation -Encoding UTF8
                    Write-Host "✔ Results saved to: $outputPath" -ForegroundColor Green
                }
            } catch {
                Write-Warning "Simulation failed for $name $_"
            }
        }

        Disconnect-ExchangeOnline -Confirm:$false
    } else {
        Write-Warning "No file selected. Operation cancelled."
    }
    Pause
}

# Main loop
do {
    Show-Menu
    $choice = Read-Host "Choose an option (0-3)"

    switch ($choice) {
        "0" { Generate-DDLReport }
        "1" { Upload-And-ApplyFilters }
        "2" { Upload-And-DryRunFilters }
        "3" { Write-Host "Exiting...`n" -ForegroundColor Yellow }
        default { Write-Warning "⚠ Invalid choice. Please select 0 to 3." ; Pause }
    }
} while ($choice -ne "3")
