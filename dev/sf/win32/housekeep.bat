SETLOCAL
SET buildpath=%1
SET srcpath=%2
IF EXIST %buildpath% RD /q /s %buildpath%
MD %buildpath%
COPY bu\lib\allegro5\*.dll %buildpath%
COPY bu\lib\fmod5\*.dll %buildpath%
COPY bu\lib\tinyc2\*.dll %buildpath%
COPY bu\lib\*.dll %buildpath%
MD %buildpath%\data
XCOPY /f /s /e /y %srcpath%\data %buildpath%\data
PAUSE
