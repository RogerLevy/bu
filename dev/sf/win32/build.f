\ Relevant word: BUILD
\ Builds are placed in builds\ (relative to repository)
\ You can specify any project folder, build name, and initialiation routine.
\ The data\ folder will be copied from the project folder to each build folder, along with
\  all the dependency DLL's.
\ Two builds (turnkeys) are generated; one regular and another containing debug executables.

\ SwiftForth \ Win32 version; housekeep.bat does the necessary folder cleanup \ creation, and copying

bu: idiom build:
    import bu\mo\cellstack

create buildname  #260 allot
create srcpath    #260 allot
defer cold

private:
    : releasedir  " builds\" buildname count strjoin ;
    : debugdir    " builds\" buildname count strjoin " _debug" strjoin ;

    : (cold)  'idiom @ set-idiom   cold ;
    : gui      #0 'main cell+ !  ;
    : console  #-1 'main cell+ ! ;

    : cmdline-starter  false to allegro?  'idiom @ set-idiom  interactive ;
    : debug-starter  R0 @ RP!  false to allegro?  +display  (cold)  ok  interactive ;
    : release-main   R0 @ RP!  false to allegro?  +display  (cold)  begin  ok  again ;

public:
: build  ( -- <projectpath> <buildname> <initword> )

    \ parse parameters
    bl parse srcpath place
        bl parse buildname place
            starter

    " bu\dev\sf\win32\housekeep.bat " s[ releasedir +s  "  " +s  srcpath count +s  ]s  2dup type cr  zstring >PROCESS-WAIT
    ['] release-main 'main !
    " program " s[ releasedir +s " \" +s  buildname count +s ]s evaluate

    " bu\dev\sf\win32\housekeep.bat " s[ debugdir   +s  "  " +s  srcpath count +s  ]s 2dup type cr  zstring >PROCESS-WAIT
    " program " s[ debugdir   +s " \" +s  buildname count +s ]s evaluate

    ['] development 'main !  ['] debug-starter 'starter !
    " program " s[ debugdir   +s " \" +s  buildname count +s  " _debug" +s   ]s evaluate

    ['] development 'main !  ['] cmdline-starter 'starter !
    " program " s[ debugdir   +s " \" +s  buildname count +s  " _cmdline" +s ]s evaluate
    poppath ;
