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

The script will move photos from removable device, while renaming them.

Description END #>

# BEGINNING OF SCRIPT

$photoFiles = @(Get-ChildItem -File -Path 'F:\Images\')
if (-not $?) { exit 1 }

[System.Collections.Generic.HashSet[string]] $pFolders =
  @(foreach ($cTimeStamp in $photoFiles.CreationTime) {
      $cTimeStamp.ToString('pyyMMdd')
  })

foreach ($pFolder in $pFolders) {
  [System.Boolean] $notArranged = $true
  $pFolderPath = "C:\photos\$pFolder"
  if (-not (Test-Path -Path $pFolderPath)) {
    $null = New-Item -ItemType Directory -Path 'C:\photos' -Name $pFolder
    $notArranged = $false
  }

  if ($notArranged) {
    $pFolderContents = @(Get-ChildItem -Path $pFolderPath -File -Filter *.jpg)
    if ($pFolderContents) {
      $fileNameNumericPart = 1
      foreach ($photoFileJpg in $pFolderContents) {
        $fileEndPart = '{0:d4}' -f $fileNameNumericPart
        $oldPhotoFileName = $photoFileJpg.FullName
        $newPhotoFileName = $oldPhotoFileName -replace '\d{4}(?=\.jpg$)', $fileEndPart
        if ($newPhotoFileName -ne $oldPhotoFileName) {
          Rename-Item -Path $oldPhotoFileName -NewName $newPhotoFileName
        }
        $fileNameNumericPart++
      }
    }
    $notArranged = $false
  }

  foreach ($photoFile in $photoFiles) {
    if ($photoFile.CreationTime.ToString('pyyMMdd') -like $pFolder) {
      $pNewName = 'photo{0:d4}.jpg' -f (@(Get-ChildItem -Path $pFolderPath).Length + 1)
      $pNewDestination = "$pFolderPath\$pNewName"
      $null = exiftool.exe '-all:all=' $photoFile.FullName '-o' $pNewDestination 2> $null
      Remove-Item -Path $photoFile.FullName
    }
  }
}

# END OF SCRIPT

