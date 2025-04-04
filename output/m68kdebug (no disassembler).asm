; C:\COSMICIMPALASM68K\PROGRAMS\DEBUGMONITORCODE\M68KDEBUG (NO DISASSEMBLER).C - Compiled by CC68K  Version 5.00 (c) 1991-2005  Peter J. Fondse
; #include "DebugMonitor.h"
; // use 08030000 for a system running from sram or 0B000000 for system running from dram
; #define StartOfExceptionVectorTable 0x08030000
; //#define StartOfExceptionVectorTable 0x0B000000
; // use 0C000000 for dram or hex 08040000 for sram
; #define TopOfStack 0x08040000
; //#define TopOfStack 0x0C000000
; /* DO NOT INITIALISE GLOBAL VARIABLES - DO IT in MAIN() */
; unsigned int i, x, y, z, PortA_Count;
; int     Trace, GoFlag, Echo;                       // used in tracing/single stepping
; // 68000 register dump and preintialise value (these can be changed by the user program when it is running, e.g. stack pointer, registers etc
; unsigned int d0,d1,d2,d3,d4,d5,d6,d7 ;
; unsigned int a0,a1,a2,a3,a4,a5,a6 ;
; unsigned int PC, SSP, USP ;
; unsigned short int SR;
; // Breakpoint variables
; unsigned int BreakPointAddress[8];                      //array of 8 breakpoint addresses
; unsigned short int BreakPointInstruction[8] ;           // to hold the instruction opcode at the breakpoint
; unsigned int BreakPointSetOrCleared[8] ;
; unsigned int InstructionSize ;
; // watchpoint variables
; unsigned int WatchPointAddress[8];                      //array of 8 breakpoint addresses
; unsigned int WatchPointSetOrCleared[8] ;
; int clock_count_ms;
; char    TempString[100] ;
; void InstallExceptionHandler( void (*function_ptr)(), int level)
; {
       section   code
       xdef      _InstallExceptionHandler
_InstallExceptionHandler:
       link      A6,#-4
; volatile long int *RamVectorAddress = (volatile long int *)(StartOfExceptionVectorTable) ;   // pointer to the Ram based interrupt vector table created in Cstart in debug monitor
       move.l    #134414336,-4(A6)
; RamVectorAddress[level] = (long int *)(function_ptr);
       move.l    -4(A6),A0
       move.l    12(A6),D0
       lsl.l     #2,D0
       move.l    8(A6),0(A0,D0.L)
       unlk      A6
       rts
; }
; /*********************************************************************************************
; *Subroutine to initialise the RS232 Port by writing some commands to the internal registers
; *********************************************************************************************/
; void Init_RS232(void)
; {
       xdef      _Init_RS232
_Init_RS232:
; RS232_Control = (char)(0x15) ; //  %00010101    divide by 16 clock, set rts low, 8 bits no parity, 1 stop bit transmitter interrupt disabled
       move.b    #21,4194368
; RS232_Baud = (char)(0x1) ;      // program baud rate generator 000 = 230k, 001 = 115k, 010 = 57.6k, 011 = 38.4k, 100 = 19.2, all others = 9600
       move.b    #1,4194372
       rts
; }
; int kbhit(void)
; {
       xdef      _kbhit
_kbhit:
; if(((char)(RS232_Status) & (char)(0x01)) == (char)(0x01))    // wait for Rx bit in status register to be '1'
       move.b    4194368,D0
       and.b     #1,D0
       cmp.b     #1,D0
       bne.s     kbhit_1
; return 1 ;
       moveq     #1,D0
       bra.s     kbhit_3
kbhit_1:
; else
; return 0 ;
       clr.l     D0
kbhit_3:
       rts
; }
; /*********************************************************************************************************
; **  Subroutine to provide a low level output function to 6850 ACIA
; **  This routine provides the basic functionality to output a single character to the serial Port
; **  to allow the board to communicate with HyperTerminal Program
; **
; **  NOTE you do not call this function directly, instead you call the normal putchar() function
; **  which in turn calls _putch() below). Other functions like puts(), printf() call putchar() so will
; **  call _putch() also
; *********************************************************************************************************/
; int _putch( int c)
; {
       xdef      __putch
__putch:
       link      A6,#0
; while(((char)(RS232_Status) & (char)(0x02)) != (char)(0x02))    // wait for Tx bit in status register or 6850 serial comms chip to be '1'
_putch_1:
       move.b    4194368,D0
       and.b     #2,D0
       cmp.b     #2,D0
       beq.s     _putch_3
       bra       _putch_1
_putch_3:
; ;
; (char)(RS232_TxData) = ((char)(c) & (char)(0x7f));                      // write to the data register to output the character (mask off bit 8 to keep it 7 bit ASCII)
       move.l    8(A6),D0
       and.b     #127,D0
       move.b    D0,4194370
; return c ;                                              // putchar() expects the character to be returned
       move.l    8(A6),D0
       unlk      A6
       rts
; }
; /*********************************************************************************************************
; **  Subroutine to provide a low level input function to 6850 ACIA
; **  This routine provides the basic functionality to input a single character from the serial Port
; **  to allow the board to communicate with HyperTerminal Program Keyboard (your PC)
; **
; **  NOTE you do not call this function directly, instead you call the normal _getch() function
; **  which in turn calls _getch() below). Other functions like gets(), scanf() call _getch() so will
; **  call _getch() also
; *********************************************************************************************************/
; int _getch( void )
; {
       xdef      __getch
__getch:
       move.l    D2,-(A7)
; int c ;
; while(((char)(RS232_Status) & (char)(0x01)) != (char)(0x01))    // wait for Rx bit in 6850 serial comms chip status register to be '1'
_getch_1:
       move.b    4194368,D0
       and.b     #1,D0
       cmp.b     #1,D0
       beq.s     _getch_3
       bra       _getch_1
_getch_3:
; ;
; c = (RS232_RxData & (char)(0x7f));                   // read received character, mask off top bit and return as 7 bit ASCII character
       move.b    4194370,D0
       and.l     #255,D0
       and.l     #127,D0
       move.l    D0,D2
; // shall we echo the character? Echo is set to TRUE at reset, but for speed we don't want to echo when downloading code with the 'L' debugger command
; if(Echo)
       tst.l     _Echo.L
       beq.s     _getch_4
; _putch(c);
       move.l    D2,-(A7)
       jsr       __putch
       addq.w    #4,A7
_getch_4:
; return c ;
       move.l    D2,D0
       move.l    (A7)+,D2
       rts
; }
; // flush the input stream for any unread characters
; void FlushKeyboard(void)
; {
       xdef      _FlushKeyboard
_FlushKeyboard:
       link      A6,#-4
; char c ;
; while(1)    {
FlushKeyboard_1:
; if(((char)(RS232_Status) & (char)(0x01)) == (char)(0x01))    // if Rx bit in status register is '1'
       move.b    4194368,D0
       and.b     #1,D0
       cmp.b     #1,D0
       bne.s     FlushKeyboard_4
; c = ((char)(RS232_RxData) & (char)(0x7f)) ;
       move.b    4194370,D0
       and.b     #127,D0
       move.b    D0,-1(A6)
       bra.s     FlushKeyboard_5
FlushKeyboard_4:
; else
; return ;
       bra.s     FlushKeyboard_6
FlushKeyboard_5:
       bra       FlushKeyboard_1
FlushKeyboard_6:
       unlk      A6
       rts
; }
; }
; // converts hex char to 4 bit binary equiv in range 0000-1111 (0-F)
; // char assumed to be a valid hex char 0-9, a-f, A-F
; char xtod(int c)
; {
       xdef      _xtod
_xtod:
       link      A6,#0
       move.l    D2,-(A7)
       move.l    8(A6),D2
; if ((char)(c) <= (char)('9'))
       cmp.b     #57,D2
       bgt.s     xtod_1
; return c - (char)(0x30);    // 0 - 9 = 0x30 - 0x39 so convert to number by sutracting 0x30
       move.b    D2,D0
       sub.b     #48,D0
       bra.s     xtod_3
xtod_1:
; else if((char)(c) > (char)('F'))    // assume lower case
       cmp.b     #70,D2
       ble.s     xtod_4
; return c - (char)(0x57);    // a-f = 0x61-66 so needs to be converted to 0x0A - 0x0F so subtract 0x57
       move.b    D2,D0
       sub.b     #87,D0
       bra.s     xtod_3
xtod_4:
; else
; return c - (char)(0x37);    // A-F = 0x41-46 so needs to be converted to 0x0A - 0x0F so subtract 0x37
       move.b    D2,D0
       sub.b     #55,D0
xtod_3:
       move.l    (A7)+,D2
       unlk      A6
       rts
; }
; int Get2HexDigits(char *CheckSumPtr)
; {
       xdef      _Get2HexDigits
_Get2HexDigits:
       link      A6,#0
       move.l    D2,-(A7)
; register int i = (xtod(_getch()) << 4) | (xtod(_getch()));
       move.l    D0,-(A7)
       jsr       __getch
       move.l    D0,D1
       move.l    (A7)+,D0
       move.l    D1,-(A7)
       jsr       _xtod
       addq.w    #4,A7
       and.l     #255,D0
       asl.l     #4,D0
       move.l    D0,-(A7)
       move.l    D1,-(A7)
       jsr       __getch
       move.l    (A7)+,D1
       move.l    D0,-(A7)
       jsr       _xtod
       addq.w    #4,A7
       move.l    D0,D1
       move.l    (A7)+,D0
       and.l     #255,D1
       or.l      D1,D0
       move.l    D0,D2
; if(CheckSumPtr)
       tst.l     8(A6)
       beq.s     Get2HexDigits_1
; *CheckSumPtr += i ;
       move.l    8(A6),A0
       add.b     D2,(A0)
Get2HexDigits_1:
; return i ;
       move.l    D2,D0
       move.l    (A7)+,D2
       unlk      A6
       rts
; }
; int Get4HexDigits(char *CheckSumPtr)
; {
       xdef      _Get4HexDigits
_Get4HexDigits:
       link      A6,#0
; return (Get2HexDigits(CheckSumPtr) << 8) | (Get2HexDigits(CheckSumPtr));
       move.l    8(A6),-(A7)
       jsr       _Get2HexDigits
       addq.w    #4,A7
       asl.l     #8,D0
       move.l    D0,-(A7)
       move.l    8(A6),-(A7)
       jsr       _Get2HexDigits
       addq.w    #4,A7
       move.l    D0,D1
       move.l    (A7)+,D0
       or.l      D1,D0
       unlk      A6
       rts
; }
; int Get6HexDigits(char *CheckSumPtr)
; {
       xdef      _Get6HexDigits
_Get6HexDigits:
       link      A6,#0
; return (Get4HexDigits(CheckSumPtr) << 8) | (Get2HexDigits(CheckSumPtr));
       move.l    8(A6),-(A7)
       jsr       _Get4HexDigits
       addq.w    #4,A7
       asl.l     #8,D0
       move.l    D0,-(A7)
       move.l    8(A6),-(A7)
       jsr       _Get2HexDigits
       addq.w    #4,A7
       move.l    D0,D1
       move.l    (A7)+,D0
       or.l      D1,D0
       unlk      A6
       rts
; }
; int Get8HexDigits(char *CheckSumPtr)
; {
       xdef      _Get8HexDigits
_Get8HexDigits:
       link      A6,#0
; return (Get4HexDigits(CheckSumPtr) << 16) | (Get4HexDigits(CheckSumPtr));
       move.l    8(A6),-(A7)
       jsr       _Get4HexDigits
       addq.w    #4,A7
       asl.l     #8,D0
       asl.l     #8,D0
       move.l    D0,-(A7)
       move.l    8(A6),-(A7)
       jsr       _Get4HexDigits
       addq.w    #4,A7
       move.l    D0,D1
       move.l    (A7)+,D0
       or.l      D1,D0
       unlk      A6
       rts
; }
; void UnknownCommand()
; {
       xdef      _UnknownCommand
_UnknownCommand:
; printf("\r\nUnknown Command.....\r\n") ;
       pea       @m68kde~1_1.L
       jsr       _printf
       addq.w    #4,A7
; Help() ;
       jsr       _Help
       rts
; }
; // system when the users program executes a TRAP #15 instruction to halt program and return to debug monitor
; void CallDebugMonitor(void)
; {
       xdef      _CallDebugMonitor
_CallDebugMonitor:
; printf("\r\nProgram Ended (TRAP #15)....") ;
       pea       @m68kde~1_2.L
       jsr       _printf
       addq.w    #4,A7
; menu();
       jsr       _menu
       rts
; }
; void Help(void)
; {
       xdef      _Help
_Help:
       movem.l   D2/A2,-(A7)
       lea       _printf.L,A2
; char *banner = "\r\n----------------------------------------------------------------" ;
       lea       @m68kde~1_3.L,A0
       move.l    A0,D2
; printf(banner) ;
       move.l    D2,-(A7)
       jsr       (A2)
       addq.w    #4,A7
; printf("\r\n  Final Project") ;
       pea       @m68kde~1_4.L
       jsr       (A2)
       addq.w    #4,A7
; printf(banner) ;
       move.l    D2,-(A7)
       jsr       (A2)
       addq.w    #4,A7
; printf("\r\n  T    - Run Cosmic Impala Game") ;
       pea       @m68kde~1_5.L
       jsr       (A2)
       addq.w    #4,A7
; printf(banner) ;
       move.l    D2,-(A7)
       jsr       (A2)
       addq.w    #4,A7
; printf("\r\n  G    - Run Graphics Test") ;
       pea       @m68kde~1_6.L
       jsr       (A2)
       addq.w    #4,A7
; printf(banner) ;
       move.l    D2,-(A7)
       jsr       (A2)
       addq.w    #4,A7
       movem.l   (A7)+,D2/A2
       rts
; }
; void menu(void)
; {
       xdef      _menu
_menu:
       link      A6,#-4
       movem.l   D2/A2,-(A7)
       lea       _printf.L,A2
; char c;
; int c1 ;
; while(1)    {
menu_1:
; FlushKeyboard() ;               // dump unread characters from keyboard
       jsr       _FlushKeyboard
; printf("\r\n#") ;
       pea       @m68kde~1_7.L
       jsr       (A2)
       addq.w    #4,A7
; c = toupper(_getch());
       move.l    D0,-(A7)
       jsr       __getch
       move.l    D0,D1
       move.l    (A7)+,D0
       move.l    D1,-(A7)
       jsr       _toupper
       addq.w    #4,A7
       move.b    D0,D2
; if ( c == (char)('T'))  {
       cmp.b     #84,D2
       bne.s     menu_4
; printf("\nRunning Cosmic Impalas Game\n");
       pea       @m68kde~1_8.L
       jsr       (A2)
       addq.w    #4,A7
; cosmic_impalas_main();
       jsr       _cosmic_impalas_main
; continue;
       bra.s     menu_2
menu_4:
; } 
; if ( c == (char)('G'))  {
       cmp.b     #71,D2
       bne.s     menu_6
; printf("\nRunning Graphics Test\n");
       pea       @m68kde~1_9.L
       jsr       (A2)
       addq.w    #4,A7
; graphics_test_main();
       jsr       _graphics_test_main
; continue;
       bra.s     menu_2
menu_6:
; } 
; UnknownCommand() ;
       jsr       _UnknownCommand
menu_2:
       bra       menu_1
; }
; }
; void PrintErrorMessageandAbort(char *string) {
       xdef      _PrintErrorMessageandAbort
_PrintErrorMessageandAbort:
       link      A6,#0
; printf("\r\n\r\nProgram ABORT !!!!!!\r\n") ;
       pea       @m68kde~1_10.L
       jsr       _printf
       addq.w    #4,A7
; printf("%s\r\n", string) ;
       move.l    8(A6),-(A7)
       pea       @m68kde~1_11.L
       jsr       _printf
       addq.w    #8,A7
; menu() ;
       jsr       _menu
       unlk      A6
       rts
; }
; void IRQMessage(int level) {
       xdef      _IRQMessage
_IRQMessage:
       link      A6,#0
; printf("\r\n\r\nProgram ABORT !!!!!");
       pea       @m68kde~1_12.L
       jsr       _printf
       addq.w    #4,A7
; printf("\r\nUnhandled Interrupt: IRQ%d !!!!!", level) ;
       move.l    8(A6),-(A7)
       pea       @m68kde~1_13.L
       jsr       _printf
       addq.w    #8,A7
; menu() ;
       jsr       _menu
       unlk      A6
       rts
; }
; void UnhandledIRQ1(void) {
       xdef      _UnhandledIRQ1
_UnhandledIRQ1:
; IRQMessage(1);
       pea       1
       jsr       _IRQMessage
       addq.w    #4,A7
       rts
; }
; void UnhandledIRQ2(void) {
       xdef      _UnhandledIRQ2
_UnhandledIRQ2:
; IRQMessage(2);
       pea       2
       jsr       _IRQMessage
       addq.w    #4,A7
       rts
; }
; void UnhandledIRQ3(void){
       xdef      _UnhandledIRQ3
_UnhandledIRQ3:
; IRQMessage(3);
       pea       3
       jsr       _IRQMessage
       addq.w    #4,A7
       rts
; }
; void UnhandledIRQ4(void) {
       xdef      _UnhandledIRQ4
_UnhandledIRQ4:
; IRQMessage(4);
       pea       4
       jsr       _IRQMessage
       addq.w    #4,A7
       rts
; }
; void UnhandledIRQ5(void) {
       xdef      _UnhandledIRQ5
_UnhandledIRQ5:
; IRQMessage(5);
       pea       5
       jsr       _IRQMessage
       addq.w    #4,A7
       rts
; }
; void UnhandledIRQ6(void) {
       xdef      _UnhandledIRQ6
_UnhandledIRQ6:
; PrintErrorMessageandAbort("ADDRESS ERROR: 16 or 32 Bit Transfer to/from an ODD Address....") ;
       pea       @m68kde~1_14.L
       jsr       _PrintErrorMessageandAbort
       addq.w    #4,A7
; menu() ;
       jsr       _menu
       rts
; }
; void UnhandledIRQ7(void) {
       xdef      _UnhandledIRQ7
_UnhandledIRQ7:
; IRQMessage(7);
       pea       7
       jsr       _IRQMessage
       addq.w    #4,A7
       rts
; }
; void UnhandledTrap(void) {
       xdef      _UnhandledTrap
_UnhandledTrap:
; PrintErrorMessageandAbort("Unhandled Trap !!!!!") ;
       pea       @m68kde~1_15.L
       jsr       _PrintErrorMessageandAbort
       addq.w    #4,A7
       rts
; }
; void BusError() {
       xdef      _BusError
_BusError:
; PrintErrorMessageandAbort("BUS Error!") ;
       pea       @m68kde~1_16.L
       jsr       _PrintErrorMessageandAbort
       addq.w    #4,A7
       rts
; }
; void AddressError() {
       xdef      _AddressError
_AddressError:
; PrintErrorMessageandAbort("ADDRESS Error!") ;
       pea       @m68kde~1_17.L
       jsr       _PrintErrorMessageandAbort
       addq.w    #4,A7
       rts
; }
; void IllegalInstruction() {
       xdef      _IllegalInstruction
_IllegalInstruction:
; PrintErrorMessageandAbort("ILLEGAL INSTRUCTION") ;
       pea       @m68kde~1_18.L
       jsr       _PrintErrorMessageandAbort
       addq.w    #4,A7
       rts
; }
; void Dividebyzero() {
       xdef      _Dividebyzero
_Dividebyzero:
; PrintErrorMessageandAbort("DIVIDE BY ZERO") ;
       pea       @m68kde~1_19.L
       jsr       _PrintErrorMessageandAbort
       addq.w    #4,A7
       rts
; }
; void Check() {
       xdef      _Check
_Check:
; PrintErrorMessageandAbort("'CHK' INSTRUCTION") ;
       pea       @m68kde~1_20.L
       jsr       _PrintErrorMessageandAbort
       addq.w    #4,A7
       rts
; }
; void Trapv() {
       xdef      _Trapv
_Trapv:
; PrintErrorMessageandAbort("TRAPV INSTRUCTION") ;
       pea       @m68kde~1_21.L
       jsr       _PrintErrorMessageandAbort
       addq.w    #4,A7
       rts
; }
; void PrivError() {
       xdef      _PrivError
_PrivError:
; PrintErrorMessageandAbort("PRIVILEGE VIOLATION") ;
       pea       @m68kde~1_22.L
       jsr       _PrintErrorMessageandAbort
       addq.w    #4,A7
       rts
; }
; void UnitIRQ() {
       xdef      _UnitIRQ
_UnitIRQ:
; PrintErrorMessageandAbort("UNINITIALISED IRQ") ;
       pea       @m68kde~1_23.L
       jsr       _PrintErrorMessageandAbort
       addq.w    #4,A7
       rts
; }
; void Spurious() {
       xdef      _Spurious
_Spurious:
; PrintErrorMessageandAbort("SPURIOUS IRQ") ;
       pea       @m68kde~1_24.L
       jsr       _PrintErrorMessageandAbort
       addq.w    #4,A7
       rts
; }
; /*********************************************************************************
; ** Timer ISR
; **********************************************************************************/
; void Timer_ISR(void)
; {
       xdef      _Timer_ISR
_Timer_ISR:
; if(Timer1Status == 1) {       // Did Timer 1 produce the Interrupt?
       move.b    4194354,D0
       cmp.b     #1,D0
       bne.s     Timer_ISR_1
; clock_count_ms = clock_count_ms + 10; //100 HZ clock = 10ms per clock tick
       add.l     #10,_clock_count_ms.L
; //printf("in timer isr, clock_count_ms = %d\n",clock_count_ms);
; Timer1Control = 3;      	// if so clear interrupt and restart timer
       move.b    #3,4194354
Timer_ISR_1:
       rts
; }
; }
; /**********************************************************************************
; ** Timer Initialisation Routine
; **********************************************************************************/
; void Timer1_Init(void)
; {
       xdef      _Timer1_Init
_Timer1_Init:
; Timer1Data = 0x03;		// program 100 hz time delay into timer 1.
       move.b    #3,4194352
; /*
; ** timer driven off 25Mhz clock so program value so that it counts down in 0.01 secs
; ** the example 0x03 above is loaded into top 8 bits of a 24 bit timer so reads as
; ** 0x03FFFF a value of 0x03 would be 262,143/25,000,000, so is close to 1/100th sec
; **
; **
; ** Now write binary 00000011 to timer control register:
; **	Bit0 = 1 (enable interrupt from that timer)
; **	Bit 1 = 1 enable counting
; */
; Timer1Control = 3;
       move.b    #3,4194354
       rts
; }
; void main(void)
; {
       xdef      _main
_main:
       link      A6,#-12
       movem.l   A2/A3/A4,-(A7)
       lea       _InstallExceptionHandler.L,A2
       lea       _Timer_ISR.L,A3
       lea       _printf.L,A4
; char *BugMessage = "DE1-68k 15/11/2024 14:44";
       lea       @m68kde~1_25.L,A0
       move.l    A0,-12(A6)
; char *CopyrightMessage = "Copyright (C) PJ Davies 2016";
       lea       @m68kde~1_26.L,A0
       move.l    A0,-8(A6)
; char *nameAndStudentNumber = "Yair Linn";
       lea       @m68kde~1_27.L,A0
       move.l    A0,-4(A6)
; clock_count_ms = 0;
       clr.l     _clock_count_ms.L
; Init_RS232() ;     // initialise the RS232 port
       jsr       _Init_RS232
; InstallExceptionHandler(Timer_ISR, 25) ;		      // install handler for interrupts
       pea       25
       move.l    A3,-(A7)
       jsr       (A2)
       addq.w    #8,A7
; InstallExceptionHandler(Timer_ISR, 26) ;		      // install handler for interrupts
       pea       26
       move.l    A3,-(A7)
       jsr       (A2)
       addq.w    #8,A7
; InstallExceptionHandler(Timer_ISR, 27) ;		      // install handler for interrupts
       pea       27
       move.l    A3,-(A7)
       jsr       (A2)
       addq.w    #8,A7
; InstallExceptionHandler(Timer_ISR, 28) ;		      // install handler for interrupts
       pea       28
       move.l    A3,-(A7)
       jsr       (A2)
       addq.w    #8,A7
; InstallExceptionHandler(Timer_ISR, 29) ;		      // install handler for interrupts
       pea       29
       move.l    A3,-(A7)
       jsr       (A2)
       addq.w    #8,A7
; InstallExceptionHandler(Timer_ISR, 30) ;		      // install handler for interrupts
       pea       30
       move.l    A3,-(A7)
       jsr       (A2)
       addq.w    #8,A7
; InstallExceptionHandler(UnhandledIRQ7, 31) ;		      // install handler for interrupts
       pea       31
       pea       _UnhandledIRQ7.L
       jsr       (A2)
       addq.w    #8,A7
; InstallExceptionHandler(BusError,2) ;                          // install Bus error handler
       pea       2
       pea       _BusError.L
       jsr       (A2)
       addq.w    #8,A7
; InstallExceptionHandler(AddressError,3) ;                      // install address error handler (doesn't work on soft core 68k implementation)
       pea       3
       pea       _AddressError.L
       jsr       (A2)
       addq.w    #8,A7
; InstallExceptionHandler(IllegalInstruction,4) ;                // install illegal instruction exception handler
       pea       4
       pea       _IllegalInstruction.L
       jsr       (A2)
       addq.w    #8,A7
; InstallExceptionHandler(Dividebyzero,5) ;                      // install /0 exception handler
       pea       5
       pea       _Dividebyzero.L
       jsr       (A2)
       addq.w    #8,A7
; InstallExceptionHandler(Check,6) ;                             // install check instruction exception handler
       pea       6
       pea       _Check.L
       jsr       (A2)
       addq.w    #8,A7
; InstallExceptionHandler(Trapv,7) ;                             // install trapv instruction exception handler
       pea       7
       pea       _Trapv.L
       jsr       (A2)
       addq.w    #8,A7
; InstallExceptionHandler(PrivError,8) ;                         // install Priv Violation exception handler
       pea       8
       pea       _PrivError.L
       jsr       (A2)
       addq.w    #8,A7
; InstallExceptionHandler(UnitIRQ,15) ;                          // install uninitialised IRQ exception handler
       pea       15
       pea       _UnitIRQ.L
       jsr       (A2)
       addq.w    #8,A7
; InstallExceptionHandler(Check,24) ;                            // install spurious IRQ exception handler
       pea       24
       pea       _Check.L
       jsr       (A2)
       addq.w    #8,A7
; Timer1_Init();
       jsr       _Timer1_Init
; FlushKeyboard() ;                        // dump unread characters from keyboard
       jsr       _FlushKeyboard
; TraceException = 0 ;                     // clear trace exception port to remove any software generated single step/trace
       clr.b     4194314
; printf("\r\n%s", BugMessage) ;
       move.l    -12(A6),-(A7)
       pea       @m68kde~1_28.L
       jsr       (A4)
       addq.w    #8,A7
; printf("\r\n%s", CopyrightMessage) ;
       move.l    -8(A6),-(A7)
       pea       @m68kde~1_29.L
       jsr       (A4)
       addq.w    #8,A7
; printf("\r\n%s", nameAndStudentNumber);
       move.l    -4(A6),-(A7)
       pea       @m68kde~1_30.L
       jsr       (A4)
       addq.w    #8,A7
; menu();
       jsr       _menu
       movem.l   (A7)+,A2/A3/A4
       unlk      A6
       rts
; }
       section   const
@m68kde~1_1:
       dc.b      13,10,85,110,107,110,111,119,110,32,67,111,109
       dc.b      109,97,110,100,46,46,46,46,46,13,10,0
@m68kde~1_2:
       dc.b      13,10,80,114,111,103,114,97,109,32,69,110,100
       dc.b      101,100,32,40,84,82,65,80,32,35,49,53,41,46
       dc.b      46,46,46,0
@m68kde~1_3:
       dc.b      13,10,45,45,45,45,45,45,45,45,45,45,45,45,45
       dc.b      45,45,45,45,45,45,45,45,45,45,45,45,45,45,45
       dc.b      45,45,45,45,45,45,45,45,45,45,45,45,45,45,45
       dc.b      45,45,45,45,45,45,45,45,45,45,45,45,45,45,45
       dc.b      45,45,45,45,45,45,0
@m68kde~1_4:
       dc.b      13,10,32,32,70,105,110,97,108,32,80,114,111
       dc.b      106,101,99,116,0
@m68kde~1_5:
       dc.b      13,10,32,32,84,32,32,32,32,45,32,82,117,110
       dc.b      32,67,111,115,109,105,99,32,73,109,112,97,108
       dc.b      97,32,71,97,109,101,0
@m68kde~1_6:
       dc.b      13,10,32,32,71,32,32,32,32,45,32,82,117,110
       dc.b      32,71,114,97,112,104,105,99,115,32,84,101,115
       dc.b      116,0
@m68kde~1_7:
       dc.b      13,10,35,0
@m68kde~1_8:
       dc.b      10,82,117,110,110,105,110,103,32,67,111,115
       dc.b      109,105,99,32,73,109,112,97,108,97,115,32,71
       dc.b      97,109,101,10,0
@m68kde~1_9:
       dc.b      10,82,117,110,110,105,110,103,32,71,114,97,112
       dc.b      104,105,99,115,32,84,101,115,116,10,0
@m68kde~1_10:
       dc.b      13,10,13,10,80,114,111,103,114,97,109,32,65
       dc.b      66,79,82,84,32,33,33,33,33,33,33,13,10,0
@m68kde~1_11:
       dc.b      37,115,13,10,0
@m68kde~1_12:
       dc.b      13,10,13,10,80,114,111,103,114,97,109,32,65
       dc.b      66,79,82,84,32,33,33,33,33,33,0
@m68kde~1_13:
       dc.b      13,10,85,110,104,97,110,100,108,101,100,32,73
       dc.b      110,116,101,114,114,117,112,116,58,32,73,82
       dc.b      81,37,100,32,33,33,33,33,33,0
@m68kde~1_14:
       dc.b      65,68,68,82,69,83,83,32,69,82,82,79,82,58,32
       dc.b      49,54,32,111,114,32,51,50,32,66,105,116,32,84
       dc.b      114,97,110,115,102,101,114,32,116,111,47,102
       dc.b      114,111,109,32,97,110,32,79,68,68,32,65,100
       dc.b      100,114,101,115,115,46,46,46,46,0
@m68kde~1_15:
       dc.b      85,110,104,97,110,100,108,101,100,32,84,114
       dc.b      97,112,32,33,33,33,33,33,0
@m68kde~1_16:
       dc.b      66,85,83,32,69,114,114,111,114,33,0
@m68kde~1_17:
       dc.b      65,68,68,82,69,83,83,32,69,114,114,111,114,33
       dc.b      0
@m68kde~1_18:
       dc.b      73,76,76,69,71,65,76,32,73,78,83,84,82,85,67
       dc.b      84,73,79,78,0
@m68kde~1_19:
       dc.b      68,73,86,73,68,69,32,66,89,32,90,69,82,79,0
@m68kde~1_20:
       dc.b      39,67,72,75,39,32,73,78,83,84,82,85,67,84,73
       dc.b      79,78,0
@m68kde~1_21:
       dc.b      84,82,65,80,86,32,73,78,83,84,82,85,67,84,73
       dc.b      79,78,0
@m68kde~1_22:
       dc.b      80,82,73,86,73,76,69,71,69,32,86,73,79,76,65
       dc.b      84,73,79,78,0
@m68kde~1_23:
       dc.b      85,78,73,78,73,84,73,65,76,73,83,69,68,32,73
       dc.b      82,81,0
@m68kde~1_24:
       dc.b      83,80,85,82,73,79,85,83,32,73,82,81,0
@m68kde~1_25:
       dc.b      68,69,49,45,54,56,107,32,49,53,47,49,49,47,50
       dc.b      48,50,52,32,49,52,58,52,52,0
@m68kde~1_26:
       dc.b      67,111,112,121,114,105,103,104,116,32,40,67
       dc.b      41,32,80,74,32,68,97,118,105,101,115,32,50,48
       dc.b      49,54,0
@m68kde~1_27:
       dc.b      89,97,105,114,32,76,105,110,110,0
@m68kde~1_28:
       dc.b      13,10,37,115,0
@m68kde~1_29:
       dc.b      13,10,37,115,0
@m68kde~1_30:
       dc.b      13,10,37,115,0
       section   bss
       xdef      _i
_i:
       ds.b      4
       xdef      _x
_x:
       ds.b      4
       xdef      _y
_y:
       ds.b      4
       xdef      _z
_z:
       ds.b      4
       xdef      _PortA_Count
_PortA_Count:
       ds.b      4
       xdef      _Trace
_Trace:
       ds.b      4
       xdef      _GoFlag
_GoFlag:
       ds.b      4
       xdef      _Echo
_Echo:
       ds.b      4
       xdef      _d0
_d0:
       ds.b      4
       xdef      _d1
_d1:
       ds.b      4
       xdef      _d2
_d2:
       ds.b      4
       xdef      _d3
_d3:
       ds.b      4
       xdef      _d4
_d4:
       ds.b      4
       xdef      _d5
_d5:
       ds.b      4
       xdef      _d6
_d6:
       ds.b      4
       xdef      _d7
_d7:
       ds.b      4
       xdef      _a0
_a0:
       ds.b      4
       xdef      _a1
_a1:
       ds.b      4
       xdef      _a2
_a2:
       ds.b      4
       xdef      _a3
_a3:
       ds.b      4
       xdef      _a4
_a4:
       ds.b      4
       xdef      _a5
_a5:
       ds.b      4
       xdef      _a6
_a6:
       ds.b      4
       xdef      _PC
_PC:
       ds.b      4
       xdef      _SSP
_SSP:
       ds.b      4
       xdef      _USP
_USP:
       ds.b      4
       xdef      _SR
_SR:
       ds.b      2
       xdef      _BreakPointAddress
_BreakPointAddress:
       ds.b      32
       xdef      _BreakPointInstruction
_BreakPointInstruction:
       ds.b      16
       xdef      _BreakPointSetOrCleared
_BreakPointSetOrCleared:
       ds.b      32
       xdef      _InstructionSize
_InstructionSize:
       ds.b      4
       xdef      _WatchPointAddress
_WatchPointAddress:
       ds.b      32
       xdef      _WatchPointSetOrCleared
_WatchPointSetOrCleared:
       ds.b      32
       xdef      _clock_count_ms
_clock_count_ms:
       ds.b      4
       xdef      _TempString
_TempString:
       ds.b      100
       xref      _cosmic_impalas_main
       xref      _graphics_test_main
       xref      _toupper
       xref      _printf
