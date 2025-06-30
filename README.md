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

| 🌐 Environment | 🎯 Scope        | 🛠️ Description                                                                                                                               | 📄 Script |
|----------------|----------------|----------------------------------------------------------------------------------------------------------------------------------------------|-----------|
| **Teams**      | Channels        | Bulk add users to a private channel in a Microsoft Team using a CSV of UPNs.                                                                 | [View Script](Teams/Teams_Add-Users-To-PrivateChannel.ps1) |
| **Exchange**   | SMB (Shared Mailboxes) | Generates a detailed report of all Shared Mailboxes in Exchange Online, including last activity (sent/received), delegation rights (Full Access, SendAs), and access information. Helps identify inactive or mismanaged shared mailboxes for cleanup or auditing. | [View Script](https://github.com/gelndjj/_EXCHANGE_SMBsReport-) |
| **EntraID**    | Users           | Exports all users from Microsoft Entra ID with comprehensive attributes including MFA methods, license assignments, privileged roles, hybrid sync status, and Immutable ID. Ideal for audits, migrations, and identity cleanup. | [View Script](https://github.com/gelndjj/_ENTRA_UserReport) |
| **EntraID**    | Groups          | Exports all Entra ID groups with metadata, Teams linkage, owners, roles, CA policies, and app role usage.                                  | [View Script](https://github.com/gelndjj/_ENTRA_GroupReport) |
| **Intune**     | Devices         | Collect AutoPilot hardware hash and save the CSV to a selected location.                                                                    | [View Script](https://github.com/gelndjj/_INTUNE_Autopilot) |

---

### 🤝 Contributing
Feel free to fork the repository and submit pull requests for new scripts, improvements, or documentation enhancements. All contributions are welcome!
