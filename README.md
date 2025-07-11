# 🧰 PowerShell Scripts Toolbox

A curated collection of useful PowerShell scripts categorized by Microsoft 365 environments such as **Entra ID**, **Exchange**, **Teams**, and more. Each script is designed to automate common administrative tasks in modern cloud environments.

---

## 📁 Repository Structure

```
/EntraID
/Intune
/Exchange
/Defender
/Teams
/Sharepoint
```


Each folder contains scripts specific to its environment, along with usage instructions and templates when applicable.

---

## 🚀 Getting Started

Before running any script, ensure you have the necessary PowerShell modules installed. An example of installing module:

```powershell
# Install Microsoft Teams module
Install-Module MicrosoftTeams -Force

# Install Exchange Online module
Install-Module ExchangeOnlineManagement -Force

# Install Microsoft Graph module
Install-Module Microsoft.Graph -Scope CurrentUser -Force
```
⚠️ You may need to run PowerShell as Administrator and accept the NuGet provider prompt the first time.

---

<h2>📦 Script Toolbox</h2>

<table>
  <thead>
    <tr>
      <th>🌐 Environment</th>
      <th>🎯 Scope</th>
      <th>🛠️ Description</th>
      <th>📁 Project</th>
      <th>📄 Script</th>
      <th>📜 Runbook</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><strong>Teams</strong></td>
      <td>Channels</td>
      <td>Bulk add users to a private channel in a Microsoft Team using a CSV of UPNs.</td>
      <td>No</td>
      <td><a href="Teams/Teams_Add-Users-To-PrivateChannel.ps1">View Script</a></td>
      <td>No</td>
    </tr>
    <tr>
      <td><strong>Teams</strong></td>
      <td>Overview Report</td>
      <td>Exports a fast batched report of all Microsoft Teams with channel types, owners, member counts, and team settings. Ideal for audits and governance.</td>
      <td><a href="https://github.com/gelndjj/_TEAMS_OverviewReport">Yes</a></td>
      <td><a href="Teams/Teams_Overview_Report.ps1">View Script</a></td>
      <td>No</td>
    </tr>
    <tr>
      <td><strong>Exchange</strong></td>
      <td>SMB (Shared Mailboxes)</td>
      <td>Generates a detailed report of all Shared Mailboxes in Exchange Online, including last activity (sent/received), delegation rights (Full Access, SendAs), and access information. Helps identify inactive or mismanaged shared mailboxes for cleanup or auditing.</td>
      <td><a href="https://github.com/gelndjj/_EXCHANGE_SMBsReport">Yes</a></td>
      <td><a href="https://github.com/gelndjj/_EXCHANGE_SMBsReport/blob/main/ExchangeSharedMailboxAudit.ps1">View Script</a></td>
      <td><a href="https://github.com/gelndjj/_EXCHANGE_SMBsReport/blob/main/Runbook_Template-SharedMailboxes-Report.ps1">View Template</a></td>
    </tr>
    <tr>
      <td><strong>Exchange</strong></td>
      <td>Dynamic Distribution Lists</td>
      <td>Manage Dynamic DLs in Exchange Online: generate full recipient filter reports, update filters in bulk, and preview matching members via dry run. Ideal for cleanups, audits, and bulk filter management.</td>
      <td><a href="https://github.com/gelndjj/_EXCHANGE_DDLsFilterUpdate">Yes</a></td>
      <td><a href="https://github.com/gelndjj/_EXCHANGE_DDLsFilterUpdate/blob/main/DynamicDL_Updater.ps1">View Script</a></td>
      <td><a href="https://github.com/gelndjj/_EXCHANGE_DDLsFilterUpdate/blob/main/Runbook_Template-DDL_Report.ps1">View Template</a></td>
    </tr>
    <tr>
      <td><strong>EntraID</strong></td>
      <td>Users</td>
      <td>Exports all users from Microsoft Entra ID with comprehensive attributes including MFA methods, license assignments, privileged roles, hybrid sync status, and Immutable ID. Ideal for audits, migrations, and identity cleanup.</td>
      <td><a href="https://github.com/gelndjj/_ENTRA_UserReport">Yes</a></td>
      <td><a href="https://github.com/gelndjj/_ENTRA_UserReport/blob/main/export_entraid_usrs.ps1">View Script</a></td>
      <td>No</td>
    </tr>
    <tr>
      <td><strong>EntraID</strong></td>
      <td>Groups</td>
      <td>Exports all Entra ID groups with metadata, Teams linkage, owners, roles, CA policies, and app role usage.</td>
      <td><a href="https://github.com/gelndjj/_ENTRA_GroupReport">Yes</a></td>
      <td><a href="https://github.com/gelndjj/_ENTRA_GroupReport/blob/main/EntraID_Groups_Report.ps1">View Script</a></td>
      <td>No</td>
    </tr>
    <tr>
      <td><strong>EntraID</strong></td>
      <td>Enterprise Applications</td>
      <td>Exports all Entra ID Enterprise Applications (Service Principals) with owners, assigned users/groups, sign-in activity, OAuth2 scopes, app roles, and sign-in status. Ideal for auditing app usage, permissions, and lifecycle tracking.</td>
      <td><a href="https://github.com/gelndjj/_ENTRA_EnterpriseAppsReport">Yes</a></td>
      <td><a href="https://github.com/gelndjj/_ENTRA_EnterpriseAppsReport/blob/main/Export_EnterpriseAppsReport.ps1">View Script</a></td>
      <td>No</td>
    </tr>
    <tr>
      <td><strong>Intune</strong></td>
      <td>Devices</td>
      <td>Exports all Intune-managed and Entra-registered devices with status on join type, encryption, compliance, threat state, user assignment, OS, and storage. Designed for security and endpoint audit reports.</td>
      <td><a href="https://github.com/gelndjj/_INTUNE_DevicesReport">Yes</a></td>
      <td><a href="https://github.com/gelndjj/_INTUNE_DevicesReport/blob/main/Intune_DevicePostureReport.ps1">View Script</a></td>
      <td><a href="https://github.com/gelndjj/_INTUNE_DevicesReport/blob/main/Runbook_Template-DevicesReport.ps1">View Template</a></td>
    </tr>
    <tr>
      <td><strong>Intune</strong></td>
      <td>Detected Apps</td>
      <td>Exports all apps detected on Intune-managed devices using Microsoft Graph. Includes device name, user display name, app name, version, publisher, platform, and app ID. Ideal for software inventory, compliance checks, and shadow IT detection.</td>
      <td><a href="https://github.com/gelndjj/_INTUNE_DetectedAppsReport">Yes</a></td>
      <td><a href="https://github.com/gelndjj/_INTUNE_DetectedAppsReport/blob/main/Export-IntuneDetectedAppsReport.ps1">View Script</a></td>
      <td><a href="https://github.com/gelndjj/_INTUNE_DetectedAppsReport/blob/main/Runbook_Template-DetectedAppsReport.ps1">View Template</a></td>
    </tr>
    <tr>
      <td><strong>Intune</strong></td>
      <td>Devices (AutoPilot Hash)</td>
      <td>Collect AutoPilot hardware hash and save the CSV to a selected location.</td>
      <td><a href="https://github.com/gelndjj/_INTUNE_Autopilot">Yes</a></td>
      <td><a href="https://github.com/gelndjj/_INTUNE_Autopilot/blob/main/autopilot_ONLINE.ps1">View Script</a></td>
      <td>No</td>
    </tr>
  </tbody>
</table>


### 🤝 Contributing
Feel free to fork the repository and submit pull requests for new scripts, improvements, or documentation enhancements. All contributions are welcome!
