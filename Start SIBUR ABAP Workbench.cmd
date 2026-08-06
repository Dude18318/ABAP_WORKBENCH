@echo off
setlocal EnableExtensions
set "WORKBENCH_DIR=%~dp0tools\workbench-app"
set "WORKBENCH_URL=http://127.0.0.1:3000"

echo Checking SIBUR AI ABAP Workbench...
if not exist "%WORKBENCH_DIR%\server.js" (
  echo.
  echo server.js was not found in:
  echo %WORKBENCH_DIR%
  pause
  exit /b 1
)

where node >nul 2>nul
if errorlevel 1 (
  echo.
  echo Node.js was not found. Install Node.js and run this file again.
  pause
  exit /b 1
)

powershell -NoProfile -Command "if (Test-NetConnection -ComputerName 127.0.0.1 -Port 3000 -InformationLevel Quiet) { exit 0 } else { exit 1 }"
if errorlevel 1 (
  echo Starting local server...
  start "SIBUR AI ABAP Workbench Server" /min cmd /c "cd /d ""%WORKBENCH_DIR%"" && node server.js"
)

for /L %%I in (1,1,15) do (
  powershell -NoProfile -Command "if (Test-NetConnection -ComputerName 127.0.0.1 -Port 3000 -InformationLevel Quiet) { exit 0 } else { exit 1 }"
  if not errorlevel 1 goto :open_browser
  timeout /t 1 /nobreak >nul
)

echo.
echo The server did not start on port 3000. Check the server window for an error.
pause
exit /b 1

:open_browser
start "" "%WORKBENCH_URL%"
endlocal