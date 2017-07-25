include bu/lib/fmod5/fmod5  \ note FMOD is loaded only if ALLEGRO-AUDIO doesn't exist

variable fmod

: -audio  \ TBD
;

: +audio  \ TBD
;

: init-audio
    fmod FMOD_System_Create
    fmod @ #32 0 0 FMOD_System_Init
;

: audio-update  \ necessary for callbacks and FMOD_NONBLOCKING to work
    fmod @ FMOD_System_Update
;

