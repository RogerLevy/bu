IF x%CD%:bu\dev=%==x%CD% cd ../..
SETLOCAL
IF "%1" == "" SET buildname=app
IF NOT EXIST builds MD builds
IF EXIST builds/%buildname% RD /q /s builds/%buildname%
MD builds/%buildname%
COPY data builds/%buildname%
COPY bu/lib/allegro5/*.dll builds/%buildname%
COPY bu/lib/fmod5/*.dll builds/%buildname%
COPY bu/lib/tinyc2/*.dll builds/%buildname%
COPY bu/lib/*.dll builds/%buildname%

