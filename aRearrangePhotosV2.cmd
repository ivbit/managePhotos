@echo off

goto :beginningOfScript

Intellectual property information START

Copyright (c) 2021 Ivan Bityutskiy 

Permission to use, copy, modify, and distribute this software for any
purpose with or without fee is hereby granted, provided that the above
copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

Intellectual property information END

Description START

The script will rearrange all photos in all folders in order:
photo0001.jpg, photo0002.jpg, photo0003.jpg, ...

Description END

:beginningOfScript
SETLOCAL EnableExtensions EnableDelayedExpansion

rem Declare variables START
rem Provide the location of folders containing
rem photos with folder names in format pyyMMdd
set "photoFolder=C:\photos"
set "numPartFileName= "
set "numPartCounter= "
set counter=0
rem Declare variables END

rem Reset the ERRORLEVEL to 0
> NUL verify
rem Check existence of input path
> NUL 2>&1 dir "%photoFolder%"
if ERRORLEVEL 1 (
  title ERROR
  echo "%photoFolder%" is unavailable. Exiting.
  timeout /T 10
  title %COMSPEC%
  exit /B 1
)

rem Rearange all photos in that folder in order.
rem photo0001.jpg, photo0002.jpg, photo0003.jpg, ...
rem For each folder, compare the file names:
rem Extract the numeric part of a file name into numPartFileName variable.
rem Convert the number in the counter variable to 4 digit form,
rem and store it in numPartCounter variable.
rem Perform string comparsion of the 2 variables,
rem otherwise cmd.exe will treat numbers with leading zeroes as octal.
for /D %%y in ("%photoFolder%\y*") do (
  for /D %%A in ("%%~fy\p*") do (
    set counter=0
    for %%B in ("%%~fA\*.jpg") do (
      set /A "counter+=1"
      set "numPartFileName=%%~nB"
      set "numPartFileName=!numPartFileName:photo=!"
      set "numPartCounter=000!counter!"
      set "numPartCounter=!numPartCounter:~-4!"
      if NOT "!numPartCounter!"=="!numPartFileName!" (
        ren "%%~fB" "photo!numPartCounter!.jpg"
      )
    )
  )
)

ENDLOCAL

