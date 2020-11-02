@echo off
REM: Bypass.bat
REM: cmd /C bypass.bat yourps1.ps1
powershell.exe -noprofile -Command "powershell.exe -noprofile set-executionpolicy Unrestricted"