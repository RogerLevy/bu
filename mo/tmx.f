\ TMX (Tiled) support
\ This just provides access to the data and some conversion tools
\ It directly supports only a subset of features
\  - Object groups
\  - Single and Multiple image tilesets
\  - Tilemaps in Base64 uncompressed format (sorry no zlib, maybe later)
\  - Rectangles
\  - Referenced tileset files - in fact in an effort to salvage my sanity embedded tilesets are NOT supported.  Sorry.  (You ought to be using external tilesets anyway. ;)
\  - Layer Groups are NOT supported.  Sorry.

\ TODO
\  [ ] - Custom Properties
\  [ ] - Other shapes besides rectangle
\  [ ] - Add custom property to allow some tile images not to be loaded since they're for the editor only and would waste RAM

\ You can access one TMX file at a time.
\ To preserve global ID coherence, when you load the tiles of a TMX file, ALL tileset nodes are loaded
\ into the system, freeing what was there before.  You can load other maps without reloading the
\ tiles, but you can't mix and match tilesets.

\ Programmer's rant:
\ I just want to say that Tiled is a classic example of passing time and thought onto the user ...
\ Why not support a simpler format or two in addition to the complex one?
\ And why all the tilemap format options?  Surely people could have hung with 2 or 3 instead of 5.
\ Why doesn't anyone understand what a serious issue this is?  Instead of one person solving a problem, they'd have hundreds of people deal with the unnecessary problems they created...

bu: idiom tmx:   \ BU is parent to limit coupling
    import bu/mo/node
    import bu/mo/cellstack
    import bu/mo/xml
    import bu/mo/base64

private: 0 value map public:

100 cellstack tilesetdoms
100 cellstack layernodes
100 cellstack objgroupnodes

200 cellstack tilesets  \ firstgid , tileset element , first gid , tileset element , ...

0 value lasttmx
create tmxdir  256 allot

: loadxml   file@  2dup xml  >r  drop free throw  r> ;

: load-objectgroups  objgroupnodes 0 truncate  map " objectgroup" eachel> objgroupnodes push ;
: load-layers  layernodes 0 truncate  map " layer" eachel> layernodes push ;

\ used with several node types:
private:
    : @source  " source" attr$ ;
    : @name    " name" attr$ ;
    : @w       " width" attr ;
    : @h       " height" attr ;
    : @wh      dup @w swap @h ;
    : @id      " id" attr ;
    : @x       " x" attr ;
    : @y       " y" attr ;
    : @xy      dup @x swap @y ;
public:

\ Opening a TMX
private:
: !dir  2dup 2dup [char] / [char] \ replace-char  -name  #1 +  ( add the trailing slash )  tmxdir place ;
: +dir  tmxdir count 2swap strjoin ;
public:
: >tsx  @source +dir 2dup cr type loadxml ;
: +tileset  ( firstgid tilesetdom -- )
    dup tilesetdoms push  >root " tileset" 0 child  swap tilesets push  tilesets push ;
: load-tilesets
    tilesetdoms scount for  @+ dom-free  loop drop
    tilesetdoms 0 truncate
    tilesets 0 truncate
    map " tileset" eachel> dup " firstgid" attr  swap >tsx +tileset ;
: >map   " map" 0 ?child not abort" File is not a recognized TMX file!" ;
: closetmx  lasttmx ?dup -exit dom-free  0 to lasttmx ;
: opentmx  ( path c -- )  !dir  closetmx  loadxml dup to lasttmx  >root >map to map  load-tilesets  load-layers  load-objectgroups ;


\ Tilesets!
\ "tileset" really refers to a 2 cell data structure defined above, in TILESETS.
: #tilesets  tilesetdoms #pushed ;
: tileset[]  2 * tilesets [] ;
: >el  cell+ @ ;
: multi-image?  ( tileset -- flag )  >el " image" 0 child? not ;
: @firstgid  ( tileset -- gid )  @ ;
: single-image  ( tileset -- path c )  >el " image" 0 child @source +dir ;
: @tilecount  ( tileset -- n )  >el " tilecount" attr ;
: tile-gid  ( tileset n -- gid )  over @firstgid >r  >r >el " tile" r> child @id  r> + ;
: tile-image  ( tileset n -- imagepath c )  >r >el " tile" r> child " image" 0 child @source +dir ;


\ Layers!
: #layers  layernodes #pushed ;
: layer[]  layernodes [] @ ;
: ?layer  ( name c -- layer | 0 )  \ find layer by name
    locals| c n |
    #layers for
        i layer[]  @name  n c compare 0= if
            i layer[]  unloop exit
        then
    loop  0 ;
: extract  ( layer dest pitch -- )  \ read out tilemap data. you'll probably need to process it.
    third @wh locals| h w pitch dest |  ( layer )
    here >r
    " data" 0 child  >text  b64, \ Base64, no compression!!!
    r@  w cells  dest  pitch  h  w cells  2move
    r> reclaim ;

\ Object groups!
: #objgroups  objgroupnodes #pushed ;
: objgroup[]  objgroupnodes [] @ ;
: ?objgroup  ( name c -- objgroup-node | 0 )  \ find object group by name
    locals| c n |
    #objgroups for
        i objgroup[]  @name  n c compare 0= if
            i objgroup[]  unloop exit
        then
    loop  0 ;
: @gid  " gid" attr $0fffffff and ;
private: : @type  " type" attr$ ;
public:
: @rotation  " rotation" attr ;
: @visible  " visible" attr 0<> ;
: @vflip  " gid" attr $40000000 and 0<> ;
: @hflip  " gid" attr $80000000 and 0<> ;
: rectangle?  " gid" ?attr dup if nip then  not ;  \ doesn't actually guarantee it's not some other shape, because TMX is stupid.  so check for those first.
\ : polygon? ;
\ : ellipse? ;
\ : polyline? ;
0 value (code)
: objects>  ( layer -- <code> )  ( objectnode -- )
    r> to (code)  " object" eachel>  (code) call ;
