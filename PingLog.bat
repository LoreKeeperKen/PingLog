@echo off
setlocal EnableDelayedExpansion






rem ============================================================================================
rem ============================================================================================
rem = Intialize variables
rem ============================================================================================
rem ============================================================================================


set hyphen=-
set response=0
set default=8.8.8.8
set i=0
set argArray=
set argCount=0


rem ===== English replies ======================================================================
set replies[0409]=Reply
set pingRequests[0409]=Ping request
set requests[0409]=Request
set failure[0409]=PING:


rem ===== German/Deutsch replies =======================================================================
set replies[0407]=Antwort
set pingRequests[0407]=Ping-Anforderung
set requests[0407]=Zeitüberschreitung
set failure[0407]=PING:

rem When adding support for new languages use the number returned by the below reg query for the index 


rem ==== Getting and storing system's default language =========================================
for /f "delims=" %%a in ('reg query "hklm\system\controlset001\control\nls\language" /v Default') do @set defaultLang=%%a
set defaultLang=%defaultLang:~-4%


rem ==== Store string length for use in LOOP ==================================================
call :strlen replyLength replies[!defaultLang!]
call :strlen pingRequestLength pingRequests[!defaultLang!]
call :strlen requestLength requests[!defaultLang!]






rem ============================================================================================
rem ============================================================================================
rem = Check environment variable to see if pinglog was executed from cmd line or by clicking 
rem = on the batch file. 
rem ============================================================================================
rem ============================================================================================


if "!cmdcmdline!"=="!cmdcmdline:%~f0=!" (
    set executefrom=cmd
)


if "!executefrom!"=="cmd" (
    goto CMD
)


goto FILE






rem ============================================================================================
rem ============================================================================================
rem = If executed from cmd, iterates over passed arguments, removes -* arguments, and sets IP.
rem ============================================================================================
rem ============================================================================================


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
    goto PREP
)


goto PREP






rem ============================================================================================
rem ============================================================================================
rem = If executed by clicking on batch file, prompts for IP, defaults if no IP provided, 
rem = and removes -* arguments.
rem ============================================================================================
rem ============================================================================================


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


goto PREP






rem ============================================================================================
rem ============================================================================================
rem = Preps IP and time and intializes filename.
rem ============================================================================================
rem ============================================================================================


:PREP


set ip=%ip: =%
set hour=%time: =0%
set filename=ping-%ip%-%DATE:~-4,4%%DATE:~-10,2%%DATE:~-7,2%-%hour:~0,2%%hour:~3,2%.txt


goto LOOP






rem ============================================================================================
rem ============================================================================================
rem = Loops ping -n 1 to simulate timeless ping
rem ============================================================================================
rem ============================================================================================


:LOOP


for /f "delims=" %%P in ('ping -n 1 %ip%') do (
    set /A i+=1
    set pingarray[!i!]=%%P
)


set LineCount=%i%


rem %replyLength%!
rem replies[%defaultLang%]
rem replies[0409]


rem =========== Interates over the ping reply =================================================
for /l %%L in (1,1,%LineCount%) do (
    if "!pingarray[%%L]:~0,5!"=="!replies[%defaultLang%]!" (
        set response=!pingarray[%%L]!
    ) else if "!pingarray[%%L]:~0,7!"=="!requests[%defaultLang%]!" (
        set response=!pingarray[%%L]! 
    ) else if "!pingarray[%%L]:~0,5!"=="!failure[%defaultLang%]!" (
        set response=!pingarray[%%L]!
    ) else if "!pingarray[%%L]:~0,12!"=="!pingRequests[%defaultLang%]!" (
        set response=!pingarray[%%L]!
        echo !response! - %date% - %time:~0,-3%
        if "!executefrom!"=="cmd" (
            goto :eof
        ) else (
            set ip=
            echo Please try again
            goto FILE
        )

    ) else (
        echo Unused lines. > NUL
    )
)


rem =========== Writes the ping reply to logfile ================================================
echo %response% - %date% - %time:~0,-3%>> "%filename%"


rem =========== Reads the last line from the logfile =============================================
for /f "tokens=*" %%L in (%filename%) do ( 
    set line=%%L 
)


echo %line%


ping 224.0.0.0 -n 1 -w 1400 >NUL


goto LOOP






rem ============================================================================================
rem ============================================================================================
rem = Functions
rem ============================================================================================
rem ============================================================================================


:strlen <resultVar> <stringVar>
(   
    (set^ tmp=!%~2!)
    if defined tmp (
        set "len=1"
        for %%P in (4096 2048 1024 512 256 128 64 32 16 8 4 2 1) do (
            if "!tmp:~%%P,1!" NEQ "" ( 
                set /a "len+=%%P"
                set "tmp=!tmp:~%%P!"
            )
        )
    ) ELSE (
        set len=0
    )
)




