<# Intellectual property information START

Copyright (c) 2020 Ivan Bityutskiy 

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

Intellectual property information END #>

<# Description START

The script will rename photos in order. 
Applies to all existing files.
Can be used after deleting some of recent photos.

Description END #>

# BEGINNING OF SCRIPT

$photoFolder = 'C:\photos'

$allFolders = @(Get-ChildItem -Path $photoFolder -Directory)

foreach ($photoFolder in $allFolders) {
  $photoFolderContents = @(Get-ChildItem -Path $photoFolder.FullName -File -Filter *.jpg)
  $fileNameNumericPart = 1
  foreach ($photoFile in $photoFolderContents) {
    $fileEndPart = '{0:d4}' -f $fileNameNumericPart
    $oldPhotoFileName = $photoFile.FullName
    $newPhotoFileName = $oldPhotoFileName -replace '\d{4}(?=\.jpg$)', $fileEndPart
    if ($newPhotoFileName -ne $oldPhotoFileName) {
      Rename-Item -Path $oldPhotoFileName -NewName $newPhotoFileName
    }
    $fileNameNumericPart++
  }
}

# END OF SCRIPT

