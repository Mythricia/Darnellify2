@echo off

REM REQUIRES 7zip to be installed
REM WILL DELETE any Darnellify2 .zip files in the directiory!
REM This batch file packages the addon into a releaseable .zip
REM Sounds are NOT INCLUDED ON GIT, make sure to get them first

REM Get the active Git tag
for /f %%i in ('git tag') do set TAG=%%i

REM Remove any existing Darnellify2 version zips
del /Q Darnellify2*.zip

7z a -tzip Darnellify2_%TAG%.zip -r *.lua Readme.txt Darnellify2.toc Sounds\
