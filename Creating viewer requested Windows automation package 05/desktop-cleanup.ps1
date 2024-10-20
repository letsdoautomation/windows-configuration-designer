Remove-LocalUser "provisioning"
Unregister-ScheduledTask -TaskName "Provisioning cleanup" -Confirm:$false