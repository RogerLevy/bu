\ better XML handling.
\ only read words for now (7/17/2016)

bu: idiom xml:
    import bu/mo/cellstack


16 cellstack doms
0 value dom

decimal

0 value xn  \ xml node
&of xn constant &xn

: open>  " &of xn with>" evaluate ; immediate

\ the node in here is different from the one defined in nodes.f
: >root ( dom -- node )  dom>iter nni-root ;
: >next ( node -- node|0 )  nnn>dnn dnn-next@ ;
: done  dom dom-free  doms pop to dom ;
: xml  ( adr c -- root-node )
    dom doms push
    dom-new to dom
    true dom dom-read-string 0= throw  dom >root ;
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
: .element  ( node -- )  dup .name dup .attributes .elements ;
: name=  third @name compare 0= ;
: ?el[] ( node adr c n -- node true | false )
    locals| n c adr |
    >first  begin  dup while
        dup element? if
            adr c name=  n 0 = and if true exit then
            -1 +to n
        then
        >next
    repeat ;
: el[]  ( node adr c n -- node )  ?el[] 0= abort" child element not found" ;
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

: (?attr)  ( xn=node adr c -- node|false )
    locals| c adr |
    xn >first  begin  dup while
        dup @type dom.attribute = if  adr c name= ?exit then
        >next
    repeat ;

\ the following use the xn register for the input node, to cut down on stack juggling.
: ?attr$  ( xn=node adr c -- adr c true | false )  (?attr) dup if @val true then ;
: ?attr  ( xn=node adr c -- n true | false )  (?attr) dup if @val evaluate true then ;
: attr ( xn=node adr c -- n )  ?attr 0= abort" attribute not found" ;
: attr$ ( xn=node adr c -- adr c )  ?attr$ 0= abort" attribute not found" ;

: $=  compare 0= ;

: strattr   create   parse-word string,  does>  count  attr$ ;
: numattr   create   parse-word string,  does>  count  attr ;
: attrchecker create parse-word string,  does>  count  (?attr) ;
: childnode create   parse-word string,  does>  ( node n ) count rot el[] ;

: .xn  cr xn .element ;
