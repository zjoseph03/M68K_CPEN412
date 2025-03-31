/*
* EXAMPLE_1.C
*
* This is a minimal program to verify multitasking.
*
*/
#include <stdio.h>
#include <Bios.h>
#include <ucos_ii.h>
#define STACKSIZE 256
/*
** Stacks for each task are allocated here in the application in this case = 256 bytes
** but you can change size if required
*/
OS_STK Task1Stk[STACKSIZE];
OS_STK Task2Stk[STACKSIZE];
OS_STK Task3Stk[STACKSIZE];
OS_STK Task4Stk[STACKSIZE];
/* Prototypes for our tasks/threads*/
void LEDTask(void *); /* (void *) means the child task expects no data from parent*/
void HexCTask(void *);
void HexBTask(void *);
void HexATask(void *);
/*
** Our main application which has to
** 1) Initialise any peripherals on the board, e.g. RS232 for hyperterminal + LCD
** 2) Call OSInit() to initialise the OS
** 3) Create our application task/threads
** 4) Call OSStart()
*/
void main(void)
{
 // initialise board hardware by calling our routines from the BIOS.C source file
 Init_RS232();
 Init_LCD();
/* display welcome message on LCD display */
 Oline0("Altera DE1/68K");
 Oline1("Micrium uC/OS-II RTOS");
 OSInit(); // call to initialise the OS
/*
** Now create the 4 child tasks and pass them no data.
** the smaller the numerical priority value, the higher the task priority
*/
 OSTaskCreate(LEDTask, OS_NULL, &Task1Stk[STACKSIZE], 12);
 OSTaskCreate(HexCTask, OS_NULL, &Task2Stk[STACKSIZE], 11); // highest priority task
 OSTaskCreate(HexBTask, OS_NULL, &Task3Stk[STACKSIZE], 13);
 OSTaskCreate(HexATask, OS_NULL, &Task4Stk[STACKSIZE], 14); // lowest priority task
 OSStart(); // call to start the OS scheduler, (never returns from this function)
}
/*
** IMPORTANT : Timer 1 interrupts must be started by the highest priority task
** that runs first which is Task2
*/
void LEDTask(void *pdata)
{
  int delay ;
  unsigned char count = 0 ;

  while(1)    {
    PortA = count;
    printf("\r\nLED Task Count = %d", count);
          
      OSTimeDly(40);
      count++;

  }
}

/*
** Task 2 below was created with the highest priority so it must start timer1
** so that it produces interrupts for the 100hz context switches
*/
void HexCTask(void *pdata)
{
 int delay ;
 unsigned char count = 0 ;
  // must start timer ticker here
 Timer1_Init() ; // this function is in BIOS.C and written by us to start timer


 while(1)    {
    HEX_C = count;
    OSTimeDly(10);
    count++;}
}

void HexBTask(void *pdata)
{
  int delay ;
  unsigned char count = 0 ;

  while(1)    {
    HEX_B = count;
    OSTimeDly(40);
    count++;
  }
}
void HexATask(void *pdata)
{
  unsigned int delay ;
  unsigned char count = 0 ;

  while(1)    {
    HEX_A = count;
    OSTimeDly(50);
    count++;
  }
}