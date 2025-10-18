@echo off
setlocal enabledelayedexpansion

:: Compiler & linker
set FASM=fasm
set LINKER=x86_64-w64-mingw32-ld

:: Directories
set SRC_DIR=src\windows_x64
set BUILD_DIR=build\windows_x64
set OBJ_DIR=!BUILD_DIR!\obj
set ASSET_DIR=assets
set BUILD_ASSETS=!BUILD_DIR!\assets
set BIN=!BUILD_DIR!\Pixie.exe

:: Create necessary directories
mkdir "!OBJ_DIR!" 2>nul
mkdir "!BUILD_ASSETS!" 2>nul

:: Copy assets
if exist "!ASSET_DIR!" xcopy /Y /Q /I /S "!ASSET_DIR!\*" "!BUILD_ASSETS!\" 2>nul

:: Assemble source files
set OBJS=
for %%F in (!SRC_DIR!\*.asm) do (
    set FNAME=%%~nF
    set OBJ=!OBJ_DIR!\!FNAME:.asm=.o!
    "!FASM!" "%%F" "!OBJ!"
    if errorlevel 1 exit /b 1
    set OBJS=!OBJS! !OBJ!
)

:: Link objects
"!LINKER!" !OBJS! -o "!BIN!" -L!SRC_DIR!\lib -lraylib -lm -lmsvcrt -e main -subsystem console
if errorlevel 1 exit /b 1

:: Copy required DLLs next to EXE
if exist "!SRC_DIR!\lib\raylib.dll" xcopy /Y /Q "!SRC_DIR!\lib\raylib.dll" "!BUILD_DIR!\" 2>nul

echo Build complete: !BIN!
pause
