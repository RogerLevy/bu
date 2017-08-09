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
: !tiles  tiles #pushed swap  dup subcount @ 0 do  i over imgsubbmp  tiles push  loop  drop ;
: add-tiles ( image tilew tileh -- firstn ) third subdivide  !tiles ;
: change-tiles  ( image tilew tileh n -- )  tiles #pushed >r  tiles swap truncate  add-tiles  drop
    tiles #pushed r> max tiles swap truncate ;
: clear-tiles  ( -- )  0 tiles [] a!>  maxtiles for  @+ -bmp  loop  tiles 0 truncate ;


\ Render a tilemap
\  Given a starting address, a pitch, and a tile base, render tiles to fill the current
\  clip rectangle of the current destination bitmap.
\  The tilemap format is in cells and in the following format:
\  00vh 0000 0000 0000 tttt tttt tttt tt00  ( t=tile # 0-16383, b=bank 0-15, v=vflip, h=hflip)
\  DRAW-TILEMAP draws within the clip rectangle
\  DRAW-TILEMAP-BG draws within the clip rectangle plus 1 tile in both directions, enabling scrolling
\  NOTE: Base tile + 1's width and height defines the "grid dimensions". (0 is nothing and transparent)


0 value tba  \ tile base address
: tilebase!  ( tile# -- )  cells tiles + to tba ;
0 tilebase!

: tbwh  tba cell+ @ bmpwh ;

: ?tile+  ?dup if  dup $0000fffc and tba + @  swap 28 >>  blitf  then  0 +at ;
: (draw-tilemap)  ( addr /pitch cols rows -- )
    tbwh locals| th tw rows cols pitch |
    a@ >r
    rows for
        at@  ( addr x y )
        third a!  cols for  tw @+ ?tile+  loop
        th + at   pitch +
    loop  drop  r> a! ;

: draw-tilemap  ( addr /pitch -- )  clipwh  unscaled  tbwh 2/  (draw-tilemap) ;

: draw-tilemap-bg  ( addr /pitch -- )  clipwh  unscaled  tbwh 2/  1 1 2+  (draw-tilemap) ;
