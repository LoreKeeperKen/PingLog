@echo off
setlocal enabledelayedexpansion

set hyphen=-
set response=0
set default=8.8.8.8
set i=0
set argArray=
set argCount=0


if "!cmdcmdline!"=="!cmdcmdline:%~f0=!" (
    set executefrom=cmd
)

if "!executefrom!"=="cmd" (
    goto CMD
)

goto FILE



REM CMD START ============================================================================================

:CMD

for %%P in (%*) do (
    set /A argCount+=1
    if not [%%P]==[] (
        set argArray[!argCount!]=%%~P
        if "!argArray[!argCount!]:~0,1!"=="%hyphen%" ( 
            set argArray[!argCount!]= 
        )
    )
)

for /l %%I in (1,1,9) do (
    set ip=!ip!!argArray[%%I]!
)

if "!ip!"=="" (
    set ip=%default%
    echo No IP/URL entered, using default !default!
    goto MIDDLE
)

goto MIDDLE

REM CMD END ========================================================================================



REM FILE START ==========================================================================================

:FILE

if "!ip!"=="" (
    set /p ip="Enter IP/URL to timeless ping: "
)

if "!ip!"=="" (
    set ip=%default%
    echo No IP/URL entered, using default !default!
)

for %%C in (
-a -c -f -i -j -k -l -n -p -r -s -t -v -w -4 
-A -C -F -I -J -K -L -N -P -R -S -T -V -W -6
) do (
   set ip=!ip:%%C=!
)

goto MIDDLE

REM FILE END ======================================================================================





REM MIDDLE START =========================================================================================

:MIDDLE

set ip=%ip: =%
set hour=%time: =0%
set filename=ping-%ip%-%DATE:~-4,4%%DATE:~-10,2%%DATE:~-7,2%-%hour:~0,2%%hour:~3,2%.txt

goto LOOP

REM MIDDLE END ====================================================================================





REM LOOP START ==========================================================================================

:LOOP

for /f "delims=" %%P in ('ping -n 1 %ip%') do (
    set /A i+=1
    set pingarray[!i!]=%%P
)

set LineCount=%i%

for /l %%L in (1,1,%LineCount%) do (
    if "!pingarray[%%L]:~0,5!%"=="Reply" (
        set response=!pingarray[%%L]!
    ) else if "!pingarray[%%L]:~0,4!%"=="PING" (
        set response=!pingarray[%%L]!
        echo !response! - %time:~0,-3%
        if "!executefrom!"=="cmd" (
            goto END
        ) else (
            set ip=
            echo Please try again
            goto FILE
        )
    ) else if "!pingarray[%%L]:~0,12!%"=="Ping request" (
        set response=!pingarray[%%L]!
        echo !response! - %time:~0,-3%
        if "!executefrom!"=="cmd" (
            goto END
        ) else (
            set ip=
            echo Please try again
            goto FILE
        )
    ) else if "!pingarray[%%L]:~0,7!%"=="Request" (
        set response=!pingarray[%%L]! 
    ) else (
        echo Unused lines. > NUL
    )
)

set response=%response:time<=time=%
echo %response% - %time:~0,-3%>> "%filename%"

for /f "tokens=*" %%L in (%filename%) do ( 
    set line=%%L 
)

echo %line%

ping 224.0.0.0 -n 1 -w 1400 >NUL

goto LOOP

REM LOOP END ======================================================================================

:END
