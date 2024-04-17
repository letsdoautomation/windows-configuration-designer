# Windows Configuration Designer: Remove Windows 11 bloatware and configure start menu

<b>Objectives:</b>

* Execute setup.p1
    * Remove default Windows store apps
    * Configure start menu layout
    * Prevent OneDrive from installing
    * Create local admin user
    * Skip "Privacy experiance"
* Skip OOBE


<b>Start layout location:</b>

```powershell
%LOCALAPPDATA%\Packages\Microsoft.Windows.StartMenuExperienceHost_cw5n1h2txyewy\LocalState\
```

<b>Execute setup.ps1:</b>

```powershell
powershell.exe -ExecutionPolicy Bypass -File setup.ps1
```

## Related videos

<b>PowerShell:</b>

[PowerShell: Export StartLayout, Import StartLayout alternatives for Windows 11](https://youtu.be/j-8FmXk8ssg) <br />
[PowerShell: Using Get-AppxProvisionedPackage, Remove-AppxProvisionedPackage to modify Online image](https://youtu.be/SevFgIkzAKk)

<b>Windows Registry</b>

[Windows Registry: Run and RunOnce](https://youtu.be/zgFzCq5uEPw) <br />
[Windows Registry: Active Setup](https://youtu.be/HrVJ7wdvfmo)

<b>Windows Configuration Designer:</b>

[Windows Configuration Designer playlist](https://www.youtube.com/playlist?list=PLVncjTDMNQ4SAh9zjdreUBYSzSf7L5IX2)