
\ keyboard and joystick support
decimal
\ -------------------------------- keyboard -----------------------------------
create kbstate  /ALLEGRO_KEYBOARD_STATE /allot \ current frame's state
create kblast  /ALLEGRO_KEYBOARD_STATE /allot  \ last frame's state
\ create ikbstate  /ALLEGRO_KEYBOARD_STATE /allot  \ fixes modifier key bug
\ -----------------------------------------------------------------------------
: pollKB
  kbstate kblast /ALLEGRO_KEYBOARD_STATE move
  kbstate al_get_keyboard_state ;
\ : poll-keyboard                                                                 \ poll keyboard device
\   kbstate kblast /ALLEGRO_KEYBOARD_STATE move                                   \ note: will not work without calling KBSTATE-EVENTS in an event handler.
\   ikbstate kbstate /ALLEGRO_KEYBOARD_STATE move ;
\ -----------------------------------------------------------------------------
\ : clearkb  ikbstate /ALLEGRO_KEYBOARD_STATE erase  poll-keyboard ;       \ clear keyboard buffer
: clearkb
  kblast /ALLEGRO_KEYBOARD_STATE erase
  kbstate /ALLEGRO_KEYBOARD_STATE erase
;

: resetkb
  clearkb
  al_uninstall_keyboard
  al_install_keyboard  not abort" Error re-establishing the keyboard :/"
  eventq  al_get_keyboard_event_source al_register_event_source ;
\ -----------------------------------------------------------------------------
\ : bitloc  >r 32 /mod cells r> cell+ + swap  1 swap << ;
\ : setkey  ( keycode state )  bitloc  swap or! ;
\ : unsetkey ( keycode state - )  bitloc  invert swap and! ;
\ : kbstate-events  ( event-type -- )  \ handle key up/down events
\   etype ALLEGRO_EVENT_KEY_DOWN = if
\     e ALLEGRO_KEYBOARD_EVENT-keycode @ ikbstate setkey
\   then
\   etype ALLEGRO_EVENT_KEY_UP   = if
\     e ALLEGRO_KEYBOARD_EVENT-keycode @ ikbstate unsetkey
\   then ;
\ -----------------------------------------------------------------------------
\ ------------------------------ end keyboard ---------------------------------
\ -------------------------------- joysticks ----------------------------------
\ NTS: we don't handle connecting/disconnecting devices yet,
\   but Allegro 5 /does/ support it. (via an event)
\ -----------------------------------------------------------------------------

fixed 
_AL_MAX_JOYSTICK_STICKS s>p constant MAX_STICKS
create joysticks   MAX_STICKS /ALLEGRO_JOYSTICK_STATE * /allot
: joystick[]  /ALLEGRO_JOYSTICK_STATE *  joysticks + ;
: @f>p+  dup sf@ f>p over ! cell+ ;
: convert-coords  @f>p+ @f>p+ @f>p+ ;
: >joyhandle  1i al_get_joystick ;
: joy ( joy# stick# - vector )  \ get stick position (fixed point)
  /ALLEGRO_JOYSTICK_STATE_STICK *  swap joystick[]
  ALLEGRO_JOYSTICK_STATE-sticks + ;
: #joys  al_get_num_joysticks s>p ;
: pollJoys ( -- )
  #joys 0 do
    i >joyhandle i joystick[] al_get_joystick_state
    MAX_STICKS 0 do  j i joy convert-coords  drop  loop
  loop ;
\ ------------------------------ end joysticks --------------------------------
