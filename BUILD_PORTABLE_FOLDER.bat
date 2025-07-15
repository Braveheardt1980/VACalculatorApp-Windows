@echo off
REM This script creates a portable folder for Windows

echo Building VA Calculator Portable for Windows...

REM Build with embedded Swift runtime
swift build --configuration release --static-swift-stdlib

REM Create portable folder
mkdir VACalculator-Portable
mkdir VACalculator-Portable\bin

REM Copy executable
copy .build\release\VACalculatorApp-Windows.exe VACalculator-Portable\

REM Create run script
echo @echo off > VACalculator-Portable\RunVACalculator.bat
echo start VACalculatorApp-Windows.exe >> VACalculator-Portable\RunVACalculator.bat

REM Create readme
echo VA Calculator - Portable Edition > VACalculator-Portable\README.txt
echo. >> VACalculator-Portable\README.txt
echo To run: Double-click RunVACalculator.bat >> VACalculator-Portable\README.txt
echo Or directly run VACalculatorApp-Windows.exe >> VACalculator-Portable\README.txt
echo. >> VACalculator-Portable\README.txt
echo No installation required! >> VACalculator-Portable\README.txt

echo.
echo Portable folder created: VACalculator-Portable\
echo Copy this entire folder to any Windows PC and run!