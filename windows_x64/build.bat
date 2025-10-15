@echo off
setlocal enabledelayedexpansion

:: ===== CONFIG =====
set OUT=main.exe
set LIBS=-L. -lraylib -lmsvcrt
set ENTRY=main
set LINKER=x86_64-w64-mingw32-ld
set ASM=fasm
:: ==================

del /q *.obj 2>nul

for %%F in (*.asm) do (
    %ASM% "%%F" "%%~nF.obj"
    if errorlevel 1 exit /b 1
)

set OBJS=
for %%O in (*.obj) do set OBJS=!OBJS! %%O

%LINKER% !OBJS! -o %OUT% %LIBS% -e %ENTRY% -subsystem console
if errorlevel 1 exit /b 1

echo Build success: %OUT%
pause
