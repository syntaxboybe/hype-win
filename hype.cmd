@echo off
setlocal
set "PATH=%PATH%;C:\msys64\ucrt64\bin"
set "QT_LOGGING_RULES=qt.multimedia.ffmpeg=false"
if "%~1"=="" goto open
if /I "%~1"=="new" if "%~2"=="" goto new
goto pass
:open
    "%~dp0build\release\hype.exe" open
    exit /b %ERRORLEVEL%
:new
    "%~dp0build\release\hype.exe" new ".\presentation.md"
    exit /b %ERRORLEVEL%
:pass
    "%~dp0build\release\hype.exe" %*
    exit /b %ERRORLEVEL%
