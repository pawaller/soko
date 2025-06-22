forget -gfx
create -gfx

: MODE ( n ---)
\G Select graphics mode
  22 EMIT DUP EMIT ;

: 2EMIT ( n ---)
\G EMIT n as two characters, LSB first.
  DUP 8 RSHIFT SWAP EMIT EMIT ;

 : CLEAR-STACK ( ---)
\G Clears the stack
S0 @ SP! ;

: CURSOR ( f ---)
\G Ser cursor visibility by flag f.
    23EMIT 1 EMIT IF 1 ELSE 0 THEN EMIT ;  

 : FLIP ( ---)
\G Flip draw buffer.
    23 EMIT 0 EMIT $C3 EMIT ;   

0 CONSTANT BLACK
 1 CONSTANT RED
 2 CONSTANT GREEN
 3 CONSTANT YELLOW
 4 CONSTANT BLUE
 5 CONSTANT MAGENTA
 6 CONSTANT CYAN
 7 CONSTANT LIGHT-GREY 7 CONSTANT LIGHT-GRAY
 8 CONSTANT DARK-GREY 8 CONSTANT DARK-GRAY
 9 CONSTANT BRIGHT-RED
10 CONSTANT BRIGHT-GREEN
11 CONSTANT BRIGHT-YELLOW
12 CONSTANT BRIGHT-BLUE
13 CONSTANT BRIGHT-MAGENTA
14 CONSTANT BRIGHT-CYAN
15 CONSTANT WHITE


: FG ( c ---)
  17 EMIT EMIT ;
: BG ( c ---)
  17 EMIT 128 + EMIT ;
: GC ( c ---)
  18 EMIT 0 EMIT EMIT ;

: VWAIT ( --- )
\G Wait for vertical blank
    0 SYSVARS@
    BEGIN DUP 0 SYSVARS@ = WHILE REPEAT
    DROP
;

: GFX ( ---)
23 EMIT 27 EMIT ;

: CREATE-UDC ( d0 ... d7 n --- )
\G Create User Defined Character
23 EMIT
EMIT
8 0 do
EMIT
loop ;

: SELECT-BITMAP ( n ---)
\G Select bitmap for preceding operations
GFX 0 EMIT EMIT ;

: LOAD-BITMAP-RGB ( data w h --)
\G Load selected bitmap with data in rgb format
GFX 1 EMIT \ load bitmap
2DUP 2EMIT 2EMIT \ width & height
* 3 * 0 DO
DUP i + C@ EMIT
DUP i + 1+ C@ EMIT
DUP i + 2+ C@ EMIT
255 EMIT
3 +LOOP 
DROP ;

: LOAD-BITMAP-RGBA ( data w h ---)
\G Load selected bitmap with data in rgba format
GFX 1 EMIT \ load bitmap
2DUP 2EMIT 2EMIT \ width & height
* 4 * 0 do \ data
DUP i 3 + + C@ EMIT 
DUP i 2+ + C@ EMIT
DUP i 1+ + C@ EMIT
DUP i + C@ EMIT
4 +LOOP 
DROP ;

: LOAD_BITMAP_MONO ( data col2 col1 w h ---)
\G Load selected bitmap with data in mono format
GFX 2 EMIT \ load mono bitmap
2DUP 2EMIT 2EMIT \ width & height
rot 2EMIT \ col1 
rot 2EMIT \ col2
* 0 do \ width * height
i + C@ EMIT
loop ;



: DRAW-BITMAP ( y x ---)
\G Draw selected bitmap on screen at x y coordinates
GFX 3 EMIT 2EMIT 2EMIT ;

: SELECT-SPRITE ( n --)
\G Select sprite for preceding operations
GFX 4 EMIT 2EMIT ;

: CLEAR-SPRITE ( --)
\G Clear selected sprite
GFX 5 EMIT ;

: BITMAP2SPRITE ( n --)
\G Convert selected bitmap to selected sprite
GFX 6 EMIT 2EMIT ;

: ACTIVATE-SPRITES ( n --)
\G Activatye number of sprites
GFX 7 EMIT 2EMIT ;

: SHOW-SPRITE ( --)
\G Display selected sprite
GFX 11 EMIT ;

: HIDE-SPRITE ( --)
\G Remove selected sprite from screen
GFX 12 EMIT ;

: MOVE-SPRITE-TO ( y x --)
\G Move selected sprite to x y coordinates
GFX 13 EMIT 2EMIT 2EMIT ;

: MOVE-SPRITE-BY ( y x --)
\G Move selected sprite by x y pixels
GFX 14 EMIT 2EMIT 2EMIT ;

: UPDATE-SPRITES ( --)
\G Update sprites on screen
GFX 15 EMIT ;

: RESET-SPRITES ( --)
\G Reset all sprites
GFX 16 EMIT ;



\ eof
