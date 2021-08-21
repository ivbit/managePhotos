@if (1 == 0) @end; /* Commenting all Batch code to hide it from JScript engine.
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

The script will rearrange recent photos in order.
Number of days ago defaults to 3 or can be
passed as an argument to the script.
This script is Batch/JScript hybrid.
JScript is used to perform operations with date.

Description END

:beginningOfScript
SETLOCAL EnableExtensions EnableDelayedExpansion

rem Declare variables START
rem Retrieve number of days ago as an argument, default is 3
set numDaysAgo=3
if NOT "%~1"=="" set /A "numDaysAgo=%~1"
if %numDaysAgo% LSS 0 set numDaysAgo=3
if %numDaysAgo% GTR 11000 set numDaysAgo=3
rem Provide the location of folders containing
rem photos with names in format pyyMMdd
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


rem If the folder exists, rearange all photos in that folder in order.
rem photo0001.jpg, photo0002.jpg, photo0003.jpg, ...
rem Use JScript to compute recent folder names in pyyMMdd form.
rem For each folder, compare the file names:
rem Extract the numeric part of a file name into numPartFileName variable.
rem Convert the number in the counter variable to 4 digit form,
rem and store it in numPartCounter variable.
rem Perform string comparsion of the 2 variables,
rem otherwise cmd.exe will treat numbers with leading zeroes as octal.
for /F %%A in ('cscript.exe //E:jscript //Nologo "%~f0" %numDaysAgo%') do (
  if exist "%photoFolder%\%%~A" (
    set counter=0
    for %%B in ("%photoFolder%\%%~A\*.jpg") do (
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

goto :EOF


BEGINNING OF JScript PART OF THE SCRIPT

Define functions START
1 day equals 86400000 milliseconds
The function will receive the difference in days
as millDaysAgo argument, and use it to compute
the date millDaysAgo ago.
The day, month and year will be computed and
returned in a pyyMMdd format. */
function computePDate(millDaysAgo) {
  var todayDate = new Date();
  // If millDaysAgo equals 0, theDate is today.
  var theDate = new Date(todayDate - 86400000 * millDaysAgo);

  var theDay = (theDate.getDate());
  // Force 2 digit output format, as 01, 09, 22, 30, ...
  theDay = '0' + theDay.toString();
  theDay = theDay.substring(theDay.length - 2);

  /* First month in JScript has a 0 index, adding 1 to
     convert it to human readable format */
  var theMonth = (theDate.getMonth() + 1);
  // Force 2 digit output format, as 01, 09, 10, ...
  theMonth = '0' + theMonth.toString();
  theMonth = theMonth.substring(theMonth.length - 2);

  // Force 2 digit output format for the year
  var fullYear = theDate.getFullYear();
  var theYear = theDate.getFullYear().toString().substring(2);

  // result in format pyyMMdd
  var result = 'y' + fullYear + '\\p' + theYear + theMonth + theDay;

  return result;
}
/* Define functions END

Call the function as many times as specified in an argument
passed to cscript.exe, start with 0 to include the today's date.
An argument of 3 will return 4 dates in pyyMMdd format
(today and past 3 days). */
for (var numCounter = 0; numCounter <= WScript.Arguments(0); numCounter++) {
  WScript.Echo(computePDate(numCounter));
}

// END OF SCRIPT

