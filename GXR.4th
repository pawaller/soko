\ gxf by pawaller 01/06/2023	

: CURSOR ( f ---)
\G Ser cursor visibility by flag f.
    23EMIT 1 EMIT IF 1 ELSE 0 THEN EMIT ;  

: MODE ( n ---)
\G Select graphics mode
  22 EMIT EMIT ;
  
  : CLEAR-STACK ( ---)
\G Clears the stack
DEPTH 0 do drop LOOP ;

: 2EMIT ( n ---)
\G EMIT n as two characters, LSB first.
  DUP 8 RSHIFT SWAP EMIT EMIT ;

: GXR ( ---)
23 EMIT 27 EMIT ;

: FG ( c ---)
  17 EMIT EMIT ;

: BG ( c ---)
  17 EMIT 128 + EMIT ;

: VBL ( ---)
SYSVARS xC@ BEGIN SYSVARS xC@ OVER <> UNTIL DROP ;

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



: LOAD-MAP ( ---) \ load level from file into allocated memory
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
