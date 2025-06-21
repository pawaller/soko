\ sokoban by pawaller 01/06/2023	

CAPS ON
8 MODE
0 CURSOR


10 VALUE bd \ bitmap dimensions
create map 640 ALLOT \ assign memory for map
create rgb bd DUP * 3 * ALLOT \ assign memory for bitmap
create title 25 100 3 * * ALLOT \ assign memory for title image
0 VALUE moves
0 VALUE goals
0 VALUE flag
1 VALUE level

: CUROFF ( ---)
\G Switch cursor off
  23 EMIT 1 EMIT 0 EMIT ;

: CURON ( ---)
\G Switch cursor on
  23 EMIT 1 EMIT 1 EMIT ;

: CURSOR ( f ---)
\G Ser cursor visibility by flag f.
    23EMIT 1 EMIT IF 1 ELSE 0 THEN EMIT ;  

: MODE ( n ---)
\G Select graphics mode
  22 EMIT EMIT ;

: 2EMIT ( n ---)
\G EMIT n as two characters, LSB first.
  DUP 8 RSHIFT SWAP EMIT EMIT ;

: VDU ( ---)
23 EMIT 27 EMIT ;

: GXR ( ---)
23 EMIT 27 EMIT ;

: FG ( c ---)
  17 EMIT EMIT ;

: BG ( c ---)
  17 EMIT 128 + EMIT ;

: VBL ( ---)
SYSVARS xC@ BEGIN SYSVARS xC@ OVER <> UNTIL DROP ;

: VWAIT ( ---)
\G Wait for system vertical blank as is done in BBC basic.
    0 SYSVARS@
    BEGIN DUP 0 SYSVARS@ = WHILE REPEAT DROP ; 

: SELECT-BITMAP ( n ---) \ Select bitmap for preceding operations
GXR 0 EMIT EMIT ;

: LOAD-BITMAP-RGB ( data width height --) \ Load current bitmap with data in rgb format
GXR 1 EMIT \ load bitmap
2DUP 2EMIT 2EMIT \ width & height
* 3 * 0 DO
DUP i + C@ EMIT
DUP i + 1+ C@ EMIT
DUP i + 2+ C@ EMIT
255 EMIT
3 +LOOP 
DROP ;

: DRAW-BITMAP ( y x ---) \ Draw current bitmap on screen at x y coordinates
GXR 3 EMIT 2EMIT 2EMIT ;

: LOAD-BITMAP ( pathtofile tempspace width height bitmap_number --- data width height )
SELECT-BITMAP 
4 ROLL 4 ROLL
OSSTRING >ASCIIZ  
2DUP 
>R >R 
3 * * 
SWAP DUP 
>R 
SWAP 
OSSTRING
 -ROT 1 OSCALL -38 ?THROW
R> R> R>
LOAD-BITMAP-RGB ;

: INIT ( ---) \ load bitmaps into sprites
9 to level
S" bitmaps/title.rgb" title 25 100 $01 LOAD-BITMAP
S" bitmaps/wall.rgb" rgb bd DUP  $23 LOAD-BITMAP
S" bitmaps/blank.rgb" rgb bd DUP $0 LOAD-BITMAP
S" bitmaps/goal.rgb" rgb bd DUP $2E LOAD-BITMAP
S" bitmaps/loot.rgb" rgb bd DUP $24 LOAD-BITMAP
S" bitmaps/soko.rgb" rgb bd DUP $40 LOAD-BITMAP
S" bitmaps/loot.rgb" rgb bd DUP $2A LOAD-BITMAP
;

: CLEAR-STACK ( ---)
\G Clears the stack
DEPTH 0 do drop LOOP ;

: LOAD-MAP ( ---)
s" levels\levelxx.bin" osstring >asciiz \ put path in buffer
level s>d <# # # #> \ convert current level number into 2 char string
OSSTRING 12 + SWAP CMOVE \ inject that string into filepath
map 640 ERASE
map 640 OSSTRING ROT ROT 1 OSCALL -38 ?THROW \ load level into map
;




: .MAP ( ---) \ print current map to screen
PAGE
20 0 DO
32 0 DO
map i + j 32 * + C@
SELECT-BITMAP
bd j * bd i * DRAW-BITMAP
LOOP
LOOP ;

: START-LEVEL ( ---)
0 TO moves
0 TO flag
PAGE
16 10 AT-XY 1 FG ." LEVEL " level .
100 0 DO VBL LOOP
LOAD-MAP
.MAP ;

: .REFRESH ( ---) \ print modified current map to screen
20 0 DO
32 0 DO
map i + j 32 * + C@
DUP $23 <> IF
SELECT-BITMAP
bd j * bd i * DRAW-BITMAP
ELSE DROP
THEN
LOOP
LOOP 
;

: FIND-SOKO ( -- p) \ address of soko in map
640 0 DO
map i + C@
$40 = IF map i + THEN
LOOP ;


: FIND-GOALS ( --) \ number of uncovered goals in map
0 to goals
640 0 do
map i + C@
$2E = IF goals 1+ to goals THEN
LOOP
flag $2E = IF goals 1+ to goals THEN ;

: CHECK-KEYS ( p -- p p1 p2)
KEY
CASE
11 OF DUP 32 - DUP 32 -  ENDOF
10 OF DUP 32 + DUP 32 + ENDOF
8 OF DUP 1- DUP 1- ENDOF
21 OF DUP 1+ DUP 1+ ENDOF
27 OF PAGE 1 to level 1 MODE 1 CURSOR QUIT ENDOF \ esc
114 OF START-LEVEL ENDOF \ r
ENDCASE
;


: SOKO2P1 ( p p2 p1 -- )
$40 SWAP c! 
DROP 
flag SWAP c! 
moves 1+ TO moves
;

: LOOT2P2 ( p p1 p2 -- p p1 p2)
DUP
DUP 
c@ $2E = IF $2A SWAP c! 
ELSE $24 SWAP c!
THEN
;

: LOOTONGOAL2P2 ( p p1 p2 -- p p1 p2)
DUP
$2A SWAP c! 
 SWAP DUP 
 $2E SWAP c!
 SWAP
;


: P2VALID? ( p p2 p1 -- f)
SWAP 
DUP 
DUP 
c@ 0 = 
SWAP  
c@ $2E = 
or 
;

: RULES ( p p1 p2 --)
SWAP 
DUP 
c@ 
CASE \ P1=?
0   OF SOKO2P1 0 to flag ENDOF 
$2E OF SOKO2P1 $2E to flag ENDOF 
$24 OF P2VALID? 
 IF
LOOT2P2 SWAP SOKO2P1 THEN ENDOF 
$2A OF P2VALID? 
 IF
 LOOTONGOAL2P2 
SWAP SOKO2P1 
$2E to flag 
THEN ENDOF 
ENDCASE
;


: .SPLASH ( ---) \ print splash screen
PAGE
10 10 AT-XY 3 FG ." Cursor Keys to move"
14 14 AT-XY 3 FG ." ESC to QUIT"
10 12 AT-XY 3 FG ." R to RESTART level"
13 16 AT-XY 1 FG ." Press any key"
1 SELECT-BITMAP
50 105 DRAW-BITMAP
KEY DROP ;

: .GAME-OVER ( ---) \ print game over screen
PAGE
12 10 AT-XY 1 FG ." Game Over "
KEY
DROP ;


: SOKO ( --)
INIT
8 MODE
0 CURSOR
.SPLASH
BEGIN
START-LEVEL
BEGIN
FIND-SOKO
CHECK-KEYS
RULES
.REFRESH
FIND-GOALS
goals 0=
UNTIL
level 1+ to level
level 11 =
UNTIL
.GAME-OVER
1 CURSOR
1 MODE
;

SOKO

 
 
