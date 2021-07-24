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
Can be to rename photos with UTF-16LE names, long filenames, etc.

Description END #>

# BEGINNING OF SCRIPT

# need to fix 'the file already exists error'
$photoFolder = 'C:\photos'
$goodFolders = @((Get-ChildItem -Path $photoFolder -Recurse -Filter "photo0001.jpg").Directory.Name | Select-Object -Unique)
$allFolders = @((Get-ChildItem -Path $photoFolder -Directory -Exclude 'private').Name)
$badFolders = @($allFolders.Where({ $PSItem -notin $goodFolders }))

foreach ($badFolder in $badFolders) {
  $arrFiles = @(Get-ChildItem -File -Path "$photoFolder\$badFolder")
  $intCounter = 1
  foreach ($pFile in $arrFiles) {
    Rename-Item -Path $pFile.FullName -NewName ('photo{0:d4}.jpg' -f $intCounter++)
  }
}

# END OF SCRIPT

