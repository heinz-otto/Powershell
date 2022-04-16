# Powershell
Some Scripts for tasks for automation windows.

The scripts should be documented with comments and usage blocks.

## Run Scripts without "run a script"

```
powershell -nop -c (Invoke-WebRequest -Uri https://raw.githubusercontent.com/heinz-otto/Powershell/master/ChangeVariableInsideScript.ps1).content|powershell -
```
