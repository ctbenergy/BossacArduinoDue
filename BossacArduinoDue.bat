@ECHO off
REM ***********************************************************************************************************************
REM ***********************************************************************************************************************
REM * Description:
REM *
REM * Programming Arduino Due with Bossac in Atmel Studio 6 and Atmel Studio 7
REM *
REM *----------------------------------------------------------------------------------------------------------------------
REM *
REM * Primary usage Atmel Studio 6:
REM *
REM * 1. Copy this batch file into Atmel Studio 6 Program Folder (C:\Program Files (x86)\Atmel\Atmel Studio 6.0)
REM *
REM * 2. Configure an 'External Tool' in Atmel Studio 6 (Tools -> External Tools...).
REM *
REM * 2.1 Configure a debug build command
REM *     Titel: BossacArduinoDue(Debug)
REM *     Command: C:\Program Files (x86)\Atmel\Atmel Studio 6.0\BossacArduinoDue.bat
REM *     Arguments: "C:\Program Files (x86)\arduino-1.5.2\hardware\tools\bossac.exe" "$(ProjectDir)\Debug\$(ProjectFileName).bin"
REM *     Checkbox "Use Output Window".
REM *
REM * 2.2. Configure a release build command
REM *      Titel: BossacArduinoDue(Release)
REM *      Command: C:\Program Files (x86)\Atmel\Atmel Studio 6.0\BossacArduinoDue.bat
REM *      Arguments: "C:\Program Files (x86)\arduino-1.5.2\hardware\tools\bossac.exe" "$(ProjectDir)\Release\$(ProjectFileName).bin"
REM *      Checkbox "Use Output Window".
REM *
REM * 3. Call 'External Tool' in Atmel Studio 6.
REM *    Tools -> BossacArduinoDue(Debug) for Debug Build or BossacArduinoDue(Release) for Release Build
REM *
REM *----------------------------------------------------------------------------------------------------------------------
REM *
REM * Alternative usage Atmel Studio 6:
REM *
REM * 1.  Copy this batch file into Atmel Studio 6 Program Folder (C:\Program Files (x86)\Atmel\Atmel Studio 6.0)
REM *
REM * 2.  Configure a post build event in the project properties.
REM *     "$(DevEnvDir)\BossacArduinoDue.bat" "C:\Program Files (x86)\arduino-1.5.2\hardware\tools\bossac.exe" "$(OutputDirectory)\$(OutputFileName).bin"
REM *
REM *----------------------------------------------------------------------------------------------------------------------
REM *
REM * Primary usage Atmel Studio 7:
REM *
REM * 1. Copy this batch file into Atmel Studio 7 Program Folder (C:\Program Files (x86)\Atmel\Studio\7.0)
REM *
REM * 2. Configure an 'External Tool' in Atmel Studio 7 (Tools -> External Tools...).
REM *
REM * 2.1 Configure a debug build command
REM *     Titel: BossacArduinoDue(Debug)
REM *     Command: C:\Program Files (x86)\Atmel\Studio\7.0\BossacArduinoDue.bat
REM *     Arguments: "C:\Program Files (x86)\BOSSA\bossac.exe" "$(ProjectDir)\Debug\$(ProjectFileName).bin"
REM *     Checkbox "Use Output Window".
REM *
REM * 2.2. Configure a release build command
REM *      Titel: BossacArduinoDue(Release)
REM *      Command: C:\Program Files (x86)\Atmel\Studio\7.0\BossacArduinoDue.bat
REM *      Arguments: "C:\Program Files (x86)\BOSSA\bossac.exe" "$(ProjectDir)\Release\$(ProjectFileName).bin"
REM *      Checkbox "Use Output Window".
REM *
REM * 3. Call 'External Tool' in Atmel Studio 7.
REM *    Tools -> BossacArduinoDue(Debug) for Debug Build or BossacArduinoDue(Release) for Release Build
REM *
REM *----------------------------------------------------------------------------------------------------------------------
REM *
REM * Alternative usage Atmel Studio 7:
REM *
REM * 1.  Copy this batch file into Atmel Studio 7 Program Folder (C:\Program Files (x86)\Atmel\Studio\7.0)
REM *
REM * 2.  Configure a post build event in the project properties.
REM *     "$(DevEnvDir)\BossacArduinoDue.bat" "C:\Program Files (x86)\BOSSA\bossac.exe" "$(OutputDirectory)\$(OutputFileName).bin"
REM *
REM *----------------------------------------------------------------------------------------------------------------------
REM * Version	: 0.01
REM * Date		: 01.03.2013
REM * Name		: Ewald Weinhandl
REM *
REM * Tested with: Windows 7 64 Bit, Atmel Studio 6.0.1996 Service Pack 2, Arduino-1.5.2
REM *
REM *----------------------------------------------------------------------------------------------------------------------
REM * Version	: 0.02
REM * Date		: 06.03.2013
REM * Name		: Ewald Weinhandl
REM *
REM * Changes for post build events.
REM *
REM * Command line argument 2 is now the bin-file path.
REM * Command line argument 3 and 4 removed.
REM * 
REM * Tested with: Windows 7 64 Bit, Atmel Studio 6.0.1996 Service Pack 2, Arduino-1.5.2
REM *
REM *----------------------------------------------------------------------------------------------------------------------
REM * Version	: 0.03
REM * Date		: 02.01.2018
REM * Name		: Ewald Weinhandl
REM * 
REM * Changes for Atmel Studio 7 and fetch DeviceID of Arduino Due Programming Port from WMI Service.
REM * 
REM * Tested with: Windows 10 64 Bit, Atmel Studio 7.0.1645, Arduino-1.8.5
REM *
REM ***********************************************************************************************************************
REM ***********************************************************************************************************************
REM * Copyright (C) 2013 by arduinodue.weinhandl.org
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

REM Wait X second for memory on Arduino Due is erased.
SET WAIT_ERASED=4

ECHO ------ External tool BossacArduinoDue started ------

REM number of command line arguments ok?
IF [%1]==[] GOTO error_args
IF [%2]==[] GOTO error_args

REM set command line arguments
SET BOSSACPATH=%1
SET BINFILE=%2

REM parse command line arguments
SET BOSSACPATH=%BOSSACPATH:"=%
SET BINFILE=%BINFILE:"=%

REM workeround for bug in Atmel Studio 6.0.1996 Service Pack 2
SET BINFILE=%BINFILE:\\=\%
SET BINFILE=%BINFILE:.cproj=%

REM bossac path exist?
IF NOT EXIST "%BOSSACPATH%" GOTO error_arg1

REM bin file exist?
IF NOT EXIST "%BINFILE%" GOTO error_binfile

REM fetch DeviceID of Arduino Due Programming Port from WMI Service
FOR /f "tokens=* skip=1" %%a IN ('wmic PATH Win32_SerialPort Where "Caption LIKE '%%Arduino Due Programming Port%%'" get DeviceID') DO (
    SET COMX=%%a
    GOTO exit1
)

REM Arduino Due Programming Port not exist
GOTO error_comport

:exit1

REM remove blank
SET COMPORT=%COMX: =%

REM report in Atmel Studio 6.0 IDE output window
ECHO BossacPath=%BOSSACPATH%
ECHO BinFile=%BINFILE%
ECHO Arduino Due Programming Port is detected as %COMPORT%.

REM The bossac bootloader only runs if the memory on Arduino Due is erased.
REM The Arduino IDE does this by opening and closing the COM port at 1200 baud.
REM This causes the Due to execute a soft erase command.
ECHO Forcing reset using 1200bps open/close on port 
ECHO MODE %COMPORT%:1200,N,8,1
MODE %COMPORT%:1200,N,8,1

REM Wait X second for memory on Arduino Due is erased.
ECHO Wait for memory on Arduino Due is erased...
PING -n %WAIT_ERASED% 127.0.0.1>NUL

REM Execute bossac.exe
ECHO Execute bossac with command line:
ECHO "%BOSSACPATH%" -i -d --port=%COMPORT% -U false -e -w -v -b "%BINFILE%" -R
START /WAIT "" "%BOSSACPATH%" -i -d --port=%COMPORT% -U false -e -w -v -b "%BINFILE%" -R

GOTO end

:error_args
ECHO Error: wrong number of command line arguments passed!
GOTO end

:error_arg1
ECHO Error: command line argument 1 - path to bossac.exe not exist! - "C:\Program Files (x86)\arduino-1.5.2\hardware\tools\bossac.exe"
ECHO Error: command line argument 1 - argument passed = %1
GOTO end

:error_arg2
ECHO Error: command line argument 2 - path to bin file not exist! - use $(OutputDirectory)\$(OutputFileName).bin
ECHO Error: command line argument 2 - argument passed = %1
GOTO end

:error_binfile
ECHO Error: bin file "%BINFILE%" not exist!
GOTO end

:error_comport
ECHO Error: Arduino Due Programming Port not found!

:end

ECHO ======================== Done ========================
