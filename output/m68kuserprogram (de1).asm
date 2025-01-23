; C:\M68KV6.0 - 800BY480\PROGRAMS\DEBUGMONITORCODE\M68KUSERPROGRAM (DE1).C - Compiled by CC68K  Version 5.00 (c) 1991-2005  Peter J. Fondse
; #include <stdio.h>
; #include <string.h>
; #include <ctype.h>
; //IMPORTANT
; //
; // Uncomment one of the two #defines below
; // Define StartOfExceptionVectorTable as 08030000 if running programs from sram or
; // 0B000000 for running programs from dram
; //
; // In your labs, you will initially start by designing a system with SRam and later move to
; // Dram, so these constants will need to be changed based on the version of the system you have
; // building
; //
; // The working 68k system SOF file posted on canvas that you can use for your pre-lab
; // is based around Dram so #define accordingly before building
; #define StartOfExceptionVectorTable 0x08030000
; // #define StartOfExceptionVectorTable 0x0B000000
; /**********************************************************************************************
; **	Parallel port addresses
; **********************************************************************************************/
; #define PortA   *(volatile unsigned char *)(0x00400000)
; #define PortB   *(volatile unsigned char *)(0x00400002)
; #define PortC   *(volatile unsigned char *)(0x00400004)
; #define PortD   *(volatile unsigned char *)(0x00400006)
; #define PortE   *(volatile unsigned char *)(0x00400008)
; /*********************************************************************************************
; **	Hex 7 seg displays port addresses
; *********************************************************************************************/
; #define HEX_A        *(volatile unsigned char *)(0x00400010)
; #define HEX_B        *(volatile unsigned char *)(0x00400012)
; #define HEX_C        *(volatile unsigned char *)(0x00400014)    // de2 only
; #define HEX_D        *(volatile unsigned char *)(0x00400016)    // de2 only
; /**********************************************************************************************
; **	LCD display port addresses
; **********************************************************************************************/
; #define LCDcommand   *(volatile unsigned char *)(0x00400020)
; #define LCDdata      *(volatile unsigned char *)(0x00400022)
; /********************************************************************************************
; **	Timer Port addresses
; *********************************************************************************************/
; #define Timer1Data      *(volatile unsigned char *)(0x00400030)
; #define Timer1Control   *(volatile unsigned char *)(0x00400032)
; #define Timer1Status    *(volatile unsigned char *)(0x00400032)
; #define Timer2Data      *(volatile unsigned char *)(0x00400034)
; #define Timer2Control   *(volatile unsigned char *)(0x00400036)
; #define Timer2Status    *(volatile unsigned char *)(0x00400036)
; #define Timer3Data      *(volatile unsigned char *)(0x00400038)
; #define Timer3Control   *(volatile unsigned char *)(0x0040003A)
; #define Timer3Status    *(volatile unsigned char *)(0x0040003A)
; #define Timer4Data      *(volatile unsigned char *)(0x0040003C)
; #define Timer4Control   *(volatile unsigned char *)(0x0040003E)
; #define Timer4Status    *(volatile unsigned char *)(0x0040003E)
; /*********************************************************************************************
; **	RS232 port addresses
; *********************************************************************************************/
; #define RS232_Control     *(volatile unsigned char *)(0x00400040)
; #define RS232_Status      *(volatile unsigned char *)(0x00400040)
; #define RS232_TxData      *(volatile unsigned char *)(0x00400042)
; #define RS232_RxData      *(volatile unsigned char *)(0x00400042)
; #define RS232_Baud        *(volatile unsigned char *)(0x00400044)
; /*********************************************************************************************
; **	PIA 1 and 2 port addresses
; *********************************************************************************************/
; #define PIA1_PortA_Data     *(volatile unsigned char *)(0x00400050)         // combined data and data direction register share same address
; #define PIA1_PortA_Control *(volatile unsigned char *)(0x00400052)
; #define PIA1_PortB_Data     *(volatile unsigned char *)(0x00400054)         // combined data and data direction register share same address
; #define PIA1_PortB_Control *(volatile unsigned char *)(0x00400056)
; #define PIA2_PortA_Data     *(volatile unsigned char *)(0x00400060)         // combined data and data direction register share same address
; #define PIA2_PortA_Control *(volatile unsigned char *)(0x00400062)
; #define PIA2_PortB_data     *(volatile unsigned char *)(0x00400064)         // combined data and data direction register share same address
; #define PIA2_PortB_Control *(volatile unsigned char *)(0x00400066)
; /*********************************************************************************************************************************
; (( DO NOT initialise global variables here, do it main even if you want 0
; (( it's a limitation of the compiler
; (( YOU HAVE BEEN WARNED
; *********************************************************************************************************************************/
; unsigned int i, x, y, z, PortA_Count;
; unsigned char Timer1Count, Timer2Count, Timer3Count, Timer4Count ;
; /*******************************************************************************************
; ** Function Prototypes
; *******************************************************************************************/
; void Wait1ms(void);
; void Wait3ms(void);
; void Init_LCD(void) ;
; void LCDOutchar(int c);
; void LCDOutMess(char *theMessage);
; void LCDClearln(void);
; void LCDline1Message(char *theMessage);
; void LCDline2Message(char *theMessage);
; int sprintf(char *out, const char *format, ...) ;
; /*****************************************************************************************
; **	Interrupt service routine for Timers
; **
; **  Timers 1 - 4 share a common IRQ on the CPU  so this function uses polling to figure
; **  out which timer is producing the interrupt
; **
; *****************************************************************************************/
; void Timer_ISR()
; {
       section   code
       xdef      _Timer_ISR
_Timer_ISR:
; if(Timer1Status == 1) {         // Did Timer 1 produce the Interrupt?
       move.b    4194354,D0
       cmp.b     #1,D0
       bne.s     Timer_ISR_1
; Timer1Control = 3;      	// reset the timer to clear the interrupt, enable interrupts and allow counter to run
       move.b    #3,4194354
; PortA = Timer1Count++ ;     // increment an LED count on PortA with each tick of Timer 1
       move.b    _Timer1Count.L,D0
       addq.b    #1,_Timer1Count.L
       move.b    D0,4194304
Timer_ISR_1:
; }
; if(Timer2Status == 1) {         // Did Timer 2 produce the Interrupt?
       move.b    4194358,D0
       cmp.b     #1,D0
       bne.s     Timer_ISR_3
; Timer2Control = 3;      	// reset the timer to clear the interrupt, enable interrupts and allow counter to run
       move.b    #3,4194358
; PortC = Timer2Count++ ;     // increment an LED count on PortC with each tick of Timer 2
       move.b    _Timer2Count.L,D0
       addq.b    #1,_Timer2Count.L
       move.b    D0,4194308
Timer_ISR_3:
; }
; if(Timer3Status == 1) {         // Did Timer 3 produce the Interrupt?
       move.b    4194362,D0
       cmp.b     #1,D0
       bne.s     Timer_ISR_5
; Timer3Control = 3;      	// reset the timer to clear the interrupt, enable interrupts and allow counter to run
       move.b    #3,4194362
; HEX_A = Timer3Count++ ;     // increment a HEX count on Port HEX_A with each tick of Timer 3
       move.b    _Timer3Count.L,D0
       addq.b    #1,_Timer3Count.L
       move.b    D0,4194320
Timer_ISR_5:
; }
; if(Timer4Status == 1) {         // Did Timer 4 produce the Interrupt?
       move.b    4194366,D0
       cmp.b     #1,D0
       bne.s     Timer_ISR_7
; Timer4Control = 3;      	// reset the timer to clear the interrupt, enable interrupts and allow counter to run
       move.b    #3,4194366
; HEX_B = Timer4Count++ ;     // increment a HEX count on HEX_B with each tick of Timer 4
       move.b    _Timer4Count.L,D0
       addq.b    #1,_Timer4Count.L
       move.b    D0,4194322
Timer_ISR_7:
       rts
; }
; }
; /*****************************************************************************************
; **	Interrupt service routine for ACIA. This device has it's own dedicate IRQ level
; **  Add your code here to poll Status register and clear interrupt
; *****************************************************************************************/
; void ACIA_ISR()
; {}
       xdef      _ACIA_ISR
_ACIA_ISR:
       rts
; /***************************************************************************************
; **	Interrupt service routine for PIAs 1 and 2. These devices share an IRQ level
; **  Add your code here to poll Status register and clear interrupt
; *****************************************************************************************/
; void PIA_ISR()
; {}
       xdef      _PIA_ISR
_PIA_ISR:
       rts
; /***********************************************************************************
; **	Interrupt service routine for Key 2 on DE1 board. Add your own response here
; ************************************************************************************/
; void Key2PressISR()
; {}
       xdef      _Key2PressISR
_Key2PressISR:
       rts
; /***********************************************************************************
; **	Interrupt service routine for Key 1 on DE1 board. Add your own response here
; ************************************************************************************/
; void Key1PressISR()
; {}
       xdef      _Key1PressISR
_Key1PressISR:
       rts
; /************************************************************************************
; **   Delay Subroutine to give the 68000 something useless to do to waste 1 mSec
; ************************************************************************************/
; void Wait1ms(void)
; {
       xdef      _Wait1ms
_Wait1ms:
       move.l    D2,-(A7)
; int  i ;
; for(i = 0; i < 1000; i ++)
       clr.l     D2
Wait1ms_1:
       cmp.l     #1000,D2
       bge.s     Wait1ms_3
       addq.l    #1,D2
       bra       Wait1ms_1
Wait1ms_3:
       move.l    (A7)+,D2
       rts
; ;
; }
; /************************************************************************************
; **  Subroutine to give the 68000 something useless to do to waste 3 mSec
; **************************************************************************************/
; void Wait3ms(void)
; {
       xdef      _Wait3ms
_Wait3ms:
       move.l    D2,-(A7)
; int i ;
; for(i = 0; i < 3; i++)
       clr.l     D2
Wait3ms_1:
       cmp.l     #3,D2
       bge.s     Wait3ms_3
; Wait1ms() ;
       jsr       _Wait1ms
       addq.l    #1,D2
       bra       Wait3ms_1
Wait3ms_3:
       move.l    (A7)+,D2
       rts
; }
; /*********************************************************************************************
; **  Subroutine to initialise the LCD display by writing some commands to the LCD internal registers
; **  Sets it for parallel port and 2 line display mode (if I recall correctly)
; *********************************************************************************************/
; void Init_LCD(void)
; {
       xdef      _Init_LCD
_Init_LCD:
; LCDcommand = 0x0c ;
       move.b    #12,4194336
; Wait3ms() ;
       jsr       _Wait3ms
; LCDcommand = 0x38 ;
       move.b    #56,4194336
; Wait3ms() ;
       jsr       _Wait3ms
       rts
; }
; /*********************************************************************************************
; **  Subroutine to initialise the RS232 Port by writing some commands to the internal registers
; *********************************************************************************************/
; void Init_RS232(void)
; {
       xdef      _Init_RS232
_Init_RS232:
; RS232_Control = 0x15 ; //  %00010101 set up 6850 uses divide by 16 clock, set RTS low, 8 bits no parity, 1 stop bit, transmitter interrupt disabled
       move.b    #21,4194368
; RS232_Baud = 0x1 ;      // program baud rate generator 001 = 115k, 010 = 57.6k, 011 = 38.4k, 100 = 19.2, all others = 9600
       move.b    #1,4194372
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
; while((RS232_Status & (char)(0x02)) != (char)(0x02))    // wait for Tx bit in status register or 6850 serial comms chip to be '1'
_putch_1:
       move.b    4194368,D0
       and.b     #2,D0
       cmp.b     #2,D0
       beq.s     _putch_3
       bra       _putch_1
_putch_3:
; ;
; RS232_TxData = (c & (char)(0x7f));                      // write to the data register to output the character (mask off bit 8 to keep it 7 bit ASCII)
       move.l    8(A6),D0
       and.l     #127,D0
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
; **  NOTE you do not call this function directly, instead you call the normal getchar() function
; **  which in turn calls _getch() below). Other functions like gets(), scanf() call getchar() so will
; **  call _getch() also
; *********************************************************************************************************/
; int _getch( void )
; {
       xdef      __getch
__getch:
       link      A6,#-4
; char c ;
; while((RS232_Status & (char)(0x01)) != (char)(0x01))    // wait for Rx bit in 6850 serial comms chip status register to be '1'
_getch_1:
       move.b    4194368,D0
       and.b     #1,D0
       cmp.b     #1,D0
       beq.s     _getch_3
       bra       _getch_1
_getch_3:
; ;
; return (RS232_RxData & (char)(0x7f));                   // read received character, mask off top bit and return as 7 bit ASCII character
       move.b    4194370,D0
       and.l     #255,D0
       and.l     #127,D0
       unlk      A6
       rts
; }
; /******************************************************************************
; **  Subroutine to output a single character to the 2 row LCD display
; **  It is assumed the character is an ASCII code and it will be displayed at the
; **  current cursor position
; *******************************************************************************/
; void LCDOutchar(int c)
; {
       xdef      _LCDOutchar
_LCDOutchar:
       link      A6,#0
; LCDdata = (char)(c);
       move.l    8(A6),D0
       move.b    D0,4194338
; Wait1ms() ;
       jsr       _Wait1ms
       unlk      A6
       rts
; }
; /**********************************************************************************
; *subroutine to output a message at the current cursor position of the LCD display
; ************************************************************************************/
; void LCDOutMessage(char *theMessage)
; {
       xdef      _LCDOutMessage
_LCDOutMessage:
       link      A6,#-4
; char c ;
; while((c = *theMessage++) != 0)     // output characters from the string until NULL
LCDOutMessage_1:
       move.l    8(A6),A0
       addq.l    #1,8(A6)
       move.b    (A0),-1(A6)
       move.b    (A0),D0
       beq.s     LCDOutMessage_3
; LCDOutchar(c) ;
       move.b    -1(A6),D1
       ext.w     D1
       ext.l     D1
       move.l    D1,-(A7)
       jsr       _LCDOutchar
       addq.w    #4,A7
       bra       LCDOutMessage_1
LCDOutMessage_3:
       unlk      A6
       rts
; }
; /******************************************************************************
; *subroutine to clear the line by issuing 24 space characters
; *******************************************************************************/
; void LCDClearln(void)
; {
       xdef      _LCDClearln
_LCDClearln:
       move.l    D2,-(A7)
; int i ;
; for(i = 0; i < 24; i ++)
       clr.l     D2
LCDClearln_1:
       cmp.l     #24,D2
       bge.s     LCDClearln_3
; LCDOutchar(' ') ;       // write a space char to the LCD display
       pea       32
       jsr       _LCDOutchar
       addq.w    #4,A7
       addq.l    #1,D2
       bra       LCDClearln_1
LCDClearln_3:
       move.l    (A7)+,D2
       rts
; }
; /******************************************************************************
; **  Subroutine to move the LCD cursor to the start of line 1 and clear that line
; *******************************************************************************/
; void LCDLine1Message(char *theMessage)
; {
       xdef      _LCDLine1Message
_LCDLine1Message:
       link      A6,#0
; LCDcommand = 0x80 ;
       move.b    #128,4194336
; Wait3ms();
       jsr       _Wait3ms
; LCDClearln() ;
       jsr       _LCDClearln
; LCDcommand = 0x80 ;
       move.b    #128,4194336
; Wait3ms() ;
       jsr       _Wait3ms
; LCDOutMessage(theMessage) ;
       move.l    8(A6),-(A7)
       jsr       _LCDOutMessage
       addq.w    #4,A7
       unlk      A6
       rts
; }
; /******************************************************************************
; **  Subroutine to move the LCD cursor to the start of line 2 and clear that line
; *******************************************************************************/
; void LCDLine2Message(char *theMessage)
; {
       xdef      _LCDLine2Message
_LCDLine2Message:
       link      A6,#0
; LCDcommand = 0xC0 ;
       move.b    #192,4194336
; Wait3ms();
       jsr       _Wait3ms
; LCDClearln() ;
       jsr       _LCDClearln
; LCDcommand = 0xC0 ;
       move.b    #192,4194336
; Wait3ms() ;
       jsr       _Wait3ms
; LCDOutMessage(theMessage) ;
       move.l    8(A6),-(A7)
       jsr       _LCDOutMessage
       addq.w    #4,A7
       unlk      A6
       rts
; }
; /*********************************************************************************************************************************
; **  IMPORTANT FUNCTION
; **  This function install an exception handler so you can capture and deal with any 68000 exception in your program
; **  You pass it the name of a function in your code that will get called in response to the exception (as the 1st parameter)
; **  and in the 2nd parameter, you pass it the exception number that you want to take over (see 68000 exceptions for details)
; **  Calling this function allows you to deal with Interrupts for example
; ***********************************************************************************************************************************/
; void InstallExceptionHandler( void (*function_ptr)(), int level)
; {
       xdef      _InstallExceptionHandler
_InstallExceptionHandler:
       link      A6,#-4
; volatile long int *RamVectorAddress = (volatile long int *)(StartOfExceptionVectorTable) ;   // pointer to the Ram based interrupt vector table created in Cstart in debug monitor
       move.l    #134414336,-4(A6)
; RamVectorAddress[level] = (long int *)(function_ptr);                       // install the address of our function into the exception table
       move.l    -4(A6),A0
       move.l    12(A6),D0
       lsl.l     #2,D0
       move.l    8(A6),0(A0,D0.L)
       unlk      A6
       rts
; }
; /******************************************************************************************************************************
; * Start of user program
; ******************************************************************************************************************************/
; void MemoryTest(void)
; {
       xdef      _MemoryTest
_MemoryTest:
       link      A6,#-188
       movem.l   D2/D3/D4/D5/D6/A2/A3/A4,-(A7)
       lea       _printf.L,A2
       lea       _scanf.L,A3
       lea       -4(A6),A4
; unsigned int *RamPtr, counter1=1 ;
       move.l    #1,-184(A6)
; register unsigned int i ;
; unsigned int Start, End ;
; char c, text[150];
; unsigned int* addressPointer;
; unsigned int startAddress = NULL;
       clr.l     -16(A6)
; unsigned int endAddress = NULL;
       clr.l     -12(A6)
; unsigned int bitLength;
; unsigned int dataSize = 0;
       clr.l     -8(A6)
; unsigned int dataPattern = 0;
       clr.l     D2
; unsigned int currAddress;
; unsigned int addrCount;
; unsigned int intBuffer = NULL;
       clr.l     (A4)
; // printf("\r\nStart Address: ") ;
; // Start = Get8HexDigits(0) ;
; // printf("\r\nEnd Address: ") ;
; // End = Get8HexDigits(0) ;
; // TODO
; scanflush();
       jsr       _scanflush
; memset(text, 0, sizeof(text));  // fills with zeros
       pea       150
       clr.l     -(A7)
       pea       -166(A6)
       jsr       _memset
       add.w     #12,A7
; printf("Enter what size of memory you want to read/write\n Byte = 0\n Word = 1\n Long Word = 2\n");
       pea       @m68kus~1_1.L
       jsr       (A2)
       addq.w    #4,A7
; scanf("%d", &dataSize);
       pea       -8(A6)
       pea       @m68kus~1_2.L
       jsr       (A3)
       addq.w    #8,A7
; if (dataSize == 0) {
       move.l    -8(A6),D0
       bne       MemoryTest_1
; printf("Enter which data pattern you want to write into memory\n 0xA1 = 0\n 0xB2 = 1\n 0xC3 = 2\n 0xD4 = 3\n");
       pea       @m68kus~1_3.L
       jsr       (A2)
       addq.w    #4,A7
; scanf("%d", &intBuffer);
       move.l    A4,-(A7)
       pea       @m68kus~1_2.L
       jsr       (A3)
       addq.w    #8,A7
; switch (intBuffer) {
       move.l    (A4),D0
       cmp.l     #4,D0
       bhs.s     MemoryTest_4
       asl.l     #1,D0
       move.w    MemoryTest_5(PC,D0.L),D0
       jmp       MemoryTest_5(PC,D0.W)
MemoryTest_5:
       dc.w      MemoryTest_6-MemoryTest_5
       dc.w      MemoryTest_7-MemoryTest_5
       dc.w      MemoryTest_8-MemoryTest_5
       dc.w      MemoryTest_9-MemoryTest_5
MemoryTest_6:
; case(0):
; dataPattern = 0xA1;
       move.l    #161,D2
; break;
       bra.s     MemoryTest_4
MemoryTest_7:
; case(1):
; dataPattern = 0xB2;
       move.l    #178,D2
; break;
       bra.s     MemoryTest_4
MemoryTest_8:
; case(2):
; dataPattern = 0xC3;
       move.l    #195,D2
; break;
       bra.s     MemoryTest_4
MemoryTest_9:
; case(3):
; dataPattern = 0xD4;
       move.l    #212,D2
; break;
MemoryTest_4:
; }
; bitLength = 8;
       moveq     #8,D4
       bra       MemoryTest_11
MemoryTest_1:
; } else if (dataSize == 1) {
       move.l    -8(A6),D0
       cmp.l     #1,D0
       bne       MemoryTest_10
; printf("Enter which data pattern you want to write into memory\n 0xABCD = 0\n 0x1234 = 1\n 0xA1B2 = 2\n 0xC3D4 = 3\n");
       pea       @m68kus~1_4.L
       jsr       (A2)
       addq.w    #4,A7
; scanf("%d", &intBuffer);
       move.l    A4,-(A7)
       pea       @m68kus~1_2.L
       jsr       (A3)
       addq.w    #8,A7
; switch (intBuffer) {
       move.l    (A4),D0
       cmp.l     #4,D0
       bhs.s     MemoryTest_13
       asl.l     #1,D0
       move.w    MemoryTest_14(PC,D0.L),D0
       jmp       MemoryTest_14(PC,D0.W)
MemoryTest_14:
       dc.w      MemoryTest_15-MemoryTest_14
       dc.w      MemoryTest_16-MemoryTest_14
       dc.w      MemoryTest_17-MemoryTest_14
       dc.w      MemoryTest_18-MemoryTest_14
MemoryTest_15:
; case(0):
; dataPattern = 0xABCD;
       move.l    #43981,D2
; break;
       bra.s     MemoryTest_13
MemoryTest_16:
; case(1):
; dataPattern = 0x1234;
       move.l    #4660,D2
; break;
       bra.s     MemoryTest_13
MemoryTest_17:
; case(2):
; dataPattern = 0xA1B2;
       move.l    #41394,D2
; break;
       bra.s     MemoryTest_13
MemoryTest_18:
; case(3):
; dataPattern = 0xC3D4;
       move.l    #50132,D2
; break;
MemoryTest_13:
; }
; bitLength = 16;
       moveq     #16,D4
       bra       MemoryTest_11
MemoryTest_10:
; } else {
; printf("Enter which data pattern you want to write into memory\n 0xABCD_1234 = 0\n 0xAABB_CCDD = 1\n 0x1122_3344 = 2\n 0x7654_3210 = 3\n");
       pea       @m68kus~1_5.L
       jsr       (A2)
       addq.w    #4,A7
; scanf("%d", &intBuffer);
       move.l    A4,-(A7)
       pea       @m68kus~1_2.L
       jsr       (A3)
       addq.w    #8,A7
; switch (intBuffer) {
       move.l    (A4),D0
       cmp.l     #4,D0
       bhs.s     MemoryTest_20
       asl.l     #1,D0
       move.w    MemoryTest_21(PC,D0.L),D0
       jmp       MemoryTest_21(PC,D0.W)
MemoryTest_21:
       dc.w      MemoryTest_22-MemoryTest_21
       dc.w      MemoryTest_23-MemoryTest_21
       dc.w      MemoryTest_24-MemoryTest_21
       dc.w      MemoryTest_25-MemoryTest_21
MemoryTest_22:
; case(0):
; dataPattern = 0xABCD1234;
       move.l    #-1412623820,D2
; break;
       bra.s     MemoryTest_20
MemoryTest_23:
; case(1):
; dataPattern = 0xAABBCCDD;
       move.l    #-1430532899,D2
; break;
       bra.s     MemoryTest_20
MemoryTest_24:
; case(2):
; dataPattern = 0x11223344;
       move.l    #287454020,D2
; break;
       bra.s     MemoryTest_20
MemoryTest_25:
; case(3):
; dataPattern = 0x76543210;
       move.l    #1985229328,D2
; break;
MemoryTest_20:
; }
; bitLength = 32;
       moveq     #32,D4
MemoryTest_11:
; }
; while (startAddress == NULL || 
MemoryTest_26:
       move.l    -16(A6),D0
       beq.s     MemoryTest_29
       move.l    -16(A6),-(A7)
       move.l    D4,-(A7)
       jsr       ULDIV
       move.l    4(A7),D0
       addq.w    #8,A7
       tst.l     D0
       bne.s     MemoryTest_29
       move.l    -16(A6),D0
       cmp.l     #134348800,D0
       blo.s     MemoryTest_29
       move.l    #134414336,D0
       sub.l     D4,D0
       cmp.l     -16(A6),D0
       bhs.s     MemoryTest_28
MemoryTest_29:
; startAddress % bitLength != 0 || 
; startAddress < 0x08020000 || 
; startAddress > 0x08030000 - bitLength) {
; printf("Provide Start Address in hex (do not use 0x prefix)\n0x");
       pea       @m68kus~1_6.L
       jsr       (A2)
       addq.w    #4,A7
; scanf("%x", &startAddress);
       pea       -16(A6)
       pea       @m68kus~1_7.L
       jsr       (A3)
       addq.w    #8,A7
       bra       MemoryTest_26
MemoryTest_28:
; }
; while (endAddress == NULL || 
MemoryTest_30:
       move.l    -12(A6),D0
       beq.s     MemoryTest_33
       move.l    -12(A6),-(A7)
       move.l    D4,-(A7)
       jsr       ULDIV
       move.l    4(A7),D0
       addq.w    #8,A7
       tst.l     D0
       bne.s     MemoryTest_33
       move.l    #134414336,D0
       sub.l     D4,D0
       cmp.l     -12(A6),D0
       blo.s     MemoryTest_33
       move.l    -16(A6),D0
       add.l     D4,D0
       cmp.l     -12(A6),D0
       bls.s     MemoryTest_32
MemoryTest_33:
; endAddress % bitLength != 0 || 
; endAddress > 0x08030000 - bitLength || 
; endAddress < startAddress + bitLength) {
; printf("Provide End Address in hex (do not use 0x prefix)\n0x");
       pea       @m68kus~1_8.L
       jsr       (A2)
       addq.w    #4,A7
; scanf("%x", &endAddress);
       pea       -12(A6)
       pea       @m68kus~1_7.L
       jsr       (A3)
       addq.w    #8,A7
       bra       MemoryTest_30
MemoryTest_32:
; }
; printf("Start Address 0x%08x\n", startAddress);
       move.l    -16(A6),-(A7)
       pea       @m68kus~1_9.L
       jsr       (A2)
       addq.w    #8,A7
; printf("End Address: 0x%08x\n", endAddress);
       move.l    -12(A6),-(A7)
       pea       @m68kus~1_10.L
       jsr       (A2)
       addq.w    #8,A7
; addrCount = 0;
       clr.l     D6
; for (currAddress = startAddress; currAddress < endAddress; currAddress += bitLength) {
       move.l    -16(A6),D5
MemoryTest_34:
       cmp.l     -12(A6),D5
       bhs       MemoryTest_36
; if (endAddress - currAddress >= bitLength) {
       move.l    -12(A6),D0
       sub.l     D5,D0
       cmp.l     D4,D0
       blo       MemoryTest_37
; addressPointer = (int*)(currAddress);
       move.l    D5,D3
; *addressPointer = dataPattern;
       move.l    D3,A0
       move.l    D2,(A0)
; if (*addressPointer != dataPattern) {
       move.l    D3,A0
       cmp.l     (A0),D2
       beq.s     MemoryTest_39
; printf("ERROR... Value written to location 0x%x == 0x%x. Value Expected: 0x%x", (void*)addressPointer, *addressPointer, dataPattern);
       move.l    D2,-(A7)
       move.l    D3,A0
       move.l    (A0),-(A7)
       move.l    D3,-(A7)
       pea       @m68kus~1_11.L
       jsr       (A2)
       add.w     #16,A7
MemoryTest_39:
; }
; addrCount++;
       addq.l    #1,D6
; if (addrCount % 1 == 0) {
       move.l    D6,-(A7)
       pea       1
       jsr       ULDIV
       move.l    4(A7),D0
       addq.w    #8,A7
       tst.l     D0
       bne       MemoryTest_46
; if (dataSize == 0) {
       move.l    -8(A6),D0
       bne.s     MemoryTest_43
; printf("Address: 0x%x Value: 0x%02X\n",
       move.l    D3,A0
       move.l    (A0),-(A7)
       move.l    D3,-(A7)
       pea       @m68kus~1_12.L
       jsr       (A2)
       add.w     #12,A7
       bra       MemoryTest_46
MemoryTest_43:
; (unsigned int)addressPointer, *addressPointer);
; }
; else if (dataSize == 1) {
       move.l    -8(A6),D0
       cmp.l     #1,D0
       bne.s     MemoryTest_45
; printf("Address: 0x%x Value: 0x%04X\n",
       move.l    D3,A0
       move.l    (A0),-(A7)
       move.l    D3,-(A7)
       pea       @m68kus~1_13.L
       jsr       (A2)
       add.w     #12,A7
       bra.s     MemoryTest_46
MemoryTest_45:
; (unsigned int)addressPointer, *addressPointer);
; }
; else {
; printf("Address: 0x%x Value: 0x%08X\n",
       move.l    D3,A0
       move.l    (A0),-(A7)
       move.l    D3,-(A7)
       pea       @m68kus~1_14.L
       jsr       (A2)
       add.w     #12,A7
MemoryTest_46:
       bra.s     MemoryTest_38
MemoryTest_37:
; (unsigned int)addressPointer, *addressPointer);
; }
; }
; } else {
; printf("Current Address: 0x%x, No room to write to memory to fit within end address 0x%x", currAddress, endAddress);
       move.l    -12(A6),-(A7)
       move.l    D5,-(A7)
       pea       @m68kus~1_15.L
       jsr       (A2)
       add.w     #12,A7
MemoryTest_38:
       add.l     D4,D5
       bra       MemoryTest_34
MemoryTest_36:
       movem.l   (A7)+,D2/D3/D4/D5/D6/A2/A3/A4
       unlk      A6
       rts
; }
; }
; // add your code to test memory here using 32 bit reads and writes of data between the start and end of memory
; }
; void main()
; {
       xdef      _main
_main:
       link      A6,#-220
       movem.l   A2/A3,-(A7)
       lea       _InstallExceptionHandler.L,A2
       lea       _printf.L,A3
; unsigned int row, i=0, count=0, counter1=1;
       clr.l     -216(A6)
       clr.l     -212(A6)
       move.l    #1,-208(A6)
; char c, text[150];
; int PassFailFlag = 1;
       move.l    #1,-52(A6)
; unsigned int* baseAddressPtr = (int*)0x08020000;
       move.l    #134348800,-48(A6)
; unsigned int* addressPointer;
; unsigned int readValue;
; unsigned int memoryOffset;
; unsigned int startAddress = NULL;
       clr.l     -32(A6)
; unsigned int endAddress = NULL;
       clr.l     -28(A6)
; unsigned int bitLength;
; unsigned int dataSize = 0;
       clr.l     -20(A6)
; unsigned int dataPattern = 0;
       clr.l     -16(A6)
; unsigned int currAddress;
; unsigned int addrCount;
; unsigned int intBuffer = NULL;
       clr.l     -4(A6)
; i = x = y = z = PortA_Count = 0;
       clr.l     _PortA_Count.L
       clr.l     _z.L
       clr.l     _y.L
       clr.l     _x.L
       clr.l     -216(A6)
; Timer1Count = Timer2Count = Timer3Count = Timer4Count = 0;
       clr.b     _Timer4Count.L
       clr.b     _Timer3Count.L
       clr.b     _Timer2Count.L
       clr.b     _Timer1Count.L
; InstallExceptionHandler(PIA_ISR, 25);
       pea       25
       pea       _PIA_ISR.L
       jsr       (A2)
       addq.w    #8,A7
; InstallExceptionHandler(ACIA_ISR, 26);
       pea       26
       pea       _ACIA_ISR.L
       jsr       (A2)
       addq.w    #8,A7
; InstallExceptionHandler(Timer_ISR, 27);
       pea       27
       pea       _Timer_ISR.L
       jsr       (A2)
       addq.w    #8,A7
; InstallExceptionHandler(Key2PressISR, 28);
       pea       28
       pea       _Key2PressISR.L
       jsr       (A2)
       addq.w    #8,A7
; InstallExceptionHandler(Key1PressISR, 29);
       pea       29
       pea       _Key1PressISR.L
       jsr       (A2)
       addq.w    #8,A7
; Timer1Data = 0x10;
       move.b    #16,4194352
; Timer2Data = 0x20;
       move.b    #32,4194356
; Timer3Data = 0x15;
       move.b    #21,4194360
; Timer4Data = 0x25;
       move.b    #37,4194364
; Timer1Control = 3;
       move.b    #3,4194354
; Timer2Control = 3;
       move.b    #3,4194358
; Timer3Control = 3;
       move.b    #3,4194362
; Timer4Control = 3;
       move.b    #3,4194366
; Init_LCD();
       jsr       _Init_LCD
; Init_RS232();
       jsr       _Init_RS232
; scanflush();
       jsr       _scanflush
; printf("\r\nEnter Integer: ") ;
       pea       @m68kus~1_16.L
       jsr       (A3)
       addq.w    #4,A7
; scanf("%d", &i) ;
       pea       -216(A6)
       pea       @m68kus~1_2.L
       jsr       _scanf
       addq.w    #8,A7
; printf("You entered %d", i) ;
       move.l    -216(A6),-(A7)
       pea       @m68kus~1_17.L
       jsr       (A3)
       addq.w    #8,A7
; sprintf(text, "Hello CPEN 412 Student");
       pea       @m68kus~1_18.L
       pea       -202(A6)
       jsr       _sprintf
       addq.w    #8,A7
; LCDLine1Message(text);
       pea       -202(A6)
       jsr       _LCDLine1Message
       addq.w    #4,A7
; printf("\r\nHello CPEN 412 Student\r\nYour LEDs should be Flashing");
       pea       @m68kus~1_19.L
       jsr       (A3)
       addq.w    #4,A7
; printf("\r\nYour LCD should be displaying");
       pea       @m68kus~1_20.L
       jsr       (A3)
       addq.w    #4,A7
; MemoryTest();
       jsr       _MemoryTest
; // Memory test loop
; // for (memoryOffset = 0; memoryOffset < 0xFFFF; memoryOffset += 8) {
; //     addressPointer = (int*)(0x08020000 + memoryOffset);
; //     *addressPointer = memoryOffset;
; //     readValue = *addressPointer;
; //     sprintf(text, "Address: 0x%p Value: %d\n", (void*)addressPointer, readValue);
; //     LCDLine1Message(text);
; // }
; // scanflush();
; // memset(text, 0, sizeof(text));  // fills with zeros
; // printf("Enter what size of memory you want to read/write\n Byte = 0\n Word = 1\n Long Word = 2\n");
; // scanf("%d", &dataSize);
; // if (dataSize == 0) {
; //     printf("Enter which data pattern you want to write into memory\n 0xA1 = 0\n 0xB2 = 1\n 0xC3 = 2\n 0xD4 = 3\n");
; //     scanf("%d", &intBuffer);
; //     switch (intBuffer) {
; //         case(0):
; //             dataPattern = 0xA1;
; //             break;
; //         case(1):
; //             dataPattern = 0xB2;
; //             break;
; //         case(2):
; //             dataPattern = 0xC3;
; //             break;
; //         case(3):
; //             dataPattern = 0xD4;
; //             break;
; //     }
; //     bitLength = 8;
; // } else if (dataSize == 1) {
; //     printf("Enter which data pattern you want to write into memory\n 0xABCD = 0\n 0x1234 = 1\n 0xA1B2 = 2\n 0xC3D4 = 3\n");
; //     scanf("%d", &intBuffer);
; //     switch (intBuffer) {
; //         case(0):
; //             dataPattern = 0xABCD;
; //             break;
; //         case(1):
; //             dataPattern = 0x1234;
; //             break;
; //         case(2):
; //             dataPattern = 0xA1B2;
; //             break;
; //         case(3):
; //             dataPattern = 0xC3D4;
; //             break;
; //     }
; //     bitLength = 16;
; // } else {
; //     printf("Enter which data pattern you want to write into memory\n 0xABCD_1234 = 0\n 0xAABB_CCDD = 1\n 0x1122_3344 = 2\n 0x7654_3210 = 3\n");
; //     scanf("%d", &intBuffer);
; //     switch (intBuffer) {
; //         case(0):
; //             dataPattern = 0xABCD1234;
; //             break;
; //         case(1):
; //             dataPattern = 0xAABBCCDD;
; //             break;
; //         case(2):
; //             dataPattern = 0x11223344;
; //             break;
; //         case(3):
; //             dataPattern = 0x76543210;
; //             break;
; //     }
; //     bitLength = 32;
; // }
; // while (startAddress == NULL || 
; //         startAddress % bitLength != 0 || 
; //         startAddress < 0x08020000 || 
; //         startAddress > 0x08030000 - bitLength) {
; //     printf("Provide Start Address in hex (do not use 0x prefix)\n0x");
; //     scanf("%x", &startAddress);
; // }
; // while (endAddress == NULL || 
; //         endAddress % bitLength != 0 || 
; //         endAddress > 0x08030000 - bitLength || 
; //         endAddress < startAddress + bitLength) {
; //     printf("Provide End Address in hex (do not use 0x prefix)\n0x");
; //     scanf("%x", &endAddress);
; // }
; // printf("Start Address 0x%08x\n", startAddress);
; // printf("End Address: 0x%08x\n", endAddress);
; // addrCount = 0;
; // for (currAddress = startAddress; currAddress < endAddress; currAddress += bitLength) {
; //     if (endAddress - currAddress >= bitLength) {
; //         addressPointer = (int*)(currAddress);
; //         *addressPointer = dataPattern;
; //         if (*addressPointer != dataPattern) {
; //             printf("ERROR... Value written to location 0x%x == 0x%x. Value Expected: 0x%x", (void*)addressPointer, *addressPointer, dataPattern);
; //         }
; //         addrCount++;
; //         if (addrCount % 100 == 0) {
; //             if (dataSize == 0) {
; //                 printf("Address: 0x%x Value: 0x%02X\n",
; //                     (unsigned int)addressPointer, *addressPointer);
; //             }
; //             else if (dataSize == 1) {
; //                 printf("Address: 0x%x Value: 0x%04X\n",
; //                     (unsigned int)addressPointer, *addressPointer);
; //             }
; //             else {
; //                 printf("Address: 0x%x Value: 0x%08X\n",
; //                     (unsigned int)addressPointer, *addressPointer);
; //             }
; //         }
; //     } else {
; //         printf("Current Address: 0x%x, No room to write to memory to fit within end address 0x%x", currAddress, endAddress);
; //     }
; // }
; while(1);
main_1:
       bra       main_1
; }
       section   const
@m68kus~1_1:
       dc.b      69,110,116,101,114,32,119,104,97,116,32,115
       dc.b      105,122,101,32,111,102,32,109,101,109,111,114
       dc.b      121,32,121,111,117,32,119,97,110,116,32,116
       dc.b      111,32,114,101,97,100,47,119,114,105,116,101
       dc.b      10,32,66,121,116,101,32,61,32,48,10,32,87,111
       dc.b      114,100,32,61,32,49,10,32,76,111,110,103,32
       dc.b      87,111,114,100,32,61,32,50,10,0
@m68kus~1_2:
       dc.b      37,100,0
@m68kus~1_3:
       dc.b      69,110,116,101,114,32,119,104,105,99,104,32
       dc.b      100,97,116,97,32,112,97,116,116,101,114,110
       dc.b      32,121,111,117,32,119,97,110,116,32,116,111
       dc.b      32,119,114,105,116,101,32,105,110,116,111,32
       dc.b      109,101,109,111,114,121,10,32,48,120,65,49,32
       dc.b      61,32,48,10,32,48,120,66,50,32,61,32,49,10,32
       dc.b      48,120,67,51,32,61,32,50,10,32,48,120,68,52
       dc.b      32,61,32,51,10,0
@m68kus~1_4:
       dc.b      69,110,116,101,114,32,119,104,105,99,104,32
       dc.b      100,97,116,97,32,112,97,116,116,101,114,110
       dc.b      32,121,111,117,32,119,97,110,116,32,116,111
       dc.b      32,119,114,105,116,101,32,105,110,116,111,32
       dc.b      109,101,109,111,114,121,10,32,48,120,65,66,67
       dc.b      68,32,61,32,48,10,32,48,120,49,50,51,52,32,61
       dc.b      32,49,10,32,48,120,65,49,66,50,32,61,32,50,10
       dc.b      32,48,120,67,51,68,52,32,61,32,51,10,0
@m68kus~1_5:
       dc.b      69,110,116,101,114,32,119,104,105,99,104,32
       dc.b      100,97,116,97,32,112,97,116,116,101,114,110
       dc.b      32,121,111,117,32,119,97,110,116,32,116,111
       dc.b      32,119,114,105,116,101,32,105,110,116,111,32
       dc.b      109,101,109,111,114,121,10,32,48,120,65,66,67
       dc.b      68,95,49,50,51,52,32,61,32,48,10,32,48,120,65
       dc.b      65,66,66,95,67,67,68,68,32,61,32,49,10,32,48
       dc.b      120,49,49,50,50,95,51,51,52,52,32,61,32,50,10
       dc.b      32,48,120,55,54,53,52,95,51,50,49,48,32,61,32
       dc.b      51,10,0
@m68kus~1_6:
       dc.b      80,114,111,118,105,100,101,32,83,116,97,114
       dc.b      116,32,65,100,100,114,101,115,115,32,105,110
       dc.b      32,104,101,120,32,40,100,111,32,110,111,116
       dc.b      32,117,115,101,32,48,120,32,112,114,101,102
       dc.b      105,120,41,10,48,120,0
@m68kus~1_7:
       dc.b      37,120,0
@m68kus~1_8:
       dc.b      80,114,111,118,105,100,101,32,69,110,100,32
       dc.b      65,100,100,114,101,115,115,32,105,110,32,104
       dc.b      101,120,32,40,100,111,32,110,111,116,32,117
       dc.b      115,101,32,48,120,32,112,114,101,102,105,120
       dc.b      41,10,48,120,0
@m68kus~1_9:
       dc.b      83,116,97,114,116,32,65,100,100,114,101,115
       dc.b      115,32,48,120,37,48,56,120,10,0
@m68kus~1_10:
       dc.b      69,110,100,32,65,100,100,114,101,115,115,58
       dc.b      32,48,120,37,48,56,120,10,0
@m68kus~1_11:
       dc.b      69,82,82,79,82,46,46,46,32,86,97,108,117,101
       dc.b      32,119,114,105,116,116,101,110,32,116,111,32
       dc.b      108,111,99,97,116,105,111,110,32,48,120,37,120
       dc.b      32,61,61,32,48,120,37,120,46,32,86,97,108,117
       dc.b      101,32,69,120,112,101,99,116,101,100,58,32,48
       dc.b      120,37,120,0
@m68kus~1_12:
       dc.b      65,100,100,114,101,115,115,58,32,48,120,37,120
       dc.b      32,86,97,108,117,101,58,32,48,120,37,48,50,88
       dc.b      10,0
@m68kus~1_13:
       dc.b      65,100,100,114,101,115,115,58,32,48,120,37,120
       dc.b      32,86,97,108,117,101,58,32,48,120,37,48,52,88
       dc.b      10,0
@m68kus~1_14:
       dc.b      65,100,100,114,101,115,115,58,32,48,120,37,120
       dc.b      32,86,97,108,117,101,58,32,48,120,37,48,56,88
       dc.b      10,0
@m68kus~1_15:
       dc.b      67,117,114,114,101,110,116,32,65,100,100,114
       dc.b      101,115,115,58,32,48,120,37,120,44,32,78,111
       dc.b      32,114,111,111,109,32,116,111,32,119,114,105
       dc.b      116,101,32,116,111,32,109,101,109,111,114,121
       dc.b      32,116,111,32,102,105,116,32,119,105,116,104
       dc.b      105,110,32,101,110,100,32,97,100,100,114,101
       dc.b      115,115,32,48,120,37,120,0
@m68kus~1_16:
       dc.b      13,10,69,110,116,101,114,32,73,110,116,101,103
       dc.b      101,114,58,32,0
@m68kus~1_17:
       dc.b      89,111,117,32,101,110,116,101,114,101,100,32
       dc.b      37,100,0
@m68kus~1_18:
       dc.b      72,101,108,108,111,32,67,80,69,78,32,52,49,50
       dc.b      32,83,116,117,100,101,110,116,0
@m68kus~1_19:
       dc.b      13,10,72,101,108,108,111,32,67,80,69,78,32,52
       dc.b      49,50,32,83,116,117,100,101,110,116,13,10,89
       dc.b      111,117,114,32,76,69,68,115,32,115,104,111,117
       dc.b      108,100,32,98,101,32,70,108,97,115,104,105,110
       dc.b      103,0
@m68kus~1_20:
       dc.b      13,10,89,111,117,114,32,76,67,68,32,115,104
       dc.b      111,117,108,100,32,98,101,32,100,105,115,112
       dc.b      108,97,121,105,110,103,0
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
       xdef      _Timer1Count
_Timer1Count:
       ds.b      1
       xdef      _Timer2Count
_Timer2Count:
       ds.b      1
       xdef      _Timer3Count
_Timer3Count:
       ds.b      1
       xdef      _Timer4Count
_Timer4Count:
       ds.b      1
       xref      _sprintf
       xref      _memset
       xref      _scanf
       xref      ULDIV
       xref      _scanflush
       xref      _printf
