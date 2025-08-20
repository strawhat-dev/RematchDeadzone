@echo off
setlocal enabledelayedexpansion
net session >nul 2>&1 || ( powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath '%~f0' -Verb RunAs" & exit /b %errorlevel% )
"%~dp0.interception-driver.exe" /install
set exitcode=%errorlevel%
C:\Windows\System32\timeout.exe /t -1
exit /b %exitcode%
