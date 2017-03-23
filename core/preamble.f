\ Forth Language-level Extensions - load once per session.
\ This is probably better thought of as a "dialect" and I should come up with a better name for it.

\ load Idioms, DOM, floating point, string extensions, file wordset, fixed point, Allegro,
\

\ "O" Register
0 value o
&of o constant &o
: for>  ( val addr -- )  r>  -rot  dup dup >r @ >r  !  call  r> r> ! ;
: reverse   ( ... count -- ... ) 1+ 1 max 1 ?do i 1- roll loop ;

\ Idioms
include bu/lib/idiom
: include  sp@ >r  include  r> sp@ cell+ <> ?dup if  .s abort" STACK DEPTH CHANGED" then ;
  
\ ffl DOM
include bu/lib/ffl-0.8.0/ffl.f
$F320000 'FPOPT !  \ hopefully fixes fixed point math on linux
pushpath
cd bu/lib/ffl-0.8.0
[undefined] dom-create [if]
    global ffling +order
    include ffl/dom.fs
    include ffl/b64.fs
    ffling -order
[then]
poppath

\ floating point - FFL loads fpmath anyway...
[undefined] f+ [if]
  +opt warning on
  $ ls  \ ???
  requires fpmath
  cr .( loaded: fpmath)
[then]

  
\ Various extensions
include bu/lib/fpext
cr .( loaded: fpext)
requires rnd \ SwiftForth
include bu/lib/string-operations
include bu/lib/files
include bu/lib/fixedp
:noname [ is onSetIdiom ]  ints @ ?fixed ;

\ Import Allegro 5 for graphics, sound, input etc
include bu/lib/allegro-5.2/allegro-5.2.f

\ RLD dev tool - reload from the top
: rld  ( -- )  s" dev.f" included ;

\ Null personality - disables console output
create null-personality
  4 cells , 19 , 0 , 0 ,
  ' noop , \ INVOKE    ( -- )
  ' noop , \ REVOKE    ( -- )
  ' noop , \ /INPUT    ( -- )
  ' drop ,  \ EMIT      ( char -- )
  ' 2drop , \ TYPE      ( addr len -- )
  ' 2drop , \ ?TYPE     ( addr len -- )
  ' noop , \ CR        ( -- )
  ' noop , \ PAGE      ( -- )
  ' drop , \ ATTRIBUTE ( n -- )
  ' dup , \ KEY       ( -- char )
  ' dup , \ KEY?      ( -- flag )
  ' dup , \ EKEY      ( -- echar )
  ' dup , \ EKEY?     ( -- flag )
  ' dup , \ AKEY      ( -- char )
  ' 2drop , \ PUSHTEXT  ( addr len -- )
  ' 2drop ,  \ AT-XY     ( x y -- )
  ' 2dup , \ GET-XY    ( -- x y )
  ' 2dup , \ GET-SIZE  ( -- x y )
  ' drop , \ ACCEPT    ( addr u1 -- u2)

: turnkey-starter  null-personality open-personality " include main ok bye" evaluate ;
: refresh  " eventq al_flush_event_queue  rld  ok" evaluate ;

\ RLD
create rld$ 256 /allot
: rld
    0 parse dup 0= if
        2drop
        rld$ c@ 0= if
            abort" No file set.  Say RLD <name> to set file to reload."
        else
            rld$ count included
        then
    else
        rld$ place
    then ;

gild