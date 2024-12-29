@echo off
if exist desolate.com del desolate.com
if exist desolcod0.bin del desolcod0.bin
if exist desolcod0.exp del desolcod0.exp
if exist desolcode.bin del desolcode.bin
if exist desolcode.exp del desolcode.exp
if exist desolcode.zx0 del desolcode.zx0

rem Define ESCchar to use in ANSI escape sequences
rem https://stackoverflow.com/questions/2048509/how-to-echo-with-different-colors-in-the-windows-command-line
for /F "delims=#" %%E in ('"prompt #$E# & for %%E in (1) do rem"') do set "ESCchar=%%E"

@echo on
tools\pasmo --w8080 desolcod0.asm desolcod0.bin
@if errorlevel 1 goto Failed
@echo off

dir /-c desolcod0.bin|findstr /R /C:"desolcod0.bin"

@echo on
tools\pasmo --w8080 desolcoda.asm desolcode.bin desolcode.exp
@if errorlevel 1 goto Failed
@echo off

findstr /B "Desolate" desolcode.exp

dir /-c desolcode.bin|findstr /R /C:"desolcode.bin"

tools\salvador.exe -classic desolcode.bin desolcode.zx0

dir /-c desolcode.zx0|findstr /R /C:"desolcode.zx0"

copy /b desolcod0.bin+desolcode.zx0 DESOLATE.COM >nul

dir /-c desolate.com|findstr /R /C:"DESOLATE.COM"

if exist x-desolate.kdi del x-desolate.kdi
copy x-clean.kdi x-desolate.kdi

tools\xkorvet a x-desolate.kdi DESOLATE.COM

echo %ESCchar%[92mSUCCESS%ESCchar%[0m
exit

:Failed
@echo off
echo %ESCchar%[91mFAILED%ESCchar%[0m
exit /b
