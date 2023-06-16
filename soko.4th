\ sokoban by pawaller 01/06/2023	

1 CAPS
0 VALUE moves
0 VALUE goals
0 VALUE flag 
1 VALUE level
20 VALUE md \ map dimensions
9 VALUE bd \ bitmap dimensions
create map md DUP * ALLOT
create rgb bd DUP * 3 * ALLOT

: CUROFF ( ---)
\G Switch cursor off
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
\G Draw selected bitmap on screen at x y coordinates
VDU 3 EMIT 2EMIT 2EMIT ;

: LOAD-BITMAP ( pathtofile tempspace x y n --- data w h )
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

S" bitmaps/wall.rgb" rgb bd DUP  $23 LOAD-BITMAP
S" bitmaps/blank.rgb" rgb bd DUP $0 LOAD-BITMAP
S" bitmaps/goal.rgb" rgb bd DUP $2E LOAD-BITMAP
S" bitmaps/loot.rgb" rgb bd DUP $24 LOAD-BITMAP
S" bitmaps/soko.rgb" rgb bd DUP $40 LOAD-BITMAP
S" bitmaps/log.rgb" rgb bd DUP $2A LOAD-BITMAP



: LOAD-MAP ( ---)
s" levels\levelxx.bin" osstring >asciiz \ put path in buffer
level s>d <# # # #> \ convert current level number into 2 char string
OSSTRING 12 + SWAP CMOVE \ inject that string into filepath
map md DUP * OSSTRING ROT ROT 1 OSCALL -38 ?THROW \ load level into map
;

: CLEAR-STACK (  ---)
\G Clears the stack.
depth 0 do drop loop ;

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
DUP $23 <> if
SELECT-BITMAP
bd j * bd i * DRAW-BITMAP
THEN
LOOP
LOOP
;


: find_soko ( -- p) \ address of soko in map
md DUP * 0 do
map i + 
c@ $40 = if map i + then
loop
;


: find_goals ( --) \ number of uncovered goals in map
0 to goals
md DUP * 0 do
map i + 
c@ $2E = if goals 1+ to goals then
loop
flag $2E = if goals 1+ to goals then
;

: soko_up ( p  -- p p1 p2)
DUP mode - 
DUP md - 
;

: soko_down ( p -- p p1 p2) 
DUP md + 
DUP md + 
;

: soko_left ( p -- p p1 p2)
DUP 1 - 
DUP 1 - 
;

: soko_right ( p -- p p1 p2)
DUP 1 + 
DUP 1 + 
;


: move_soko ( p -- p p1 p2)
key
case
11 of soko_up endof
10 of soko_down endof
8 of soko_left endof
21 of soko_right endof
113 of quit endof \ q key pressed
\ 114 of start_level endof \ r key pressed
endcase
;

: soko2p1 ( p p2 p1 -- )
$40 SWAP c! 
drop 
flag SWAP c! 
moves 1+ to moves
;

: loot2p2 ( p p1 p2 -- p p1 p2)
DUP DUP 
c@ $2E = if $2A SWAP c! 
else $24 SWAP c!
then
;

: lootongoal2p2 ( p p1 p2 -- p p1 p2)
DUP
$2A SWAP c! 
SWAP DUP 
$2E SWAP c!
SWAP
;


: p2valid? ( p p2 p1 -- f)
SWAP 
DUP 
DUP 
c@ 0 = 
SWAP 
c@ $2E = 
or 
;

: rules ( p p1 p2 --)
SWAP 
DUP 
c@ 
case 
0   of soko2p1 0 to flag endof 
$2E of soko2p1 $2E to flag endof 
$24 of p2valid? 
 if 
loot2p2 SWAP soko2p1 then endof 
$2A of p2valid? 
 if 
 lootongoal2p2 
SWAP soko2p1 $2E to flag then endof 
endcase
clear-stack
;

: start_level ( ---)
clearstack
load_map
0 to moves
page
.map
;

: SOKO ( --)
begin
2 MODE
CUROFF
start_level
begin
find_soko
move_soko
rules
find_goals
.MAP
goals 0=
until
level 1+ to level
level 6 =
until
;


 
 
