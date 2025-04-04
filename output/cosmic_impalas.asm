; C:\COSMICIMPALASM68K\PROGRAMS\DEBUGMONITORCODE\COSMIC_IMPALAS.C - Compiled by CC68K  Version 5.00 (c) 1991-2005  Peter J. Fondse
; #include <string.h>
; #include <stdio.h>
; #include <stdlib.h>
; #include <limits.h>
; #define PIXEL_BUFFER_VGA_BASEADDRESS   (0x01000000)
; #define VIDMEM_DIM1_W_BLANK_EDGES (256)
; #define VIDMEM_DIM1 (224)
; #define VIDMEM_DIM2 (32)
; #define VIDEOMEM_ADDR(x,y) ((volatile unsigned char *)(PIXEL_BUFFER_VGA_BASEADDRESS + ((y)*VIDMEM_DIM1_W_BLANK_EDGES)+(x)))
; #define VIDMEM(x,y) (*VIDEOMEM_ADDR(x,y))
; #define COSMIC_IMPALAS_TIMER_DELAY_MS (50)
; #define WRITE_VIDMEM(x,y,CH) ((*(volatile unsigned char *)(PIXEL_BUFFER_VGA_BASEADDRESS + ((y)*VIDMEM_DIM1_W_BLANK_EDGES)+(x))) = CH)
; #define MAX_ENEMIES 28
; int FIRE1  ;
; int LEFT1  ;
; int RIGHT1 ;
; #define LOCHAR 0x20
; #define HICHAR 0x5e
; //
; // GAME CODE
; //
; #define MAXLIVES 5
; typedef unsigned char byte;
; typedef signed char sbyte;
; typedef unsigned short word;
; typedef struct {
; byte x;
; byte y;
; byte shape; 
; } Enemy;
; typedef struct {
; byte right;
; byte down;
; } MarchMode;
; MarchMode this_mode, next_mode;
; byte enemy_index;
; byte num_enemies;
; byte player_x;
; byte bullet_x;
; byte bullet_y;
; byte bomb_x;
; byte bomb_y;
; byte attract;
; byte credits;
; byte curplayer;
; word score;
; byte lives;
; Enemy enemies[MAX_ENEMIES];
; char font8x8[HICHAR-LOCHAR+1][8];
; byte player_bitmap[56];
; byte bomb_bitmap[7];
; byte bullet_bitmap[6];
; byte enemy1_bitmap[34];
; byte enemy2_bitmap[34];
; byte enemy3_bitmap[34];
; byte enemy4_bitmap[34];
; byte* enemy_bitmaps[4];
; unsigned long seed; 
; extern int clock_count_ms;
; ///////////////////////////////////////////////////////////////////////////
; //
; // Functions to Implement
; //
; ///////////////////////////////////////////////////////////////////////////
; void draw_sprite(byte* src, byte x, byte y)
; {
       section   code
       xdef      _draw_sprite
_draw_sprite:
       link      A6,#0
       unlk      A6
       rts
; //complete this function
; }
; byte xor_sprite(byte *src, byte x, byte y)
; {
       xdef      _xor_sprite
_xor_sprite:
       link      A6,#0
       unlk      A6
       rts
; //complete this function
; }
; void erase_sprite(byte *src, byte x, byte y)
; {
       xdef      _erase_sprite
_erase_sprite:
       link      A6,#0
       unlk      A6
       rts
; //complete this function
; }
; void clear_sprite(byte *src, byte x, byte y)
; {
       xdef      _clear_sprite
_clear_sprite:
       link      A6,#0
       unlk      A6
       rts
; //complete this function
; }
; void move_player() {
       xdef      _move_player
_move_player:
       rts
; //complete this function
; }
; ///////////////////////////////////////////////////////////////////////////
; //
; // End Functions to Implement
; //
; ///////////////////////////////////////////////////////////////////////////
; // Set the seed
; void srand(unsigned long new_seed) {
       xdef      _srand
_srand:
       link      A6,#0
; seed = new_seed;
       move.l    8(A6),_seed.L
       unlk      A6
       rts
; }
; // Generate a pseudorandom number
; unsigned long long_rand(void) {
       xdef      _long_rand
_long_rand:
       move.l    A2,-(A7)
       lea       _seed.L,A2
; seed ^= seed << 13; // XOR with shifted value
       move.l    (A2),D0
       lsl.l     #8,D0
       lsl.l     #5,D0
       eor.l     D0,(A2)
; seed ^= seed >> 17;
       move.l    (A2),D0
       lsr.l     #8,D0
       lsr.l     #8,D0
       lsr.l     #1,D0
       eor.l     D0,(A2)
; seed ^= seed << 5;
       move.l    (A2),D0
       lsl.l     #5,D0
       eor.l     D0,(A2)
; return seed;
       move.l    (A2),D0
       move.l    (A7)+,A2
       rts
; }
; int clock() {
       xdef      _clock
_clock:
; return clock_count_ms;
       move.l    _clock_count_ms.L,D0
       rts
; }
; void delay_ms(int num_ms) {
       xdef      _delay_ms
_delay_ms:
       link      A6,#0
       movem.l   D2/D3,-(A7)
; int start_time;
; int current_time;
; start_time = clock();
       jsr       _clock
       move.l    D0,D2
; do {
delay_ms_1:
; current_time = clock();
       jsr       _clock
       move.l    D0,D3
; if (current_time < start_time) { //handle wraparound
       cmp.l     D2,D3
       bge.s     delay_ms_3
; num_ms = num_ms - (INT_MAX-start_time);
       move.l    #2147483647,D0
       sub.l     D2,D0
       sub.l     D0,8(A6)
; start_time = current_time;
       move.l    D3,D2
delay_ms_3:
       move.l    D3,D0
       sub.l     D2,D0
       cmp.l     8(A6),D0
       blt       delay_ms_1
       movem.l   (A7)+,D2/D3
       unlk      A6
       rts
; }
; } while ((current_time - start_time) < num_ms);
; }
; void clrscr() {
       xdef      _clrscr
_clrscr:
       movem.l   D2/D3,-(A7)
; int a;
; int b;
; for (a = 0; a < VIDMEM_DIM1; a++) {
       clr.l     D3
clrscr_1:
       cmp.l     #224,D3
       bge       clrscr_3
; for (b = 0; b < VIDMEM_DIM2; b++) {
       clr.l     D2
clrscr_4:
       cmp.l     #32,D2
       bge.s     clrscr_6
; WRITE_VIDMEM(a,b,0 /*0xff*/);	   
       move.l    #16777216,D0
       move.l    D2,-(A7)
       pea       256
       jsr       LMUL
       move.l    (A7),D1
       addq.w    #8,A7
       add.l     D3,D1
       add.l     D1,D0
       move.l    D0,A0
       clr.b     (A0)
       addq.l    #1,D2
       bra       clrscr_4
clrscr_6:
       addq.l    #1,D3
       bra       clrscr_1
clrscr_3:
       movem.l   (A7)+,D2/D3
       rts
; }
; }
; //memset(vidmem, 0, VIDMEM_DIM1*VIDMEM_DIM2);
; }
; void xor_pixel(unsigned char x, unsigned char y) {
       xdef      _xor_pixel
_xor_pixel:
       link      A6,#-4
; unsigned char* dest;
; dest =  VIDEOMEM_ADDR(x,y>>3);
       move.l    #16777216,D0
       move.b    15(A6),D1
       lsr.b     #3,D1
       and.w     #255,D1
       asl.w     #8,D1
       ext.l     D1
       move.l    D0,-(A7)
       move.b    11(A6),D0
       and.l     #255,D0
       add.l     D0,D1
       move.l    (A7)+,D0
       add.l     D1,D0
       move.l    D0,-4(A6)
; *dest = (*dest) ^ (0x1 << (y&7));
       move.l    -4(A6),A0
       moveq     #1,D0
       move.b    15(A6),D1
       and.b     #7,D1
       lsl.b     D1,D0
       eor.b     D0,(A0)
       unlk      A6
       rts
; }
; void draw_vline(unsigned char x, unsigned char y1, unsigned char y2) {
       xdef      _draw_vline
_draw_vline:
       link      A6,#-4
       movem.l   D2/D3/D4/D5/D6,-(A7)
       move.b    19(A6),D5
       and.l     #255,D5
; unsigned char yb1;
; unsigned char yb2;
; unsigned char val;
; unsigned char* dest;
; int nchars;
; yb1 = y1>>3;
       move.b    15(A6),D0
       lsr.b     #3,D0
       move.b    D0,D6
; yb2 = y2>>3;
       move.b    D5,D0
       lsr.b     #3,D0
       move.b    D0,-1(A6)
; nchars  = (((unsigned int) yb2) & 0xff) - (((unsigned int) yb1) & 0xff);
       move.b    -1(A6),D0
       and.l     #255,D0
       and.l     #255,D0
       move.b    D6,D1
       and.l     #255,D1
       and.l     #255,D1
       sub.l     D1,D0
       move.l    D0,D4
; dest = VIDEOMEM_ADDR(x,yb1);
       move.l    #16777216,D0
       move.b    D6,D1
       and.w     #255,D1
       asl.w     #8,D1
       ext.l     D1
       move.l    D0,-(A7)
       move.b    11(A6),D0
       and.l     #255,D0
       add.l     D0,D1
       move.l    (A7)+,D0
       add.l     D1,D0
       move.l    D0,D3
; val = 0xff << (y1&7);
       move.w    #255,D0
       move.b    15(A6),D1
       and.b     #7,D1
       and.w     #255,D1
       asl.w     D1,D0
       move.b    D0,D2
; *dest ^= val;
       move.l    D3,A0
       eor.b     D2,(A0)
; dest = dest+VIDMEM_DIM1_W_BLANK_EDGES;
       add.l     #256,D3
; if (nchars > 0) {
       cmp.l     #0,D4
       ble       draw_vline_1
; while (--nchars > 0) {
draw_vline_3:
       subq.l    #1,D4
       cmp.l     #0,D4
       ble.s     draw_vline_5
; val =  0xff;
       move.b    #255,D2
; *dest ^= val;
       move.l    D3,A0
       eor.b     D2,(A0)
; dest = dest+VIDMEM_DIM1_W_BLANK_EDGES;	  
       add.l     #256,D3
       bra       draw_vline_3
draw_vline_5:
; }
; val = (0xff >> (~y2&7));
       move.w    #255,D0
       move.b    D5,D1
       not.b     D1
       and.b     #7,D1
       and.w     #255,D1
       asr.w     D1,D0
       move.b    D0,D2
; *dest ^= val;
       move.l    D3,A0
       eor.b     D2,(A0)
       bra.s     draw_vline_2
draw_vline_1:
; } else {
; dest = dest-VIDMEM_DIM1_W_BLANK_EDGES; 
       sub.l     #256,D3
; val = (0xff << ((y2+1)&7));
       move.w    #255,D0
       move.b    D5,D1
       addq.b    #1,D1
       and.b     #7,D1
       and.w     #255,D1
       asl.w     D1,D0
       move.b    D0,D2
; *dest ^= val;
       move.l    D3,A0
       eor.b     D2,(A0)
draw_vline_2:
       movem.l   (A7)+,D2/D3/D4/D5/D6
       unlk      A6
       rts
; }
; }
; void draw_char(unsigned char ch, unsigned char x, unsigned char y) {
       xdef      _draw_char
_draw_char:
       link      A6,#0
       movem.l   D2/D3/D4,-(A7)
; unsigned char i;
; unsigned char* src;
; unsigned char* dest;
; src  = &font8x8[(ch-LOCHAR)][0];
       lea       _font8x8.L,A0
       move.b    11(A6),D0
       and.l     #255,D0
       sub.l     #32,D0
       lsl.l     #3,D0
       add.l     D0,A0
       move.l    A0,D4
; dest = VIDEOMEM_ADDR(x*8,y);
       move.l    #16777216,D0
       move.b    19(A6),D1
       and.w     #255,D1
       asl.w     #8,D1
       ext.l     D1
       move.l    D0,-(A7)
       move.b    15(A6),D0
       and.w     #255,D0
       mulu.w    #8,D0
       and.l     #255,D0
       add.l     D0,D1
       move.l    (A7)+,D0
       add.l     D1,D0
       move.l    D0,D3
; for (i=0; i<8; i++) {
       clr.b     D2
draw_char_1:
       cmp.b     #8,D2
       bhs.s     draw_char_3
; *dest = *src;
       move.l    D4,A0
       move.l    D3,A1
       move.b    (A0),(A1)
; dest += 1;//32;
       addq.l    #1,D3
; src += 1;
       addq.l    #1,D4
       addq.b    #1,D2
       bra       draw_char_1
draw_char_3:
       movem.l   (A7)+,D2/D3/D4
       unlk      A6
       rts
; }
; }
; void draw_string(char* str, byte x, byte y) {
       xdef      _draw_string
_draw_string:
       link      A6,#0
       move.l    D2,-(A7)
; do {
draw_string_1:
; byte ch = *str++;
       move.l    8(A6),A0
       addq.l    #1,8(A6)
       move.b    (A0),D2
; if (!ch) break;
       tst.b     D2
       bne.s     draw_string_3
       bra.s     draw_string_2
draw_string_3:
; draw_char(ch, x, y);
       move.b    19(A6),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.b    15(A6),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       and.l     #255,D2
       move.l    D2,-(A7)
       jsr       _draw_char
       add.w     #12,A7
; x++;
       addq.b    #1,15(A6)
       bra       draw_string_1
draw_string_2:
       move.l    (A7)+,D2
       unlk      A6
       rts
; } while (1);
; }
; void draw_bcd_word(word bcd, byte x, byte y) {
       xdef      _draw_bcd_word
_draw_bcd_word:
       link      A6,#0
       movem.l   D2/D3,-(A7)
       move.b    15(A6),D3
       and.l     #255,D3
; byte j;
; x += 3;
       addq.b    #3,D3
; for (j=0; j<4; j++) {
       clr.b     D2
draw_bcd_word_1:
       cmp.b     #4,D2
       bhs       draw_bcd_word_3
; draw_char('0'+(bcd&0xf), x, y);
       move.b    19(A6),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       and.l     #255,D3
       move.l    D3,-(A7)
       moveq     #48,D1
       ext.w     D1
       move.l    D0,-(A7)
       move.w    10(A6),D0
       and.w     #15,D0
       add.w     D0,D1
       move.l    (A7)+,D0
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       _draw_char
       add.w     #12,A7
; x--;
       subq.b    #1,D3
; bcd >>= 4;
       move.w    10(A6),D0
       lsr.w     #4,D0
       move.w    D0,10(A6)
       addq.b    #1,D2
       bra       draw_bcd_word_1
draw_bcd_word_3:
       movem.l   (A7)+,D2/D3
       unlk      A6
       rts
; }
; }
; // Function to add two BCD numbers
; word bcd_add(word a, word b)
; {
       xdef      _bcd_add
_bcd_add:
       link      A6,#-4
       movem.l   D2/D3/D4/D5/D6/D7,-(A7)
       move.w    14(A6),D4
       and.l     #65535,D4
       move.w    10(A6),D5
       and.l     #65535,D5
; word result, carry, place, digit_a, digit_b, sum;
; result = 0;  /* Final BCD result */
       moveq     #0,D7
; carry = 0;   /* Carry for BCD addition */
       clr.w     D2
; place = 0;   /* Bit position for reconstructing the result */
       clr.w     D6
; while (a > 0 || b > 0 || carry > 0) {
bcd_add_1:
       cmp.w     #0,D5
       bhi.s     bcd_add_4
       cmp.w     #0,D4
       bhi.s     bcd_add_4
       cmp.w     #0,D2
       bls       bcd_add_3
bcd_add_4:
; /* Extract the lowest BCD digit from each number using a mask */
; digit_a = a & 0xF;
       move.w    D5,D0
       and.w     #15,D0
       move.w    D0,-4(A6)
; digit_b = b & 0xF;
       move.w    D4,D0
       and.w     #15,D0
       move.w    D0,-2(A6)
; /* Add the digits and the carry */
; sum = digit_a + digit_b + carry;
       move.w    -4(A6),D0
       add.w     -2(A6),D0
       add.w     D2,D0
       move.w    D0,D3
; /* Perform BCD correction if sum > 9 */
; if (sum > 9) {
       cmp.w     #9,D3
       bls.s     bcd_add_5
; sum -= 10;  /* Correct the sum */
       sub.w     #10,D3
; carry = 1;  /* Set the carry */
       moveq     #1,D2
       bra.s     bcd_add_6
bcd_add_5:
; } else {
; carry = 0;  /* Reset carry */
       clr.w     D2
bcd_add_6:
; }
; /* Add the corrected digit to the result in its proper place */
; result |= (sum << place);
       move.w    D3,D0
       lsl.w     D6,D0
       or.w      D0,D7
; /* Move to the next higher BCD digit */
; a >>= 4;
       lsr.w     #4,D5
; b >>= 4;
       lsr.w     #4,D4
; place += 4;  /* Move to the next nibble */
       addq.w    #4,D6
       bra       bcd_add_1
bcd_add_3:
; }
; return result;
       move.w    D7,D0
       movem.l   (A7)+,D2/D3/D4/D5/D6/D7
       unlk      A6
       rts
; }
; void draw_lives(byte player) 
; {
       xdef      _draw_lives
_draw_lives:
       link      A6,#-4
       move.l    D2,-(A7)
; byte i, n, x, y;
; n = lives;
       move.b    _lives.L,-3(A6)
; x = player ? (22 - MAXLIVES) : 6;
       tst.b     11(A6)
       beq.s     draw_lives_1
       moveq     #17,D0
       bra.s     draw_lives_2
draw_lives_1:
       moveq     #6,D0
draw_lives_2:
       move.b    D0,-2(A6)
; y = 30;
       move.b    #30,-1(A6)
; for (i = 0; i < MAXLIVES; i++) {
       clr.b     D2
draw_lives_3:
       cmp.b     #5,D2
       bhs       draw_lives_5
; draw_char(i < n ? '*' : ' ', x++, y);
       move.b    -1(A6),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.b    -2(A6),D1
       addq.b    #1,-2(A6)
       and.l     #255,D1
       move.l    D1,-(A7)
       cmp.b     -3(A6),D2
       bhs.s     draw_lives_6
       moveq     #42,D1
       bra.s     draw_lives_7
draw_lives_6:
       moveq     #32,D1
draw_lives_7:
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       _draw_char
       add.w     #12,A7
       addq.b    #1,D2
       bra       draw_lives_3
draw_lives_5:
       move.l    (A7)+,D2
       unlk      A6
       rts
; }
; }
; void draw_score(byte player) {
       xdef      _draw_score
_draw_score:
       link      A6,#-4
; byte x, y;
; x = player ? 24 : 0;
       tst.b     11(A6)
       beq.s     draw_score_1
       moveq     #24,D0
       bra.s     draw_score_2
draw_score_1:
       clr.b     D0
draw_score_2:
       move.b    D0,-2(A6)
; y = 30;
       move.b    #30,-1(A6)
; draw_bcd_word(score, x, y);
       move.b    -1(A6),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.b    -2(A6),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.w    _score.L,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       jsr       _draw_bcd_word
       add.w     #12,A7
       unlk      A6
       rts
; }
; void add_score(word pts) {
       xdef      _add_score
_add_score:
       link      A6,#0
; if (attract) return;
       tst.b     _attract.L
       beq.s     add_score_1
       bra.s     add_score_3
add_score_1:
; score = bcd_add(score, pts);
       move.w    10(A6),D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       move.w    _score.L,D1
       and.l     #65535,D1
       move.l    D1,-(A7)
       jsr       _bcd_add
       addq.w    #8,A7
       move.w    D0,_score.L
; draw_score(curplayer);
       move.b    _curplayer.L,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       _draw_score
       addq.w    #4,A7
add_score_3:
       unlk      A6
       rts
; }
; byte get_char_rand() {
       xdef      _get_char_rand
_get_char_rand:
       link      A6,#-4
; byte rand;
; rand = (byte) (long_rand() & 0xff);  	
       jsr       _long_rand
       and.l     #255,D0
       move.b    D0,-1(A6)
; return rand;
       move.b    -1(A6),D0
       unlk      A6
       rts
; }
; void xor_player_derez() {
       xdef      _xor_player_derez
_xor_player_derez:
       link      A6,#-4
       movem.l   D2/D3/D4/A2,-(A7)
       lea       _get_char_rand.L,A2
; byte i, j, x, y, rand;
; signed char xx, yy;
; x = player_x + 13;
       move.b    _player_x.L,D0
       add.b     #13,D0
       move.b    D0,-4(A6)
; y = 8;
       move.b    #8,-3(A6)
; rand = get_char_rand();
       jsr       (A2)
       move.b    D0,D2
; for (j = 1; j <= 0x1f; j++) {
       moveq     #1,D3
xor_player_derez_1:
       cmp.b     #31,D3
       bhi       xor_player_derez_3
; for (i = 0; i < 50; i++) {
       clr.b     D4
xor_player_derez_4:
       cmp.b     #50,D4
       bhs       xor_player_derez_6
; rand = get_char_rand();
       jsr       (A2)
       move.b    D0,D2
; xx = x + (rand & 0x1f) - 15;
       move.b    -4(A6),D0
       move.b    D2,D1
       and.b     #31,D1
       add.b     D1,D0
       sub.b     #15,D0
       move.b    D0,-2(A6)
; rand = get_char_rand();
       jsr       (A2)
       move.b    D0,D2
; yy = y + (rand & j);
       move.b    -3(A6),D0
       move.b    D2,D1
       and.b     D3,D1
       add.b     D1,D0
       move.b    D0,-1(A6)
; xor_pixel(xx, yy);
       move.b    -1(A6),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.b    -2(A6),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       _xor_pixel
       addq.w    #8,A7
       addq.b    #1,D4
       bra       xor_player_derez_4
xor_player_derez_6:
       addq.b    #1,D3
       bra       xor_player_derez_1
xor_player_derez_3:
       movem.l   (A7)+,D2/D3/D4/A2
       unlk      A6
       rts
; }
; }
; }
; void destroy_player() {
       xdef      _destroy_player
_destroy_player:
; xor_player_derez(); // xor derez pattern
       jsr       _xor_player_derez
; xor_sprite(player_bitmap, player_x, 1); // erase ship via xor
       pea       1
       move.b    _player_x.L,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       pea       _player_bitmap.L
       jsr       _xor_sprite
       add.w     #12,A7
; xor_player_derez(); // xor 2x to erase derez pattern
       jsr       _xor_player_derez
; player_x = 0xff;
       move.b    #255,_player_x.L
; lives--;
       subq.b    #1,_lives.L
       rts
; }
; void init_enemies() {
       xdef      _init_enemies
_init_enemies:
       movem.l   D2/D3/D4/D5/A2,-(A7)
       lea       _enemies.L,A2
; byte i, x, y, bm;
; x = 0;
       clr.b     D3
; y = 26;
       moveq     #26,D5
; bm = 0;
       clr.b     D4
; for (i = 0; i < MAX_ENEMIES; i++) {
       clr.b     D2
init_enemies_1:
       cmp.b     #28,D2
       bhs       init_enemies_3
; enemies[i].x = x;
       and.l     #255,D2
       move.l    D2,D0
       muls      #3,D0
       move.b    D3,0(A2,D0.L)
; enemies[i].y = y;
       and.l     #255,D2
       move.l    D2,D0
       muls      #3,D0
       lea       0(A2,D0.L),A0
       move.b    D5,1(A0)
; enemies[i].shape = bm;
       and.l     #255,D2
       move.l    D2,D0
       muls      #3,D0
       lea       0(A2,D0.L),A0
       move.b    D4,2(A0)
; x += 28;
       add.b     #28,D3
; if (x > 180) {
       and.w     #255,D3
       cmp.w     #180,D3
       bls.s     init_enemies_4
; x = 0;
       clr.b     D3
; y -= 3;
       subq.b    #3,D5
; bm++;
       addq.b    #1,D4
init_enemies_4:
       addq.b    #1,D2
       bra       init_enemies_1
init_enemies_3:
; }
; }
; enemy_index = 0;
       clr.b     _enemy_index.L
; num_enemies = MAX_ENEMIES;
       move.b    #28,_num_enemies.L
; this_mode.right = 1;
       move.b    #1,_this_mode.L
; this_mode.down = 0;
       clr.b     _this_mode+1.L
; next_mode.right = 1;
       move.b    #1,_next_mode.L
; next_mode.down = 0;
       clr.b     _next_mode+1.L
       movem.l   (A7)+,D2/D3/D4/D5/A2
       rts
; }
; void delete_enemy(Enemy* e) {
       xdef      _delete_enemy
_delete_enemy:
       link      A6,#0
       move.l    D2,-(A7)
       move.l    8(A6),D2
; clear_sprite(enemy_bitmaps[e->shape], e->x, e->y);
       move.l    D2,A0
       move.b    1(A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    D2,A0
       move.b    (A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    D2,A0
       move.b    2(A0),D1
       and.l     #255,D1
       lsl.l     #2,D1
       lea       _enemy_bitmaps.L,A0
       move.l    0(A0,D1.L),-(A7)
       jsr       _clear_sprite
       add.w     #12,A7
; memmove(e, e+1, sizeof(Enemy)*(enemies-e+MAX_ENEMIES-1));
       lea       _enemies.L,A0
       sub.l     D2,A0
       move.l    A0,D1
       divs.w    #3,D1
       add.l     #28,D1
       subq.l    #1,D1
       move.l    D1,-(A7)
       pea       3
       jsr       LMUL
       move.l    (A7),D1
       addq.w    #8,A7
       move.l    D1,-(A7)
       move.l    D2,D1
       addq.l    #3,D1
       move.l    D1,-(A7)
       move.l    D2,-(A7)
       jsr       _memmove
       add.w     #12,A7
; num_enemies--; // update_next_enemy() will check enemy_index
       subq.b    #1,_num_enemies.L
       move.l    (A7)+,D2
       unlk      A6
       rts
; }
; void update_next_enemy() {
       xdef      _update_next_enemy
_update_next_enemy:
       movem.l   A2/A3,-(A7)
       lea       _enemies.L,A2
       lea       _this_mode.L,A3
; if (enemy_index >= num_enemies) {
       move.b    _enemy_index.L,D0
       cmp.b     _num_enemies.L,D0
       blo.s     update_next_enemy_1
; enemy_index = 0;
       clr.b     _enemy_index.L
; this_mode.down = next_mode.down;
       move.b    _next_mode+1.L,1(A3)
; this_mode.right = next_mode.right;
       move.b    _next_mode.L,(A3)
update_next_enemy_1:
; }
; clear_sprite(enemy_bitmaps[enemies[enemy_index].shape], enemies[enemy_index].x, enemies[enemy_index].y);
       move.b    _enemy_index.L,D1
       and.l     #255,D1
       muls      #3,D1
       lea       0(A2,D1.L),A0
       move.b    1(A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.b    _enemy_index.L,D1
       and.l     #255,D1
       muls      #3,D1
       move.b    0(A2,D1.L),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.b    _enemy_index.L,D1
       and.l     #255,D1
       muls      #3,D1
       lea       0(A2,D1.L),A0
       move.b    2(A0),D1
       and.l     #255,D1
       lsl.l     #2,D1
       lea       _enemy_bitmaps.L,A0
       move.l    0(A0,D1.L),-(A7)
       jsr       _clear_sprite
       add.w     #12,A7
; if (this_mode.down) {
       tst.b     1(A3)
       beq       update_next_enemy_3
; // if too close to ground, end game
; enemies[enemy_index].y = enemies[enemy_index].y-1;
       move.b    _enemy_index.L,D0
       and.l     #255,D0
       muls      #3,D0
       lea       0(A2,D0.L),A0
       move.b    1(A0),D0
       subq.b    #1,D0
       move.b    _enemy_index.L,D1
       and.l     #255,D1
       muls      #3,D1
       lea       0(A2,D1.L),A0
       move.b    D0,1(A0)
; if (enemies[enemy_index].y < 5) {
       move.b    _enemy_index.L,D0
       and.l     #255,D0
       muls      #3,D0
       lea       0(A2,D0.L),A0
       move.b    1(A0),D0
       cmp.b     #5,D0
       bhs.s     update_next_enemy_5
; destroy_player();
       jsr       _destroy_player
; lives = 0;
       clr.b     _lives.L
update_next_enemy_5:
; }
; next_mode.down = 0;
       clr.b     _next_mode+1.L
       bra       update_next_enemy_11
update_next_enemy_3:
; } else {
; if (this_mode.right) {
       tst.b     (A3)
       beq.s     update_next_enemy_7
; enemies[enemy_index].x += 2;
       move.b    _enemy_index.L,D0
       and.l     #255,D0
       muls      #3,D0
       addq.b    #2,0(A2,D0.L)
; if (enemies[enemy_index].x >= 200) {
       move.b    _enemy_index.L,D0
       and.l     #255,D0
       muls      #3,D0
       move.b    0(A2,D0.L),D0
       and.w     #255,D0
       cmp.w     #200,D0
       blo.s     update_next_enemy_9
; next_mode.down = 1;
       move.b    #1,_next_mode+1.L
; next_mode.right = 0;
       clr.b     _next_mode.L
update_next_enemy_9:
       bra.s     update_next_enemy_11
update_next_enemy_7:
; }
; } else {
; enemies[enemy_index].x -= 2;
       move.b    _enemy_index.L,D0
       and.l     #255,D0
       muls      #3,D0
       subq.b    #2,0(A2,D0.L)
; if (enemies[enemy_index].x == 0) {
       move.b    _enemy_index.L,D0
       and.l     #255,D0
       muls      #3,D0
       move.b    0(A2,D0.L),D0
       bne.s     update_next_enemy_11
; next_mode.down = 1;
       move.b    #1,_next_mode+1.L
; next_mode.right = 1;
       move.b    #1,_next_mode.L
update_next_enemy_11:
; }
; }
; }
; draw_sprite(enemy_bitmaps[enemies[enemy_index].shape], enemies[enemy_index].x, enemies[enemy_index].y);
       move.b    _enemy_index.L,D1
       and.l     #255,D1
       muls      #3,D1
       lea       0(A2,D1.L),A0
       move.b    1(A0),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.b    _enemy_index.L,D1
       and.l     #255,D1
       muls      #3,D1
       move.b    0(A2,D1.L),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.b    _enemy_index.L,D1
       and.l     #255,D1
       muls      #3,D1
       lea       0(A2,D1.L),A0
       move.b    2(A0),D1
       and.l     #255,D1
       lsl.l     #2,D1
       lea       _enemy_bitmaps.L,A0
       move.l    0(A0,D1.L),-(A7)
       jsr       _draw_sprite
       add.w     #12,A7
; enemy_index++;
       addq.b    #1,_enemy_index.L
       movem.l   (A7)+,A2/A3
       rts
; }
; void draw_bunker(byte x, byte y, byte y2, byte h, byte w) {
       xdef      _draw_bunker
_draw_bunker:
       link      A6,#0
       movem.l   D2/D3/D4/D5/D6/A2,-(A7)
       move.b    15(A6),D3
       and.l     #255,D3
       move.b    23(A6),D4
       and.l     #255,D4
       move.b    11(A6),D5
       and.l     #255,D5
       move.b    19(A6),D6
       and.l     #255,D6
       lea       _draw_vline.L,A2
; byte i;
; for (i=0; i<h; i++) {
       clr.b     D2
draw_bunker_1:
       cmp.b     D4,D2
       bhs       draw_bunker_3
; draw_vline(x+i, y+i, y+y2+i*2);
       move.b    D3,D1
       add.b     D6,D1
       move.l    D0,-(A7)
       move.b    D2,D0
       and.w     #255,D0
       mulu.w    #2,D0
       add.b     D0,D1
       move.l    (A7)+,D0
       and.l     #255,D1
       move.l    D1,-(A7)
       move.b    D3,D1
       add.b     D2,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.b    D5,D1
       add.b     D2,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       (A2)
       add.w     #12,A7
; draw_vline(x+h*2+w-i-1, y+i, y+y2+i*2);
       move.b    D3,D1
       add.b     D6,D1
       move.l    D0,-(A7)
       move.b    D2,D0
       and.w     #255,D0
       mulu.w    #2,D0
       add.b     D0,D1
       move.l    (A7)+,D0
       and.l     #255,D1
       move.l    D1,-(A7)
       move.b    D3,D1
       add.b     D2,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.b    D5,D1
       move.l    D0,-(A7)
       move.b    D4,D0
       and.w     #255,D0
       mulu.w    #2,D0
       add.b     D0,D1
       move.l    (A7)+,D0
       add.b     27(A6),D1
       sub.b     D2,D1
       subq.b    #1,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       (A2)
       add.w     #12,A7
       addq.b    #1,D2
       bra       draw_bunker_1
draw_bunker_3:
; }
; for (i=0; i<w; i++) {
       clr.b     D2
draw_bunker_4:
       cmp.b     27(A6),D2
       bhs       draw_bunker_6
; draw_vline(x+h+i, y+h, y+y2+h*2);
       move.b    D3,D1
       add.b     D6,D1
       move.l    D0,-(A7)
       move.b    D4,D0
       and.w     #255,D0
       mulu.w    #2,D0
       add.b     D0,D1
       move.l    (A7)+,D0
       and.l     #255,D1
       move.l    D1,-(A7)
       move.b    D3,D1
       add.b     D4,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.b    D5,D1
       add.b     D4,D1
       add.b     D2,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       (A2)
       add.w     #12,A7
       addq.b    #1,D2
       bra       draw_bunker_4
draw_bunker_6:
       movem.l   (A7)+,D2/D3/D4/D5/D6/A2
       unlk      A6
       rts
; }
; }
; void draw_playfield() {
       xdef      _draw_playfield
_draw_playfield:
       move.l    D2,-(A7)
; byte i;
; clrscr();
       jsr       _clrscr
; draw_string("PLAYER 1", 0, 31);
       pea       31
       clr.l     -(A7)
       pea       @cosmic~1_1.L
       jsr       _draw_string
       add.w     #12,A7
; draw_score(0);
       clr.l     -(A7)
       jsr       _draw_score
       addq.w    #4,A7
; draw_lives(0);
       clr.l     -(A7)
       jsr       _draw_lives
       addq.w    #4,A7
; for (i=0; i<224; i++) {
       clr.b     D2
draw_playfield_1:
       and.w     #255,D2
       cmp.w     #224,D2
       bhs.s     draw_playfield_3
; WRITE_VIDMEM(i,0,0x7f & 0x55);
       move.l    #16777216,D0
       and.l     #255,D2
       add.l     D2,D0
       move.l    D0,A0
       move.b    #85,(A0)
       addq.b    #1,D2
       bra       draw_playfield_1
draw_playfield_3:
; }
; draw_bunker(30, 40, 15, 15, 20);
       pea       20
       pea       15
       pea       15
       pea       40
       pea       30
       jsr       _draw_bunker
       add.w     #20,A7
; draw_bunker(140, 40, 15, 15, 20);
       pea       20
       pea       15
       pea       15
       pea       40
       pea       140
       jsr       _draw_bunker
       add.w     #20,A7
       move.l    (A7)+,D2
       rts
; }
; char in_rect(e, x, y, w, h)
; Enemy *e;
; byte x, y, w, h;
; {
       xdef      _in_rect
_in_rect:
       link      A6,#-4
       move.l    D2,-(A7)
       move.l    8(A6),D2
; byte eh, ew;
; eh = enemy_bitmaps[e->shape][0];
       move.l    D2,A0
       move.b    2(A0),D0
       and.l     #255,D0
       lsl.l     #2,D0
       lea       _enemy_bitmaps.L,A0
       move.l    0(A0,D0.L),A0
       move.b    (A0),-2(A6)
; ew = enemy_bitmaps[e->shape][1];
       move.l    D2,A0
       move.b    2(A0),D0
       and.l     #255,D0
       lsl.l     #2,D0
       lea       _enemy_bitmaps.L,A0
       move.l    0(A0,D0.L),A0
       move.b    1(A0),-1(A6)
; return (x >= e->x - w && x <= e->x + ew && y >= e->y - h && y <= e->y + eh);
       move.l    D2,A0
       move.b    (A0),D0
       sub.b     23(A6),D0
       cmp.b     15(A6),D0
       bhi       in_rect_1
       move.l    D2,A0
       move.b    (A0),D0
       add.b     -1(A6),D0
       cmp.b     15(A6),D0
       blo.s     in_rect_1
       move.l    D2,A0
       move.b    1(A0),D0
       sub.b     27(A6),D0
       cmp.b     19(A6),D0
       bhi.s     in_rect_1
       move.l    D2,A0
       move.b    1(A0),D0
       add.b     -2(A6),D0
       cmp.b     19(A6),D0
       blo.s     in_rect_1
       moveq     #1,D0
       bra.s     in_rect_2
in_rect_1:
       clr.l     D0
in_rect_2:
       move.l    (A7)+,D2
       unlk      A6
       rts
; }
; Enemy *find_enemy_at(x, y)
; byte x, y;
; {
       xdef      _find_enemy_at
_find_enemy_at:
       link      A6,#0
       movem.l   D2/D3,-(A7)
; byte i;
; Enemy *e;
; for (i = 0; i < num_enemies; i++) {
       clr.b     D2
find_enemy_at_1:
       cmp.b     _num_enemies.L,D2
       bhs       find_enemy_at_3
; e = &enemies[i];
       lea       _enemies.L,A0
       and.l     #255,D2
       move.l    D2,D0
       muls      #3,D0
       add.l     D0,A0
       move.l    A0,D3
; if (in_rect(e, x, y, 2, 0)) {
       clr.l     -(A7)
       pea       2
       move.b    15(A6),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.b    11(A6),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    D3,-(A7)
       jsr       _in_rect
       add.w     #20,A7
       tst.b     D0
       beq.s     find_enemy_at_4
; return e;
       move.l    D3,D0
       bra.s     find_enemy_at_6
find_enemy_at_4:
       addq.b    #1,D2
       bra       find_enemy_at_1
find_enemy_at_3:
; }
; }
; return NULL;
       clr.l     D0
find_enemy_at_6:
       movem.l   (A7)+,D2/D3
       unlk      A6
       rts
; }
; void check_bullet_hit(x, y)
; byte x, y;
; {
       xdef      _check_bullet_hit
_check_bullet_hit:
       link      A6,#0
       move.l    D2,-(A7)
; Enemy *e;
; e = find_enemy_at(x, y);
       move.b    15(A6),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.b    11(A6),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       _find_enemy_at
       addq.w    #8,A7
       move.l    D0,D2
; if (e) {
       tst.l     D2
       beq.s     check_bullet_hit_1
; delete_enemy(e);
       move.l    D2,-(A7)
       jsr       _delete_enemy
       addq.w    #4,A7
; add_score(0x25);
       pea       37
       jsr       _add_score
       addq.w    #4,A7
check_bullet_hit_1:
       move.l    (A7)+,D2
       unlk      A6
       rts
; }
; }
; void fire_bullet()
; {
       xdef      _fire_bullet
_fire_bullet:
; bullet_x = player_x + 13;
       move.b    _player_x.L,D0
       add.b     #13,D0
       move.b    D0,_bullet_x.L
; bullet_y = 3;
       move.b    #3,_bullet_y.L
; xor_sprite(bullet_bitmap, bullet_x, bullet_y); /* Draw bullet */
       move.b    _bullet_y.L,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.b    _bullet_x.L,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       pea       _bullet_bitmap.L
       jsr       _xor_sprite
       add.w     #12,A7
       rts
; }
; void move_bullet()
; {
       xdef      _move_bullet
_move_bullet:
       link      A6,#-4
       move.l    A2,-(A7)
       lea       _bullet_bitmap.L,A2
; byte leftover;
; leftover = xor_sprite(bullet_bitmap, bullet_x, bullet_y); /* Erase bullet */
       move.b    _bullet_y.L,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.b    _bullet_x.L,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    A2,-(A7)
       jsr       _xor_sprite
       add.w     #12,A7
       move.b    D0,-1(A6)
; if (leftover || bullet_y > 26) {
       move.b    -1(A6),D0
       and.l     #255,D0
       bne.s     move_bullet_3
       move.b    _bullet_y.L,D0
       cmp.b     #26,D0
       bls       move_bullet_1
move_bullet_3:
; clear_sprite(bullet_bitmap, bullet_x, bullet_y);
       move.b    _bullet_y.L,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.b    _bullet_x.L,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    A2,-(A7)
       jsr       _clear_sprite
       add.w     #12,A7
; check_bullet_hit(bullet_x, bullet_y + 2);
       move.b    _bullet_y.L,D1
       addq.b    #2,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.b    _bullet_x.L,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       _check_bullet_hit
       addq.w    #8,A7
; bullet_y = 0;
       clr.b     _bullet_y.L
       bra.s     move_bullet_2
move_bullet_1:
; } else {
; bullet_y++;
       addq.b    #1,_bullet_y.L
; xor_sprite(bullet_bitmap, bullet_x, bullet_y); /* Draw bullet */
       move.b    _bullet_y.L,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.b    _bullet_x.L,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    A2,-(A7)
       jsr       _xor_sprite
       add.w     #12,A7
move_bullet_2:
       move.l    (A7)+,A2
       unlk      A6
       rts
; }
; }
; void drop_bomb()
; {
       xdef      _drop_bomb
_drop_bomb:
       move.l    D2,-(A7)
; Enemy *e;
; e = &enemies[enemy_index];
       lea       _enemies.L,A0
       move.b    _enemy_index.L,D0
       and.l     #255,D0
       muls      #3,D0
       add.l     D0,A0
       move.l    A0,D2
; bomb_x = e->x + 7;
       move.l    D2,A0
       move.b    (A0),D0
       addq.b    #7,D0
       move.b    D0,_bomb_x.L
; bomb_y = e->y - 2;
       move.l    D2,A0
       move.b    1(A0),D0
       subq.b    #2,D0
       move.b    D0,_bomb_y.L
; xor_sprite(bomb_bitmap, bomb_x, bomb_y); /* Draw bomb */
       move.b    _bomb_y.L,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.b    _bomb_x.L,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       pea       _bomb_bitmap.L
       jsr       _xor_sprite
       add.w     #12,A7
       move.l    (A7)+,D2
       rts
; }
; void move_bomb()
; {
       xdef      _move_bomb
_move_bomb:
       link      A6,#-4
       move.l    A2,-(A7)
       lea       _bomb_bitmap.L,A2
; byte leftover;
; leftover = xor_sprite(bomb_bitmap, bomb_x, bomb_y); /* Erase bomb */
       move.b    _bomb_y.L,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.b    _bomb_x.L,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    A2,-(A7)
       jsr       _xor_sprite
       add.w     #12,A7
       move.b    D0,-1(A6)
; if (bomb_y < 2) {
       move.b    _bomb_y.L,D0
       cmp.b     #2,D0
       bhs.s     move_bomb_1
; bomb_y = 0;
       clr.b     _bomb_y.L
       bra       move_bomb_4
move_bomb_1:
; } else if (leftover) {
       tst.b     -1(A6)
       beq.s     move_bomb_3
; erase_sprite(bomb_bitmap, bomb_x, bomb_y); /* Erase bunker */
       move.b    _bomb_y.L,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.b    _bomb_x.L,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    A2,-(A7)
       jsr       _erase_sprite
       add.w     #12,A7
; if (bomb_y < 3) {
       move.b    _bomb_y.L,D0
       cmp.b     #3,D0
       bhs.s     move_bomb_5
; /* Player was hit (probably) */
; destroy_player();
       jsr       _destroy_player
move_bomb_5:
; }
; bomb_y = 0;
       clr.b     _bomb_y.L
       bra.s     move_bomb_4
move_bomb_3:
; } else {
; bomb_y--;
       subq.b    #1,_bomb_y.L
; xor_sprite(bomb_bitmap, bomb_x, bomb_y); /* Draw bomb */
       move.b    _bomb_y.L,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.b    _bomb_x.L,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.l    A2,-(A7)
       jsr       _xor_sprite
       add.w     #12,A7
move_bomb_4:
       move.l    (A7)+,A2
       unlk      A6
       rts
; }
; }
; byte frame;
; void play_round() {
       xdef      _play_round
_play_round:
; draw_playfield();
       jsr       _draw_playfield
; player_x = 96;
       move.b    #96,_player_x.L
; bullet_y = 0;
       clr.b     _bullet_y.L
; bomb_y = 0;
       clr.b     _bomb_y.L
; frame = 0;
       clr.b     _frame.L
; while (player_x != 0xff && num_enemies) {
play_round_1:
       move.b    _player_x.L,D0
       and.w     #255,D0
       cmp.w     #255,D0
       beq       play_round_3
       move.b    _num_enemies.L,D0
       and.l     #255,D0
       beq       play_round_3
; delay_ms(COSMIC_IMPALAS_TIMER_DELAY_MS);
       pea       50
       jsr       _delay_ms
       addq.w    #4,A7
; move_player();
       jsr       _move_player
; if (bullet_y) {
       tst.b     _bullet_y.L
       beq.s     play_round_4
; move_bullet();
       jsr       _move_bullet
play_round_4:
; }
; update_next_enemy();
       jsr       _update_next_enemy
; if (frame & 1) {
       move.b    _frame.L,D0
       and.b     #1,D0
       beq.s     play_round_9
; if (bomb_y == 0) {
       move.b    _bomb_y.L,D0
       bne.s     play_round_8
; drop_bomb();
       jsr       _drop_bomb
       bra.s     play_round_9
play_round_8:
; } else {
; move_bomb();
       jsr       _move_bomb
play_round_9:
; }
; }
; frame++;
       addq.b    #1,_frame.L
       bra       play_round_1
play_round_3:
       rts
; }
; }
; void init_game() {
       xdef      _init_game
_init_game:
; score = 0;
       clr.w     _score.L
; lives = MAXLIVES;
       move.b    #5,_lives.L
; curplayer = 0;
       clr.b     _curplayer.L
       rts
; }
; void game_over_msg() {
       xdef      _game_over_msg
_game_over_msg:
       movem.l   D2/A2,-(A7)
       lea       _draw_string.L,A2
; byte i;
; for (i=0; i<50; i++) {
       clr.b     D2
game_over_msg_1:
       cmp.b     #50,D2
       bhs       game_over_msg_3
; draw_string(" *************** ", 5, 15);
       pea       15
       pea       5
       pea       @cosmic~1_2.L
       jsr       (A2)
       add.w     #12,A7
; draw_string("***           ***", 5, 16);
       pea       16
       pea       5
       pea       @cosmic~1_3.L
       jsr       (A2)
       add.w     #12,A7
; draw_string("**  GAME OVER  **", 5, 17);
       pea       17
       pea       5
       pea       @cosmic~1_4.L
       jsr       (A2)
       add.w     #12,A7
; draw_string("***           ***", 5, 18);
       pea       18
       pea       5
       pea       @cosmic~1_5.L
       jsr       (A2)
       add.w     #12,A7
; draw_string(" *************** ", 5, 19);
       pea       19
       pea       5
       pea       @cosmic~1_6.L
       jsr       (A2)
       add.w     #12,A7
       addq.b    #1,D2
       bra       game_over_msg_1
game_over_msg_3:
       movem.l   (A7)+,D2/A2
       rts
; }
; }
; void play_game() {
       xdef      _play_game
_play_game:
; attract = 0;
       clr.b     _attract.L
; init_game();
       jsr       _init_game
; init_enemies();
       jsr       _init_enemies
; while (lives) {
play_game_1:
       tst.b     _lives.L
       beq.s     play_game_3
; play_round();
       jsr       _play_round
; if (num_enemies == 0) {
       move.b    _num_enemies.L,D0
       bne.s     play_game_4
; init_enemies();
       jsr       _init_enemies
play_game_4:
       bra       play_game_1
play_game_3:
; }
; }
; game_over_msg();
       jsr       _game_over_msg
       rts
; }
; void attract_mode() {
       xdef      _attract_mode
_attract_mode:
; attract = 1;
       move.b    #1,_attract.L
; while (1) {
attract_mode_1:
; init_enemies();
       jsr       _init_enemies
; play_round();
       jsr       _play_round
       bra       attract_mode_1
; }
; }
; void initialize_all_bitmaps() {
       xdef      _initialize_all_bitmaps
_initialize_all_bitmaps:
       movem.l   A2/A3/A4/A5,-(A7)
       lea       _font8x8.L,A2
       lea       _player_bitmap.L,A3
       lea       _enemy4_bitmap.L,A4
       lea       _enemy3_bitmap.L,A5
; /* Initialize player_bitmap */
; player_bitmap[0] = 2;
       move.b    #2,(A3)
; player_bitmap[1] = 27;
       move.b    #27,1(A3)
; player_bitmap[2] = 0x00;
       clr.b     2(A3)
; player_bitmap[3] = 0x00;
       clr.b     3(A3)
; player_bitmap[4] = 0x00;
       clr.b     4(A3)
; player_bitmap[5] = 0x00;
       clr.b     5(A3)
; player_bitmap[6] = 0x0F;
       move.b    #15,6(A3)
; player_bitmap[7] = 0x00;
       clr.b     7(A3)
; player_bitmap[8] = 0x3E;
       move.b    #62,8(A3)
; player_bitmap[9] = 0x00;
       clr.b     9(A3)
; player_bitmap[10] = 0xF4;
       move.b    #244,10(A3)
; player_bitmap[11] = 0x07;
       move.b    #7,11(A3)
; player_bitmap[12] = 0xEC;
       move.b    #236,12(A3)
; player_bitmap[13] = 0x00;
       clr.b     13(A3)
; player_bitmap[14] = 0x76;
       move.b    #118,14(A3)
; player_bitmap[15] = 0x00;
       clr.b     15(A3)
; player_bitmap[16] = 0x2B;
       move.b    #43,16(A3)
; player_bitmap[17] = 0x00;
       clr.b     17(A3)
; player_bitmap[18] = 0x33;
       move.b    #51,18(A3)
; player_bitmap[19] = 0x00;
       clr.b     19(A3)
; player_bitmap[20] = 0x75;
       move.b    #117,20(A3)
; player_bitmap[21] = 0x00;
       clr.b     21(A3)
; player_bitmap[22] = 0xF5;
       move.b    #245,22(A3)
; player_bitmap[23] = 0x00;
       clr.b     23(A3)
; player_bitmap[24] = 0xEB;
       move.b    #235,24(A3)
; player_bitmap[25] = 0x31;
       move.b    #49,25(A3)
; player_bitmap[26] = 0xBF;
       move.b    #191,26(A3)
; player_bitmap[27] = 0xEF;
       move.b    #239,27(A3)
; player_bitmap[28] = 0x3F;
       move.b    #63,28(A3)
; player_bitmap[29] = 0xCF;
       move.b    #207,29(A3)
; player_bitmap[30] = 0xBF;
       move.b    #191,30(A3)
; player_bitmap[31] = 0xEF;
       move.b    #239,31(A3)
; player_bitmap[32] = 0xEB;
       move.b    #235,32(A3)
; player_bitmap[33] = 0x31;
       move.b    #49,33(A3)
; player_bitmap[34] = 0xF5;
       move.b    #245,34(A3)
; player_bitmap[35] = 0x00;
       clr.b     35(A3)
; player_bitmap[36] = 0x75;
       move.b    #117,36(A3)
; player_bitmap[37] = 0x00;
       clr.b     37(A3)
; player_bitmap[38] = 0x33;
       move.b    #51,38(A3)
; player_bitmap[39] = 0x00;
       clr.b     39(A3)
; player_bitmap[40] = 0x2B;
       move.b    #43,40(A3)
; player_bitmap[41] = 0x00;
       clr.b     41(A3)
; player_bitmap[42] = 0x76;
       move.b    #118,42(A3)
; player_bitmap[43] = 0x00;
       clr.b     43(A3)
; player_bitmap[44] = 0xEC;
       move.b    #236,44(A3)
; player_bitmap[45] = 0x00;
       clr.b     45(A3)
; player_bitmap[46] = 0xF4;
       move.b    #244,46(A3)
; player_bitmap[47] = 0x07;
       move.b    #7,47(A3)
; player_bitmap[48] = 0x3E;
       move.b    #62,48(A3)
; player_bitmap[49] = 0x00;
       clr.b     49(A3)
; player_bitmap[50] = 0x0F;
       move.b    #15,50(A3)
; player_bitmap[51] = 0x00;
       clr.b     51(A3)
; player_bitmap[52] = 0x00;
       clr.b     52(A3)
; player_bitmap[53] = 0x00;
       clr.b     53(A3)
; player_bitmap[54] = 0x00;
       clr.b     54(A3)
; player_bitmap[55] = 0x00;
       clr.b     55(A3)
; /* Initialize bomb_bitmap */
; bomb_bitmap[0] = 1;
       move.b    #1,_bomb_bitmap.L
; bomb_bitmap[1] = 5;
       move.b    #5,_bomb_bitmap+1.L
; bomb_bitmap[2] = 0x88;
       move.b    #136,_bomb_bitmap+2.L
; bomb_bitmap[3] = 0x55;
       move.b    #85,_bomb_bitmap+3.L
; bomb_bitmap[4] = 0x77;
       move.b    #119,_bomb_bitmap+4.L
; bomb_bitmap[5] = 0x55;
       move.b    #85,_bomb_bitmap+5.L
; bomb_bitmap[6] = 0x88;
       move.b    #136,_bomb_bitmap+6.L
; /* Initialize bullet_bitmap */
; bullet_bitmap[0] = 2;
       move.b    #2,_bullet_bitmap.L
; bullet_bitmap[1] = 2;
       move.b    #2,_bullet_bitmap+1.L
; bullet_bitmap[2] = 0x88;
       move.b    #136,_bullet_bitmap+2.L
; bullet_bitmap[3] = 0x88;
       move.b    #136,_bullet_bitmap+3.L
; bullet_bitmap[4] = 0x44;
       move.b    #68,_bullet_bitmap+4.L
; bullet_bitmap[5] = 0x44;
       move.b    #68,_bullet_bitmap+5.L
; /* Initialize enemy1_bitmap */
; enemy1_bitmap[0] = 2;
       move.b    #2,_enemy1_bitmap.L
; enemy1_bitmap[1] = 17;
       move.b    #17,_enemy1_bitmap+1.L
; enemy1_bitmap[2] = 0x00;
       clr.b     _enemy1_bitmap+2.L
; enemy1_bitmap[3] = 0x00;
       clr.b     _enemy1_bitmap+3.L
; enemy1_bitmap[4] = 0x00;
       clr.b     _enemy1_bitmap+4.L
; enemy1_bitmap[5] = 0x0C;
       move.b    #12,_enemy1_bitmap+5.L
; enemy1_bitmap[6] = 0x04;
       move.b    #4,_enemy1_bitmap+6.L
; enemy1_bitmap[7] = 0x1E;
       move.b    #30,_enemy1_bitmap+7.L
; enemy1_bitmap[8] = 0x46;
       move.b    #70,_enemy1_bitmap+8.L
; enemy1_bitmap[9] = 0x3F;
       move.b    #63,_enemy1_bitmap+9.L
; enemy1_bitmap[10] = 0xB8;
       move.b    #184,_enemy1_bitmap+10.L
; enemy1_bitmap[11] = 0x7F;
       move.b    #127,_enemy1_bitmap+11.L
; enemy1_bitmap[12] = 0xB0;
       move.b    #176,_enemy1_bitmap+12.L
; enemy1_bitmap[13] = 0x7F;
       move.b    #127,_enemy1_bitmap+13.L
; enemy1_bitmap[14] = 0xBA;
       move.b    #186,_enemy1_bitmap+14.L
; enemy1_bitmap[15] = 0x7F;
       move.b    #127,_enemy1_bitmap+15.L
; enemy1_bitmap[16] = 0xFD;
       move.b    #253,_enemy1_bitmap+16.L
; enemy1_bitmap[17] = 0x3F;
       move.b    #63,_enemy1_bitmap+17.L
; enemy1_bitmap[18] = 0xFC;
       move.b    #252,_enemy1_bitmap+18.L
; enemy1_bitmap[19] = 0x07;
       move.b    #7,_enemy1_bitmap+19.L
; enemy1_bitmap[20] = 0xFC;
       move.b    #252,_enemy1_bitmap+20.L
; enemy1_bitmap[21] = 0x07;
       move.b    #7,_enemy1_bitmap+21.L
; enemy1_bitmap[22] = 0xFD;
       move.b    #253,_enemy1_bitmap+22.L
; enemy1_bitmap[23] = 0x3F;
       move.b    #63,_enemy1_bitmap+23.L
; enemy1_bitmap[24] = 0xBA;
       move.b    #186,_enemy1_bitmap+24.L
; enemy1_bitmap[25] = 0x7F;
       move.b    #127,_enemy1_bitmap+25.L
; enemy1_bitmap[26] = 0xB0;
       move.b    #176,_enemy1_bitmap+26.L
; enemy1_bitmap[27] = 0x7F;
       move.b    #127,_enemy1_bitmap+27.L
; enemy1_bitmap[28] = 0xB8;
       move.b    #184,_enemy1_bitmap+28.L
; enemy1_bitmap[29] = 0x7F;
       move.b    #127,_enemy1_bitmap+29.L
; enemy1_bitmap[30] = 0x46;
       move.b    #70,_enemy1_bitmap+30.L
; enemy1_bitmap[31] = 0x3F;
       move.b    #63,_enemy1_bitmap+31.L
; enemy1_bitmap[32] = 0x04;
       move.b    #4,_enemy1_bitmap+32.L
; enemy1_bitmap[33] = 0x1E;
       move.b    #30,_enemy1_bitmap+33.L
; /* Initialize enemy2_bitmap */
; enemy2_bitmap[0] = 2;
       move.b    #2,_enemy2_bitmap.L
; enemy2_bitmap[1] = 16;
       move.b    #16,_enemy2_bitmap+1.L
; enemy2_bitmap[2] = 0x26;
       move.b    #38,_enemy2_bitmap+2.L
; enemy2_bitmap[3] = 0x00;
       clr.b     _enemy2_bitmap+3.L
; enemy2_bitmap[4] = 0x59;
       move.b    #89,_enemy2_bitmap+4.L
; enemy2_bitmap[5] = 0x10;
       move.b    #16,_enemy2_bitmap+5.L
; enemy2_bitmap[6] = 0x10;
       move.b    #16,_enemy2_bitmap+6.L
; enemy2_bitmap[7] = 0x30;
       move.b    #48,_enemy2_bitmap+7.L
; enemy2_bitmap[8] = 0x33;
       move.b    #51,_enemy2_bitmap+8.L
; enemy2_bitmap[9] = 0x18;
       move.b    #24,_enemy2_bitmap+9.L
; enemy2_bitmap[10] = 0xE6;
       move.b    #230,_enemy2_bitmap+10.L
; enemy2_bitmap[11] = 0x61;
       move.b    #97,_enemy2_bitmap+11.L
; enemy2_bitmap[12] = 0xC4;
       move.b    #196,_enemy2_bitmap+12.L
; enemy2_bitmap[13] = 0x56;
       move.b    #86,_enemy2_bitmap+13.L
; enemy2_bitmap[14] = 0x03;
       move.b    #3,_enemy2_bitmap+14.L
; enemy2_bitmap[15] = 0x03;
       move.b    #3,_enemy2_bitmap+15.L
; enemy2_bitmap[16] = 0xDC;
       move.b    #220,_enemy2_bitmap+16.L
; enemy2_bitmap[17] = 0x03;
       move.b    #3,_enemy2_bitmap+17.L
; enemy2_bitmap[18] = 0xDC;
       move.b    #220,_enemy2_bitmap+18.L
; enemy2_bitmap[19] = 0x03;
       move.b    #3,_enemy2_bitmap+19.L
; enemy2_bitmap[20] = 0x03;
       move.b    #3,_enemy2_bitmap+20.L
; enemy2_bitmap[21] = 0x03;
       move.b    #3,_enemy2_bitmap+21.L
; enemy2_bitmap[22] = 0xC4;
       move.b    #196,_enemy2_bitmap+22.L
; enemy2_bitmap[23] = 0x56;
       move.b    #86,_enemy2_bitmap+23.L
; enemy2_bitmap[24] = 0xE6;
       move.b    #230,_enemy2_bitmap+24.L
; enemy2_bitmap[25] = 0x61;
       move.b    #97,_enemy2_bitmap+25.L
; enemy2_bitmap[26] = 0x33;
       move.b    #51,_enemy2_bitmap+26.L
; enemy2_bitmap[27] = 0x18;
       move.b    #24,_enemy2_bitmap+27.L
; enemy2_bitmap[28] = 0x10;
       move.b    #16,_enemy2_bitmap+28.L
; enemy2_bitmap[29] = 0x30;
       move.b    #48,_enemy2_bitmap+29.L
; enemy2_bitmap[30] = 0x59;
       move.b    #89,_enemy2_bitmap+30.L
; enemy2_bitmap[31] = 0x10;
       move.b    #16,_enemy2_bitmap+31.L
; enemy2_bitmap[32] = 0x26;
       move.b    #38,_enemy2_bitmap+32.L
; enemy2_bitmap[33] = 0x00;
       clr.b     _enemy2_bitmap+33.L
; /* Initialize enemy3_bitmap */
; enemy3_bitmap[0] = 2;
       move.b    #2,(A5)
; enemy3_bitmap[1] = 16;
       move.b    #16,1(A5)
; enemy3_bitmap[2] = 0x80;
       move.b    #128,2(A5)
; enemy3_bitmap[3] = 0x1F;
       move.b    #31,3(A5)
; enemy3_bitmap[4] = 0xC0;
       move.b    #192,4(A5)
; enemy3_bitmap[5] = 0x03;
       move.b    #3,5(A5)
; enemy3_bitmap[6] = 0xF8;
       move.b    #248,6(A5)
; enemy3_bitmap[7] = 0x3F;
       move.b    #63,7(A5)
; enemy3_bitmap[8] = 0x70;
       move.b    #112,8(A5)
; enemy3_bitmap[9] = 0x00;
       clr.b     9(A5)
; enemy3_bitmap[10] = 0xF0;
       move.b    #240,10(A5)
; enemy3_bitmap[11] = 0x01;
       move.b    #1,11(A5)
; enemy3_bitmap[12] = 0xFC;
       move.b    #252,12(A5)
; enemy3_bitmap[13] = 0x07;
       move.b    #7,13(A5)
; enemy3_bitmap[14] = 0xE8;
       move.b    #232,14(A5)
; enemy3_bitmap[15] = 0x01;
       move.b    #1,15(A5)
; enemy3_bitmap[16] = 0xF8;
       move.b    #248,16(A5)
; enemy3_bitmap[17] = 0x03;
       move.b    #3,17(A5)
; enemy3_bitmap[18] = 0xF8;
       move.b    #248,18(A5)
; enemy3_bitmap[19] = 0x03;
       move.b    #3,19(A5)
; enemy3_bitmap[20] = 0xE8;
       move.b    #232,20(A5)
; enemy3_bitmap[21] = 0x01;
       move.b    #1,21(A5)
; enemy3_bitmap[22] = 0xF8;
       move.b    #248,22(A5)
; enemy3_bitmap[23] = 0x07;
       move.b    #7,23(A5)
; enemy3_bitmap[24] = 0xF0;
       move.b    #240,24(A5)
; enemy3_bitmap[25] = 0x01;
       move.b    #1,25(A5)
; enemy3_bitmap[26] = 0x70;
       move.b    #112,26(A5)
; enemy3_bitmap[27] = 0x00;
       clr.b     27(A5)
; enemy3_bitmap[28] = 0xF8;
       move.b    #248,28(A5)
; enemy3_bitmap[29] = 0x3F;
       move.b    #63,29(A5)
; enemy3_bitmap[30] = 0xC0;
       move.b    #192,30(A5)
; enemy3_bitmap[31] = 0x03;
       move.b    #3,31(A5)
; enemy3_bitmap[32] = 0x80;
       move.b    #128,32(A5)
; enemy3_bitmap[33] = 0x1F;
       move.b    #31,33(A5)
; /* Initialize enemy4_bitmap */
; enemy4_bitmap[0] = 2;
       move.b    #2,(A4)
; enemy4_bitmap[1] = 16;
       move.b    #16,1(A4)
; enemy4_bitmap[2] = 0x06;
       move.b    #6,2(A4)
; enemy4_bitmap[3] = 0x00;
       clr.b     3(A4)
; enemy4_bitmap[4] = 0x0C;
       move.b    #12,4(A4)
; enemy4_bitmap[5] = 0x00;
       clr.b     5(A4)
; enemy4_bitmap[6] = 0x28;
       move.b    #40,6(A4)
; enemy4_bitmap[7] = 0x00;
       clr.b     7(A4)
; enemy4_bitmap[8] = 0x70;
       move.b    #112,8(A4)
; enemy4_bitmap[9] = 0x1F;
       move.b    #31,9(A4)
; enemy4_bitmap[10] = 0x84;
       move.b    #132,10(A4)
; enemy4_bitmap[11] = 0x3F;
       move.b    #63,11(A4)
; enemy4_bitmap[12] = 0xDE;
       move.b    #222,12(A4)
; enemy4_bitmap[13] = 0x37;
       move.b    #55,13(A4)
; enemy4_bitmap[14] = 0xBB;
       move.b    #187,14(A4)
; enemy4_bitmap[15] = 0x3F;
       move.b    #63,15(A4)
; enemy4_bitmap[16] = 0xF0;
       move.b    #240,16(A4)
; enemy4_bitmap[17] = 0x3F;
       move.b    #63,17(A4)
; enemy4_bitmap[18] = 0xF0;
       move.b    #240,18(A4)
; enemy4_bitmap[19] = 0x3F;
       move.b    #63,19(A4)
; enemy4_bitmap[20] = 0xBB;
       move.b    #187,20(A4)
; enemy4_bitmap[21] = 0x3F;
       move.b    #63,21(A4)
; enemy4_bitmap[22] = 0xDE;
       move.b    #222,22(A4)
; enemy4_bitmap[23] = 0x37;
       move.b    #55,23(A4)
; enemy4_bitmap[24] = 0x84;
       move.b    #132,24(A4)
; enemy4_bitmap[25] = 0x3F;
       move.b    #63,25(A4)
; enemy4_bitmap[26] = 0x70;
       move.b    #112,26(A4)
; enemy4_bitmap[27] = 0x1F;
       move.b    #31,27(A4)
; enemy4_bitmap[28] = 0x28;
       move.b    #40,28(A4)
; enemy4_bitmap[29] = 0x00;
       clr.b     29(A4)
; enemy4_bitmap[30] = 0x0C;
       move.b    #12,30(A4)
; enemy4_bitmap[31] = 0x00;
       clr.b     31(A4)
; enemy4_bitmap[32] = 0x06;
       move.b    #6,32(A4)
; enemy4_bitmap[33] = 0x00;
       clr.b     33(A4)
; enemy_bitmaps[0] = enemy1_bitmap;
       lea       _enemy1_bitmap.L,A0
       move.l    A0,_enemy_bitmaps.L
; enemy_bitmaps[1] = enemy2_bitmap;
       lea       _enemy2_bitmap.L,A0
       move.l    A0,_enemy_bitmaps+4.L
; enemy_bitmaps[2] = enemy3_bitmap;
       move.l    A5,_enemy_bitmaps+8.L
; enemy_bitmaps[3] = enemy4_bitmap;
       move.l    A4,_enemy_bitmaps+12.L
; font8x8[0 ][0]=0x00;font8x8[0 ][1]=0x00;font8x8[0 ][2]=0x00;font8x8[0 ][3]=0x00;font8x8[0 ][4]=0x00;font8x8[0 ][5]=0x00;font8x8[0 ][6]=0x00;font8x8[0 ][7]=0x00;
       clr.b     (A2)
       clr.b     1(A2)
       clr.b     2(A2)
       clr.b     3(A2)
       clr.b     4(A2)
       clr.b     5(A2)
       clr.b     6(A2)
       clr.b     7(A2)
; font8x8[1 ][0]=0x00;font8x8[1 ][1]=0x00;font8x8[1 ][2]=0x00;font8x8[1 ][3]=0x79;font8x8[1 ][4]=0x79;font8x8[1 ][5]=0x00;font8x8[1 ][6]=0x00;font8x8[1 ][7]=0x00;
       clr.b     8(A2)
       clr.b     8+1(A2)
       clr.b     8+2(A2)
       move.b    #121,8+3(A2)
       move.b    #121,8+4(A2)
       clr.b     8+5(A2)
       clr.b     8+6(A2)
       clr.b     8+7(A2)
; font8x8[2 ][0]=0x00;font8x8[2 ][1]=0x70;font8x8[2 ][2]=0x70;font8x8[2 ][3]=0x00;font8x8[2 ][4]=0x00;font8x8[2 ][5]=0x70;font8x8[2 ][6]=0x70;font8x8[2 ][7]=0x00; 
       clr.b     16(A2)
       move.b    #112,16+1(A2)
       move.b    #112,16+2(A2)
       clr.b     16+3(A2)
       clr.b     16+4(A2)
       move.b    #112,16+5(A2)
       move.b    #112,16+6(A2)
       clr.b     16+7(A2)
; font8x8[3 ][0]=0x14;font8x8[3 ][1]=0x7f;font8x8[3 ][2]=0x7f;font8x8[3 ][3]=0x14;font8x8[3 ][4]=0x14;font8x8[3 ][5]=0x7f;font8x8[3 ][6]=0x7f;font8x8[3 ][7]=0x14; 
       move.b    #20,24(A2)
       move.b    #127,24+1(A2)
       move.b    #127,24+2(A2)
       move.b    #20,24+3(A2)
       move.b    #20,24+4(A2)
       move.b    #127,24+5(A2)
       move.b    #127,24+6(A2)
       move.b    #20,24+7(A2)
; font8x8[4 ][0]=0x00;font8x8[4 ][1]=0x12;font8x8[4 ][2]=0x3a;font8x8[4 ][3]=0x6b;font8x8[4 ][4]=0x6b;font8x8[4 ][5]=0x2e;font8x8[4 ][6]=0x24;font8x8[4 ][7]=0x00;
       clr.b     32(A2)
       move.b    #18,32+1(A2)
       move.b    #58,32+2(A2)
       move.b    #107,32+3(A2)
       move.b    #107,32+4(A2)
       move.b    #46,32+5(A2)
       move.b    #36,32+6(A2)
       clr.b     32+7(A2)
; font8x8[5 ][0]=0x00;font8x8[5 ][1]=0x63;font8x8[5 ][2]=0x66;font8x8[5 ][3]=0x0c;font8x8[5 ][4]=0x18;font8x8[5 ][5]=0x33;font8x8[5 ][6]=0x63;font8x8[5 ][7]=0x00; 
       clr.b     40(A2)
       move.b    #99,40+1(A2)
       move.b    #102,40+2(A2)
       move.b    #12,40+3(A2)
       move.b    #24,40+4(A2)
       move.b    #51,40+5(A2)
       move.b    #99,40+6(A2)
       clr.b     40+7(A2)
; font8x8[6 ][0]=0x00;font8x8[6 ][1]=0x26;font8x8[6 ][2]=0x7f;font8x8[6 ][3]=0x59;font8x8[6 ][4]=0x59;font8x8[6 ][5]=0x77;font8x8[6 ][6]=0x27;font8x8[6 ][7]=0x05; 
       clr.b     48(A2)
       move.b    #38,48+1(A2)
       move.b    #127,48+2(A2)
       move.b    #89,48+3(A2)
       move.b    #89,48+4(A2)
       move.b    #119,48+5(A2)
       move.b    #39,48+6(A2)
       move.b    #5,48+7(A2)
; font8x8[7 ][0]=0x00;font8x8[7 ][1]=0x00;font8x8[7 ][2]=0x00;font8x8[7 ][3]=0x10;font8x8[7 ][4]=0x30;font8x8[7 ][5]=0x60;font8x8[7 ][6]=0x40;font8x8[7 ][7]=0x00; 
       clr.b     56(A2)
       clr.b     56+1(A2)
       clr.b     56+2(A2)
       move.b    #16,56+3(A2)
       move.b    #48,56+4(A2)
       move.b    #96,56+5(A2)
       move.b    #64,56+6(A2)
       clr.b     56+7(A2)
; font8x8[8 ][0]=0x00;font8x8[8 ][1]=0x00;font8x8[8 ][2]=0x1c;font8x8[8 ][3]=0x3e;font8x8[8 ][4]=0x63;font8x8[8 ][5]=0x41;font8x8[8 ][6]=0x00;font8x8[8 ][7]=0x00; 
       clr.b     64(A2)
       clr.b     64+1(A2)
       move.b    #28,64+2(A2)
       move.b    #62,64+3(A2)
       move.b    #99,64+4(A2)
       move.b    #65,64+5(A2)
       clr.b     64+6(A2)
       clr.b     64+7(A2)
; font8x8[9 ][0]=0x00;font8x8[9 ][1]=0x00;font8x8[9 ][2]=0x41;font8x8[9 ][3]=0x63;font8x8[9 ][4]=0x3e;font8x8[9 ][5]=0x1c;font8x8[9 ][6]=0x00;font8x8[9 ][7]=0x00; 
       clr.b     72(A2)
       clr.b     72+1(A2)
       move.b    #65,72+2(A2)
       move.b    #99,72+3(A2)
       move.b    #62,72+4(A2)
       move.b    #28,72+5(A2)
       clr.b     72+6(A2)
       clr.b     72+7(A2)
; font8x8[10][0]=0x08;font8x8[10][1]=0x2a;font8x8[10][2]=0x3e;font8x8[10][3]=0x1c;font8x8[10][4]=0x1c;font8x8[10][5]=0x3e;font8x8[10][6]=0x2a;font8x8[10][7]=0x08; 
       move.b    #8,80(A2)
       move.b    #42,80+1(A2)
       move.b    #62,80+2(A2)
       move.b    #28,80+3(A2)
       move.b    #28,80+4(A2)
       move.b    #62,80+5(A2)
       move.b    #42,80+6(A2)
       move.b    #8,80+7(A2)
; font8x8[11][0]=0x00;font8x8[11][1]=0x08;font8x8[11][2]=0x08;font8x8[11][3]=0x3e;font8x8[11][4]=0x3e;font8x8[11][5]=0x08;font8x8[11][6]=0x08;font8x8[11][7]=0x00; 
       clr.b     88(A2)
       move.b    #8,88+1(A2)
       move.b    #8,88+2(A2)
       move.b    #62,88+3(A2)
       move.b    #62,88+4(A2)
       move.b    #8,88+5(A2)
       move.b    #8,88+6(A2)
       clr.b     88+7(A2)
; font8x8[12][0]=0x00;font8x8[12][1]=0x00;font8x8[12][2]=0x00;font8x8[12][3]=0x03;font8x8[12][4]=0x03;font8x8[12][5]=0x00;font8x8[12][6]=0x00;font8x8[12][7]=0x00; 
       clr.b     96(A2)
       clr.b     96+1(A2)
       clr.b     96+2(A2)
       move.b    #3,96+3(A2)
       move.b    #3,96+4(A2)
       clr.b     96+5(A2)
       clr.b     96+6(A2)
       clr.b     96+7(A2)
; font8x8[13][0]=0x00;font8x8[13][1]=0x08;font8x8[13][2]=0x08;font8x8[13][3]=0x08;font8x8[13][4]=0x08;font8x8[13][5]=0x08;font8x8[13][6]=0x08;font8x8[13][7]=0x00; 
       clr.b     104(A2)
       move.b    #8,104+1(A2)
       move.b    #8,104+2(A2)
       move.b    #8,104+3(A2)
       move.b    #8,104+4(A2)
       move.b    #8,104+5(A2)
       move.b    #8,104+6(A2)
       clr.b     104+7(A2)
; font8x8[14][0]=0x00;font8x8[14][1]=0x00;font8x8[14][2]=0x00;font8x8[14][3]=0x03;font8x8[14][4]=0x03;font8x8[14][5]=0x00;font8x8[14][6]=0x00;font8x8[14][7]=0x00; 
       clr.b     112(A2)
       clr.b     112+1(A2)
       clr.b     112+2(A2)
       move.b    #3,112+3(A2)
       move.b    #3,112+4(A2)
       clr.b     112+5(A2)
       clr.b     112+6(A2)
       clr.b     112+7(A2)
; font8x8[15][0]=0x00;font8x8[15][1]=0x01;font8x8[15][2]=0x03;font8x8[15][3]=0x06;font8x8[15][4]=0x0c;font8x8[15][5]=0x18;font8x8[15][6]=0x30;font8x8[15][7]=0x20; 
       clr.b     120(A2)
       move.b    #1,120+1(A2)
       move.b    #3,120+2(A2)
       move.b    #6,120+3(A2)
       move.b    #12,120+4(A2)
       move.b    #24,120+5(A2)
       move.b    #48,120+6(A2)
       move.b    #32,120+7(A2)
; font8x8[16][0]=0x00;font8x8[16][1]=0x3e;font8x8[16][2]=0x7f;font8x8[16][3]=0x49;font8x8[16][4]=0x51;font8x8[16][5]=0x7f;font8x8[16][6]=0x3e;font8x8[16][7]=0x00; 
       clr.b     128(A2)
       move.b    #62,128+1(A2)
       move.b    #127,128+2(A2)
       move.b    #73,128+3(A2)
       move.b    #81,128+4(A2)
       move.b    #127,128+5(A2)
       move.b    #62,128+6(A2)
       clr.b     128+7(A2)
; font8x8[17][0]=0x00;font8x8[17][1]=0x01;font8x8[17][2]=0x11;font8x8[17][3]=0x7f;font8x8[17][4]=0x7f;font8x8[17][5]=0x01;font8x8[17][6]=0x01;font8x8[17][7]=0x00; 
       clr.b     136(A2)
       move.b    #1,136+1(A2)
       move.b    #17,136+2(A2)
       move.b    #127,136+3(A2)
       move.b    #127,136+4(A2)
       move.b    #1,136+5(A2)
       move.b    #1,136+6(A2)
       clr.b     136+7(A2)
; font8x8[18][0]=0x00;font8x8[18][1]=0x23;font8x8[18][2]=0x67;font8x8[18][3]=0x45;font8x8[18][4]=0x49;font8x8[18][5]=0x79;font8x8[18][6]=0x31;font8x8[18][7]=0x00; 
       clr.b     144(A2)
       move.b    #35,144+1(A2)
       move.b    #103,144+2(A2)
       move.b    #69,144+3(A2)
       move.b    #73,144+4(A2)
       move.b    #121,144+5(A2)
       move.b    #49,144+6(A2)
       clr.b     144+7(A2)
; font8x8[19][0]=0x00;font8x8[19][1]=0x22;font8x8[19][2]=0x63;font8x8[19][3]=0x49;font8x8[19][4]=0x49;font8x8[19][5]=0x7f;font8x8[19][6]=0x36;font8x8[19][7]=0x00; 
       clr.b     152(A2)
       move.b    #34,152+1(A2)
       move.b    #99,152+2(A2)
       move.b    #73,152+3(A2)
       move.b    #73,152+4(A2)
       move.b    #127,152+5(A2)
       move.b    #54,152+6(A2)
       clr.b     152+7(A2)
; font8x8[20][0]=0x00;font8x8[20][1]=0x0c;font8x8[20][2]=0x0c;font8x8[20][3]=0x14;font8x8[20][4]=0x34;font8x8[20][5]=0x7f;font8x8[20][6]=0x7f;font8x8[20][7]=0x04; 
       clr.b     160(A2)
       move.b    #12,160+1(A2)
       move.b    #12,160+2(A2)
       move.b    #20,160+3(A2)
       move.b    #52,160+4(A2)
       move.b    #127,160+5(A2)
       move.b    #127,160+6(A2)
       move.b    #4,160+7(A2)
; font8x8[21][0]=0x00;font8x8[21][1]=0x72;font8x8[21][2]=0x73;font8x8[21][3]=0x51;font8x8[21][4]=0x51;font8x8[21][5]=0x5f;font8x8[21][6]=0x4e;font8x8[21][7]=0x00; 
       clr.b     168(A2)
       move.b    #114,168+1(A2)
       move.b    #115,168+2(A2)
       move.b    #81,168+3(A2)
       move.b    #81,168+4(A2)
       move.b    #95,168+5(A2)
       move.b    #78,168+6(A2)
       clr.b     168+7(A2)
; font8x8[22][0]=0x00;font8x8[22][1]=0x3e;font8x8[22][2]=0x7f;font8x8[22][3]=0x49;font8x8[22][4]=0x49;font8x8[22][5]=0x6f;font8x8[22][6]=0x26;font8x8[22][7]=0x00; 
       clr.b     176(A2)
       move.b    #62,176+1(A2)
       move.b    #127,176+2(A2)
       move.b    #73,176+3(A2)
       move.b    #73,176+4(A2)
       move.b    #111,176+5(A2)
       move.b    #38,176+6(A2)
       clr.b     176+7(A2)
; font8x8[23][0]=0x00;font8x8[23][1]=0x60;font8x8[23][2]=0x60;font8x8[23][3]=0x4f;font8x8[23][4]=0x5f;font8x8[23][5]=0x70;font8x8[23][6]=0x60;font8x8[23][7]=0x00; 
       clr.b     184(A2)
       move.b    #96,184+1(A2)
       move.b    #96,184+2(A2)
       move.b    #79,184+3(A2)
       move.b    #95,184+4(A2)
       move.b    #112,184+5(A2)
       move.b    #96,184+6(A2)
       clr.b     184+7(A2)
; font8x8[24][0]=0x00;font8x8[24][1]=0x36;font8x8[24][2]=0x7f;font8x8[24][3]=0x49;font8x8[24][4]=0x49;font8x8[24][5]=0x7f;font8x8[24][6]=0x36;font8x8[24][7]=0x00; 
       clr.b     192(A2)
       move.b    #54,192+1(A2)
       move.b    #127,192+2(A2)
       move.b    #73,192+3(A2)
       move.b    #73,192+4(A2)
       move.b    #127,192+5(A2)
       move.b    #54,192+6(A2)
       clr.b     192+7(A2)
; font8x8[25][0]=0x00;font8x8[25][1]=0x32;font8x8[25][2]=0x7b;font8x8[25][3]=0x49;font8x8[25][4]=0x49;font8x8[25][5]=0x7f;font8x8[25][6]=0x3e;font8x8[25][7]=0x00; 
       clr.b     200(A2)
       move.b    #50,200+1(A2)
       move.b    #123,200+2(A2)
       move.b    #73,200+3(A2)
       move.b    #73,200+4(A2)
       move.b    #127,200+5(A2)
       move.b    #62,200+6(A2)
       clr.b     200+7(A2)
; font8x8[26][0]=0x00;font8x8[26][1]=0x00;font8x8[26][2]=0x00;font8x8[26][3]=0x12;font8x8[26][4]=0x12;font8x8[26][5]=0x00;font8x8[26][6]=0x00;font8x8[26][7]=0x00; 
       clr.b     208(A2)
       clr.b     208+1(A2)
       clr.b     208+2(A2)
       move.b    #18,208+3(A2)
       move.b    #18,208+4(A2)
       clr.b     208+5(A2)
       clr.b     208+6(A2)
       clr.b     208+7(A2)
; font8x8[27][0]=0x00;font8x8[27][1]=0x00;font8x8[27][2]=0x00;font8x8[27][3]=0x13;font8x8[27][4]=0x13;font8x8[27][5]=0x00;font8x8[27][6]=0x00;font8x8[27][7]=0x00; 
       clr.b     216(A2)
       clr.b     216+1(A2)
       clr.b     216+2(A2)
       move.b    #19,216+3(A2)
       move.b    #19,216+4(A2)
       clr.b     216+5(A2)
       clr.b     216+6(A2)
       clr.b     216+7(A2)
; font8x8[28][0]=0x00;font8x8[28][1]=0x08;font8x8[28][2]=0x1c;font8x8[28][3]=0x36;font8x8[28][4]=0x63;font8x8[28][5]=0x41;font8x8[28][6]=0x41;font8x8[28][7]=0x00; 
       clr.b     224(A2)
       move.b    #8,224+1(A2)
       move.b    #28,224+2(A2)
       move.b    #54,224+3(A2)
       move.b    #99,224+4(A2)
       move.b    #65,224+5(A2)
       move.b    #65,224+6(A2)
       clr.b     224+7(A2)
; font8x8[29][0]=0x00;font8x8[29][1]=0x14;font8x8[29][2]=0x14;font8x8[29][3]=0x14;font8x8[29][4]=0x14;font8x8[29][5]=0x14;font8x8[29][6]=0x14;font8x8[29][7]=0x00; 
       clr.b     232(A2)
       move.b    #20,232+1(A2)
       move.b    #20,232+2(A2)
       move.b    #20,232+3(A2)
       move.b    #20,232+4(A2)
       move.b    #20,232+5(A2)
       move.b    #20,232+6(A2)
       clr.b     232+7(A2)
; font8x8[30][0]=0x00;font8x8[30][1]=0x41;font8x8[30][2]=0x41;font8x8[30][3]=0x63;font8x8[30][4]=0x36;font8x8[30][5]=0x1c;font8x8[30][6]=0x08;font8x8[30][7]=0x00; 
       clr.b     240(A2)
       move.b    #65,240+1(A2)
       move.b    #65,240+2(A2)
       move.b    #99,240+3(A2)
       move.b    #54,240+4(A2)
       move.b    #28,240+5(A2)
       move.b    #8,240+6(A2)
       clr.b     240+7(A2)
; font8x8[31][0]=0x00;font8x8[31][1]=0x20;font8x8[31][2]=0x60;font8x8[31][3]=0x45;font8x8[31][4]=0x4d;font8x8[31][5]=0x78;font8x8[31][6]=0x30;font8x8[31][7]=0x00; 
       clr.b     248(A2)
       move.b    #32,248+1(A2)
       move.b    #96,248+2(A2)
       move.b    #69,248+3(A2)
       move.b    #77,248+4(A2)
       move.b    #120,248+5(A2)
       move.b    #48,248+6(A2)
       clr.b     248+7(A2)
; font8x8[32][0]=0x00;font8x8[32][1]=0x3e;font8x8[32][2]=0x7f;font8x8[32][3]=0x41;font8x8[32][4]=0x59;font8x8[32][5]=0x79;font8x8[32][6]=0x3a;font8x8[32][7]=0x00; 
       clr.b     256(A2)
       move.b    #62,256+1(A2)
       move.b    #127,256+2(A2)
       move.b    #65,256+3(A2)
       move.b    #89,256+4(A2)
       move.b    #121,256+5(A2)
       move.b    #58,256+6(A2)
       clr.b     256+7(A2)
; font8x8[33][0]=0x00;font8x8[33][1]=0x1f;font8x8[33][2]=0x3f;font8x8[33][3]=0x68;font8x8[33][4]=0x68;font8x8[33][5]=0x3f;font8x8[33][6]=0x1f;font8x8[33][7]=0x00; 
       clr.b     264(A2)
       move.b    #31,264+1(A2)
       move.b    #63,264+2(A2)
       move.b    #104,264+3(A2)
       move.b    #104,264+4(A2)
       move.b    #63,264+5(A2)
       move.b    #31,264+6(A2)
       clr.b     264+7(A2)
; font8x8[34][0]=0x00;font8x8[34][1]=0x7f;font8x8[34][2]=0x7f;font8x8[34][3]=0x49;font8x8[34][4]=0x49;font8x8[34][5]=0x7f;font8x8[34][6]=0x36;font8x8[34][7]=0x00; 
       clr.b     272(A2)
       move.b    #127,272+1(A2)
       move.b    #127,272+2(A2)
       move.b    #73,272+3(A2)
       move.b    #73,272+4(A2)
       move.b    #127,272+5(A2)
       move.b    #54,272+6(A2)
       clr.b     272+7(A2)
; font8x8[35][0]=0x00;font8x8[35][1]=0x3e;font8x8[35][2]=0x7f;font8x8[35][3]=0x41;font8x8[35][4]=0x41;font8x8[35][5]=0x63;font8x8[35][6]=0x22;font8x8[35][7]=0x00; 
       clr.b     280(A2)
       move.b    #62,280+1(A2)
       move.b    #127,280+2(A2)
       move.b    #65,280+3(A2)
       move.b    #65,280+4(A2)
       move.b    #99,280+5(A2)
       move.b    #34,280+6(A2)
       clr.b     280+7(A2)
; font8x8[36][0]=0x00;font8x8[36][1]=0x7f;font8x8[36][2]=0x7f;font8x8[36][3]=0x41;font8x8[36][4]=0x63;font8x8[36][5]=0x3e;font8x8[36][6]=0x1c;font8x8[36][7]=0x00; 
       clr.b     288(A2)
       move.b    #127,288+1(A2)
       move.b    #127,288+2(A2)
       move.b    #65,288+3(A2)
       move.b    #99,288+4(A2)
       move.b    #62,288+5(A2)
       move.b    #28,288+6(A2)
       clr.b     288+7(A2)
; font8x8[37][0]=0x00;font8x8[37][1]=0x7f;font8x8[37][2]=0x7f;font8x8[37][3]=0x49;font8x8[37][4]=0x49;font8x8[37][5]=0x41;font8x8[37][6]=0x41;font8x8[37][7]=0x00; 
       clr.b     296(A2)
       move.b    #127,296+1(A2)
       move.b    #127,296+2(A2)
       move.b    #73,296+3(A2)
       move.b    #73,296+4(A2)
       move.b    #65,296+5(A2)
       move.b    #65,296+6(A2)
       clr.b     296+7(A2)
; font8x8[38][0]=0x00;font8x8[38][1]=0x7f;font8x8[38][2]=0x7f;font8x8[38][3]=0x48;font8x8[38][4]=0x48;font8x8[38][5]=0x40;font8x8[38][6]=0x40;font8x8[38][7]=0x00; 
       clr.b     304(A2)
       move.b    #127,304+1(A2)
       move.b    #127,304+2(A2)
       move.b    #72,304+3(A2)
       move.b    #72,304+4(A2)
       move.b    #64,304+5(A2)
       move.b    #64,304+6(A2)
       clr.b     304+7(A2)
; font8x8[39][0]=0x00;font8x8[39][1]=0x3e;font8x8[39][2]=0x7f;font8x8[39][3]=0x41;font8x8[39][4]=0x49;font8x8[39][5]=0x6f;font8x8[39][6]=0x2e;font8x8[39][7]=0x00; 
       clr.b     312(A2)
       move.b    #62,312+1(A2)
       move.b    #127,312+2(A2)
       move.b    #65,312+3(A2)
       move.b    #73,312+4(A2)
       move.b    #111,312+5(A2)
       move.b    #46,312+6(A2)
       clr.b     312+7(A2)
; font8x8[40][0]=0x00;font8x8[40][1]=0x7f;font8x8[40][2]=0x7f;font8x8[40][3]=0x08;font8x8[40][4]=0x08;font8x8[40][5]=0x7f;font8x8[40][6]=0x7f;font8x8[40][7]=0x00; 
       clr.b     320(A2)
       move.b    #127,320+1(A2)
       move.b    #127,320+2(A2)
       move.b    #8,320+3(A2)
       move.b    #8,320+4(A2)
       move.b    #127,320+5(A2)
       move.b    #127,320+6(A2)
       clr.b     320+7(A2)
; font8x8[41][0]=0x00;font8x8[41][1]=0x00;font8x8[41][2]=0x41;font8x8[41][3]=0x7f;font8x8[41][4]=0x7f;font8x8[41][5]=0x41;font8x8[41][6]=0x00;font8x8[41][7]=0x00; 
       clr.b     328(A2)
       clr.b     328+1(A2)
       move.b    #65,328+2(A2)
       move.b    #127,328+3(A2)
       move.b    #127,328+4(A2)
       move.b    #65,328+5(A2)
       clr.b     328+6(A2)
       clr.b     328+7(A2)
; font8x8[42][0]=0x00;font8x8[42][1]=0x02;font8x8[42][2]=0x03;font8x8[42][3]=0x41;font8x8[42][4]=0x7f;font8x8[42][5]=0x7e;font8x8[42][6]=0x40;font8x8[42][7]=0x00; 
       clr.b     336(A2)
       move.b    #2,336+1(A2)
       move.b    #3,336+2(A2)
       move.b    #65,336+3(A2)
       move.b    #127,336+4(A2)
       move.b    #126,336+5(A2)
       move.b    #64,336+6(A2)
       clr.b     336+7(A2)
; font8x8[43][0]=0x00;font8x8[43][1]=0x7f;font8x8[43][2]=0x7f;font8x8[43][3]=0x1c;font8x8[43][4]=0x36;font8x8[43][5]=0x63;font8x8[43][6]=0x41;font8x8[43][7]=0x00; 
       clr.b     344(A2)
       move.b    #127,344+1(A2)
       move.b    #127,344+2(A2)
       move.b    #28,344+3(A2)
       move.b    #54,344+4(A2)
       move.b    #99,344+5(A2)
       move.b    #65,344+6(A2)
       clr.b     344+7(A2)
; font8x8[44][0]=0x00;font8x8[44][1]=0x7f;font8x8[44][2]=0x7f;font8x8[44][3]=0x01;font8x8[44][4]=0x01;font8x8[44][5]=0x01;font8x8[44][6]=0x01;font8x8[44][7]=0x00; 
       clr.b     352(A2)
       move.b    #127,352+1(A2)
       move.b    #127,352+2(A2)
       move.b    #1,352+3(A2)
       move.b    #1,352+4(A2)
       move.b    #1,352+5(A2)
       move.b    #1,352+6(A2)
       clr.b     352+7(A2)
; font8x8[45][0]=0x00;font8x8[45][1]=0x7f;font8x8[45][2]=0x7f;font8x8[45][3]=0x30;font8x8[45][4]=0x18;font8x8[45][5]=0x30;font8x8[45][6]=0x7f;font8x8[45][7]=0x7f; 
       clr.b     360(A2)
       move.b    #127,360+1(A2)
       move.b    #127,360+2(A2)
       move.b    #48,360+3(A2)
       move.b    #24,360+4(A2)
       move.b    #48,360+5(A2)
       move.b    #127,360+6(A2)
       move.b    #127,360+7(A2)
; font8x8[46][0]=0x00;font8x8[46][1]=0x7f;font8x8[46][2]=0x7f;font8x8[46][3]=0x38;font8x8[46][4]=0x1c;font8x8[46][5]=0x7f;font8x8[46][6]=0x7f;font8x8[46][7]=0x00; 
       clr.b     368(A2)
       move.b    #127,368+1(A2)
       move.b    #127,368+2(A2)
       move.b    #56,368+3(A2)
       move.b    #28,368+4(A2)
       move.b    #127,368+5(A2)
       move.b    #127,368+6(A2)
       clr.b     368+7(A2)
; font8x8[47][0]=0x00;font8x8[47][1]=0x3e;font8x8[47][2]=0x7f;font8x8[47][3]=0x41;font8x8[47][4]=0x41;font8x8[47][5]=0x7f;font8x8[47][6]=0x3e;font8x8[47][7]=0x00; 
       clr.b     376(A2)
       move.b    #62,376+1(A2)
       move.b    #127,376+2(A2)
       move.b    #65,376+3(A2)
       move.b    #65,376+4(A2)
       move.b    #127,376+5(A2)
       move.b    #62,376+6(A2)
       clr.b     376+7(A2)
; font8x8[48][0]=0x00;font8x8[48][1]=0x7f;font8x8[48][2]=0x7f;font8x8[48][3]=0x48;font8x8[48][4]=0x48;font8x8[48][5]=0x78;font8x8[48][6]=0x30;font8x8[48][7]=0x00; 
       clr.b     384(A2)
       move.b    #127,384+1(A2)
       move.b    #127,384+2(A2)
       move.b    #72,384+3(A2)
       move.b    #72,384+4(A2)
       move.b    #120,384+5(A2)
       move.b    #48,384+6(A2)
       clr.b     384+7(A2)
; font8x8[49][0]=0x00;font8x8[49][1]=0x3c;font8x8[49][2]=0x7e;font8x8[49][3]=0x42;font8x8[49][4]=0x43;font8x8[49][5]=0x7f;font8x8[49][6]=0x3d;font8x8[49][7]=0x00; 
       clr.b     392(A2)
       move.b    #60,392+1(A2)
       move.b    #126,392+2(A2)
       move.b    #66,392+3(A2)
       move.b    #67,392+4(A2)
       move.b    #127,392+5(A2)
       move.b    #61,392+6(A2)
       clr.b     392+7(A2)
; font8x8[50][0]=0x00;font8x8[50][1]=0x7f;font8x8[50][2]=0x7f;font8x8[50][3]=0x4c;font8x8[50][4]=0x4e;font8x8[50][5]=0x7b;font8x8[50][6]=0x31;font8x8[50][7]=0x00; 
       clr.b     400(A2)
       move.b    #127,400+1(A2)
       move.b    #127,400+2(A2)
       move.b    #76,400+3(A2)
       move.b    #78,400+4(A2)
       move.b    #123,400+5(A2)
       move.b    #49,400+6(A2)
       clr.b     400+7(A2)
; font8x8[51][0]=0x00;font8x8[51][1]=0x32;font8x8[51][2]=0x7b;font8x8[51][3]=0x49;font8x8[51][4]=0x49;font8x8[51][5]=0x6f;font8x8[51][6]=0x26;font8x8[51][7]=0x00; 
       clr.b     408(A2)
       move.b    #50,408+1(A2)
       move.b    #123,408+2(A2)
       move.b    #73,408+3(A2)
       move.b    #73,408+4(A2)
       move.b    #111,408+5(A2)
       move.b    #38,408+6(A2)
       clr.b     408+7(A2)
; font8x8[52][0]=0x00;font8x8[52][1]=0x40;font8x8[52][2]=0x40;font8x8[52][3]=0x7f;font8x8[52][4]=0x7f;font8x8[52][5]=0x40;font8x8[52][6]=0x40;font8x8[52][7]=0x00; 
       clr.b     416(A2)
       move.b    #64,416+1(A2)
       move.b    #64,416+2(A2)
       move.b    #127,416+3(A2)
       move.b    #127,416+4(A2)
       move.b    #64,416+5(A2)
       move.b    #64,416+6(A2)
       clr.b     416+7(A2)
; font8x8[53][0]=0x00;font8x8[53][1]=0x7e;font8x8[53][2]=0x7f;font8x8[53][3]=0x01;font8x8[53][4]=0x01;font8x8[53][5]=0x7f;font8x8[53][6]=0x7e;font8x8[53][7]=0x00; 
       clr.b     424(A2)
       move.b    #126,424+1(A2)
       move.b    #127,424+2(A2)
       move.b    #1,424+3(A2)
       move.b    #1,424+4(A2)
       move.b    #127,424+5(A2)
       move.b    #126,424+6(A2)
       clr.b     424+7(A2)
; font8x8[54][0]=0x00;font8x8[54][1]=0x7c;font8x8[54][2]=0x7e;font8x8[54][3]=0x03;font8x8[54][4]=0x03;font8x8[54][5]=0x7e;font8x8[54][6]=0x7c;font8x8[54][7]=0x00; 
       clr.b     432(A2)
       move.b    #124,432+1(A2)
       move.b    #126,432+2(A2)
       move.b    #3,432+3(A2)
       move.b    #3,432+4(A2)
       move.b    #126,432+5(A2)
       move.b    #124,432+6(A2)
       clr.b     432+7(A2)
; font8x8[55][0]=0x00;font8x8[55][1]=0x7f;font8x8[55][2]=0x7f;font8x8[55][3]=0x06;font8x8[55][4]=0x0c;font8x8[55][5]=0x06;font8x8[55][6]=0x7f;font8x8[55][7]=0x7f; 
       clr.b     440(A2)
       move.b    #127,440+1(A2)
       move.b    #127,440+2(A2)
       move.b    #6,440+3(A2)
       move.b    #12,440+4(A2)
       move.b    #6,440+5(A2)
       move.b    #127,440+6(A2)
       move.b    #127,440+7(A2)
; font8x8[56][0]=0x00;font8x8[56][1]=0x63;font8x8[56][2]=0x77;font8x8[56][3]=0x1c;font8x8[56][4]=0x1c;font8x8[56][5]=0x77;font8x8[56][6]=0x63;font8x8[56][7]=0x00; 
       clr.b     448(A2)
       move.b    #99,448+1(A2)
       move.b    #119,448+2(A2)
       move.b    #28,448+3(A2)
       move.b    #28,448+4(A2)
       move.b    #119,448+5(A2)
       move.b    #99,448+6(A2)
       clr.b     448+7(A2)
; font8x8[57][0]=0x00;font8x8[57][1]=0x70;font8x8[57][2]=0x78;font8x8[57][3]=0x0f;font8x8[57][4]=0x0f;font8x8[57][5]=0x78;font8x8[57][6]=0x70;font8x8[57][7]=0x00; 
       clr.b     456(A2)
       move.b    #112,456+1(A2)
       move.b    #120,456+2(A2)
       move.b    #15,456+3(A2)
       move.b    #15,456+4(A2)
       move.b    #120,456+5(A2)
       move.b    #112,456+6(A2)
       clr.b     456+7(A2)
; font8x8[58][0]=0x00;font8x8[58][1]=0x43;font8x8[58][2]=0x47;font8x8[58][3]=0x4d;font8x8[58][4]=0x59;font8x8[58][5]=0x71;font8x8[58][6]=0x61;font8x8[58][7]=0x00; 
       clr.b     464(A2)
       move.b    #67,464+1(A2)
       move.b    #71,464+2(A2)
       move.b    #77,464+3(A2)
       move.b    #89,464+4(A2)
       move.b    #113,464+5(A2)
       move.b    #97,464+6(A2)
       clr.b     464+7(A2)
; font8x8[59][0]=0x00;font8x8[59][1]=0x00;font8x8[59][2]=0x7f;font8x8[59][3]=0x7f;font8x8[59][4]=0x41;font8x8[59][5]=0x41;font8x8[59][6]=0x00;font8x8[59][7]=0x00; 
       clr.b     472(A2)
       clr.b     472+1(A2)
       move.b    #127,472+2(A2)
       move.b    #127,472+3(A2)
       move.b    #65,472+4(A2)
       move.b    #65,472+5(A2)
       clr.b     472+6(A2)
       clr.b     472+7(A2)
; font8x8[60][0]=0x00;font8x8[60][1]=0x20;font8x8[60][2]=0x30;font8x8[60][3]=0x18;font8x8[60][4]=0x0c;font8x8[60][5]=0x06;font8x8[60][6]=0x03;font8x8[60][7]=0x01; 
       clr.b     480(A2)
       move.b    #32,480+1(A2)
       move.b    #48,480+2(A2)
       move.b    #24,480+3(A2)
       move.b    #12,480+4(A2)
       move.b    #6,480+5(A2)
       move.b    #3,480+6(A2)
       move.b    #1,480+7(A2)
; font8x8[61][0]=0x00;font8x8[61][1]=0x00;font8x8[61][2]=0x41;font8x8[61][3]=0x41;font8x8[61][4]=0x7f;font8x8[61][5]=0x7f;font8x8[61][6]=0x00;font8x8[61][7]=0x00; 
       clr.b     488(A2)
       clr.b     488+1(A2)
       move.b    #65,488+2(A2)
       move.b    #65,488+3(A2)
       move.b    #127,488+4(A2)
       move.b    #127,488+5(A2)
       clr.b     488+6(A2)
       clr.b     488+7(A2)
; font8x8[62][0]=0x00;font8x8[62][1]=0x08;font8x8[62][2]=0x18;font8x8[62][3]=0x3f;font8x8[62][4]=0x3f;font8x8[62][5]=0x18;font8x8[62][6]=0x08;font8x8[62][7]=0x00;
       clr.b     496(A2)
       move.b    #8,496+1(A2)
       move.b    #24,496+2(A2)
       move.b    #63,496+3(A2)
       move.b    #63,496+4(A2)
       move.b    #24,496+5(A2)
       move.b    #8,496+6(A2)
       clr.b     496+7(A2)
       movem.l   (A7)+,A2/A3/A4/A5
       rts
; }
; void cosmic_impalas_main() {
       xdef      _cosmic_impalas_main
_cosmic_impalas_main:
; // NOTE: initializers don't get run, so we init here
; FIRE1  = 0;
       clr.l     _FIRE1.L
; LEFT1  = 0;
       clr.l     _LEFT1.L
; RIGHT1 = 0;
       clr.l     _RIGHT1.L
; srand(1234);
       pea       1234
       jsr       _srand
       addq.w    #4,A7
; initialize_all_bitmaps();
       jsr       _initialize_all_bitmaps
; credits = 0;
       clr.b     _credits.L
; play_game(); 
       jsr       _play_game
       rts
; }
       section   const
@cosmic~1_1:
       dc.b      80,76,65,89,69,82,32,49,0
@cosmic~1_2:
       dc.b      32,42,42,42,42,42,42,42,42,42,42,42,42,42,42
       dc.b      42,32,0
@cosmic~1_3:
       dc.b      42,42,42,32,32,32,32,32,32,32,32,32,32,32,42
       dc.b      42,42,0
@cosmic~1_4:
       dc.b      42,42,32,32,71,65,77,69,32,79,86,69,82,32,32
       dc.b      42,42,0
@cosmic~1_5:
       dc.b      42,42,42,32,32,32,32,32,32,32,32,32,32,32,42
       dc.b      42,42,0
@cosmic~1_6:
       dc.b      32,42,42,42,42,42,42,42,42,42,42,42,42,42,42
       dc.b      42,32,0
       section   bss
       xdef      _FIRE1
_FIRE1:
       ds.b      4
       xdef      _LEFT1
_LEFT1:
       ds.b      4
       xdef      _RIGHT1
_RIGHT1:
       ds.b      4
       xdef      _this_mode
_this_mode:
       ds.b      2
       xdef      _next_mode
_next_mode:
       ds.b      2
       xdef      _enemy_index
_enemy_index:
       ds.b      1
       xdef      _num_enemies
_num_enemies:
       ds.b      1
       xdef      _player_x
_player_x:
       ds.b      1
       xdef      _bullet_x
_bullet_x:
       ds.b      1
       xdef      _bullet_y
_bullet_y:
       ds.b      1
       xdef      _bomb_x
_bomb_x:
       ds.b      1
       xdef      _bomb_y
_bomb_y:
       ds.b      1
       xdef      _attract
_attract:
       ds.b      1
       xdef      _credits
_credits:
       ds.b      1
       xdef      _curplayer
_curplayer:
       ds.b      1
       xdef      _score
_score:
       ds.b      2
       xdef      _lives
_lives:
       ds.b      1
       xdef      _enemies
_enemies:
       ds.b      84
       xdef      _font8x8
_font8x8:
       ds.b      504
       xdef      _player_bitmap
_player_bitmap:
       ds.b      56
       xdef      _bomb_bitmap
_bomb_bitmap:
       ds.b      7
       xdef      _bullet_bitmap
_bullet_bitmap:
       ds.b      4
       xdef      _enemy1_bitmap
_enemy1_bitmap:
       ds.b      34
       xdef      _enemy2_bitmap
_enemy2_bitmap:
       ds.b      34
       xdef      _enemy3_bitmap
_enemy3_bitmap:
       ds.b      34
       xdef      _enemy4_bitmap
_enemy4_bitmap:
       ds.b      34
       xdef      _enemy_bitmaps
_enemy_bitmaps:
       ds.b      16
       xdef      _seed
_seed:
       ds.b      4
       xdef      _frame
_frame:
       ds.b      1
       xref      _memmove
       xref      _clock_count_ms
       xref      LMUL
