\ sokoban by pawaller 01/06/2023	

CAPS ON
0 VALUE moves
0 VALUE goals
0 VALUE flag 
1 VALUE level
20 VALUE md \ map dimensions
9 VALUE bd \ bitmap dimensions
create map md DUP * ALLOT
create rgb bd DUP * 3 * ALLOT

: CUROFF ( ---)
\G Switch cursor OFf
  23 EMIT 1 EMIT 0 EMIT ;

: CURON ( ---)
\G Switch cursor on
  23 EMIT 1 EMIT 1 EMIT ;

: MODE ( n ---)
\G Select graphics mode
  22 EMIT DUP EMIT ;

: 2EMIT ( n ---)
\G EMIT n as two characters, LSB first.
  DUP 8 RSHIFT SWAP EMIT EMIT ;

: VDU ( ---)
23 EMIT 27 EMIT ;

: FG ( c ---)
  17 EMIT EMIT ;
: BG ( c ---)
  17 EMIT 128 + EMIT ;

: SELECT-BITMAP ( n ---)
\G Select bitmap for preceding operations
VDU 0 EMIT EMIT ;

: LOAD-BITMAP-RGB ( data w h --)
\G Load current bitmap with data in rgb format
VDU 1 EMIT \ load bitmap
2DUP 2EMIT 2EMIT \ width & height
* 3 * 0 DO
DUP i + C@ EMIT
DUP i + 1+ C@ EMIT
DUP i + 2+ C@ EMIT
255 EMIT
3 +LOOP 
DROP ;

: DRAW-BITMAP ( y x ---)
\G Draw current bitmap on screen at x y coordinates
VDU 3 EMIT 2EMIT 2EMIT ;

: LOAD-BITMAP ( pathtofile tempspace w h n --- data w h )
SELECT-BITMAP 
4 ROLL 4 ROLL
OSSTRING >ASCIIZ  
2DUP >R >R 
3 * * SWAP DUP >R SWAP 
OSSTRING -ROT 1 OSCALL -38 ?THROW
R> R> R>
LOAD-BITMAP-RGB ;

S" bitmaps/wall.rgb" rgb bd DUP  $23 LOAD-BITMAP
S" bitmaps/blank.rgb" rgb bd DUP $0 LOAD-BITMAP
S" bitmaps/goal.rgb" rgb bd DUP $2E LOAD-BITMAP
S" bitmaps/loot.rgb" rgb bd DUP $24 LOAD-BITMAP
S" bitmaps/soko.rgb" rgb bd DUP $40 LOAD-BITMAP
S" bitmaps/log.rgb" rgb bd DUP $2A LOAD-BITMAP



: LOAD-MAP ( ---)
s" levels\levelxx.bin" osstring >asciiz \ put path in buffer
level S>D <# # # #> \ convert current level number into 2 char string
OSSTRING 12 + SWAP CMOVE \ inject that string into filepath
map md DUP * OSSTRING ROT ROT 1 OSCALL -38 ?THROW \ load level into map
;

: CLEAR-STACK (  ---)
\G Clears the stack.
depth 0 DO DROP LOOP ;

: .MAP ( ---)
PAGE
32 0 DO
20 0 DO
map i + j md * + C@
SELECT-BITMAP
bd j * bd i * DRAW-BITMAP
LOOP
LOOP
;

: .REFRESH ( ---)
32 0 DO
20 0 DO
map i + j md * + C@
DUP $23 <> IF
SELECT-BITMAP
bd j * bd i * DRAW-BITMAP
THEN
LOOP
LOOP
;

: FIND-SOKO ( -- p) \ address of soko in map
md DUP * 0 do
map i + C@
$40 = IF map i + THEN
LOOP
;


: FIND-GOALS ( --) \ number of uncovered goals in map
0 to goals
md DUP * 0 do
map i + C@
$2E = IF goals 1+ to goals THEN
LOOP
flag $2E = IF goals 1+ to goals THEN ;

: MOVE-SOKO ( p -- p p1 p2)
KEY
CASE
11 OF DUP md - DUP md -  ENDOF
10 OF DUP md + DUP md + ENDOF
8 OF DUP 1- DUP 1- ENDOF
21 OF DUP 1+ DUP 1+ ENDOF
113 OF quit ENDOF \ q key pressed
\ 114 OF start_level ENDOF \ r key pressed
ENDCASE
;

: SOKO2P1 ( p p2 p1 -- )
$40 SWAP c! 
DROP 
flag SWAP c! 
moves 1+ to moves
;

: LOOT2P2 ( p p1 p2 -- p p1 p2)
DUP DUP 
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
SWAP DUP DUP 
c@ 0 = SWAP 
c@ $2E = or 
;

: RULES ( p p1 p2 --)
SWAP DUP C@ 
CASE
0   OF SOKO2P1 0 to flag ENDOF 
$2E OF SOKO2P1 $2E to flag ENDOF 
$24 OF P2VALID? 
 IF LOOT2P2 SWAP SOKO2P1 THEN ENDOF 
$2A OF P2VALID? 
 IF LOOTONGOAL2P2 
SWAP SOKO2P1 $2E to flag THEN ENDOF 
ENDCASE
CLEAR-STACK
;

: START-LEVEL ( ---)
CLEAR-STACK
LOAD-MAP
0 to moves
PAGE
.MAP
;

: SOKO ( --)
BEGIN
2 MODE
CUROFF
START-LEVEL
BEGIN
FIND-SOKO
MOVE-SOKO
RULES
FIND-GOALS
.REFRESH
goals 0=
UNTIL
level 1+ to level
level 6 =
UNTIL
;


 
 
