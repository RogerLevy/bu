\ better XML handling.
\ only read words for now (7/17/2016)
\ pretty experimental, will probably be superseded by xml2 ;)

bu: idiom xml:
    import bu/mo/cellstack

0 value dom
decimal

\ the node in here is different from the one defined in nodes.f
: >root ( dom -- node )  dom>iter nni-root ;
: >next ( node -- node|0 )  nnn>dnn dnn-next@ ;
: xml  ( adr c -- DOM )
    dom-new  true over dom-read-string 0= throw ;
\ NOTE: the word DOM is not used for the rest of the file!!!!!!!!!!  (it's kind of a dumb convenience)
: #children  ( node -- n )  nnn>children dnl>length @ ;
: @name  ( node -- adr c )  dom>node>name str-get ;
: @val  ( node -- adr c )  dom>node>value str-get ;
: @type  ( node -- dom-node-type )  dom>node>type @ ;
: element?  ( node -- node flag )  @type dom.element = ;
\ : ?children  dup #children 0= abort" element has no children" ;
: >first  nnn>children dnl>first @ ;
0 value XT
: (scan)  ( node -- ) ( ... node -- stop? ... )
    >first   begin  ?dup while  dup >r  XT execute  if  r> drop exit then  r> >next  repeat ;
: scan  ( node xt -- ) ( ... node -- stop? ... )  \ scan all kinds of DOM nodes
    XT >r  to XT  (scan)  r> to XT  ;
: .name  ( node -- )  ." <" @name type ." >" space ;
: (.elements)  ( node -- flag )  dup element? if  .name  else  drop  then  false ;
: .elements  ( node -- )  ['] (.elements) scan ;
: .attribute  ( node -- )  dup @name type ." =" @val type space ;
: (.attributes)  ( node -- flag )  dup @type dom.attribute = if  .attribute  else  drop  then  false ;
: .attributes  ( node -- )  ['] (.attributes) scan ;
: name=  third @name compare 0= ;
: ?el[] ( node adr c n -- node true | false )
    locals| n c adr |
    >first  begin  dup while
        dup element? if
            adr c name= dup if  -1 +to n  then
                n -1 = and if  true exit  then
        then
        >next
    repeat ;
: el[]  ( node adr c n -- node )  ?el[] 0= abort" child element not found" ;
: el[]?  ?el[] dup if nip then ;
: eachel  ( node adr c xt -- )  ( ... node -- ... )
    XT >r  to XT
    2>r
    >first  begin ?dup while
        dup element? if
            2r@ name= if  dup >r  XT execute  r>  then
        then
        >next
    repeat
    2r> 2drop
    r> to XT ;
: eachel>  r> code> eachel ;

: (?attr)  ( node adr c -- node|false )
    locals| c adr |
    >first  begin  dup while
        dup @type dom.attribute = if  adr c name= ?exit then
        >next
    repeat ;


\ for error reporting
: !str  2dup pocket place ;
: ?print  dup if  pocket count type space  then ;

: ?attr$  ( node adr c -- adr c true | false )  !str (?attr) dup if @val true then ;
: ?attr  ( node adr c -- n true | false )  !str (?attr) dup if @val evaluate true then ;
: attr ( node adr c -- n )  ?attr 0= ?print abort" attribute not found" ;
: attr$ ( node adr c -- adr c )  ?attr$ 0= ?print abort" attribute not found" ;

: $=  compare 0= ;

\ : strattr   create   parse-word string,  does>  count  attr$ ;
\ : numattr   create   parse-word string,  does>  count  attr ;
\ : attrchecker create parse-word string,  does>  count  (?attr) ;
\ : childnode create   parse-word string,  does>  ( n addr )
\     swap >r xn swap count r> el[] ;

: x.  ( node -- )  dup .name dup .attributes .elements ;
