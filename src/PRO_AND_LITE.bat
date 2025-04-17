@echo off
echo Running Lua script: split_pro_and_lite.lua

:: Run the Lua script to split the source script into "Pro" and "Lite" editions
lua54 split_pro_and_lite.lua

:: Check for errors
if %ERRORLEVEL% neq 0 (
    echo.
    echo Script failed with error code %ERRORLEVEL%.
    pause
    exit /b %ERRORLEVEL%
)

echo.
echo Script executed successfully.
echo.
pause