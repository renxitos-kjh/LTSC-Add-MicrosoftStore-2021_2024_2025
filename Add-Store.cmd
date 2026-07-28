@echo off
set psc=powershell.exe
set _PSarg="""%~f0""" -el
>nul fltmc || (
%psc% "start cmd.exe -arg '/c %_PSarg%' -verb runas" && exit /b
goto :administrator
)
for /f "tokens=6 delims=[]. " %%G in ('ver') do if %%G lss 19044 goto :version
if /i "%PROCESSOR_ARCHITECTURE%" equ "AMD64" (set "arch=x64") else (set "arch=x86")
set "install=PowerShell -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass add-appxpackage -ErrorAction SilentlyContinue"
set "check=PowerShell -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -Command "Get-AppxPackage"
if exist "%~dp0*StorePurchaseApp*.Msixbundle" (
for /f %%i in ('dir /s/b %~dp0*StorePurchaseApp*.Msixbundle 2^>nul') do set "PurchaseApp=%%i"
)
if exist "%~dp0*XboxIdentityProvider*.AppxBundle" (
for /f %%i in ('dir /s/b %~dp0*XboxIdentityProvider*.AppxBundle 2^>nul') do set "XboxIdentity=%%i"
)
:ChoicePrompt
set "choice="
set /p choice="Do you want to install latest DesktopAppInstaller with winget included? This may take a while.(Y/N): "
set choice=%choice:~0,1%
if /i "%choice%"=="Y" (
    echo Downloading Winget via BITS...
    %psc% -Command "try { Start-BitsTransfer -Source 'https://aka.ms/getwinget' -Destination '%~dp0Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle'; exit 0 } catch { exit 1 }"
    if %errorlevel% equ 0 set "AppInstaller=Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
    goto checkarch
) else if /i "%choice%"=="N" (
    goto checkarch
) else (
    goto ChoicePrompt
)
:checkarch
if /i %arch%==x64 (goto :x64) else (goto :x86)
goto :error
:x64
echo.
echo Microsoft.WindowsAppRuntime.1.8 x64 installing...
for /f %%i in ('dir /s/b %~dp0*WindowsAppRuntime.1.8*x64*.Msix') do %install% %%i && echo Microsoft.WindowsAppRuntime.1.8 x64 install finished
echo.
echo Microsoft.NET.Native.Framework x64 installing...
for /f %%i in ('dir /s/b %~dp0*NET.Native.Framework*x64*') do %install% %%i && echo Microsoft.NET.Native.Framework x64 install finished
echo.
echo Microsoft.NET.Native.Runtime x64 installing...
for /f %%i in ('dir /s/b %~dp0*NET.Native.Runtime*x64*') do %install% %%i && echo Microsoft.NET.Native.Runtime x64 install finished
echo.
echo Microsoft.UI.Xaml x64 installing...
for /f %%i in ('dir /s/b %~dp0*UI.Xaml*x64*') do %install% %%i && echo Microsoft.UI.Xaml x64 install finished
echo.
echo Microsoft.VCLibs x64 and UWP x64 installing...
for /f %%i in ('dir /s/b %~dp0*VCLibs*x64*') do %install% %%i
echo Microsoft.VCLibs x64 and UWP x64 install finished
:x86
echo.
echo Microsoft.WindowsAppRuntime.1.8 x86 installing...
for /f %%i in ('dir /s/b %~dp0*WindowsAppRuntime.1.8*x86*.Msix') do %install% %%i && echo Microsoft.WindowsAppRuntime.1.8 x86 install finished
echo.
echo Microsoft.NET.Native.Framework x86 installing...
for /f %%i in ('dir /s/b %~dp0*NET.Native.Framework*x86*') do %install% %%i && echo Microsoft.NET.Native.Framework x86 install finished
echo.
echo Microsoft.NET.Native.Runtime x86 installing...
for /f %%i in ('dir /s/b %~dp0*NET.Native.Runtime*x86*') do %install% %%i && echo Microsoft.NET.Native.Runtime x86 install finished
echo.
echo Microsoft.UI.Xaml x86 installing...
for /f %%i in ('dir /s/b %~dp0*UI.Xaml*x86*') do %install% %%i && echo Microsoft.UI.Xaml x86 install finished
echo.
echo Microsoft.VCLibs x86 and UWP x86 installing...
for /f %%i in ('dir /s/b %~dp0*VCLibs*x86*') do %install% %%i
echo Microsoft.VCLibs x86 and UWP x86 install finished
echo.
echo Microsoft.WindowsStore installing...
for /f %%i in ('dir /s/b %~dp0*WindowsStore*') do %install% %%i && echo Microsoft.WindowsStore install finished
if defined AppInstaller (
echo.
echo Latest DesktopAppInstaller installing...
%install% "%~dp0\%AppInstaller%" && echo Latest DesktopAppInstaller install finished
) else (
echo.
echo DesktopAppInstaller installing...
for /f %%i in ('dir /s/b %~dp0*DesktopAppInstaller*') do %install% %%i && echo DesktopAppInstaller install finished
)
if defined PurchaseApp (
echo.
echo Microsoft.StorePurchaseApp installing...
%install% "%PurchaseApp%" && echo Microsoft.StorePurchaseApp install finished
)
if defined XboxIdentity (
echo.
echo Microsoft.XboxIdentityProvider installing...
%install% "%XboxIdentity%" && echo Microsoft.XboxIdentityProvider install finished
)
goto :finished

:administrator
echo.
echo Please run this by administrator privilege.
echo.
goto :finished
:version
echo.
echo Error: This pack is for Windows 10 version 21H2 and later
echo.
goto :finished
:error
echo error: Can not detect system arch.
goto :finished
:finished
echo.
echo Press any key to Exit
pause >nul
exit