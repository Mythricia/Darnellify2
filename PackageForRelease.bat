@echo off

REM REQUIRES 7zip to be installed
REM WILL DELETE any Darnellify2 .zip files in the directiory!
REM This batch file packages the addon into a releaseable .zip
REM Sounds are NOT INCLUDED ON GIT, make sure to get them first

mkdir Builds

REM Get the active Git tag
for /f %%i in ('git tag --sort=v:refname') do set TAG=%%i

REM Remove any existing zip of this version
del /Q Builds\Darnellify2_%TAG%.zip

7z a -tzip Builds\Darnellify2_%TAG%.zip -r *.lua Readme.txt Darnellify2.toc Sounds\
