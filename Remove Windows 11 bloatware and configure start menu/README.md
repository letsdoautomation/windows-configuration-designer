# Windows Configuration Designer: Remove Windows 11 bloatware and configure start menu

<b>Objectives:</b>

* Execute oobe-setup.p1
    * Create local admin user
    * Skip "Privacy experiance"
    * Execute oobe-bloatware.ps1
        * Remove default Windows store apps
        * Configure start menu layout
        * Prevent OneDrive, Outlook (new) and Home Dev from installing
* Skip OOBE


<b>Start layout location:</b>

```powershell
%LOCALAPPDATA%\Packages\Microsoft.Windows.StartMenuExperienceHost_cw5n1h2txyewy\LocalState\
```

<b>Execute setup.ps1:</b>

```powershell
powershell.exe -ExecutionPolicy Bypass -File oobe-setup.ps1
```

## Related videos

<b>PowerShell:</b>

[PowerShell: Export StartLayout, Import StartLayout alternatives for Windows 11](https://youtu.be/j-8FmXk8ssg) <br />
[PowerShell: Using Get-AppxProvisionedPackage, Remove-AppxProvisionedPackage to modify Online image](https://youtu.be/SevFgIkzAKk) <br />

<b>Windows:</b>

[Windows: Prevent Outlook new and Dev Home from installing for new users](https://youtu.be/zkN0DyI9mLI) <br />
[Windows: Prevent OneDrive from installing for new users](https://youtu.be/-u2MbM-ROto) <br />

<b>Windows Registry:</b>

[Windows Registry: Run and RunOnce](https://youtu.be/zgFzCq5uEPw) <br />
[Windows Registry: Active Setup](https://youtu.be/HrVJ7wdvfmo)

<b>Windows Configuration Designer:</b>

[Windows Configuration Designer: Skip Out-Of-Box Experience](https://youtu.be/Lqf4i1nHV7I)
[Windows Configuration Designer playlist](https://www.youtube.com/playlist?list=PLVncjTDMNQ4SAh9zjdreUBYSzSf7L5IX2)
