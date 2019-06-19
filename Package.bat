@echo off

REM REQUIRES 7zip to be installed
REM WILL DELETE any Darnellify2 .zip files in the directiory!
REM This batch file packages the addon into a releaseable .zip
REM Sounds are NOT INCLUDED ON GIT, make sure to get them first

set NAME=Darnellify2
set BUILDDIR=Builds

mkdir %BUILDDIR%
mkdir %NAME%

REM Get the active Git tag
for /f %%i in ('git tag --sort=v:refname') do set TAG=%%i

REM Remove any existing zip of this version
del /Q %BUILDDIR%\%NAME%_%TAG%.zip

xcopy /E /I /Y Sounds %NAME%\Sounds
copy /V /Y *.lua %NAME%
copy /V /Y %NAME%.toc %NAME%
copy /V /Y Readme.* %NAME%

7z a -tzip %BUILDDIR%\%NAME%_%TAG%.zip -r Darnellify2

rmdir /S /Q %NAME%