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

## 📦 Script Toolbox

| 🌐 Environment | 🎯 Scope                    | 🛠️ Description                                                                                                                               | 📁 Project | 📄 Script |
|----------------|----------------------------|----------------------------------------------------------------------------------------------------------------------------------------------|-------------|-----------|
| **Teams**      | Channels                   | Bulk add users to a private channel in a Microsoft Team using a CSV of UPNs.                                                                 | No          | [View Script](Teams/Teams_Add-Users-To-PrivateChannel.ps1) |
| **Exchange**   | SMB (Shared Mailboxes)     | Generates a detailed report of all Shared Mailboxes in Exchange Online, including last activity (sent/received), delegation rights (Full Access, SendAs), and access information. Helps identify inactive or mismanaged shared mailboxes for cleanup or auditing. | [Yes](https://github.com/gelndjj/_EXCHANGE_SMBsReport) | [View Script](https://github.com/gelndjj/_EXCHANGE_SMBsReport/blob/main/ExchangeSharedMailboxAudit.ps1) |
| **Exchange**   | Dynamic Distribution Lists | Manage Dynamic DLs in Exchange Online: generate full recipient filter reports, update filters in bulk, and preview matching members via dry run. Ideal for cleanups, audits, and bulk filter management. | [Yes](https://github.com/gelndjj/_EXCHANGE_DDLsFilterUpdate) | [View Script](https://github.com/gelndjj/_EXCHANGE_DDLsFilterUpdate/blob/main/DynamicDL_Updater.ps1) |
| **EntraID**    | Users                      | Exports all users from Microsoft Entra ID with comprehensive attributes including MFA methods, license assignments, privileged roles, hybrid sync status, and Immutable ID. Ideal for audits, migrations, and identity cleanup. | [Yes](https://github.com/gelndjj/_ENTRA_UserReport) | [View Script](https://github.com/gelndjj/_ENTRA_UserReport/blob/main/export_entraid_usrs.ps1) |
| **EntraID**    | Groups                     | Exports all Entra ID groups with metadata, Teams linkage, owners, roles, CA policies, and app role usage.                                  | [Yes](https://github.com/gelndjj/_ENTRA_GroupReport) | [View Script](https://github.com/gelndjj/_ENTRA_GroupReport/blob/main/EntraID_Groups_Report.ps1) |
| **Intune**    | Devices                    | Exports all Intune-managed and Entra-registered devices with status on join type, encryption, compliance, threat state, user assignment, OS, and storage. Designed for security and endpoint audit reports. | [Yes](https://github.com/gelndjj/_INTUNE_DevicesReport) | [View Script](https://github.com/gelndjj/_INTUNE_DevicesReport/blob/main/Intune_DevicePostureReport.ps1) |
| **Intune**    | Detected Apps             | Exports all apps detected on Intune-managed devices using Microsoft Graph. Includes device name, user display name, app name, version, publisher, platform, and app ID. Ideal for software inventory, compliance checks, and shadow IT detection. | [Yes](https://github.com/gelndjj/_INTUNE_DetectedAppsReport) | [View Script](https://github.com/gelndjj/_INTUNE_DetectedAppsReport/blob/main/Export-IntuneDetectedAppsReport.ps1) |
| **Intune**     | Devices                    | Collect AutoPilot hardware hash and save the CSV to a selected location.                                                                    | [Yes](https://github.com/gelndjj/_INTUNE_Autopilot) | [View Script](https://github.com/gelndjj/_INTUNE_Autopilot/blob/main/autopilot_ONLINE.ps1) |

---

### 🤝 Contributing
Feel free to fork the repository and submit pull requests for new scripts, improvements, or documentation enhancements. All contributions are welcome!
