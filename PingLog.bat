@echo off
setlocal enabledelayedexpansion

set ip=%1
if "%ip%"=="" (
    set /p ip="Enter IP/URL to timeless ping: "
)
if "%ip%"=="" (
    set ip=8.8.8.8
    echo No IP/URL entered, using default !ip!
)

set hour=%time: =0%
set filename=ping-%ip%-%DATE:~-4,4%%DATE:~-10,2%%DATE:~-7,2%-%hour:~0,2%%hour:~3,2%.txt


:REPEAT

set response=0
for /f "delims=" %%P in ('ping -n 1 %ip% ^| find "Reply"') do (set response=!response!%%P)
set response=%response:time<=time=%
if "%response:~0,2%"=="0R" (
    echo %response:~1% - %time:~0,-3%>> "%filename%" 
) else (
    echo Request timed out. - %time:~0,-3%>> "%filename%"
)


for /f "tokens=*" %%L in (%filename%) do ( 
    set line=%%L 
)
echo %line%


ping 224.0.0.0 -n 1 -w 1400 >NUL


goto REPEAT
