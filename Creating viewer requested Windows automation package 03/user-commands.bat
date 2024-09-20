@echo off
REG IMPORT "C:\ProgramData\provisioning\user-settings.reg"
powershell (new-object -com wscript.shell).SendKeys([char]173)
powershell ([System.IO.DirectoryInfo]'%USERPROFILE%').GetDirectories('Desktop').GetFiles('*.lnk').Delete()