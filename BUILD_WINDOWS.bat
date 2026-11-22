@echo off
setlocal
cd /d "%~dp0"
where flutter >nul 2>nul
if errorlevel 1 (
 echo Flutter is not on PATH. Set your Flutter SDK bin folder in PATH, then retry.
 pause
 exit /b 1
)
call flutter pub get
if errorlevel 1 goto failed
call flutter build windows --release
if errorlevel 1 goto failed
explorer "build\windows\x64\runner\Release"
pause
exit /b 0
:failed
echo Build failed. Windows builds require Visual Studio Desktop development with C++.
pause
exit /b 1
