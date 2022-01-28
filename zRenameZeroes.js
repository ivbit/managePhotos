/* Intellectual property information START

Copyright (c) 2022 Ivan Bityutskiy 

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

"Somebody" fatfingered the code in supposedly working version of
"aManagePhotosV1.wsf". This script is made to fix the issue:
photo00014.jpg instead of photo0014.jpg after calling rearrangeFiles().

Find all files with extra 0 in their names, rename the files.

Description END

Declare variables START */
var objFSO = WScript.CreateObject('Scripting.FileSystemObject');
var strOutPath = 'C:\\photos';
var strPath = '';
var objMainFolder = objFSO.GetFolder(strOutPath);
var objMainFolderEnum = new Enumerator(objMainFolder.SubFolders);
var objYearFolder, objYearFolderEnum, objPhotoFolder, objPhotoFolderEnum;
var objPhotoFile;
var regexpYear = /^y\d+$/;
var regexpZeroes = /^photo000\d\d\.jpg$/;
/* Declare variables END

BEGINNING OF SCRIPT */
while (! objMainFolderEnum.atEnd())
{
  objYearFolder = objFSO.GetFolder(objMainFolderEnum.item());
  if (objYearFolder.Name.match(regexpYear))
  {
    objYearFolderEnum = new Enumerator(objYearFolder.SubFolders);
    while (! objYearFolderEnum.atEnd())
    {
      objPhotoFolder = objFSO.GetFolder(objYearFolderEnum.item());
      objPhotoFolderEnum = new Enumerator(objPhotoFolder.Files);
      while (! objPhotoFolderEnum.atEnd())
      {
        objPhotoFile = objFSO.GetFile(objPhotoFolderEnum.item());
        if (objPhotoFile.Name.match(regexpZeroes))
        {
          strPath = objPhotoFile.ParentFolder + '\\photo00' + objPhotoFile.Name.substring(8);
          objPhotoFile.Move(strPath);
        }
        objPhotoFolderEnum.moveNext();
      }
      objYearFolderEnum.moveNext();
    }
  } // End If
  objMainFolderEnum.moveNext();
}
WScript.Echo('All done!');
// END OF SCRIPT

