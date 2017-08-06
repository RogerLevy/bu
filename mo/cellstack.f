\ [ ] overflow checking

bu: idiom cellstack:

: cellstack  ( max-size -- <name> )  ( -- stack/data )  create 0 , cells /allot does> cell+ ;
: #pushed  cell- @ ;
: truncate  ( stack/data newsize -- )  swap cell- ! ;
: pop  ( s/d -- val )  cell-  >r  r@ @ 0= abort" ERROR: Stack object underflow." r@ dup @ cells + @  -1 r> +! ;
: push  ( val s/d -- )  cell-  >r  1 r@ +!   r> dup @ cells + !  ;
: pushes  ( ... s/d n -- ) -cell u+  swap locals| s |  0 ?do  s push  loop ;
: pops    ( s/d n -- ... ) -cell u+  swap locals| s |  0 ?do  s pop  loop ;
: splace  ( addr count s/d -- ) -cell u+  2dup !  cell u+  swap imove ;
: scount  ( s/d -- addr count ) dup cell- @  ;
