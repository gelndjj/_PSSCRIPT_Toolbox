# 🧰 PowerShell Scripts Toolbox

A curated collection of useful PowerShell scripts categorized by Microsoft 365 environments such as **Entra ID**, **Exchange**, **Teams**, and more. Each script is designed to automate common administrative tasks in modern cloud environments.

---

## 📁 Repository Structure

```
/EntraID
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

| 🌐 Environment | 🛠️ Description                                                                 | 📄 Script |
|----------------|--------------------------------------------------------------------------------|-----------|
| **Teams**      | Bulk add users to a private channel in a Microsoft Team using a CSV of UPNs.  | [View Script](Teams/Teams_Add-Users-To-PrivateChannel.ps1) |


---

### 🤝 Contributing
Feel free to fork the repository and submit pull requests for new scripts, improvements, or documentation enhancements. All contributions are welcome!
