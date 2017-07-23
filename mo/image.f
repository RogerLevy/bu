bu: idiom image:

\ ---------------------------------- images -----------------------------------
0
  xvar bmp  xvar subw  xvar subh  xvar fsubw  xvar fsubh
  xvar subcols  xvar subrows  xvar subcount
struct /image

: initImage  ( ALLEGRO_BITMAP image -- ) bmp ! ;

: image  ( -- <name> <path> )
  create /image allotment <filespec> zstring al_load_bitmap swap initImage ;

\ dimensions
: imgw  bmp @ bmpw ;
: imgh  bmp @ bmph ;
: imgwh  bmp @ bmpwh ;

\ ------------------------------ subimg stuff -------------------------------
: subdivide  ( tilew tileh img -- )
  >r  2dup r@ subw 2v!  2af r@ fsubw 2v!
  r@ imgwh  r@ subw 2v@  2/ 2pfloor  2dup r@ subcols 2v!
  *  r> subcount ! ;

: >subxy  ( n img -- x y )                                                    \ locate a subimg by index
    >r  pfloor  r@ subcols @  /mod  2pfloor  r> subw 2v@ 2* ;

: afsubimg  ( n img -- ALLEGRO_BITMAP fx fy fw fh )                           \ helps with calling Allegro blit functions
    >r  r@ bmp @  swap r@ >subxy 2af  r> fsubw 2v@ ;

: imgsubbmp  ( n img -- subbmp )
    >r  r@ bmp @  swap r@ >subxy  r> subw 2v@   4i  al_create_sub_bitmap ;
