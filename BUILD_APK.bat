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
call flutter build apk --release
if errorlevel 1 goto failed
explorer "build\app\outputs\flutter-apk"
pause
exit /b 0
:failed
echo Build failed. Copy the error above for troubleshooting.
pause
exit /b 1
