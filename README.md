# Powershell
Some Scripts for tasks for automation windows.

The scripts should be documented with comments and usage blocks.

## Run Scripts without "run a script"
Download Script from Web and pipe script content trough stdin.
```
powershell -nop -c (Invoke-WebRequest -Uri https://raw.githubusercontent.com/heinz-otto/Powershell/master/ChangeVariableInsideScript.ps1).content|powershell -
```
Call local script with extra Parameter
```
C:\WINDOWS\System32\WindowsPowerShell\v1.0\PowerShell.exe -ExecutionPolicy Bypass -File C:\tools\scripts\StartePraxis.ps1
```
