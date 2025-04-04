; C:\COSMICIMPALASM68K\PROGRAMS\DEBUGMONITORCODE\GRAPHICS_TEST.C - Compiled by CC68K  Version 5.00 (c) 1991-2005  Peter J. Fondse
; #include <string.h>
; #define PIXEL_BUFFER_VGA_BASEADDRESS   (0x01000000)
; #define VIDMEM_DIM1_W_BLANK_EDGES (256)
; #define VIDMEM_DIM1 (224)
; #define VIDMEM_DIM2 (32)
; #define VIDEOMEM_ADDR(x,y) ((volatile unsigned char *)(PIXEL_BUFFER_VGA_BASEADDRESS + ((y)*VIDMEM_DIM1_W_BLANK_EDGES)+(x)))
; #define VIDMEM(x,y) (*VIDEOMEM_ADDR(x,y))
; #define WRITE_VIDMEM(x,y,CH) ((*(volatile unsigned char *)(PIXEL_BUFFER_VGA_BASEADDRESS + ((y)*VIDMEM_DIM1_W_BLANK_EDGES)+(x))) = CH)
; #define LOCHAR 0x20
; #define HICHAR 0x5e
; char graphics_font8x8[HICHAR-LOCHAR+1][8];
; void graphics_test_main();
; /// GRAPHICS FUNCTIONS
; void graphics_test_clrscr() {
       section   code
       xdef      _graphics_test_clrscr
_graphics_test_clrscr:
       movem.l   D2/D3,-(A7)
; int a;
; int b;
; for (a = 0; a < VIDMEM_DIM1; a++) {
       clr.l     D3
graphics_test_clrscr_1:
       cmp.l     #224,D3
       bge       graphics_test_clrscr_3
; for (b = 0; b < VIDMEM_DIM2; b++) {
       clr.l     D2
graphics_test_clrscr_4:
       cmp.l     #32,D2
       bge.s     graphics_test_clrscr_6
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
       bra       graphics_test_clrscr_4
graphics_test_clrscr_6:
       addq.l    #1,D3
       bra       graphics_test_clrscr_1
graphics_test_clrscr_3:
       movem.l   (A7)+,D2/D3
       rts
; }
; }
; }
; void graphics_xor_pixel(unsigned char x, unsigned char y) {
       xdef      _graphics_xor_pixel
_graphics_xor_pixel:
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
; void graphics_draw_vline(unsigned char x, unsigned char y1, unsigned char y2) {
       xdef      _graphics_draw_vline
_graphics_draw_vline:
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
       ble       graphics_draw_vline_1
; while (--nchars > 0) {
graphics_draw_vline_3:
       subq.l    #1,D4
       cmp.l     #0,D4
       ble.s     graphics_draw_vline_5
; val =  0xff;
       move.b    #255,D2
; *dest ^= val;
       move.l    D3,A0
       eor.b     D2,(A0)
; dest = dest+VIDMEM_DIM1_W_BLANK_EDGES;	  
       add.l     #256,D3
       bra       graphics_draw_vline_3
graphics_draw_vline_5:
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
       bra.s     graphics_draw_vline_2
graphics_draw_vline_1:
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
graphics_draw_vline_2:
       movem.l   (A7)+,D2/D3/D4/D5/D6
       unlk      A6
       rts
; }
; }
; void graphics_draw_char(unsigned char ch, unsigned char x, unsigned char y) {
       xdef      _graphics_draw_char
_graphics_draw_char:
       link      A6,#0
       movem.l   D2/D3/D4,-(A7)
; unsigned char i;
; unsigned char* src;
; unsigned char* dest;
; src  = &graphics_font8x8[(ch-LOCHAR)][0];
       lea       _graphics_font8x8.L,A0
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
graphics_draw_char_1:
       cmp.b     #8,D2
       bhs.s     graphics_draw_char_3
; *dest = *src;
       move.l    D4,A0
       move.l    D3,A1
       move.b    (A0),(A1)
; dest += 1;//32;
       addq.l    #1,D3
; src += 1;
       addq.l    #1,D4
       addq.b    #1,D2
       bra       graphics_draw_char_1
graphics_draw_char_3:
       movem.l   (A7)+,D2/D3/D4
       unlk      A6
       rts
; }
; }
; void graphics_draw_string(const char* str, unsigned char x, unsigned char y) {
       xdef      _graphics_draw_string
_graphics_draw_string:
       link      A6,#0
       move.l    D2,-(A7)
; do {
graphics_draw_string_1:
; unsigned char ch;
; ch = *str++;
       move.l    8(A6),A0
       addq.l    #1,8(A6)
       move.b    (A0),D2
; if (!ch) break;
       tst.b     D2
       bne.s     graphics_draw_string_3
       bra.s     graphics_draw_string_2
graphics_draw_string_3:
; graphics_draw_char(ch, x, y);
       move.b    19(A6),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.b    15(A6),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       and.l     #255,D2
       move.l    D2,-(A7)
       jsr       _graphics_draw_char
       add.w     #12,A7
; x++;
       addq.b    #1,15(A6)
       bra       graphics_draw_string_1
graphics_draw_string_2:
       move.l    (A7)+,D2
       unlk      A6
       rts
; } while (1);
; }
; void draw_font() {
       xdef      _draw_font
_draw_font:
       move.l    D2,-(A7)
; unsigned char i;
; i=LOCHAR;
       moveq     #32,D2
; do {
draw_font_1:
; graphics_draw_char(i, i&15, 31-(i>>4));
       moveq     #31,D1
       move.l    D0,-(A7)
       move.b    D2,D0
       lsr.b     #4,D0
       sub.b     D0,D1
       move.l    (A7)+,D0
       and.l     #255,D1
       move.l    D1,-(A7)
       move.b    D2,D1
       and.b     #15,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       and.l     #255,D2
       move.l    D2,-(A7)
       jsr       _graphics_draw_char
       add.w     #12,A7
; graphics_draw_vline(i, i, i*2);
       move.b    D2,D1
       and.w     #255,D1
       mulu.w    #2,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       and.l     #255,D2
       move.l    D2,-(A7)
       and.l     #255,D2
       move.l    D2,-(A7)
       jsr       _graphics_draw_vline
       add.w     #12,A7
; graphics_xor_pixel(i*15, i);
       and.l     #255,D2
       move.l    D2,-(A7)
       move.b    D2,D1
       and.w     #255,D1
       mulu.w    #15,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       jsr       _graphics_xor_pixel
       addq.w    #8,A7
       addq.b    #1,D2
       cmp.b     #94,D2
       bne       draw_font_1
       move.l    (A7)+,D2
       rts
; } while (++i != HICHAR);
; }
; void initialize_font() {
       xdef      _initialize_font
_initialize_font:
       move.l    A2,-(A7)
       lea       _graphics_font8x8.L,A2
; graphics_font8x8[0 ][0]=0x00;graphics_font8x8[0 ][1]=0x00;graphics_font8x8[0 ][2]=0x00;graphics_font8x8[0 ][3]=0x00;graphics_font8x8[0 ][4]=0x00;graphics_font8x8[0 ][5]=0x00;graphics_font8x8[0 ][6]=0x00;graphics_font8x8[0 ][7]=0x00;
       clr.b     (A2)
       clr.b     1(A2)
       clr.b     2(A2)
       clr.b     3(A2)
       clr.b     4(A2)
       clr.b     5(A2)
       clr.b     6(A2)
       clr.b     7(A2)
; graphics_font8x8[1 ][0]=0x00;graphics_font8x8[1 ][1]=0x00;graphics_font8x8[1 ][2]=0x00;graphics_font8x8[1 ][3]=0x79;graphics_font8x8[1 ][4]=0x79;graphics_font8x8[1 ][5]=0x00;graphics_font8x8[1 ][6]=0x00;graphics_font8x8[1 ][7]=0x00;
       clr.b     8(A2)
       clr.b     8+1(A2)
       clr.b     8+2(A2)
       move.b    #121,8+3(A2)
       move.b    #121,8+4(A2)
       clr.b     8+5(A2)
       clr.b     8+6(A2)
       clr.b     8+7(A2)
; graphics_font8x8[2 ][0]=0x00;graphics_font8x8[2 ][1]=0x70;graphics_font8x8[2 ][2]=0x70;graphics_font8x8[2 ][3]=0x00;graphics_font8x8[2 ][4]=0x00;graphics_font8x8[2 ][5]=0x70;graphics_font8x8[2 ][6]=0x70;graphics_font8x8[2 ][7]=0x00; 
       clr.b     16(A2)
       move.b    #112,16+1(A2)
       move.b    #112,16+2(A2)
       clr.b     16+3(A2)
       clr.b     16+4(A2)
       move.b    #112,16+5(A2)
       move.b    #112,16+6(A2)
       clr.b     16+7(A2)
; graphics_font8x8[3 ][0]=0x14;graphics_font8x8[3 ][1]=0x7f;graphics_font8x8[3 ][2]=0x7f;graphics_font8x8[3 ][3]=0x14;graphics_font8x8[3 ][4]=0x14;graphics_font8x8[3 ][5]=0x7f;graphics_font8x8[3 ][6]=0x7f;graphics_font8x8[3 ][7]=0x14; 
       move.b    #20,24(A2)
       move.b    #127,24+1(A2)
       move.b    #127,24+2(A2)
       move.b    #20,24+3(A2)
       move.b    #20,24+4(A2)
       move.b    #127,24+5(A2)
       move.b    #127,24+6(A2)
       move.b    #20,24+7(A2)
; graphics_font8x8[4 ][0]=0x00;graphics_font8x8[4 ][1]=0x12;graphics_font8x8[4 ][2]=0x3a;graphics_font8x8[4 ][3]=0x6b;graphics_font8x8[4 ][4]=0x6b;graphics_font8x8[4 ][5]=0x2e;graphics_font8x8[4 ][6]=0x24;graphics_font8x8[4 ][7]=0x00;
       clr.b     32(A2)
       move.b    #18,32+1(A2)
       move.b    #58,32+2(A2)
       move.b    #107,32+3(A2)
       move.b    #107,32+4(A2)
       move.b    #46,32+5(A2)
       move.b    #36,32+6(A2)
       clr.b     32+7(A2)
; graphics_font8x8[5 ][0]=0x00;graphics_font8x8[5 ][1]=0x63;graphics_font8x8[5 ][2]=0x66;graphics_font8x8[5 ][3]=0x0c;graphics_font8x8[5 ][4]=0x18;graphics_font8x8[5 ][5]=0x33;graphics_font8x8[5 ][6]=0x63;graphics_font8x8[5 ][7]=0x00; 
       clr.b     40(A2)
       move.b    #99,40+1(A2)
       move.b    #102,40+2(A2)
       move.b    #12,40+3(A2)
       move.b    #24,40+4(A2)
       move.b    #51,40+5(A2)
       move.b    #99,40+6(A2)
       clr.b     40+7(A2)
; graphics_font8x8[6 ][0]=0x00;graphics_font8x8[6 ][1]=0x26;graphics_font8x8[6 ][2]=0x7f;graphics_font8x8[6 ][3]=0x59;graphics_font8x8[6 ][4]=0x59;graphics_font8x8[6 ][5]=0x77;graphics_font8x8[6 ][6]=0x27;graphics_font8x8[6 ][7]=0x05; 
       clr.b     48(A2)
       move.b    #38,48+1(A2)
       move.b    #127,48+2(A2)
       move.b    #89,48+3(A2)
       move.b    #89,48+4(A2)
       move.b    #119,48+5(A2)
       move.b    #39,48+6(A2)
       move.b    #5,48+7(A2)
; graphics_font8x8[7 ][0]=0x00;graphics_font8x8[7 ][1]=0x00;graphics_font8x8[7 ][2]=0x00;graphics_font8x8[7 ][3]=0x10;graphics_font8x8[7 ][4]=0x30;graphics_font8x8[7 ][5]=0x60;graphics_font8x8[7 ][6]=0x40;graphics_font8x8[7 ][7]=0x00; 
       clr.b     56(A2)
       clr.b     56+1(A2)
       clr.b     56+2(A2)
       move.b    #16,56+3(A2)
       move.b    #48,56+4(A2)
       move.b    #96,56+5(A2)
       move.b    #64,56+6(A2)
       clr.b     56+7(A2)
; graphics_font8x8[8 ][0]=0x00;graphics_font8x8[8 ][1]=0x00;graphics_font8x8[8 ][2]=0x1c;graphics_font8x8[8 ][3]=0x3e;graphics_font8x8[8 ][4]=0x63;graphics_font8x8[8 ][5]=0x41;graphics_font8x8[8 ][6]=0x00;graphics_font8x8[8 ][7]=0x00; 
       clr.b     64(A2)
       clr.b     64+1(A2)
       move.b    #28,64+2(A2)
       move.b    #62,64+3(A2)
       move.b    #99,64+4(A2)
       move.b    #65,64+5(A2)
       clr.b     64+6(A2)
       clr.b     64+7(A2)
; graphics_font8x8[9 ][0]=0x00;graphics_font8x8[9 ][1]=0x00;graphics_font8x8[9 ][2]=0x41;graphics_font8x8[9 ][3]=0x63;graphics_font8x8[9 ][4]=0x3e;graphics_font8x8[9 ][5]=0x1c;graphics_font8x8[9 ][6]=0x00;graphics_font8x8[9 ][7]=0x00; 
       clr.b     72(A2)
       clr.b     72+1(A2)
       move.b    #65,72+2(A2)
       move.b    #99,72+3(A2)
       move.b    #62,72+4(A2)
       move.b    #28,72+5(A2)
       clr.b     72+6(A2)
       clr.b     72+7(A2)
; graphics_font8x8[10][0]=0x08;graphics_font8x8[10][1]=0x2a;graphics_font8x8[10][2]=0x3e;graphics_font8x8[10][3]=0x1c;graphics_font8x8[10][4]=0x1c;graphics_font8x8[10][5]=0x3e;graphics_font8x8[10][6]=0x2a;graphics_font8x8[10][7]=0x08; 
       move.b    #8,80(A2)
       move.b    #42,80+1(A2)
       move.b    #62,80+2(A2)
       move.b    #28,80+3(A2)
       move.b    #28,80+4(A2)
       move.b    #62,80+5(A2)
       move.b    #42,80+6(A2)
       move.b    #8,80+7(A2)
; graphics_font8x8[11][0]=0x00;graphics_font8x8[11][1]=0x08;graphics_font8x8[11][2]=0x08;graphics_font8x8[11][3]=0x3e;graphics_font8x8[11][4]=0x3e;graphics_font8x8[11][5]=0x08;graphics_font8x8[11][6]=0x08;graphics_font8x8[11][7]=0x00; 
       clr.b     88(A2)
       move.b    #8,88+1(A2)
       move.b    #8,88+2(A2)
       move.b    #62,88+3(A2)
       move.b    #62,88+4(A2)
       move.b    #8,88+5(A2)
       move.b    #8,88+6(A2)
       clr.b     88+7(A2)
; graphics_font8x8[12][0]=0x00;graphics_font8x8[12][1]=0x00;graphics_font8x8[12][2]=0x00;graphics_font8x8[12][3]=0x03;graphics_font8x8[12][4]=0x03;graphics_font8x8[12][5]=0x00;graphics_font8x8[12][6]=0x00;graphics_font8x8[12][7]=0x00; 
       clr.b     96(A2)
       clr.b     96+1(A2)
       clr.b     96+2(A2)
       move.b    #3,96+3(A2)
       move.b    #3,96+4(A2)
       clr.b     96+5(A2)
       clr.b     96+6(A2)
       clr.b     96+7(A2)
; graphics_font8x8[13][0]=0x00;graphics_font8x8[13][1]=0x08;graphics_font8x8[13][2]=0x08;graphics_font8x8[13][3]=0x08;graphics_font8x8[13][4]=0x08;graphics_font8x8[13][5]=0x08;graphics_font8x8[13][6]=0x08;graphics_font8x8[13][7]=0x00; 
       clr.b     104(A2)
       move.b    #8,104+1(A2)
       move.b    #8,104+2(A2)
       move.b    #8,104+3(A2)
       move.b    #8,104+4(A2)
       move.b    #8,104+5(A2)
       move.b    #8,104+6(A2)
       clr.b     104+7(A2)
; graphics_font8x8[14][0]=0x00;graphics_font8x8[14][1]=0x00;graphics_font8x8[14][2]=0x00;graphics_font8x8[14][3]=0x03;graphics_font8x8[14][4]=0x03;graphics_font8x8[14][5]=0x00;graphics_font8x8[14][6]=0x00;graphics_font8x8[14][7]=0x00; 
       clr.b     112(A2)
       clr.b     112+1(A2)
       clr.b     112+2(A2)
       move.b    #3,112+3(A2)
       move.b    #3,112+4(A2)
       clr.b     112+5(A2)
       clr.b     112+6(A2)
       clr.b     112+7(A2)
; graphics_font8x8[15][0]=0x00;graphics_font8x8[15][1]=0x01;graphics_font8x8[15][2]=0x03;graphics_font8x8[15][3]=0x06;graphics_font8x8[15][4]=0x0c;graphics_font8x8[15][5]=0x18;graphics_font8x8[15][6]=0x30;graphics_font8x8[15][7]=0x20; 
       clr.b     120(A2)
       move.b    #1,120+1(A2)
       move.b    #3,120+2(A2)
       move.b    #6,120+3(A2)
       move.b    #12,120+4(A2)
       move.b    #24,120+5(A2)
       move.b    #48,120+6(A2)
       move.b    #32,120+7(A2)
; graphics_font8x8[16][0]=0x00;graphics_font8x8[16][1]=0x3e;graphics_font8x8[16][2]=0x7f;graphics_font8x8[16][3]=0x49;graphics_font8x8[16][4]=0x51;graphics_font8x8[16][5]=0x7f;graphics_font8x8[16][6]=0x3e;graphics_font8x8[16][7]=0x00; 
       clr.b     128(A2)
       move.b    #62,128+1(A2)
       move.b    #127,128+2(A2)
       move.b    #73,128+3(A2)
       move.b    #81,128+4(A2)
       move.b    #127,128+5(A2)
       move.b    #62,128+6(A2)
       clr.b     128+7(A2)
; graphics_font8x8[17][0]=0x00;graphics_font8x8[17][1]=0x01;graphics_font8x8[17][2]=0x11;graphics_font8x8[17][3]=0x7f;graphics_font8x8[17][4]=0x7f;graphics_font8x8[17][5]=0x01;graphics_font8x8[17][6]=0x01;graphics_font8x8[17][7]=0x00; 
       clr.b     136(A2)
       move.b    #1,136+1(A2)
       move.b    #17,136+2(A2)
       move.b    #127,136+3(A2)
       move.b    #127,136+4(A2)
       move.b    #1,136+5(A2)
       move.b    #1,136+6(A2)
       clr.b     136+7(A2)
; graphics_font8x8[18][0]=0x00;graphics_font8x8[18][1]=0x23;graphics_font8x8[18][2]=0x67;graphics_font8x8[18][3]=0x45;graphics_font8x8[18][4]=0x49;graphics_font8x8[18][5]=0x79;graphics_font8x8[18][6]=0x31;graphics_font8x8[18][7]=0x00; 
       clr.b     144(A2)
       move.b    #35,144+1(A2)
       move.b    #103,144+2(A2)
       move.b    #69,144+3(A2)
       move.b    #73,144+4(A2)
       move.b    #121,144+5(A2)
       move.b    #49,144+6(A2)
       clr.b     144+7(A2)
; graphics_font8x8[19][0]=0x00;graphics_font8x8[19][1]=0x22;graphics_font8x8[19][2]=0x63;graphics_font8x8[19][3]=0x49;graphics_font8x8[19][4]=0x49;graphics_font8x8[19][5]=0x7f;graphics_font8x8[19][6]=0x36;graphics_font8x8[19][7]=0x00; 
       clr.b     152(A2)
       move.b    #34,152+1(A2)
       move.b    #99,152+2(A2)
       move.b    #73,152+3(A2)
       move.b    #73,152+4(A2)
       move.b    #127,152+5(A2)
       move.b    #54,152+6(A2)
       clr.b     152+7(A2)
; graphics_font8x8[20][0]=0x00;graphics_font8x8[20][1]=0x0c;graphics_font8x8[20][2]=0x0c;graphics_font8x8[20][3]=0x14;graphics_font8x8[20][4]=0x34;graphics_font8x8[20][5]=0x7f;graphics_font8x8[20][6]=0x7f;graphics_font8x8[20][7]=0x04; 
       clr.b     160(A2)
       move.b    #12,160+1(A2)
       move.b    #12,160+2(A2)
       move.b    #20,160+3(A2)
       move.b    #52,160+4(A2)
       move.b    #127,160+5(A2)
       move.b    #127,160+6(A2)
       move.b    #4,160+7(A2)
; graphics_font8x8[21][0]=0x00;graphics_font8x8[21][1]=0x72;graphics_font8x8[21][2]=0x73;graphics_font8x8[21][3]=0x51;graphics_font8x8[21][4]=0x51;graphics_font8x8[21][5]=0x5f;graphics_font8x8[21][6]=0x4e;graphics_font8x8[21][7]=0x00; 
       clr.b     168(A2)
       move.b    #114,168+1(A2)
       move.b    #115,168+2(A2)
       move.b    #81,168+3(A2)
       move.b    #81,168+4(A2)
       move.b    #95,168+5(A2)
       move.b    #78,168+6(A2)
       clr.b     168+7(A2)
; graphics_font8x8[22][0]=0x00;graphics_font8x8[22][1]=0x3e;graphics_font8x8[22][2]=0x7f;graphics_font8x8[22][3]=0x49;graphics_font8x8[22][4]=0x49;graphics_font8x8[22][5]=0x6f;graphics_font8x8[22][6]=0x26;graphics_font8x8[22][7]=0x00; 
       clr.b     176(A2)
       move.b    #62,176+1(A2)
       move.b    #127,176+2(A2)
       move.b    #73,176+3(A2)
       move.b    #73,176+4(A2)
       move.b    #111,176+5(A2)
       move.b    #38,176+6(A2)
       clr.b     176+7(A2)
; graphics_font8x8[23][0]=0x00;graphics_font8x8[23][1]=0x60;graphics_font8x8[23][2]=0x60;graphics_font8x8[23][3]=0x4f;graphics_font8x8[23][4]=0x5f;graphics_font8x8[23][5]=0x70;graphics_font8x8[23][6]=0x60;graphics_font8x8[23][7]=0x00; 
       clr.b     184(A2)
       move.b    #96,184+1(A2)
       move.b    #96,184+2(A2)
       move.b    #79,184+3(A2)
       move.b    #95,184+4(A2)
       move.b    #112,184+5(A2)
       move.b    #96,184+6(A2)
       clr.b     184+7(A2)
; graphics_font8x8[24][0]=0x00;graphics_font8x8[24][1]=0x36;graphics_font8x8[24][2]=0x7f;graphics_font8x8[24][3]=0x49;graphics_font8x8[24][4]=0x49;graphics_font8x8[24][5]=0x7f;graphics_font8x8[24][6]=0x36;graphics_font8x8[24][7]=0x00; 
       clr.b     192(A2)
       move.b    #54,192+1(A2)
       move.b    #127,192+2(A2)
       move.b    #73,192+3(A2)
       move.b    #73,192+4(A2)
       move.b    #127,192+5(A2)
       move.b    #54,192+6(A2)
       clr.b     192+7(A2)
; graphics_font8x8[25][0]=0x00;graphics_font8x8[25][1]=0x32;graphics_font8x8[25][2]=0x7b;graphics_font8x8[25][3]=0x49;graphics_font8x8[25][4]=0x49;graphics_font8x8[25][5]=0x7f;graphics_font8x8[25][6]=0x3e;graphics_font8x8[25][7]=0x00; 
       clr.b     200(A2)
       move.b    #50,200+1(A2)
       move.b    #123,200+2(A2)
       move.b    #73,200+3(A2)
       move.b    #73,200+4(A2)
       move.b    #127,200+5(A2)
       move.b    #62,200+6(A2)
       clr.b     200+7(A2)
; graphics_font8x8[26][0]=0x00;graphics_font8x8[26][1]=0x00;graphics_font8x8[26][2]=0x00;graphics_font8x8[26][3]=0x12;graphics_font8x8[26][4]=0x12;graphics_font8x8[26][5]=0x00;graphics_font8x8[26][6]=0x00;graphics_font8x8[26][7]=0x00; 
       clr.b     208(A2)
       clr.b     208+1(A2)
       clr.b     208+2(A2)
       move.b    #18,208+3(A2)
       move.b    #18,208+4(A2)
       clr.b     208+5(A2)
       clr.b     208+6(A2)
       clr.b     208+7(A2)
; graphics_font8x8[27][0]=0x00;graphics_font8x8[27][1]=0x00;graphics_font8x8[27][2]=0x00;graphics_font8x8[27][3]=0x13;graphics_font8x8[27][4]=0x13;graphics_font8x8[27][5]=0x00;graphics_font8x8[27][6]=0x00;graphics_font8x8[27][7]=0x00; 
       clr.b     216(A2)
       clr.b     216+1(A2)
       clr.b     216+2(A2)
       move.b    #19,216+3(A2)
       move.b    #19,216+4(A2)
       clr.b     216+5(A2)
       clr.b     216+6(A2)
       clr.b     216+7(A2)
; graphics_font8x8[28][0]=0x00;graphics_font8x8[28][1]=0x08;graphics_font8x8[28][2]=0x1c;graphics_font8x8[28][3]=0x36;graphics_font8x8[28][4]=0x63;graphics_font8x8[28][5]=0x41;graphics_font8x8[28][6]=0x41;graphics_font8x8[28][7]=0x00; 
       clr.b     224(A2)
       move.b    #8,224+1(A2)
       move.b    #28,224+2(A2)
       move.b    #54,224+3(A2)
       move.b    #99,224+4(A2)
       move.b    #65,224+5(A2)
       move.b    #65,224+6(A2)
       clr.b     224+7(A2)
; graphics_font8x8[29][0]=0x00;graphics_font8x8[29][1]=0x14;graphics_font8x8[29][2]=0x14;graphics_font8x8[29][3]=0x14;graphics_font8x8[29][4]=0x14;graphics_font8x8[29][5]=0x14;graphics_font8x8[29][6]=0x14;graphics_font8x8[29][7]=0x00; 
       clr.b     232(A2)
       move.b    #20,232+1(A2)
       move.b    #20,232+2(A2)
       move.b    #20,232+3(A2)
       move.b    #20,232+4(A2)
       move.b    #20,232+5(A2)
       move.b    #20,232+6(A2)
       clr.b     232+7(A2)
; graphics_font8x8[30][0]=0x00;graphics_font8x8[30][1]=0x41;graphics_font8x8[30][2]=0x41;graphics_font8x8[30][3]=0x63;graphics_font8x8[30][4]=0x36;graphics_font8x8[30][5]=0x1c;graphics_font8x8[30][6]=0x08;graphics_font8x8[30][7]=0x00; 
       clr.b     240(A2)
       move.b    #65,240+1(A2)
       move.b    #65,240+2(A2)
       move.b    #99,240+3(A2)
       move.b    #54,240+4(A2)
       move.b    #28,240+5(A2)
       move.b    #8,240+6(A2)
       clr.b     240+7(A2)
; graphics_font8x8[31][0]=0x00;graphics_font8x8[31][1]=0x20;graphics_font8x8[31][2]=0x60;graphics_font8x8[31][3]=0x45;graphics_font8x8[31][4]=0x4d;graphics_font8x8[31][5]=0x78;graphics_font8x8[31][6]=0x30;graphics_font8x8[31][7]=0x00; 
       clr.b     248(A2)
       move.b    #32,248+1(A2)
       move.b    #96,248+2(A2)
       move.b    #69,248+3(A2)
       move.b    #77,248+4(A2)
       move.b    #120,248+5(A2)
       move.b    #48,248+6(A2)
       clr.b     248+7(A2)
; graphics_font8x8[32][0]=0x00;graphics_font8x8[32][1]=0x3e;graphics_font8x8[32][2]=0x7f;graphics_font8x8[32][3]=0x41;graphics_font8x8[32][4]=0x59;graphics_font8x8[32][5]=0x79;graphics_font8x8[32][6]=0x3a;graphics_font8x8[32][7]=0x00; 
       clr.b     256(A2)
       move.b    #62,256+1(A2)
       move.b    #127,256+2(A2)
       move.b    #65,256+3(A2)
       move.b    #89,256+4(A2)
       move.b    #121,256+5(A2)
       move.b    #58,256+6(A2)
       clr.b     256+7(A2)
; graphics_font8x8[33][0]=0x00;graphics_font8x8[33][1]=0x1f;graphics_font8x8[33][2]=0x3f;graphics_font8x8[33][3]=0x68;graphics_font8x8[33][4]=0x68;graphics_font8x8[33][5]=0x3f;graphics_font8x8[33][6]=0x1f;graphics_font8x8[33][7]=0x00; 
       clr.b     264(A2)
       move.b    #31,264+1(A2)
       move.b    #63,264+2(A2)
       move.b    #104,264+3(A2)
       move.b    #104,264+4(A2)
       move.b    #63,264+5(A2)
       move.b    #31,264+6(A2)
       clr.b     264+7(A2)
; graphics_font8x8[34][0]=0x00;graphics_font8x8[34][1]=0x7f;graphics_font8x8[34][2]=0x7f;graphics_font8x8[34][3]=0x49;graphics_font8x8[34][4]=0x49;graphics_font8x8[34][5]=0x7f;graphics_font8x8[34][6]=0x36;graphics_font8x8[34][7]=0x00; 
       clr.b     272(A2)
       move.b    #127,272+1(A2)
       move.b    #127,272+2(A2)
       move.b    #73,272+3(A2)
       move.b    #73,272+4(A2)
       move.b    #127,272+5(A2)
       move.b    #54,272+6(A2)
       clr.b     272+7(A2)
; graphics_font8x8[35][0]=0x00;graphics_font8x8[35][1]=0x3e;graphics_font8x8[35][2]=0x7f;graphics_font8x8[35][3]=0x41;graphics_font8x8[35][4]=0x41;graphics_font8x8[35][5]=0x63;graphics_font8x8[35][6]=0x22;graphics_font8x8[35][7]=0x00; 
       clr.b     280(A2)
       move.b    #62,280+1(A2)
       move.b    #127,280+2(A2)
       move.b    #65,280+3(A2)
       move.b    #65,280+4(A2)
       move.b    #99,280+5(A2)
       move.b    #34,280+6(A2)
       clr.b     280+7(A2)
; graphics_font8x8[36][0]=0x00;graphics_font8x8[36][1]=0x7f;graphics_font8x8[36][2]=0x7f;graphics_font8x8[36][3]=0x41;graphics_font8x8[36][4]=0x63;graphics_font8x8[36][5]=0x3e;graphics_font8x8[36][6]=0x1c;graphics_font8x8[36][7]=0x00; 
       clr.b     288(A2)
       move.b    #127,288+1(A2)
       move.b    #127,288+2(A2)
       move.b    #65,288+3(A2)
       move.b    #99,288+4(A2)
       move.b    #62,288+5(A2)
       move.b    #28,288+6(A2)
       clr.b     288+7(A2)
; graphics_font8x8[37][0]=0x00;graphics_font8x8[37][1]=0x7f;graphics_font8x8[37][2]=0x7f;graphics_font8x8[37][3]=0x49;graphics_font8x8[37][4]=0x49;graphics_font8x8[37][5]=0x41;graphics_font8x8[37][6]=0x41;graphics_font8x8[37][7]=0x00; 
       clr.b     296(A2)
       move.b    #127,296+1(A2)
       move.b    #127,296+2(A2)
       move.b    #73,296+3(A2)
       move.b    #73,296+4(A2)
       move.b    #65,296+5(A2)
       move.b    #65,296+6(A2)
       clr.b     296+7(A2)
; graphics_font8x8[38][0]=0x00;graphics_font8x8[38][1]=0x7f;graphics_font8x8[38][2]=0x7f;graphics_font8x8[38][3]=0x48;graphics_font8x8[38][4]=0x48;graphics_font8x8[38][5]=0x40;graphics_font8x8[38][6]=0x40;graphics_font8x8[38][7]=0x00; 
       clr.b     304(A2)
       move.b    #127,304+1(A2)
       move.b    #127,304+2(A2)
       move.b    #72,304+3(A2)
       move.b    #72,304+4(A2)
       move.b    #64,304+5(A2)
       move.b    #64,304+6(A2)
       clr.b     304+7(A2)
; graphics_font8x8[39][0]=0x00;graphics_font8x8[39][1]=0x3e;graphics_font8x8[39][2]=0x7f;graphics_font8x8[39][3]=0x41;graphics_font8x8[39][4]=0x49;graphics_font8x8[39][5]=0x6f;graphics_font8x8[39][6]=0x2e;graphics_font8x8[39][7]=0x00; 
       clr.b     312(A2)
       move.b    #62,312+1(A2)
       move.b    #127,312+2(A2)
       move.b    #65,312+3(A2)
       move.b    #73,312+4(A2)
       move.b    #111,312+5(A2)
       move.b    #46,312+6(A2)
       clr.b     312+7(A2)
; graphics_font8x8[40][0]=0x00;graphics_font8x8[40][1]=0x7f;graphics_font8x8[40][2]=0x7f;graphics_font8x8[40][3]=0x08;graphics_font8x8[40][4]=0x08;graphics_font8x8[40][5]=0x7f;graphics_font8x8[40][6]=0x7f;graphics_font8x8[40][7]=0x00; 
       clr.b     320(A2)
       move.b    #127,320+1(A2)
       move.b    #127,320+2(A2)
       move.b    #8,320+3(A2)
       move.b    #8,320+4(A2)
       move.b    #127,320+5(A2)
       move.b    #127,320+6(A2)
       clr.b     320+7(A2)
; graphics_font8x8[41][0]=0x00;graphics_font8x8[41][1]=0x00;graphics_font8x8[41][2]=0x41;graphics_font8x8[41][3]=0x7f;graphics_font8x8[41][4]=0x7f;graphics_font8x8[41][5]=0x41;graphics_font8x8[41][6]=0x00;graphics_font8x8[41][7]=0x00; 
       clr.b     328(A2)
       clr.b     328+1(A2)
       move.b    #65,328+2(A2)
       move.b    #127,328+3(A2)
       move.b    #127,328+4(A2)
       move.b    #65,328+5(A2)
       clr.b     328+6(A2)
       clr.b     328+7(A2)
; graphics_font8x8[42][0]=0x00;graphics_font8x8[42][1]=0x02;graphics_font8x8[42][2]=0x03;graphics_font8x8[42][3]=0x41;graphics_font8x8[42][4]=0x7f;graphics_font8x8[42][5]=0x7e;graphics_font8x8[42][6]=0x40;graphics_font8x8[42][7]=0x00; 
       clr.b     336(A2)
       move.b    #2,336+1(A2)
       move.b    #3,336+2(A2)
       move.b    #65,336+3(A2)
       move.b    #127,336+4(A2)
       move.b    #126,336+5(A2)
       move.b    #64,336+6(A2)
       clr.b     336+7(A2)
; graphics_font8x8[43][0]=0x00;graphics_font8x8[43][1]=0x7f;graphics_font8x8[43][2]=0x7f;graphics_font8x8[43][3]=0x1c;graphics_font8x8[43][4]=0x36;graphics_font8x8[43][5]=0x63;graphics_font8x8[43][6]=0x41;graphics_font8x8[43][7]=0x00; 
       clr.b     344(A2)
       move.b    #127,344+1(A2)
       move.b    #127,344+2(A2)
       move.b    #28,344+3(A2)
       move.b    #54,344+4(A2)
       move.b    #99,344+5(A2)
       move.b    #65,344+6(A2)
       clr.b     344+7(A2)
; graphics_font8x8[44][0]=0x00;graphics_font8x8[44][1]=0x7f;graphics_font8x8[44][2]=0x7f;graphics_font8x8[44][3]=0x01;graphics_font8x8[44][4]=0x01;graphics_font8x8[44][5]=0x01;graphics_font8x8[44][6]=0x01;graphics_font8x8[44][7]=0x00; 
       clr.b     352(A2)
       move.b    #127,352+1(A2)
       move.b    #127,352+2(A2)
       move.b    #1,352+3(A2)
       move.b    #1,352+4(A2)
       move.b    #1,352+5(A2)
       move.b    #1,352+6(A2)
       clr.b     352+7(A2)
; graphics_font8x8[45][0]=0x00;graphics_font8x8[45][1]=0x7f;graphics_font8x8[45][2]=0x7f;graphics_font8x8[45][3]=0x30;graphics_font8x8[45][4]=0x18;graphics_font8x8[45][5]=0x30;graphics_font8x8[45][6]=0x7f;graphics_font8x8[45][7]=0x7f; 
       clr.b     360(A2)
       move.b    #127,360+1(A2)
       move.b    #127,360+2(A2)
       move.b    #48,360+3(A2)
       move.b    #24,360+4(A2)
       move.b    #48,360+5(A2)
       move.b    #127,360+6(A2)
       move.b    #127,360+7(A2)
; graphics_font8x8[46][0]=0x00;graphics_font8x8[46][1]=0x7f;graphics_font8x8[46][2]=0x7f;graphics_font8x8[46][3]=0x38;graphics_font8x8[46][4]=0x1c;graphics_font8x8[46][5]=0x7f;graphics_font8x8[46][6]=0x7f;graphics_font8x8[46][7]=0x00; 
       clr.b     368(A2)
       move.b    #127,368+1(A2)
       move.b    #127,368+2(A2)
       move.b    #56,368+3(A2)
       move.b    #28,368+4(A2)
       move.b    #127,368+5(A2)
       move.b    #127,368+6(A2)
       clr.b     368+7(A2)
; graphics_font8x8[47][0]=0x00;graphics_font8x8[47][1]=0x3e;graphics_font8x8[47][2]=0x7f;graphics_font8x8[47][3]=0x41;graphics_font8x8[47][4]=0x41;graphics_font8x8[47][5]=0x7f;graphics_font8x8[47][6]=0x3e;graphics_font8x8[47][7]=0x00; 
       clr.b     376(A2)
       move.b    #62,376+1(A2)
       move.b    #127,376+2(A2)
       move.b    #65,376+3(A2)
       move.b    #65,376+4(A2)
       move.b    #127,376+5(A2)
       move.b    #62,376+6(A2)
       clr.b     376+7(A2)
; graphics_font8x8[48][0]=0x00;graphics_font8x8[48][1]=0x7f;graphics_font8x8[48][2]=0x7f;graphics_font8x8[48][3]=0x48;graphics_font8x8[48][4]=0x48;graphics_font8x8[48][5]=0x78;graphics_font8x8[48][6]=0x30;graphics_font8x8[48][7]=0x00; 
       clr.b     384(A2)
       move.b    #127,384+1(A2)
       move.b    #127,384+2(A2)
       move.b    #72,384+3(A2)
       move.b    #72,384+4(A2)
       move.b    #120,384+5(A2)
       move.b    #48,384+6(A2)
       clr.b     384+7(A2)
; graphics_font8x8[49][0]=0x00;graphics_font8x8[49][1]=0x3c;graphics_font8x8[49][2]=0x7e;graphics_font8x8[49][3]=0x42;graphics_font8x8[49][4]=0x43;graphics_font8x8[49][5]=0x7f;graphics_font8x8[49][6]=0x3d;graphics_font8x8[49][7]=0x00; 
       clr.b     392(A2)
       move.b    #60,392+1(A2)
       move.b    #126,392+2(A2)
       move.b    #66,392+3(A2)
       move.b    #67,392+4(A2)
       move.b    #127,392+5(A2)
       move.b    #61,392+6(A2)
       clr.b     392+7(A2)
; graphics_font8x8[50][0]=0x00;graphics_font8x8[50][1]=0x7f;graphics_font8x8[50][2]=0x7f;graphics_font8x8[50][3]=0x4c;graphics_font8x8[50][4]=0x4e;graphics_font8x8[50][5]=0x7b;graphics_font8x8[50][6]=0x31;graphics_font8x8[50][7]=0x00; 
       clr.b     400(A2)
       move.b    #127,400+1(A2)
       move.b    #127,400+2(A2)
       move.b    #76,400+3(A2)
       move.b    #78,400+4(A2)
       move.b    #123,400+5(A2)
       move.b    #49,400+6(A2)
       clr.b     400+7(A2)
; graphics_font8x8[51][0]=0x00;graphics_font8x8[51][1]=0x32;graphics_font8x8[51][2]=0x7b;graphics_font8x8[51][3]=0x49;graphics_font8x8[51][4]=0x49;graphics_font8x8[51][5]=0x6f;graphics_font8x8[51][6]=0x26;graphics_font8x8[51][7]=0x00; 
       clr.b     408(A2)
       move.b    #50,408+1(A2)
       move.b    #123,408+2(A2)
       move.b    #73,408+3(A2)
       move.b    #73,408+4(A2)
       move.b    #111,408+5(A2)
       move.b    #38,408+6(A2)
       clr.b     408+7(A2)
; graphics_font8x8[52][0]=0x00;graphics_font8x8[52][1]=0x40;graphics_font8x8[52][2]=0x40;graphics_font8x8[52][3]=0x7f;graphics_font8x8[52][4]=0x7f;graphics_font8x8[52][5]=0x40;graphics_font8x8[52][6]=0x40;graphics_font8x8[52][7]=0x00; 
       clr.b     416(A2)
       move.b    #64,416+1(A2)
       move.b    #64,416+2(A2)
       move.b    #127,416+3(A2)
       move.b    #127,416+4(A2)
       move.b    #64,416+5(A2)
       move.b    #64,416+6(A2)
       clr.b     416+7(A2)
; graphics_font8x8[53][0]=0x00;graphics_font8x8[53][1]=0x7e;graphics_font8x8[53][2]=0x7f;graphics_font8x8[53][3]=0x01;graphics_font8x8[53][4]=0x01;graphics_font8x8[53][5]=0x7f;graphics_font8x8[53][6]=0x7e;graphics_font8x8[53][7]=0x00; 
       clr.b     424(A2)
       move.b    #126,424+1(A2)
       move.b    #127,424+2(A2)
       move.b    #1,424+3(A2)
       move.b    #1,424+4(A2)
       move.b    #127,424+5(A2)
       move.b    #126,424+6(A2)
       clr.b     424+7(A2)
; graphics_font8x8[54][0]=0x00;graphics_font8x8[54][1]=0x7c;graphics_font8x8[54][2]=0x7e;graphics_font8x8[54][3]=0x03;graphics_font8x8[54][4]=0x03;graphics_font8x8[54][5]=0x7e;graphics_font8x8[54][6]=0x7c;graphics_font8x8[54][7]=0x00; 
       clr.b     432(A2)
       move.b    #124,432+1(A2)
       move.b    #126,432+2(A2)
       move.b    #3,432+3(A2)
       move.b    #3,432+4(A2)
       move.b    #126,432+5(A2)
       move.b    #124,432+6(A2)
       clr.b     432+7(A2)
; graphics_font8x8[55][0]=0x00;graphics_font8x8[55][1]=0x7f;graphics_font8x8[55][2]=0x7f;graphics_font8x8[55][3]=0x06;graphics_font8x8[55][4]=0x0c;graphics_font8x8[55][5]=0x06;graphics_font8x8[55][6]=0x7f;graphics_font8x8[55][7]=0x7f; 
       clr.b     440(A2)
       move.b    #127,440+1(A2)
       move.b    #127,440+2(A2)
       move.b    #6,440+3(A2)
       move.b    #12,440+4(A2)
       move.b    #6,440+5(A2)
       move.b    #127,440+6(A2)
       move.b    #127,440+7(A2)
; graphics_font8x8[56][0]=0x00;graphics_font8x8[56][1]=0x63;graphics_font8x8[56][2]=0x77;graphics_font8x8[56][3]=0x1c;graphics_font8x8[56][4]=0x1c;graphics_font8x8[56][5]=0x77;graphics_font8x8[56][6]=0x63;graphics_font8x8[56][7]=0x00; 
       clr.b     448(A2)
       move.b    #99,448+1(A2)
       move.b    #119,448+2(A2)
       move.b    #28,448+3(A2)
       move.b    #28,448+4(A2)
       move.b    #119,448+5(A2)
       move.b    #99,448+6(A2)
       clr.b     448+7(A2)
; graphics_font8x8[57][0]=0x00;graphics_font8x8[57][1]=0x70;graphics_font8x8[57][2]=0x78;graphics_font8x8[57][3]=0x0f;graphics_font8x8[57][4]=0x0f;graphics_font8x8[57][5]=0x78;graphics_font8x8[57][6]=0x70;graphics_font8x8[57][7]=0x00; 
       clr.b     456(A2)
       move.b    #112,456+1(A2)
       move.b    #120,456+2(A2)
       move.b    #15,456+3(A2)
       move.b    #15,456+4(A2)
       move.b    #120,456+5(A2)
       move.b    #112,456+6(A2)
       clr.b     456+7(A2)
; graphics_font8x8[58][0]=0x00;graphics_font8x8[58][1]=0x43;graphics_font8x8[58][2]=0x47;graphics_font8x8[58][3]=0x4d;graphics_font8x8[58][4]=0x59;graphics_font8x8[58][5]=0x71;graphics_font8x8[58][6]=0x61;graphics_font8x8[58][7]=0x00; 
       clr.b     464(A2)
       move.b    #67,464+1(A2)
       move.b    #71,464+2(A2)
       move.b    #77,464+3(A2)
       move.b    #89,464+4(A2)
       move.b    #113,464+5(A2)
       move.b    #97,464+6(A2)
       clr.b     464+7(A2)
; graphics_font8x8[59][0]=0x00;graphics_font8x8[59][1]=0x00;graphics_font8x8[59][2]=0x7f;graphics_font8x8[59][3]=0x7f;graphics_font8x8[59][4]=0x41;graphics_font8x8[59][5]=0x41;graphics_font8x8[59][6]=0x00;graphics_font8x8[59][7]=0x00; 
       clr.b     472(A2)
       clr.b     472+1(A2)
       move.b    #127,472+2(A2)
       move.b    #127,472+3(A2)
       move.b    #65,472+4(A2)
       move.b    #65,472+5(A2)
       clr.b     472+6(A2)
       clr.b     472+7(A2)
; graphics_font8x8[60][0]=0x00;graphics_font8x8[60][1]=0x20;graphics_font8x8[60][2]=0x30;graphics_font8x8[60][3]=0x18;graphics_font8x8[60][4]=0x0c;graphics_font8x8[60][5]=0x06;graphics_font8x8[60][6]=0x03;graphics_font8x8[60][7]=0x01; 
       clr.b     480(A2)
       move.b    #32,480+1(A2)
       move.b    #48,480+2(A2)
       move.b    #24,480+3(A2)
       move.b    #12,480+4(A2)
       move.b    #6,480+5(A2)
       move.b    #3,480+6(A2)
       move.b    #1,480+7(A2)
; graphics_font8x8[61][0]=0x00;graphics_font8x8[61][1]=0x00;graphics_font8x8[61][2]=0x41;graphics_font8x8[61][3]=0x41;graphics_font8x8[61][4]=0x7f;graphics_font8x8[61][5]=0x7f;graphics_font8x8[61][6]=0x00;graphics_font8x8[61][7]=0x00; 
       clr.b     488(A2)
       clr.b     488+1(A2)
       move.b    #65,488+2(A2)
       move.b    #65,488+3(A2)
       move.b    #127,488+4(A2)
       move.b    #127,488+5(A2)
       clr.b     488+6(A2)
       clr.b     488+7(A2)
; graphics_font8x8[62][0]=0x00;graphics_font8x8[62][1]=0x08;graphics_font8x8[62][2]=0x18;graphics_font8x8[62][3]=0x3f;graphics_font8x8[62][4]=0x3f;graphics_font8x8[62][5]=0x18;graphics_font8x8[62][6]=0x08;graphics_font8x8[62][7]=0x00;	
       clr.b     496(A2)
       move.b    #8,496+1(A2)
       move.b    #24,496+2(A2)
       move.b    #63,496+3(A2)
       move.b    #63,496+4(A2)
       move.b    #24,496+5(A2)
       move.b    #8,496+6(A2)
       clr.b     496+7(A2)
       move.l    (A7)+,A2
       rts
; }
; void graphics_test_main() {
       xdef      _graphics_test_main
_graphics_test_main:
; initialize_font();
       jsr       _initialize_font
; graphics_test_clrscr();
       jsr       _graphics_test_clrscr
; draw_font();
       jsr       _draw_font
; graphics_draw_string("HELLO WORLD", 0, 0);
       clr.l     -(A7)
       clr.l     -(A7)
       pea       @graphi~1_1.L
       jsr       _graphics_draw_string
       add.w     #12,A7
       rts
; }
       section   const
@graphi~1_1:
       dc.b      72,69,76,76,79,32,87,79,82,76,68,0
       section   bss
       xdef      _graphics_font8x8
_graphics_font8x8:
       ds.b      504
       xref      LMUL
