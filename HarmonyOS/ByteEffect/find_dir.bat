@echo off
setlocal enabledelayedexpansion


set "script_dir=%~dp0"
if "%script_dir:~-1%"=="\" set "script_dir=%script_dir:~0,-1%"


set "root_dir=%script_dir%\..\oh_modules\.ohpm"
set "target_folder=wrapper"


for /f "delims=" %%i in ('dir "%root_dir%" /s /b /ad') do (
    for %%j in ("%%i") do (
        if /i "%%~nxj"=="%target_folder%" (
            echo %%i | findstr "wrapper@" >nul
            if !errorlevel! equ 0 (
                echo %%i
            )
        )
    )
)