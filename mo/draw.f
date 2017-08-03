\ Basic graphics wordset
import bu/mo/pen        \ parent should also import the pen in order to use this package.
bu: idiom draw:      \ do this first so early-out works
import bu/mo/pen        \ don't remove this.  parent may be different from bu:

private:
    : push postpone >r ; immediate
    : pop postpone r> ; immediate
    : 2push  postpone push postpone push ; immediate
    : 2pop  postpone pop postpone pop ; immediate
public:

create fore 4 cells allot
: colorf  ( f: r g b a )  4sf 2swap fore 2v! fore 2 cells + 2v! ;
: color   ( r g b a )  2af 2swap 2af fore 2v! fore 2 cells + 2v! ;
: color@af  fore 4@ ;
: color32   ( $AARRGGBB -- )  hex>color color ;

\ Bitmaps, backbuffer
: onto  pop  al_get_target_bitmap push  swap al_set_target_bitmap  call  pop al_set_target_bitmap ;
: movebmp  ( src sx sy w h ) write-rgba blend>  at@ 2af 0 al_draw_bitmap ;
: *bmp   ( w h -- bmp ) 2i al_create_bitmap ;
: clearbmp  ( r g b a bmp )  onto 4af al_clear_to_color ;
: backbuf  display al_get_backbuffer ;
\ : *subbmp   ( bmp w h ) at@ 2i 2swap 2i al_create_sub_bitmap ;
: backdrop  color@af al_clear_to_color ;

\ Predefined Colors
fixed
: 8>p  s>f 255e f/ f>p ;
: createcolor create 8>p swap 8>p rot 8>p , , , 1 ,  does> 4@ color ;
: (sf+)  dup sf@ f>p swap cell+ ;
: @color  fore (sf+) (sf+) (sf+) (sf+) drop ;
hex
00 00 00 createcolor black 69 71 75 createcolor dgrey
9d 9d 9d createcolor grey cc cc cc createcolor lgrey
ff ff ff createcolor white f8 e0 a0 createcolor beige
e0 68 fb createcolor pink ce 26 33 createcolor red
73 29 30 createcolor dred  eb 89 31 createcolor lbrown
a4 64 22 createcolor brown f7 e2 5b createcolor yellow
bc b3 30 createcolor dyellow ae 3c 27 createcolor lgreen
44 89 1a createcolor green 21 5c 2e createcolor dgreen
27 c1 a7 createcolor cyan 14 80 7e createcolor dcyan
24 5a ef createcolor blue 34 2a 97 createcolor dblue
31 a2 f2 createcolor lblue 93 73 eb createcolor purple
96 4b a8 createcolor dpurple cb 5c cf createcolor magenta
80 00 80 createcolor dmagenta ff ff 80 createcolor lyellow
e0 e0 80 createcolor khaki f7 b0 80 createcolor caucasian
da 42 00 createcolor orange
fixed

\ Bitmap drawing utilities - f stands for flipped
\  All of these words use the current color.
\  Not all effect combinations are available; these are
\  intended as conveniences.  For more flexibility or
\  speed use Allegro's drawing or primitive functions directly.
\  To draw regions of bitmaps, use Allegro's draw bitmap region functions directly
\  or use sub bitmaps (see subbmp).
\  After each call to one of these words, the current color is reset to white.

: blitf  ( bmp flip )  push  color@af  at@ 2af  pop al_draw_tinted_bitmap  white ;
: >center  bmpwh 0.5 0.5 2* ;
: crblitf ( bmp ang flip )
    locals| flip ang bmp |
    bmp  color@af  bmp >center  ang 3af  flip  al_draw_tinted_rotated_bitmap  white ;
: sblitf  ( bmp dw dh flip )
    locals| flip dh dw |
    ( bmp )  color@af  at@ dw dh 4af  flip  al_draw_tinted_scaled_bitmap white ;
: csrblitf ( bmp sx sy ang flip )
    locals| flip ang sy sx bmp |
    bmp  color@af  bmp >center  at@  4af  sx sy ang 3af  flip  al_draw_tinted_scaled_rotated_bitmap  white ;
: ublitf  ( bmp scale flip )
    locals| flip scale bmp |
    bmp  color@af  at@ bmp bmpwh scale dup 2* 4af  flip  al_draw_tinted_scaled_bitmap  white ;

: blit   ( bmp ) 0 blitf ;
: crblit  ( bmp ang )  0 crblitf ;
: sblit  ( bmp dw dh )  0 sblitf ;
: csrblit  ( bmp sx sy ang )  0 csrblitf ;
: nublit  ( bmp sx sy )  0 dup csrblitf ;  \ what does n stand for???
: ublit  ( bmp scale )  0 ublitf ;

\ Text
private:
create zbuf 1024 allot
: zstring  ( addr c - zaddr )  \ convert string to zero-terminated string
    zbuf zplace  zbuf ;
public:

variable fnt  default-font fnt ! 
: fontw  z" A" al_get_text_width s>p ;
: textw  ;
: fonth  al_get_font_line_height s>p ;
: aprint ( str count alignment -- )
    -rot zstring >r  >r  fnt @ color@af at@ 2af r> r@ al_draw_text
    fnt @ r> al_get_text_width s>p 0 +at ;
: print  ( str count -- )  ALLEGRO_ALIGN_LEFT aprint ;
: printr  ( str count -- )  ALLEGRO_ALIGN_RIGHT aprint ;
: printc  ( str count -- )  ALLEGRO_ALIGN_CENTER aprint ;
: font>  ( font -- <code> )  fnt !  r> call ;

\ Primitives
\ -1 = hairline thickness
: line   at@ 2swap 4af color@af -1e 1sf al_draw_line ;
: +line  at@ 2+ line ;
: line+  2dup +line +at ;
: pixel  at@ 2af  color@af  al_draw_pixel ;
: tri  ( x y x y x y ) 2push 4af 2pop 2af color@af -1e 1sf al_draw_triangle ;
: trif  ( x y x y x y ) 2push 4af 2pop 2af color@af al_draw_filled_triangle ;
: rect  ( w h )  at@ 2swap 2over 2+ 4af color@af -1e 1sf al_draw_rectangle ;
: rectf  ( w h )  at@ 2swap 2over 2+ 4af color@af al_draw_filled_rectangle ;
: capsule  ( w h rx ry )  2push at@ 2swap 2over 2+ 4af 2pop 2af color@af -1e 1sf al_draw_rounded_rectangle ;
: capsulef  ( w h rx ry )  2push at@ 2swap 2over 2+ 4af 2pop 2af color@af al_draw_filled_rounded_rectangle ;
: circle  ( r ) at@ rot 3af color@af -1e 1sf al_draw_circle ;
: circlef ( r ) at@ rot 3af color@af al_draw_filled_circle ;
: ellipse  ( rx ry ) at@ 2swap 4af color@af -1e 1sf al_draw_ellipse ;
: ellipsef ( rx ry ) at@ 2swap 4af color@af al_draw_filled_ellipse ;
: arc  ( r a1 a2 )  push at@ 2swap 4af pop 1af color@af -1e 1sf al_draw_arc ;

: untinted  white ;

\ Clipping rectangle
private: variable cx variable cy variable cw variable ch
public:
: clipxy  cx cy cw ch al_get_clipping_rectangle  cx @ cy @ ;
: clipwh  cx cy cw ch al_get_clipping_rectangle  cw @ ch @ ;
: clip>  ( x y w h -- <code> )
    cx cy cw ch al_get_clipping_rectangle
    4i al_set_clipping_rectangle   r> call
    cx @ cy @ cw @ ch @ al_set_clipping_rectangle ;

