@echo off

REM REQUIRES 7zip to be installed
REM This batch file packages the addon into a releaseable .zip
REM Sounds are NOT INCLUDED ON GIT, make sure to get them first

del Darnellify2.zip

7z a -tzip Darnellify2.zip -r *.lua Readme.txt Darnellify2.toc Sounds\
