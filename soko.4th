\ sokoban by pawaller 01/06/2023	
2 MODE
CUROFF
1 CAPS
0 VALUE moves
0 VALUE goals
0 VALUE flag 
1 VALUE level


create map 400 allot
create rgb 9 9 3 * * allot

: clear-stack (  ---)
\G Clears the stack.
depth 0 do drop loop ;

: LOAD-BITMAP ( pathtofile tempspace x y n ) \ s"bitmaps/wall9.rgb" rgb 9 9 1
SELECT-BITMAP \ str-addr str-count rgb 9 9 
4 ROLL \ str-count rgb 9 9 str-addr
4 ROLL \ rgb 9 9 str-addr str-count
OSSTRING >ASCIIZ \ rgb 9 9  
2DUP \ rgb 9 9 9 9 
>R >R \ rgb 9 9
3 * * \ rgb 243
SWAP \ 243 rgb
DUP \ 243 rgb rgb
>R \ 243 rgb
SWAP \ rgb 243
OSSTRING \ rgb 243 osstring
 -ROT        \ osstring rgb 243
1 OSCALL -38 ?THROW \ load file into tempspace
R> R> R> \ rgb 9 9 
LOAD-BITMAP-RGB
;

S" bitmaps/wall.rgb" rgb 9 9 $23 LOAD-BITMAP

s" levels\levelxx.bin" osstring >asciiz \ put path in buffer

: load_map ( ---)
level s>d <# # # #> \ convert current level number into 2 char string
osstring 12 + swap cmove \ inject that string into filepath
map 400 osstring rot rot 1 oscall -38 ?throw \ load level into map
;

: .bitmap ( ---)
32 0 DO
20 0 DO
map i + j + C@
SELECT-BITMAP
9 i * 9 j * DRAW-BITMAP
LOOP
LOOP
;

: .map ( --)
\ page
0 0 AT-XY
20 20 * 0 DO
20 0 DO
map i + j + C@
DUP $40 = IF 3 fg EMIT else
DUP $2E = IF 4 fg EMIT else
DUP $24 = IF 2 fg EMIT else
DUP $23 = IF 1 fg EMIT else
DUP $2A = IF 2 fg EMIT else
DUP 0 = if 32 emit drop else emit then then then then then then
loop
cr 
20 +loop
7 fg ." Level: " level .
5 fg ." Moves: " moves .
6 fg ." Goals: " goals .
;


: find_soko ( -- p) \ address of soko in map
20 20 * 0 do
map i + 
c@ $40 = if map i + then
loop
;


: find_goals ( --) \ number of uncovered goals in map
0 to goals
20 20 * 0 do
map i + 
c@ $2E = if goals 1+ to goals then
loop
flag $2E = if goals 1+ to goals then
;

: soko_up ( p  -- p p1 p2)
dup 20 - 
dup 20 - 
;

: soko_down ( p -- p p1 p2) 
dup 20 + 
dup 20 + 
;

: soko_left ( p -- p p1 p2)
dup 1 - 
dup 1 - 
;

: soko_right ( p -- p p1 p2)
dup 1 + 
dup 1 + 
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
$40 swap c! 
drop 
flag swap c! 
moves 1+ to moves
;

: loot2p2 ( p p1 p2 -- p p1 p2)
dup dup 
c@ $2E = if $2A swap c! 
else $24 swap c!
then
;

: lootongoal2p2 ( p p1 p2 -- p p1 p2)
dup 
$2A swap c! 
swap dup 
$2E swap c!
swap
;


: p2valid? ( p p2 p1 -- f)
swap 
dup 
dup 
c@ 0 = 
swap 
c@ $2E = 
or 
;

: rules ( p p1 p2 --)
swap 
dup 
c@ 
case 
0   of soko2p1 0 to flag endof 
$2E of soko2p1 $2E to flag endof 
$24 of p2valid? 
 if 
loot2p2 swap soko2p1 then endof 
$2A of p2valid? 
 if 
 lootongoal2p2 
swap soko2p1 $2E to flag then endof 
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

: soko ( --)

begin
start_level
begin
find_soko
move_soko
rules
find_goals
.map
goals 0=
until
level 1+ to level
level 6 =
until
;


 
 
