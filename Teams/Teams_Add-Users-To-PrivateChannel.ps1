# Requires MicrosoftTeams module
# Install-Module MicrosoftTeams -Force

function Create-CsvTemplate {
    $templatePath = "$PSScriptRoot\Teams_PrivateChannel_Users_Template.csv"
    @"
UserPrincipalName
user1@domain.com
user2@domain.com
"@ | Set-Content -Path $templatePath -Encoding UTF8

    Write-Host "CSV template created at: $templatePath`n" -ForegroundColor Green
}

function Upload-And-ProcessCsv {
    Add-Type -AssemblyName System.Windows.Forms
    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.InitialDirectory = [Environment]::GetFolderPath('Desktop')
    $OpenFileDialog.Filter = "CSV files (*.csv)|*.csv"

    if ($OpenFileDialog.ShowDialog() -eq "OK") {
        $csvPath = $OpenFileDialog.FileName
        $users = Import-Csv $csvPath

        # Connect to Teams
        Connect-MicrosoftTeams

        # Prompt for team and channel names
        $teamName = Read-Host "Enter the Team name"
        $channelName = Read-Host "Enter the Private Channel name"

        # Attempt strict match
        $matchingTeams = Get-Team | Where-Object { $_.DisplayName -eq $teamName }

        if ($matchingTeams.Count -eq 0) {
            Write-Host "No exact team found with name '$teamName'" -ForegroundColor Red

            # Try fuzzy match
            $fuzzyMatches = Get-Team | Where-Object { $_.DisplayName -like "*$teamName*" }

            if ($fuzzyMatches.Count -eq 0) {
                Write-Host "No partial matches found either. Please check the name and try again." -ForegroundColor Yellow
                return
            }

            Write-Host "Found similar team names:"
            $fuzzyMatches | ForEach-Object { Write-Host "- $($_.DisplayName) (GroupId: $($_.GroupId))" }

            $teamIdInput = Read-Host "`nPlease paste the exact GroupId of the Team you want to use"
            $team = $fuzzyMatches | Where-Object { $_.GroupId -eq $teamIdInput }

            if (-not $team) {
                Write-Host "Invalid GroupId entered." -ForegroundColor Red
                return
            }
        }
        elseif ($matchingTeams.Count -gt 1) {
            Write-Host "Multiple teams matched:"
            $matchingTeams | ForEach-Object { Write-Host "- $($_.DisplayName) (GroupId: $($_.GroupId))" }
            $teamIdInput = Read-Host "Please paste the exact GroupId of the Team you want to use"
            $team = $matchingTeams | Where-Object { $_.GroupId -eq $teamIdInput }

            if (-not $team) {
                Write-Host "Invalid GroupId entered." -ForegroundColor Red
                return
            }
        }
        else {
            $team = $matchingTeams[0]
        }

        $allChannels = Get-TeamChannel -GroupId $team.GroupId
        $channel = $allChannels | Where-Object { $_.DisplayName -eq $channelName -and $_.MembershipType -eq "Private" }

        if (-not $channel) {
            Write-Host "Private Channel '$channelName' not found in Team '$($team.DisplayName)'" -ForegroundColor Red

            # Look for possible matches
            $suggested = $allChannels | Where-Object {
                $_.MembershipType -eq "Private" -and $_.DisplayName -like "*$channelName*"
            }

            if ($suggested.Count -eq 0) {
                Write-Host "No similar private channels found." -ForegroundColor Yellow
                return
            }

            Write-Host "Did you mean one of these private channels?"
            $i = 1
            foreach ($chan in $suggested) {
                Write-Host "$i. $($chan.DisplayName)"
                $i++
            }

            $selection = Read-Host "`nType the number of the correct channel (or press Enter to cancel)"
            if ([int]::TryParse($selection, [ref]$null) -and $selection -ge 1 -and $selection -le $suggested.Count) {
                $channel = $suggested[$selection - 1]
            } else {
                Write-Host "No valid selection made. Cancelling..." -ForegroundColor Yellow
                return
            }
        }

        Write-Host "Adding users to private channel '$channelName' in team '$($team.DisplayName)'..." -ForegroundColor Cyan

        foreach ($user in $users) {
            try {
                Add-TeamChannelUser -GroupId $team.GroupId -DisplayName $channel.DisplayName -User $user.UserPrincipalName
                Write-Host "Added: $($user.UserPrincipalName)" -ForegroundColor Green
            } catch {
                Write-Host "Error adding $($user.UserPrincipalName): $_" -ForegroundColor Yellow
            }
        }

        Write-Host "Processing complete.`n" -ForegroundColor Green
    } else {
        Write-Host "Operation cancelled." -ForegroundColor Yellow
    }
}

# Main menu
do {
    Write-Host "=== Teams Private Channel User Manager ==="
    Write-Host "1. Create CSV Template"
    Write-Host "2. Upload and Process CSV"
    Write-Host "0. Exit"
    $choice = Read-Host "Choose an option"

    switch ($choice) {
        "1" { Create-CsvTemplate }
        "2" { Upload-And-ProcessCsv }
        "0" { Write-Host "Exiting..." -ForegroundColor Cyan }
        default { Write-Host "Invalid option. Please try again.`n" -ForegroundColor Yellow }
    }
} while ($choice -ne "0")
