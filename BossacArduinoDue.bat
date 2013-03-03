@ECHO off
REM ***********************************************************************************************************************
REM ***********************************************************************************************************************
REM * Description:
REM *
REM * Programming Arduino Due with Bossac in Atmel Studio 6
REM *
REM * 1. Copy this batch file into Atmel Studio 6 Program Folder (C:\Program Files (x86)\Atmel\Atmel Studio 6.0)
REM *
REM * 2. Configure an 'External Tool' in Atmel Studio 6.
REM *    Tools -> External Tools
REM *
REM * 3. Configure an debug build command
REM *    Titel: BossacArduinoDue(Debug)
REM *    Command: C:\Program Files (x86)\Atmel\Atmel Studio 6.0\BossacArduinoDue.bat
REM *    Arguments: "C:\Program Files (x86)\arduino-1.5.2\hardware\tools\bossac.exe" $(ProjectDir) $(ProjectFileName) Debug
REM *    Checkbox "Use Output Window".
REM *
REM * 4. Configure an release build command
REM *    Titel: BossacArduinoDue(Release)
REM *    Command: C:\Program Files (x86)\Atmel\Atmel Studio 6.0\BossacArduinoDue.bat
REM *    Arguments: "C:\Program Files (x86)\arduino-1.5.2\hardware\tools\bossac.exe" $(ProjectDir) $(ProjectFileName) Release
REM *    Checkbox "Use Output Window".
REM *
REM * 5. Call 'External Tool' in Atmel Studio 6.
REM *    Tools -> BossacArduinoDue(Debug) for Debug Build
REM *    Tools -> BossacArduinoDue(Release) for Release Build
REM *
REM *----------------------------------------------------------------------------------------------------------------------
REM * Version	: 0.01
REM * Date		: 01.03.2013
REM * Name		: Ewald Weinhandl
REM *
REM * Tested with: Windows 7 64 Bit, Atmel Studio 6.0.1996 Service Pack 2, Arduino-1.5.2
REM *
REM ***********************************************************************************************************************
REM ***********************************************************************************************************************
REM * 
REM * Copyright (C) 2013 by weinhandl.org
REM * 
REM * This program is free software: you can redistribute it and/or modify
REM * it under the terms of the GNU General Public License as published by
REM * the Free Software Foundation, either version 3 of the License, or
REM * (at your option) any later version.
REM * 
REM * This program is distributed in the hope that it will be useful,
REM * but WITHOUT ANY WARRANTY; without even the implied warranty of
REM * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
REM * GNU General Public License for more details.
REM * 
REM * You should have received a copy of the GNU General Public License
REM * along with this program.  If not, see <http://www.gnu.org/licenses/>.
REM * 
REM ***********************************************************************************************************************
REM ***********************************************************************************************************************

ECHO ------ External tool BossacArduinoDue started ------

REM number of command line arguments ok?
IF [%1]==[] GOTO error_args
IF [%2]==[] GOTO error_args
IF [%3]==[] GOTO error_args
IF [%4]==[] GOTO error_args

REM set command line arguments
SET BOSSACPATH=%1
SET PROJECTDIR=%2
SET PROJECTFILENAME=%3
SET BUILD=%4

REM parse command line arguments
SET BOSSACPATH=%BOSSACPATH:"=%
SET PROJECTDIR=%PROJECTDIR:"=%
SET PROJECTFILENAME=%PROJECTFILENAME:"=%
SET BUILD=%BUILD:"=%

REM parse bin file
SET BINFILENAME=%PROJECTFILENAME:cproj=bin%
SET BINFILE=%PROJECTDIR%%BUILD%\%BINFILENAME%

REM workeround for bug in Atmel Studio 6.0.1996 Service Pack 2
SET PROJECTDIR=%PROJECTDIR:\\=\%

REM bossac path exist?
IF NOT EXIST "%BOSSACPATH%" GOTO error_arg1

REM project dir exist?
IF NOT EXIST "%PROJECTDIR%" GOTO error_arg2

REM project file name exist?
IF NOT EXIST "%PROJECTDIR%""%PROJECTFILENAME%" GOTO error_arg3

REM build option debug?
ECHO.%4 | findstr /I /C:"Debug" 1>NUL
IF ERRORLEVEL 1 (
	REM pattern not found
	SET BUILD=0
) ELSE (
	REM found pattern
	GOTO binfile
)

REM build option release?
ECHO.%4 | findstr /I /C:"Release" 1>NUL
IF ERRORLEVEL 1 (
	REM pattern not found
	SET BUILD=0
) ELSE (
	REM found pattern
	GOTO binfile
)

REM no build option exist!
IF %BUILD%==0 GOTO error_arg4

:binfile

REM bin file exist?
IF NOT EXIST "%BINFILE%" GOTO error_binfile

REM fetch DeviceID of Arduino Due Programming Port from WMI Service
FOR /f "usebackq" %%B IN (`wmic PATH Win32_SerialPort Where "Caption LIKE '%%Arduino Due Programming Port%%'" Get DeviceID ^| FIND "COM"`) DO SET COMPORT=%%B

REM Arduino Due Programming Port exist?
IF [%COMPORT%]==[] GOTO error_comport

REM report in Atmel Studio 6.0 IDE output window
ECHO Build=%BUILD%
ECHO BossacPath=%BOSSACPATH%
ECHO ProjectFileName=%PROJECTFILENAME%
ECHO ProjectDir=%PROJECTDIR%
ECHO BinFile=%BINFILE%
ECHO Arduino Due Programming Port is detected as %COMPORT%.

REM The bossac bootloader only runs if the memory on Arduino Due is erased.
REM The Arduino IDE does this by opening and closing the COM port at 1200 baud.
REM This causes the Due to execute a soft erase command.
ECHO Execute a soft erase command on Arduino Due.
MODE %COMPORT%:1200,n,8,1

REM Wait 3 second for memory on Arduino Due is erased.
ECHO Wait for memory on Arduino Due is erased...
PING -n 4 127.0.0.1>NUL

REM Execute bossac.exe
ECHO Execute bossac with command line:
ECHO "%BOSSACPATH%" --port=%COMPORT% -U false -e -w -v -b -R "%BINFILE%"
START /WAIT "" "%BOSSACPATH%" --port=%COMPORT% -U false -e -w -v -b -R "%BINFILE%"

GOTO end

:error_args
ECHO Error: wrong number of command line arguments passed!
GOTO end

:error_arg1
ECHO Error: command line argument 1 - path to bossac.exe not exist!
ECHO Error: command line argument 4 - argument passed = %1
GOTO end

:error_arg2
ECHO Error: command line argument 2 - project directory not exist! - use $(ProjectDir)
ECHO Error: command line argument 4 - argument passed = %1
GOTO end

:error_arg3
ECHO Error: command line argument 3 - project file name not exist! - use $(ProjectFileName)
ECHO Error: command line argument 4 - argument passed = %2
GOTO end

:error_arg4
ECHO Error: command line argument 4 - build option not exist! - use Debug or Release
ECHO Error: command line argument 4 - passed = %4
GOTO end

:error_binfile
ECHO Error: bin file "%BINFILE%" not exist!
GOTO end

:error_comport
ECHO Error: Arduino Due Programming Port not found!

:end

ECHO ======================== Done ========================
