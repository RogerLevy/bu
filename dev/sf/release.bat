SETLOCAL
IF "%1" == "" SET buildname=app
IF x%CD%:bu\dev=%==x%CD% cd ../..
START /wait "" "build.bat ":%1
START /wait "" "sf  include main  include bu/dev/sf/build  release ":%1
START "builds/"%buildname%"/"%buildname%".exe"
