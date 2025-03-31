; C:\IDE68K\OS EXAMPLES\EXAMPLE_1.C - Compiled by CC68K  Version 5.00 (c) 1991-2005  Peter J. Fondse
; /*
; * EXAMPLE_1.C
; *
; * This is a minimal program to verify multitasking.
; *
; */
; #include <stdio.h>
; #include <Bios.h>
; #include <ucos_ii.h>
; #define STACKSIZE 256
; /*
; ** Stacks for each task are allocated here in the application in this case = 256 bytes
; ** but you can change size if required
; */
; OS_STK Task1Stk[STACKSIZE];
; OS_STK Task2Stk[STACKSIZE];
; OS_STK Task3Stk[STACKSIZE];
; OS_STK Task4Stk[STACKSIZE];
; /* Prototypes for our tasks/threads*/
; void Task1(void *); /* (void *) means the child task expects no data from parent*/
; void Task2(void *);
; void Task3(void *);
; void Task4(void *);
; /*
; ** Our main application which has to
; ** 1) Initialise any peripherals on the board, e.g. RS232 for hyperterminal + LCD
; ** 2) Call OSInit() to initialise the OS
; ** 3) Create our application task/threads
; ** 4) Call OSStart()
; */
; void main(void)
; {
       section   code
       xdef      _main
_main:
       move.l    A2,-(A7)
       lea       _OSTaskCreate.L,A2
; // initialise board hardware by calling our routines from the BIOS.C source file
; Init_RS232();
       jsr       _Init_RS232
; Init_LCD();
       jsr       _Init_LCD
; /* display welcome message on LCD display */
; Oline0("Altera DE1/68K");
       pea       @exampl~1_1.L
       jsr       _Oline0
       addq.w    #4,A7
; Oline1("Micrium uC/OS-II RTOS");
       pea       @exampl~1_2.L
       jsr       _Oline1
       addq.w    #4,A7
; OSInit(); // call to initialise the OS
       jsr       _OSInit
; /*
; ** Now create the 4 child tasks and pass them no data.
; ** the smaller the numerical priority value, the higher the task priority
; */
; OSTaskCreate(Task1, OS_NULL, &Task1Stk[STACKSIZE], 12);
       pea       12
       lea       _Task1Stk.L,A0
       add.w     #512,A0
       move.l    A0,-(A7)
       clr.l     -(A7)
       pea       _Task1.L
       jsr       (A2)
       add.w     #16,A7
; OSTaskCreate(Task2, OS_NULL, &Task2Stk[STACKSIZE], 11); // highest priority task
       pea       11
       lea       _Task2Stk.L,A0
       add.w     #512,A0
       move.l    A0,-(A7)
       clr.l     -(A7)
       pea       _Task2.L
       jsr       (A2)
       add.w     #16,A7
; OSTaskCreate(Task3, OS_NULL, &Task3Stk[STACKSIZE], 13);
       pea       13
       lea       _Task3Stk.L,A0
       add.w     #512,A0
       move.l    A0,-(A7)
       clr.l     -(A7)
       pea       _Task3.L
       jsr       (A2)
       add.w     #16,A7
; OSTaskCreate(Task4, OS_NULL, &Task4Stk[STACKSIZE], 14); // lowest priority task
       pea       14
       lea       _Task4Stk.L,A0
       add.w     #512,A0
       move.l    A0,-(A7)
       clr.l     -(A7)
       pea       _Task4.L
       jsr       (A2)
       add.w     #16,A7
; OSStart(); // call to start the OS scheduler, (never returns from this function)
       jsr       _OSStart
       move.l    (A7)+,A2
       rts
; }
; /*
; ** IMPORTANT : Timer 1 interrupts must be started by the highest priority task
; ** that runs first which is Task2
; */
; void Task1(void *pdata)
; {
       xdef      _Task1
_Task1:
       link      A6,#0
       movem.l   D2/D3,-(A7)
; int delay ;
; unsigned char count = 0 ;
       clr.b     D2
; while(1)    {
Task1_1:
; PortA = ((count << 4) + (count & 0x0f)) ;
       move.b    D2,D0
       lsl.b     #4,D0
       move.b    D2,D1
       and.b     #15,D1
       add.b     D1,D0
       move.b    D0,4194304
; for(delay = 0; delay < 2000000; delay ++)
       clr.l     D3
Task1_4:
       cmp.l     #2000000,D3
       bge.s     Task1_6
       addq.l    #1,D3
       bra       Task1_4
Task1_6:
; ;
; OSTimeDly(30);
       pea       30
       jsr       _OSTimeDly
       addq.w    #4,A7
; count ++;
       addq.b    #1,D2
       bra       Task1_1
; }
; }
; /*
; ** Task 2 below was created with the highest priority so it must start timer1
; ** so that it produces interrupts for the 100hz context switches
; */
; void Task2(void *pdata)
; {
       xdef      _Task2
_Task2:
       link      A6,#0
       movem.l   D2/D3,-(A7)
; int delay ;
; unsigned char count = 0 ;
       clr.b     D2
; // must start timer ticker here
; Timer1_Init() ; // this function is in BIOS.C and written by us to start timer
       jsr       _Timer1_Init
; while(1)    {
Task2_1:
; HEX_C = ((count << 4) + (count & 0x0f)) ;
       move.b    D2,D0
       lsl.b     #4,D0
       move.b    D2,D1
       and.b     #15,D1
       add.b     D1,D0
       move.b    D0,4194324
; for(delay = 0; delay < 2000000; delay ++)
       clr.l     D3
Task2_4:
       cmp.l     #2000000,D3
       bge.s     Task2_6
       addq.l    #1,D3
       bra       Task2_4
Task2_6:
; ;
; OSTimeDly(10);
       pea       10
       jsr       _OSTimeDly
       addq.w    #4,A7
; count ++;
       addq.b    #1,D2
       bra       Task2_1
; }
; }
; void Task3(void *pdata)
; {
       xdef      _Task3
_Task3:
       link      A6,#0
       movem.l   D2/D3,-(A7)
; int delay ;
; unsigned char count = 0 ;
       clr.b     D2
; while(1)    {
Task3_1:
; HEX_B = ((count << 4) + (count & 0x0f)) ;
       move.b    D2,D0
       lsl.b     #4,D0
       move.b    D2,D1
       and.b     #15,D1
       add.b     D1,D0
       move.b    D0,4194322
; for(delay = 0; delay < 2000000; delay ++)
       clr.l     D3
Task3_4:
       cmp.l     #2000000,D3
       bge.s     Task3_6
       addq.l    #1,D3
       bra       Task3_4
Task3_6:
; ;
; OSTimeDly(40);
       pea       40
       jsr       _OSTimeDly
       addq.w    #4,A7
; count ++;
       addq.b    #1,D2
       bra       Task3_1
; }
; }
; void Task4(void *pdata)
; {
       xdef      _Task4
_Task4:
       link      A6,#0
       movem.l   D2/D3,-(A7)
; unsigned int delay ;
; unsigned char count = 0 ;
       clr.b     D2
; while(1)    {
Task4_1:
; HEX_A = ((count << 4) + (count & 0x0f)) ;
       move.b    D2,D0
       lsl.b     #4,D0
       move.b    D2,D1
       and.b     #15,D1
       add.b     D1,D0
       move.b    D0,4194320
; for(delay = 0; delay < 2000000; delay ++)
       clr.l     D3
Task4_4:
       cmp.l     #2000000,D3
       bhs.s     Task4_6
       addq.l    #1,D3
       bra       Task4_4
Task4_6:
; ;
; OSTimeDly(50);
       pea       50
       jsr       _OSTimeDly
       addq.w    #4,A7
; count ++;
       addq.b    #1,D2
       bra       Task4_1
; }
; }
       section   const
@exampl~1_1:
       dc.b      65,108,116,101,114,97,32,68,69,49,47,54,56,75
       dc.b      0
@exampl~1_2:
       dc.b      77,105,99,114,105,117,109,32,117,67,47,79,83
       dc.b      45,73,73,32,82,84,79,83,0
       section   bss
       xdef      _Task1Stk
_Task1Stk:
       ds.b      512
       xdef      _Task2Stk
_Task2Stk:
       ds.b      512
       xdef      _Task3Stk
_Task3Stk:
       ds.b      512
       xdef      _Task4Stk
_Task4Stk:
       ds.b      512
       xref      _Init_LCD
       xref      _Timer1_Init
       xref      _Init_RS232
       xref      _OSInit
       xref      _OSStart
       xref      _OSTaskCreate
       xref      _Oline0
       xref      _Oline1
       xref      _OSTimeDly
