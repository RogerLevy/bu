\ Allegro's audio API freaking sucks, so this is here just for people who don't want to
\ worry about FMOD licensing.  
\ Even if FMOD isn't used, Allegro's API is available.

0 value mixer

: -audio
    mixer 0 al_set_mixer_playing drop
;

: +audio
    #16 al_reserve_samples not if  " Allegro: Error reserving samples." alert -1 abort  then
    al_get_default_mixer to mixer
    mixer #1 al_set_mixer_playing drop
;

: init-audio
    al_init_acodec_addon not if  " Allegro: Couldn't initialize audio codec addon." alert -1 abort  then
    al_install_audio not if  " Allegro: Couldn't initialize audio." alert -1 abort  then
    +audio
;

: audio-update
;
