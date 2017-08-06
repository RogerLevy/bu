\ Global tileset system
\  Loading tiles, tile and tilemap display and collision routines
\  Maximum 16384 tiles.

\ TODO:
\  [ ] - Tile collision
\  [ ] - Render a flipped tilemap

bu: idiom tilegame:
    import bu/mo/image
    import bu/mo/cellstack
    import bu/mo/a
    import bu/mo/pen
    import bu/mo/draw

16384 dup constant maxtiles  cellstack tiles
: tile  maxtiles 1 - and tiles [] @ ;
: +tiles  tiles #pushed swap  dup subcount @ 0 do  i over imgsubbmp  tiles push  loop  drop ;
: add-tiles ( image tilew tileh -- firstn ) third subdivide  +tiles ;
: change-tiles  ( image tilew tileh n -- )  tiles truncate  add-tiles  drop ;
: clear-tiles  ( -- )  0 tiles [] a!>  maxtiles for  @+ -bmp  loop  tiles 0 truncate ;


\ Render a tilemap, generic
\  Given a starting address, a pitch, and a base tile index, render tiles to fill the current
\  clip rectangle of the current destination bitmap.
\  The tiles are cell-sized and in the following format:
\  00vh 0000 0000 0000 tttt tttt tttt tt00  ( t=tile # 0-16383, b=bank 0-15, v=vflip, h=hflip)
\  DRAW-TILEMAP draws within the clip rectangle
\  DRAW-TILEMAP-BG draws within the clip rectangle plus 1 tile in both directions, enabling scrolling
\  NOTE: The base tile's width and height defines the "grid dimensions".

: (draw-tilemap)  ( addr #pitch rows cols basetile -- )
    cells 0 tiles [] +  dup @  bmpwh  locals| th tw tba cols rows pitch |  cells +
    a@ >r
    rows for
        at@  ( addr x y )
        third a!  cols for  @+ dup $0000fffc and tba + @  swap 28 >>  blitf  tw 0 +at  loop
        th + at   pitch +
    loop  drop  r> a! ;

: draw-tilemap  ( addr #pitch basetile -- )
    >r  clipxy clipwh 2+  third subw 2v@ 2/  r>  (draw-tilemap) ;

: draw-tilemap-bg  ( addr #pitch basetile -- )
    >r  clipxy clipwh 2+  third subw 2v@ 2/  1 1 2+  r>  (draw-tilemap) ;


