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

The script will move photos from removable device, while renaming them.

Description END

:beginningOfScript
SETLOCAL EnableExtensions EnableDelayedExpansion

rem Declare variables START
set "inPath=F:\Images"
set "outPath=C:\photos"
set "yearSet= "
set "numPartFileName= "
set "numPartCounter= "
set counter=0
set notArranged=1
rem Declare variables END

rem Reset the ERRORLEVEL to 0
> NUL verify
rem Check existence of input path
> NUL 2>&1 dir "%inPath%"
if ERRORLEVEL 1 (
  title ERROR
  echo "%inPath%" is unavailable. Exiting.
  timeout /T 10
  title %COMSPEC%
  exit /B 1
)

rem For each photo in input path, extract the LastWriteTime,
rem add it to yearSet variable in a format yYYYY
for %%A in ("%inPath%\*.jpg") do (
  for /F "tokens=1,2,3 delims=. " %%B in ("%%~tA") do (
    if "!yearSet:y%%~D=!"=="!yearSet!" set "yearSet=!yearSet!y%%~D "
  )
)

rem For each year in yearSet:
for %%y in (%yearSet%) do (
  set "dateSet= "
  rem For each photo in input path, extract the LastWriteTime,
  rem convert it to the format pyyMMdd.
  rem For each date, create an indirect variable with pyyMMdd name and store
  rem in it all file names with that date in a space delimited string.
  rem For each date, add unique date with pyyMMdd format to dateSet variable
  rem in a space delimited string.
  for %%A in ("%inPath%\*.jpg") do (
    for /F "tokens=1,2,3 delims=. " %%B in ("%%~tA") do (
      set "dateYear=%%~D"
      if "y!dateYear!"=="%%~y" (
        set "pDate=p!dateYear:~2!%%~C%%~B"
        for /F %%E in ("!pDate!") do (
          set "!pDate!=!%%~E!%%~nxA "
          if "!dateSet:%%~E=!"=="!dateSet!" set "dateSet=!dateSet!%%~E "
        )
      )
    )
  )

  rem For each value in dateSet string, check existence of a folder with same
  rem name in the output destination. Create a folder if it doesn't exist.
  rem If the folder already exists, rearange all photos in that folder in order.
  rem Compute the amount of photos in the folder and set counter to the next available integer.
  rem For each indirect variable with name in format pyyMMdd, extract file names
  rem and copy them to the destination, using exiftool.exe, renaming the accordingly.
  rem Delete the files from removable media.
  for %%A in (!dateSet!) do (
    set notArranged=1
    if NOT exist "%outPath%\%%~y\%%~A" (
      mkdir "%outPath%\%%~y\%%~A"
      set notArranged=0
    )
    if !notArranged! EQU 1 (
      set counter=0
      for %%B in ("%outPath%\%%~y\%%~A\*.jpg") do (
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
    set counter=0
    for %%B in ("%outPath%\%%~y\%%~A\*.jpg") do (
      set /A "counter+=1"
    )
    for %%B in (!%%~A!) do (
      set /A "counter+=1"
      set "numPartCounter=000!counter!"
      set "numPartCounter=!numPartCounter:~-4!"
      > NUL 2>&1 exiftool.exe "-all:all=" "%inPath%\%%~B" "-o" "%outPath%\%%~y\%%~A\photo!numPartCounter!.jpg"
      del "%inPath%\%%~B"
    )
  )
)

ENDLOCAL

rem END OF SCRIPT

