<#  
.SYNOPSIS  
Teams_Overview_Report_Batched.ps1 – Fast batched Teams overview  
.REQUIRES  
  Connect-MgGraph -Scopes "Group.Read.All","Team.ReadBasic.All","Channel.ReadBasic.All",  
                   "ChannelMember.Read.All","TeamMember.Read.All","User.Read.All"  
#>

$start = Get-Date

$GraphBase   = "https://graph.microsoft.com/v1.0"
$BatchSize   = 20            # ≤20 requests per batch
$PauseMS     = 300           # throttle between batches

Connect-MgGraph -Scopes "Group.Read.All","Team.ReadBasic.All","Channel.ReadBasic.All","ChannelMember.Read.All","TeamMember.Read.All","User.Read.All"

$timeStamp = Get-Date -Format 'yyyyMMddHHmm'
$outFile   = "$PSScriptRoot/Teams_Overview_$timeStamp.csv"

$teams = Get-MgTeam -All -Property "id,displayName"
Write-Host ("Found {0} Teams – batching…" -f $teams.Count) -Foreground Cyan

# ────────────────────────── Build every request ──────────────────────────
$reqs = foreach ($t in $teams) {
    @(
        @{ id = "team_$($t.Id)";     method = "GET"; url = "/teams/$($t.Id)" }
        @{ id = "channels_$($t.Id)"; method = "GET"; url = "/teams/$($t.Id)/channels" }
        @{ id = "owners_$($t.Id)";   method = "GET"; url = "/teams/$($t.Id)/members?\$filter=roles/any(r:r eq 'owner')" }
    )
}

# ────────────────────────── Send batches ──────────────────────────
$responses = @{}
for ($i=0; $i -lt $reqs.Count; $i += $BatchSize) {
    $batch = $reqs[$i..([math]::Min($i+$BatchSize-1,$reqs.Count-1))]
    $body  = @{ requests = $batch } | ConvertTo-Json -Depth 8
    $resp  = Invoke-MgGraphRequest -Method POST -Uri "$GraphBase/`$batch" -Body $body -ContentType 'application/json'
    foreach ($item in $resp.responses) { $responses[$item.id] = $item.body }
    Start-Sleep -Milliseconds $PauseMS
}

# ────────────────────────── Assemble report ──────────────────────────
$report = foreach ($t in $teams) {
    $teamID = $t.Id
    $team     = $responses["team_$teamID"]
    $channels = $responses["channels_$teamID"].value
    $owners   = $responses["owners_$teamID"].value

    # counts
    $std  = ($channels | Where membershipType -eq 'standard').Count
    $priv = ($channels | Where membershipType -eq 'private' ).Count
    $shrd = ($channels | Where membershipType -eq 'shared'  ).Count

    # owners → UPNs
    $ownerUPNs = $owners | ForEach-Object {
        try { (Get-MgUser -UserId $_.userId -Property userPrincipalName).userPrincipalName }
        catch { $_.displayName }
    }

    $sum = $team.summary
    [pscustomobject]@{
        Id                          = $team.id
        DisplayName                 = $team.displayName
        Description                 = $team.description
        Classification              = $team.classification
        Visibility                  = $team.visibility
        Specialization              = $team.specialization
        WebUrl                      = $team.webUrl
        CreatedDateTime             = $team.createdDateTime
        IsArchived                  = $team.isArchived
        IsMembershipLimitedToOwners = $team.isMembershipLimitedToOwners
        ShowInSearch                = $team.discoverySettings.showInTeamsSearchAndSuggestions
        OwnersCount                 = $sum.ownersCount
        MembersCount                = $sum.membersCount
        GuestsCount                 = $sum.guestsCount
        OwnerUPNs                   = $ownerUPNs -join ' ; '
        ChannelCount                = $std
        PrivateChannelCount         = $priv
        SharedChannelCount          = $shrd
        AllowCreateUpdateChannels        = $team.memberSettings.allowCreateUpdateChannels
        AllowCreatePrivateChannels       = $team.memberSettings.allowCreatePrivateChannels
        AllowDeleteChannels              = $team.memberSettings.allowDeleteChannels
        AllowAddRemoveApps               = $team.memberSettings.allowAddRemoveApps
        AllowCreateUpdateRemoveTabs      = $team.memberSettings.allowCreateUpdateRemoveTabs
        AllowCreateUpdateRemoveConnectors= $team.memberSettings.allowCreateUpdateRemoveConnectors
        AllowUserEditMessages            = $team.messagingSettings.allowUserEditMessages
        AllowUserDeleteMessages          = $team.messagingSettings.allowUserDeleteMessages
        AllowOwnerDeleteMessages         = $team.messagingSettings.allowOwnerDeleteMessages
        AllowTeamMentions                = $team.messagingSettings.allowTeamMentions
        AllowChannelMentions             = $team.messagingSettings.allowChannelMentions
        AllowGiphy                       = $team.funSettings.allowGiphy
        GiphyContentRating               = $team.funSettings.giphyContentRating
        AllowStickersAndMemes            = $team.funSettings.allowStickersAndMemes
        AllowCustomMemes                 = $team.funSettings.allowCustomMemes
    }
}

$report | Export-Csv -Path $outFile -Delimiter ';' -NoTypeInformation -Encoding UTF8
Disconnect-MgGraph

$duration = (Get-Date) - $start
Write-Host "`n✅ Batched Teams overview saved to $outFile" -Foreground Green
Write-Host "⏱️ Duration: $($duration.TotalSeconds) seconds" -Foreground Yellow