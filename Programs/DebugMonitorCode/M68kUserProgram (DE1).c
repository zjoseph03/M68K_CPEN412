#include <stdio.h>
#include <string.h>
#include <ctype.h>


//IMPORTANT
//
// Uncomment one of the two #defines below
// Define StartOfExceptionVectorTable as 08030000 if running programs from sram or
// 0B000000 for running programs from dram
//
// In your labs, you will initially start by designing a system with SRam and later move to
// Dram, so these constants will need to be changed based on the version of the system you have
// building
//
// The working 68k system SOF file posted on canvas that you can use for your pre-lab
// is based around Dram so #define accordingly before building

//#define StartOfExceptionVectorTable 0x08030000
#define StartOfExceptionVectorTable 0x0B000000

/**********************************************************************************************
**	Parallel port addresses
**********************************************************************************************/

#define PortA   *(volatile unsigned char *)(0x00400000)
#define PortB   *(volatile unsigned char *)(0x00400002)
#define PortC   *(volatile unsigned char *)(0x00400004)
#define PortD   *(volatile unsigned char *)(0x00400006)
#define PortE   *(volatile unsigned char *)(0x00400008)

/*********************************************************************************************
**	Hex 7 seg displays port addresses
*********************************************************************************************/

#define HEX_A        *(volatile unsigned char *)(0x00400010)
#define HEX_B        *(volatile unsigned char *)(0x00400012)
#define HEX_C        *(volatile unsigned char *)(0x00400014)    // de2 only
#define HEX_D        *(volatile unsigned char *)(0x00400016)    // de2 only

/**********************************************************************************************
**	LCD display port addresses
**********************************************************************************************/

#define LCDcommand   *(volatile unsigned char *)(0x00400020)
#define LCDdata      *(volatile unsigned char *)(0x00400022)

/********************************************************************************************
**	Timer Port addresses
*********************************************************************************************/

#define Timer1Data      *(volatile unsigned char *)(0x00400030)
#define Timer1Control   *(volatile unsigned char *)(0x00400032)
#define Timer1Status    *(volatile unsigned char *)(0x00400032)

#define Timer2Data      *(volatile unsigned char *)(0x00400034)
#define Timer2Control   *(volatile unsigned char *)(0x00400036)
#define Timer2Status    *(volatile unsigned char *)(0x00400036)

#define Timer3Data      *(volatile unsigned char *)(0x00400038)
#define Timer3Control   *(volatile unsigned char *)(0x0040003A)
#define Timer3Status    *(volatile unsigned char *)(0x0040003A)

#define Timer4Data      *(volatile unsigned char *)(0x0040003C)
#define Timer4Control   *(volatile unsigned char *)(0x0040003E)
#define Timer4Status    *(volatile unsigned char *)(0x0040003E)

/*********************************************************************************************
**	RS232 port addresses
*********************************************************************************************/

#define RS232_Control     *(volatile unsigned char *)(0x00400040)
#define RS232_Status      *(volatile unsigned char *)(0x00400040)
#define RS232_TxData      *(volatile unsigned char *)(0x00400042)
#define RS232_RxData      *(volatile unsigned char *)(0x00400042)
#define RS232_Baud        *(volatile unsigned char *)(0x00400044)

/*********************************************************************************************
**	PIA 1 and 2 port addresses
*********************************************************************************************/

#define PIA1_PortA_Data     *(volatile unsigned char *)(0x00400050)         // combined data and data direction register share same address
#define PIA1_PortA_Control *(volatile unsigned char *)(0x00400052)
#define PIA1_PortB_Data     *(volatile unsigned char *)(0x00400054)         // combined data and data direction register share same address
#define PIA1_PortB_Control *(volatile unsigned char *)(0x00400056)

#define PIA2_PortA_Data     *(volatile unsigned char *)(0x00400060)         // combined data and data direction register share same address
#define PIA2_PortA_Control *(volatile unsigned char *)(0x00400062)
#define PIA2_PortB_data     *(volatile unsigned char *)(0x00400064)         // combined data and data direction register share same address
#define PIA2_PortB_Control *(volatile unsigned char *)(0x00400066)


/*********************************************************************************************************************************
(( DO NOT initialise global variables here, do it main even if you want 0
(( it's a limitation of the compiler
(( YOU HAVE BEEN WARNED
*********************************************************************************************************************************/

unsigned int i, x, y, z, PortA_Count;
unsigned char Timer1Count, Timer2Count, Timer3Count, Timer4Count ;

/*******************************************************************************************
** Function Prototypes
*******************************************************************************************/
void Wait1ms(void);
void Wait3ms(void);
void Init_LCD(void) ;
void LCDOutchar(int c);
void LCDOutMess(char *theMessage);
void LCDClearln(void);
void LCDline1Message(char *theMessage);
void LCDline2Message(char *theMessage);
int sprintf(char *out, const char *format, ...) ;

/*****************************************************************************************
**	Interrupt service routine for Timers
**
**  Timers 1 - 4 share a common IRQ on the CPU  so this function uses polling to figure
**  out which timer is producing the interrupt
**
*****************************************************************************************/

void Timer_ISR()
{
   	if(Timer1Status == 1) {         // Did Timer 1 produce the Interrupt?
   	    Timer1Control = 3;      	// reset the timer to clear the interrupt, enable interrupts and allow counter to run
   	    PortA = Timer1Count++ ;     // increment an LED count on PortA with each tick of Timer 1
   	}

  	if(Timer2Status == 1) {         // Did Timer 2 produce the Interrupt?
   	    Timer2Control = 3;      	// reset the timer to clear the interrupt, enable interrupts and allow counter to run
   	    PortC = Timer2Count++ ;     // increment an LED count on PortC with each tick of Timer 2
   	}

   	if(Timer3Status == 1) {         // Did Timer 3 produce the Interrupt?
   	    Timer3Control = 3;      	// reset the timer to clear the interrupt, enable interrupts and allow counter to run
        HEX_A = Timer3Count++ ;     // increment a HEX count on Port HEX_A with each tick of Timer 3
   	}

   	if(Timer4Status == 1) {         // Did Timer 4 produce the Interrupt?
   	    Timer4Control = 3;      	// reset the timer to clear the interrupt, enable interrupts and allow counter to run
        HEX_B = Timer4Count++ ;     // increment a HEX count on HEX_B with each tick of Timer 4
   	}
}

/*****************************************************************************************
**	Interrupt service routine for ACIA. This device has it's own dedicate IRQ level
**  Add your code here to poll Status register and clear interrupt
*****************************************************************************************/

void ACIA_ISR()
{}

/***************************************************************************************
**	Interrupt service routine for PIAs 1 and 2. These devices share an IRQ level
**  Add your code here to poll Status register and clear interrupt
*****************************************************************************************/

void PIA_ISR()
{}

/***********************************************************************************
**	Interrupt service routine for Key 2 on DE1 board. Add your own response here
************************************************************************************/
void Key2PressISR()
{}

/***********************************************************************************
**	Interrupt service routine for Key 1 on DE1 board. Add your own response here
************************************************************************************/
void Key1PressISR()
{}

/************************************************************************************
**   Delay Subroutine to give the 68000 something useless to do to waste 1 mSec
************************************************************************************/
void Wait1ms(void)
{
    int  i ;
    for(i = 0; i < 1000; i ++)
        ;
}

/************************************************************************************
**  Subroutine to give the 68000 something useless to do to waste 3 mSec
**************************************************************************************/
void Wait3ms(void)
{
    int i ;
    for(i = 0; i < 3; i++)
        Wait1ms() ;
}

/*********************************************************************************************
**  Subroutine to initialise the LCD display by writing some commands to the LCD internal registers
**  Sets it for parallel port and 2 line display mode (if I recall correctly)
*********************************************************************************************/
void Init_LCD(void)
{
    LCDcommand = 0x0c ;
    Wait3ms() ;
    LCDcommand = 0x38 ;
    Wait3ms() ;
}

/*********************************************************************************************
**  Subroutine to initialise the RS232 Port by writing some commands to the internal registers
*********************************************************************************************/
void Init_RS232(void)
{
    RS232_Control = 0x15 ; //  %00010101 set up 6850 uses divide by 16 clock, set RTS low, 8 bits no parity, 1 stop bit, transmitter interrupt disabled
    RS232_Baud = 0x1 ;      // program baud rate generator 001 = 115k, 010 = 57.6k, 011 = 38.4k, 100 = 19.2, all others = 9600
}

/*********************************************************************************************************
**  Subroutine to provide a low level output function to 6850 ACIA
**  This routine provides the basic functionality to output a single character to the serial Port
**  to allow the board to communicate with HyperTerminal Program
**
**  NOTE you do not call this function directly, instead you call the normal putchar() function
**  which in turn calls _putch() below). Other functions like puts(), printf() call putchar() so will
**  call _putch() also
*********************************************************************************************************/

int _putch( int c)
{
    while((RS232_Status & (char)(0x02)) != (char)(0x02))    // wait for Tx bit in status register or 6850 serial comms chip to be '1'
        ;

    RS232_TxData = (c & (char)(0x7f));                      // write to the data register to output the character (mask off bit 8 to keep it 7 bit ASCII)
    return c ;                                              // putchar() expects the character to be returned
}

/*********************************************************************************************************
**  Subroutine to provide a low level input function to 6850 ACIA
**  This routine provides the basic functionality to input a single character from the serial Port
**  to allow the board to communicate with HyperTerminal Program Keyboard (your PC)
**
**  NOTE you do not call this function directly, instead you call the normal getchar() function
**  which in turn calls _getch() below). Other functions like gets(), scanf() call getchar() so will
**  call _getch() also
*********************************************************************************************************/
int _getch( void )
{
    char c ;
    while((RS232_Status & (char)(0x01)) != (char)(0x01))    // wait for Rx bit in 6850 serial comms chip status register to be '1'
        ;

    return (RS232_RxData & (char)(0x7f));                   // read received character, mask off top bit and return as 7 bit ASCII character
}

/******************************************************************************
**  Subroutine to output a single character to the 2 row LCD display
**  It is assumed the character is an ASCII code and it will be displayed at the
**  current cursor position
*******************************************************************************/
void LCDOutchar(int c)
{
    LCDdata = (char)(c);
    Wait1ms() ;
}

/**********************************************************************************
*subroutine to output a message at the current cursor position of the LCD display
************************************************************************************/
void LCDOutMessage(char *theMessage)
{
    char c ;
    while((c = *theMessage++) != 0)     // output characters from the string until NULL
        LCDOutchar(c) ;
}

/******************************************************************************
*subroutine to clear the line by issuing 24 space characters
*******************************************************************************/
void LCDClearln(void)
{
    int i ;
    for(i = 0; i < 24; i ++)
        LCDOutchar(' ') ;       // write a space char to the LCD display
}

/******************************************************************************
**  Subroutine to move the LCD cursor to the start of line 1 and clear that line
*******************************************************************************/
void LCDLine1Message(char *theMessage)
{
    LCDcommand = 0x80 ;
    Wait3ms();
    LCDClearln() ;
    LCDcommand = 0x80 ;
    Wait3ms() ;
    LCDOutMessage(theMessage) ;
}

/******************************************************************************
**  Subroutine to move the LCD cursor to the start of line 2 and clear that line
*******************************************************************************/
void LCDLine2Message(char *theMessage)
{
    LCDcommand = 0xC0 ;
    Wait3ms();
    LCDClearln() ;
    LCDcommand = 0xC0 ;
    Wait3ms() ;
    LCDOutMessage(theMessage) ;
}

/*********************************************************************************************************************************
**  IMPORTANT FUNCTION
**  This function install an exception handler so you can capture and deal with any 68000 exception in your program
**  You pass it the name of a function in your code that will get called in response to the exception (as the 1st parameter)
**  and in the 2nd parameter, you pass it the exception number that you want to take over (see 68000 exceptions for details)
**  Calling this function allows you to deal with Interrupts for example
***********************************************************************************************************************************/

void InstallExceptionHandler( void (*function_ptr)(), int level)
{
    volatile long int *RamVectorAddress = (volatile long int *)(StartOfExceptionVectorTable) ;   // pointer to the Ram based interrupt vector table created in Cstart in debug monitor

    RamVectorAddress[level] = (long int *)(function_ptr);                       // install the address of our function into the exception table
}

/******************************************************************************************************************************
* Start of user program
******************************************************************************************************************************/
void MemoryTest(void)
{
    unsigned int *RamPtr, counter1=1 ;
    register unsigned int i ;
    unsigned int Start, End ;
    char c, text[150];
    unsigned int* addressPointer;
    unsigned int startAddress = NULL;
    unsigned int endAddress = NULL;
    unsigned int bitLength;
    unsigned int dataSize = 0;
    unsigned int dataPattern = 0;
    unsigned int currAddress;
    unsigned int addrCount;
    unsigned int intBuffer = NULL;
    unsigned char *startAddressPtr = NULL;
    unsigned char *endAddressPtr = NULL;
    unsigned short int *wordAddressPtr = NULL;
    unsigned int *longAddressPtr = NULL;
    unsigned int byteLength;

    // printf("\r\nStart Address: ") ;
    // Start = Get8HexDigits(0) ;
    // printf("\r\nEnd Address: ") ;
    // End = Get8HexDigits(0) ;

	// TODO
    scanflush();
    memset(text, 0, sizeof(text));  // fills with zeros

    printf("Enter what size of memory you want to read/write\n Byte = 0\n Word = 1\n Long Word = 2\n");
    scanf("%d", &dataSize);

    if (dataSize == 0) {
        printf("Enter which data pattern you want to write into memory\n 0xA1 = 0\n 0xB2 = 1\n 0xC3 = 2\n 0xD4 = 3\n");
        scanf("%d", &intBuffer);
        switch (intBuffer) {
            case(0):
                dataPattern = 0xA1;
                break;
            case(1):
                dataPattern = 0xB2;
                break;
            case(2):
                dataPattern = 0xC3;
                break;
            case(3):
                dataPattern = 0xD4;
                break;
        }
        byteLength = 1;
    } else if (dataSize == 1) {
        printf("Enter which data pattern you want to write into memory\n 0xABCD = 0\n 0x1234 = 1\n 0xA1B2 = 2\n 0xC3D4 = 3\n");
        scanf("%d", &intBuffer);
        switch (intBuffer) {
            case(0):
                dataPattern = 0xABCD;
                break;
            case(1):
                dataPattern = 0x1234;
                break;
            case(2):
                dataPattern = 0xA1B2;
                break;
            case(3):
                dataPattern = 0xC3D4;
                break;
        }
        byteLength = 2;
    } else {
        printf("Enter which data pattern you want to write into memory\n 0xABCD_1234 = 0\n 0xAABB_CCDD = 1\n 0x1122_3344 = 2\n 0x7654_3210 = 3\n");
        scanf("%d", &intBuffer);

        switch (intBuffer) {
            case(0):
                dataPattern = 0xABCD1234;
                break;
            case(1):
                dataPattern = 0xAABBCCDD;
                break;
            case(2):
                dataPattern = 0x11223344;
                break;
            case(3):
                dataPattern = 0x76543210;
                break;
        }
        byteLength = 4;
    }

    // Tests the DRAM range memory from 0x0802_0000 to 0x0B00_0000
    printf("Enter start address in range of 0x0802_0000 -> %08x\n If sending word or long word, ensure it is aligned to even address\n", 0x0B000000 - byteLength);
    while (startAddressPtr == NULL || 
      (byteLength > 1 && (unsigned int) startAddressPtr % 2 != 0) || 
      (unsigned int) startAddressPtr < 0x08020000 || 
      (unsigned int) startAddressPtr > 0x0B000000 - byteLength) {
        printf("\nProvide Start Address in hex (do not use 0x prefix)\n0x");
        scanf("%x", &startAddressPtr);
    }

    printf("Enter end address in range of 0x0802_0000 -> %08x\n If sending word or long word, ensure it is aligned to even address", 0x0B000000 - byteLength);

    while (endAddressPtr == NULL || 
      (unsigned int) endAddressPtr < startAddress + byteLength) {
        printf("\nProvide End Address in hex (do not use 0x prefix)\n0x");
        scanf("%x", &endAddressPtr);
    }

    printf("Start Address 0x%08x\n", startAddressPtr);
    printf("End Address: 0x%08x\n", endAddressPtr);

    addrCount = 0;
    while (startAddressPtr < endAddressPtr && ((unsigned int)endAddressPtr - (unsigned int)startAddressPtr + 1) >= (byteLength)) {
      // If address goes beyond 0x0B00_0000 then break
      if ((unsigned int)startAddressPtr > 0x0B000000 - byteLength) {
          printf("ERROR... Address 0x%x is beyond the memory range\n", (void*)startAddressPtr);
          break;
      }

      longAddressPtr = startAddressPtr;
      wordAddressPtr = startAddressPtr;
      if (dataSize == 0) {
          *startAddressPtr = dataPattern;
          if ((*startAddressPtr) != dataPattern) {
              printf("ERROR... Value written to address 0x%x == 0x%x. Value Expected: 0x%x\n", (void*)startAddressPtr, *startAddressPtr, dataPattern);
          }
      } else if (dataSize == 1) {
          *wordAddressPtr = dataPattern;
          if ((*wordAddressPtr) != dataPattern) {
              printf("ERROR... Value written to address 0x%x == 0x%x. Value Expected: 0x%x\n", (void*)startAddressPtr, *startAddressPtr, dataPattern);
          }
      } else {
          *longAddressPtr = dataPattern;
          if ((*longAddressPtr) != dataPattern) {
              printf("ERROR... Value written to address 0x%x == 0x%x. Value Expected: 0x%x\n", (void*)startAddressPtr, *startAddressPtr, dataPattern);
          }
      }

      // if ((*startAddressPtr) != dataPattern) {
      //     printf("ERROR... Value written to address 0x%x == 0x%x. Value Expected: 0x%x\n", (void*)startAddressPtr, *startAddressPtr, dataPattern);
      // }

      addrCount++;
      if (addrCount % 128 == 0) {
          if (dataSize == 0) {
              printf("Address: 0x%x Value: 0x%02X\n",
              (unsigned int)startAddressPtr, *startAddressPtr);
          }
          else if (dataSize == 1) {
              printf("Address: 0x%x Value: 0x%04X\n",
              (unsigned int)wordAddressPtr, *wordAddressPtr);
          }
          else {
              printf("Address: 0x%x Value: 0x%08X\n",
              (unsigned int)longAddressPtr, *longAddressPtr);
          }
      }
      startAddressPtr += byteLength;
  }

	// add your code to test memory here using 32 bit reads and writes of data between the start and end of memory
}

void main()
{
    unsigned int row, i=0, count=0, counter1=1;
    char c, text[150];
    int PassFailFlag = 1;
    unsigned int* baseAddressPtr = (int*)0x08020000;
    unsigned int* addressPointer;
    unsigned int readValue;
    unsigned int memoryOffset;
    unsigned int startAddress = NULL;
    unsigned int endAddress = NULL;
    unsigned int bitLength;
    unsigned int dataSize = 0;
    unsigned int dataPattern = 0;
    unsigned int currAddress;
    unsigned int addrCount;
    unsigned int intBuffer = NULL;


    i = x = y = z = PortA_Count = 0;
    Timer1Count = Timer2Count = Timer3Count = Timer4Count = 0;

    InstallExceptionHandler(PIA_ISR, 25);
    InstallExceptionHandler(ACIA_ISR, 26);
    InstallExceptionHandler(Timer_ISR, 27);
    InstallExceptionHandler(Key2PressISR, 28);
    InstallExceptionHandler(Key1PressISR, 29);

    Timer1Data = 0x10;
    Timer2Data = 0x20;
    Timer3Data = 0x15;
    Timer4Data = 0x25;

    Timer1Control = 3;
    Timer2Control = 3;
    Timer3Control = 3;
    Timer4Control = 3;

    Init_LCD();
    Init_RS232();

    scanflush();
    printf("\r\nEnter Integer: ") ;
    scanf("%d", &i) ;
    printf("You entered %d", i) ;

    sprintf(text, "Hello CPEN 412 Student");
    LCDLine1Message(text);

    printf("\r\nHello CPEN 412 Student\r\nYour LEDs should be Flashing");
    printf("\r\nYour LCD should be displaying");

    MemoryTest();

    while(1);
}