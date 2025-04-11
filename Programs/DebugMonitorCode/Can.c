#include <stdio.h>
#include <bios.h>
#include <ucos_ii.h>
/*********************************************************************************************
** These addresses and definitions were taken from Appendix 7 of the Can Controller
** application note and adapted for the 68k assignment
*********************************************************************************************/

/*
** definition for the SJA1000 registers and bits based on 68k address map areas
** assume the addresses for the 2 can controllers given in the assignment
**
** Registers are defined in terms of the following Macro for each Can controller,
** where (i) represents an registers number
*/

#define CAN0_CONTROLLER(i) (*(volatile unsigned char *)(0x00500000 + (i << 1)))
#define CAN1_CONTROLLER(i) (*(volatile unsigned char *)(0x00500200 + (i << 1)))

/* Can 0 register definitions */
#define Can0_ModeControlReg      CAN0_CONTROLLER(0)
#define Can0_CommandReg          CAN0_CONTROLLER(1)
#define Can0_StatusReg           CAN0_CONTROLLER(2)
#define Can0_InterruptReg        CAN0_CONTROLLER(3)
#define Can0_InterruptEnReg      CAN0_CONTROLLER(4) /* PeliCAN mode */
#define Can0_BusTiming0Reg       CAN0_CONTROLLER(6)
#define Can0_BusTiming1Reg       CAN0_CONTROLLER(7)
#define Can0_OutControlReg       CAN0_CONTROLLER(8)

/* address definitions of Other Registers */
#define Can0_ArbLostCapReg       CAN0_CONTROLLER(11)
#define Can0_ErrCodeCapReg       CAN0_CONTROLLER(12)
#define Can0_ErrWarnLimitReg     CAN0_CONTROLLER(13)
#define Can0_RxErrCountReg       CAN0_CONTROLLER(14)
#define Can0_TxErrCountReg       CAN0_CONTROLLER(15)
#define Can0_RxMsgCountReg       CAN0_CONTROLLER(29)
#define Can0_RxBufStartAdr       CAN0_CONTROLLER(30)
#define Can0_ClockDivideReg      CAN0_CONTROLLER(31)

/* address definitions of Acceptance Code & Mask Registers - RESET MODE */
#define Can0_AcceptCode0Reg      CAN0_CONTROLLER(16)
#define Can0_AcceptCode1Reg      CAN0_CONTROLLER(17)
#define Can0_AcceptCode2Reg      CAN0_CONTROLLER(18)
#define Can0_AcceptCode3Reg      CAN0_CONTROLLER(19)
#define Can0_AcceptMask0Reg      CAN0_CONTROLLER(20)
#define Can0_AcceptMask1Reg      CAN0_CONTROLLER(21)
#define Can0_AcceptMask2Reg      CAN0_CONTROLLER(22)
#define Can0_AcceptMask3Reg      CAN0_CONTROLLER(23)

/* address definitions Rx Buffer - OPERATING MODE - Read only register*/
#define Can0_RxFrameInfo         CAN0_CONTROLLER(16)
#define Can0_RxBuffer1           CAN0_CONTROLLER(17)
#define Can0_RxBuffer2           CAN0_CONTROLLER(18)
#define Can0_RxBuffer3           CAN0_CONTROLLER(19)
#define Can0_RxBuffer4           CAN0_CONTROLLER(20)
#define Can0_RxBuffer5           CAN0_CONTROLLER(21)
#define Can0_RxBuffer6           CAN0_CONTROLLER(22)
#define Can0_RxBuffer7           CAN0_CONTROLLER(23)
#define Can0_RxBuffer8           CAN0_CONTROLLER(24)
#define Can0_RxBuffer9           CAN0_CONTROLLER(25)
#define Can0_RxBuffer10          CAN0_CONTROLLER(26)
#define Can0_RxBuffer11          CAN0_CONTROLLER(27)
#define Can0_RxBuffer12          CAN0_CONTROLLER(28)

/* address definitions of the Tx-Buffer - OPERATING MODE - Write only register */
#define Can0_TxFrameInfo         CAN0_CONTROLLER(16)
#define Can0_TxBuffer1           CAN0_CONTROLLER(17)
#define Can0_TxBuffer2           CAN0_CONTROLLER(18)
#define Can0_TxBuffer3           CAN0_CONTROLLER(19)
#define Can0_TxBuffer4           CAN0_CONTROLLER(20)
#define Can0_TxBuffer5           CAN0_CONTROLLER(21)
#define Can0_TxBuffer6           CAN0_CONTROLLER(22)
#define Can0_TxBuffer7           CAN0_CONTROLLER(23)
#define Can0_TxBuffer8           CAN0_CONTROLLER(24)
#define Can0_TxBuffer9           CAN0_CONTROLLER(25)
#define Can0_TxBuffer10          CAN0_CONTROLLER(26)
#define Can0_TxBuffer11          CAN0_CONTROLLER(27)
#define Can0_TxBuffer12          CAN0_CONTROLLER(28)

/* read only addresses */
#define Can0_TxFrameInfoRd       CAN0_CONTROLLER(96)
#define Can0_TxBufferRd1         CAN0_CONTROLLER(97)
#define Can0_TxBufferRd2         CAN0_CONTROLLER(98)
#define Can0_TxBufferRd3         CAN0_CONTROLLER(99)
#define Can0_TxBufferRd4         CAN0_CONTROLLER(100)
#define Can0_TxBufferRd5         CAN0_CONTROLLER(101)
#define Can0_TxBufferRd6         CAN0_CONTROLLER(102)
#define Can0_TxBufferRd7         CAN0_CONTROLLER(103)
#define Can0_TxBufferRd8         CAN0_CONTROLLER(104)
#define Can0_TxBufferRd9         CAN0_CONTROLLER(105)
#define Can0_TxBufferRd10        CAN0_CONTROLLER(106)
#define Can0_TxBufferRd11        CAN0_CONTROLLER(107)
#define Can0_TxBufferRd12        CAN0_CONTROLLER(108)


/* CAN1 Controller register definitions */
#define Can1_ModeControlReg      CAN1_CONTROLLER(0)
#define Can1_CommandReg          CAN1_CONTROLLER(1)
#define Can1_StatusReg           CAN1_CONTROLLER(2)
#define Can1_InterruptReg        CAN1_CONTROLLER(3)
#define Can1_InterruptEnReg      CAN1_CONTROLLER(4) /* PeliCAN mode */
#define Can1_BusTiming0Reg       CAN1_CONTROLLER(6)
#define Can1_BusTiming1Reg       CAN1_CONTROLLER(7)
#define Can1_OutControlReg       CAN1_CONTROLLER(8)

/* address definitions of Other Registers */
#define Can1_ArbLostCapReg       CAN1_CONTROLLER(11)
#define Can1_ErrCodeCapReg       CAN1_CONTROLLER(12)
#define Can1_ErrWarnLimitReg     CAN1_CONTROLLER(13)
#define Can1_RxErrCountReg       CAN1_CONTROLLER(14)
#define Can1_TxErrCountReg       CAN1_CONTROLLER(15)
#define Can1_RxMsgCountReg       CAN1_CONTROLLER(29)
#define Can1_RxBufStartAdr       CAN1_CONTROLLER(30)
#define Can1_ClockDivideReg      CAN1_CONTROLLER(31)

/* address definitions of Acceptance Code & Mask Registers - RESET MODE */
#define Can1_AcceptCode0Reg      CAN1_CONTROLLER(16)
#define Can1_AcceptCode1Reg      CAN1_CONTROLLER(17)
#define Can1_AcceptCode2Reg      CAN1_CONTROLLER(18)
#define Can1_AcceptCode3Reg      CAN1_CONTROLLER(19)
#define Can1_AcceptMask0Reg      CAN1_CONTROLLER(20)
#define Can1_AcceptMask1Reg      CAN1_CONTROLLER(21)
#define Can1_AcceptMask2Reg      CAN1_CONTROLLER(22)
#define Can1_AcceptMask3Reg      CAN1_CONTROLLER(23)

/* address definitions Rx Buffer - OPERATING MODE - Read only register*/
#define Can1_RxFrameInfo         CAN1_CONTROLLER(16)
#define Can1_RxBuffer1           CAN1_CONTROLLER(17)
#define Can1_RxBuffer2           CAN1_CONTROLLER(18)
#define Can1_RxBuffer3           CAN1_CONTROLLER(19)
#define Can1_RxBuffer4           CAN1_CONTROLLER(20)
#define Can1_RxBuffer5           CAN1_CONTROLLER(21)
#define Can1_RxBuffer6           CAN1_CONTROLLER(22)
#define Can1_RxBuffer7           CAN1_CONTROLLER(23)
#define Can1_RxBuffer8           CAN1_CONTROLLER(24)
#define Can1_RxBuffer9           CAN1_CONTROLLER(25)
#define Can1_RxBuffer10          CAN1_CONTROLLER(26)
#define Can1_RxBuffer11          CAN1_CONTROLLER(27)
#define Can1_RxBuffer12          CAN1_CONTROLLER(28)

/* address definitions of the Tx-Buffer - OPERATING MODE - Write only register */
#define Can1_TxFrameInfo         CAN1_CONTROLLER(16)
#define Can1_TxBuffer1           CAN1_CONTROLLER(17)
#define Can1_TxBuffer2           CAN1_CONTROLLER(18)
#define Can1_TxBuffer3           CAN1_CONTROLLER(19)
#define Can1_TxBuffer4           CAN1_CONTROLLER(20)
#define Can1_TxBuffer5           CAN1_CONTROLLER(21)
#define Can1_TxBuffer6           CAN1_CONTROLLER(22)
#define Can1_TxBuffer7           CAN1_CONTROLLER(23)
#define Can1_TxBuffer8           CAN1_CONTROLLER(24)
#define Can1_TxBuffer9           CAN1_CONTROLLER(25)
#define Can1_TxBuffer10          CAN1_CONTROLLER(26)
#define Can1_TxBuffer11          CAN1_CONTROLLER(27)
#define Can1_TxBuffer12          CAN1_CONTROLLER(28)

/* read only addresses */
#define Can1_TxFrameInfoRd       CAN1_CONTROLLER(96)
#define Can1_TxBufferRd1         CAN1_CONTROLLER(97)
#define Can1_TxBufferRd2         CAN1_CONTROLLER(98)
#define Can1_TxBufferRd3         CAN1_CONTROLLER(99)
#define Can1_TxBufferRd4         CAN1_CONTROLLER(100)
#define Can1_TxBufferRd5         CAN1_CONTROLLER(101)
#define Can1_TxBufferRd6         CAN1_CONTROLLER(102)
#define Can1_TxBufferRd7         CAN1_CONTROLLER(103)
#define Can1_TxBufferRd8         CAN1_CONTROLLER(104)
#define Can1_TxBufferRd9         CAN1_CONTROLLER(105)
#define Can1_TxBufferRd10        CAN1_CONTROLLER(106)
#define Can1_TxBufferRd11        CAN1_CONTROLLER(107)
#define Can1_TxBufferRd12        CAN1_CONTROLLER(108)


/* bit definitions for the Mode & Control Register */
#define RM_RR_Bit 0x01 /* reset mode (request) bit */
#define LOM_Bit 0x02 /* listen only mode bit */
#define STM_Bit 0x04 /* self test mode bit */
#define AFM_Bit 0x08 /* acceptance filter mode bit */
#define SM_Bit  0x10 /* enter sleep mode bit */

/* bit definitions for the Interrupt Enable & Control Register */
#define RIE_Bit 0x01 /* receive interrupt enable bit */
#define TIE_Bit 0x02 /* transmit interrupt enable bit */
#define EIE_Bit 0x04 /* error warning interrupt enable bit */
#define DOIE_Bit 0x08 /* data overrun interrupt enable bit */
#define WUIE_Bit 0x10 /* wake-up interrupt enable bit */
#define EPIE_Bit 0x20 /* error passive interrupt enable bit */
#define ALIE_Bit 0x40 /* arbitration lost interr. enable bit*/
#define BEIE_Bit 0x80 /* bus error interrupt enable bit */

/* bit definitions for the Command Register */
#define TR_Bit 0x01 /* transmission request bit */
#define AT_Bit 0x02 /* abort transmission bit */
#define RRB_Bit 0x04 /* release receive buffer bit */
#define CDO_Bit 0x08 /* clear data overrun bit */
#define SRR_Bit 0x10 /* self reception request bit */

/* bit definitions for the Status Register */
#define RBS_Bit 0x01 /* receive buffer status bit */
#define DOS_Bit 0x02 /* data overrun status bit */
#define TBS_Bit 0x04 /* transmit buffer status bit */
#define TCS_Bit 0x08 /* transmission complete status bit */
#define RS_Bit 0x10 /* receive status bit */
#define TS_Bit 0x20 /* transmit status bit */
#define ES_Bit 0x40 /* error status bit */
#define BS_Bit 0x80 /* bus status bit */

/* bit definitions for the Interrupt Register */
#define RI_Bit 0x01 /* receive interrupt bit */
#define TI_Bit 0x02 /* transmit interrupt bit */
#define EI_Bit 0x04 /* error warning interrupt bit */
#define DOI_Bit 0x08 /* data overrun interrupt bit */
#define WUI_Bit 0x10 /* wake-up interrupt bit */
#define EPI_Bit 0x20 /* error passive interrupt bit */
#define ALI_Bit 0x40 /* arbitration lost interrupt bit */
#define BEI_Bit 0x80 /* bus error interrupt bit */


/* bit definitions for the Bus Timing Registers */
#define SAM_Bit 0x80                        /* sample mode bit 1 == the bus is sampled 3 times, 0 == the bus is sampled once */

/* bit definitions for the Output Control Register OCMODE1, OCMODE0 */
#define BiPhaseMode 0x00 /* bi-phase output mode */
#define NormalMode 0x02 /* normal output mode */
#define ClkOutMode 0x03 /* clock output mode */

/* output pin configuration for TX1 */
#define OCPOL1_Bit 0x20 /* output polarity control bit */
#define Tx1Float 0x00 /* configured as float */
#define Tx1PullDn 0x40 /* configured as pull-down */
#define Tx1PullUp 0x80 /* configured as pull-up */
#define Tx1PshPull 0xC0 /* configured as push/pull */

/* output pin configuration for TX0 */
#define OCPOL0_Bit 0x04 /* output polarity control bit */
#define Tx0Float 0x00 /* configured as float */
#define Tx0PullDn 0x08 /* configured as pull-down */
#define Tx0PullUp 0x10 /* configured as pull-up */
#define Tx0PshPull 0x18 /* configured as push/pull */

/* bit definitions for the Clock Divider Register */
#define DivBy1 0x07 /* CLKOUT = oscillator frequency */
#define DivBy2 0x00 /* CLKOUT = 1/2 oscillator frequency */
#define ClkOff_Bit 0x08 /* clock off bit, control of the CLK OUT pin */
#define RXINTEN_Bit 0x20 /* pin TX1 used for receive interrupt */
#define CBP_Bit 0x40 /* CAN comparator bypass control bit */
#define CANMode_Bit 0x80 /* CAN mode definition bit */

/*- definition of used constants ---------------------------------------*/
#define YES 1
#define NO 0
#define ENABLE 1
#define DISABLE 0
#define ENABLE_N 0
#define DISABLE_N 1
#define INTLEVELACT 0
#define INTEDGEACT 1
#define PRIORITY_LOW 0
#define PRIORITY_HIGH 1

/* default (reset) value for register content, clear register */
#define ClrByte 0x00

/* constant: clear Interrupt Enable Register */
#define ClrIntEnSJA ClrByte

/* definitions for the acceptance code and mask register */
#define DontCare 0xFF

#define SENSOR_ID_THERMISTOR    0x01
#define SENSOR_ID_POTENTIOMETER 0x02
#define SENSOR_ID_LIGHT         0x03
#define SENSOR_ID_SWITCHES      0x04 


// IIC Registers
#define IIC_PRER_LO (*(volatile unsigned char *)(0x00408000))
#define IIC_PRER_HI (*(volatile unsigned char *)(0x00408002))
#define IIC_CTR     (*(volatile unsigned char *)(0x00408004))
#define IIC_TXRX    (*(volatile unsigned char *)(0x00408006))
#define IIC_CRSR    (*(volatile unsigned char *)(0x00408008))

// I2C Command/Status Register Macro Mask
#define START 0x80
#define STOP  0x40
#define READ  0x20
#define WRITE 0x10
#define ACK   0x8
#define IACK  0x1

#define NACK  0x8
#define RXACK 0x80
#define TIP   0x2
#define INTF  0x01

// DAC Information
#define PCF8591 0x49

#define NUM_SAMPLES 512  // Total samples: 256 up, 256 down
#define HALF_SAMPLES (NUM_SAMPLES / 2)
#define SAMPLE_DELAY_MS 10  // Adjust delay for your desired frequency

#define ADC_CHANNEL_LIGHT        3  // Photoresistor
#define ADC_CHANNEL_EXTERNAL     1  // External input
#define ADC_CHANNEL_POTENTIOMETER 2  // Potentiometer
#define ADC_CHANNEL_THERMISTOR   0  // Thermistor

#define STACKSIZE 256

OS_STK Task1Stk[STACKSIZE];
OS_STK Task2Stk[STACKSIZE];
OS_STK Task3Stk[STACKSIZE];
OS_STK Task4Stk[STACKSIZE];

void ADCThread(void *);
unsigned char Timer1Count;

// CAN Channel IDs

unsigned char Timer1Count;
unsigned char thermistorVal, potentiometerVal, lightSensorVal;




void IICCoreEnable() {
  IIC_CTR |= 0x80;     // Enable I2C core in control register (1000_0000)
}

void IICCoreDisable() {
  IIC_CTR &= 0x7F;    // Disable I2C core in control register (0011_1111)
}
// I2C Driver Functions
void IIC_Init(void) {
  IIC_PRER_LO = 0x59;  // Scale the I2C clock from 45 Mhz to 100 Khz
  IIC_PRER_HI = 0x00;  // Scale the I2C clock from 45 Mhz to 100 Khz
  IIC_CTR &= 0xBF;     // Disable interrupt in control register (1011_1111)
  IICCoreEnable();
}


void wait5ms(void) {
  int i;
  for (i = 0; i < 10000; i++); // Wait for 5 ms
}

void checkTIP() {
  while (IIC_CRSR & TIP);
}

void checkAck() {
  while ((IIC_CRSR & RXACK) == 1);
}

// void IICStopCondition() {
//   IIC_CRSR |= STOP | READ | IACK; // STOP + READ + IACK
//   checkTIP();
// }

void IICStartCondition(int rwBit) {
  if (rwBit == 0) {
    IIC_CRSR |= START | WRITE | IACK; // START + WRITE + IACK
  } else {
    IIC_CRSR |= START | READ | IACK; // Start condition with read bit set
  }
  checkTIP();
  checkAck();
}


/*  bus timing values for
**  bit-rate : 100 kBit/s
**  oscillator frequency : 25 MHz, 1 sample per bit, 0 tolerance %
**  maximum tolerated propagation delay : 4450 ns
**  minimum requested propagation delay : 500 ns
**
**  https://www.kvaser.com/support/calculators/bit-timing-calculator/
**  T1 	T2 	BTQ 	SP% 	SJW 	BIT RATE 	ERR% 	BTR0 	BTR1
**  17	8	25	    68	     1	      100	    0	      04	7f
*/


/*

Can Transceiver - controls logic level signals from can controller to physical ones
Can Controller - controls the logic level signals from the microcontroller to the transceive

Enters sleep mode:
- no bus activity
- no interrupt pending

*/

unsigned char GetSwitches(void)
{
    return (unsigned char)(PortA & 0xFF);  // Get just the lower 8 bits
}


// initialisation for Can controller 0
void Init_CanBus_Controller0(void)
{
  // TODO - put your Canbus initialisation code for CanController 0 here
  // See section 4.2.1 in the application note for details (PELICAN MODE)
  
  // This should just be the configuration of the registers of the SJA1000 controller
  // It is assumed that after power-on, the CAN controller gets a reset pulse at pin 17
  
  // Before setting up registers, we should check the reset/request mode flag before writing anything
  
  // Init Process:
  
  // Configure clock divider for PeliCAN, clk_out disabled
  // internal comperator should be bypassed (I THINK)
  // TX1 Output Config should be set to 0 since we're sending TX message from controller to transeiver 

  // Configure acceptance code and mask registers
  
  // COnfigure bus timing registers
  
  // Configure output control register

  // Enter operating mode

  // Poll to check if we exited reset mode AKA in normal mode, 
  //        if not go back to before entering operating mode
  
  // Enable can interrupts if used (not sure tbh)

  // INTERRUPT do later
  /* disable interrupts, if used (not necessary after power-on) */
  Can0_ModeControlReg |= RM_RR_Bit;

  Can0_InterruptReg = DISABLE; /* enable external interrupt from SJA1000 */
  Can0_InterruptEnReg = DISABLE; /* enable all interrupts */

  while((Can0_ModeControlReg & RM_RR_Bit ) == ClrByte)
  {
      /* other bits than the reset mode/request bit are unchanged */
    Can0_ModeControlReg = Can0_ModeControlReg | RM_RR_Bit ;
  }

  Can0_ClockDivideReg = CANMode_Bit | CBP_Bit | DivBy2;
  Can0_InterruptEnReg = ClrIntEnSJA; // disable all interrupts

  Can0_AcceptCode0Reg = ClrByte; // clear acceptance code registers
  Can0_AcceptCode1Reg = ClrByte;
  Can0_AcceptCode2Reg = ClrByte;
  Can0_AcceptCode3Reg = ClrByte;
  Can0_AcceptMask0Reg = DontCare; // clear acceptance mask registers
  Can0_AcceptMask1Reg = DontCare;
  Can0_AcceptMask2Reg = DontCare;
  Can0_AcceptMask3Reg = DontCare;

  //25
  Can0_BusTiming0Reg = 0x04;
  Can0_BusTiming1Reg = 0x7f;

  //45
  // Can0_BusTiming0Reg = 0x08;
  // Can0_BusTiming1Reg = 0x7f;

  Can0_OutControlReg = Tx1Float | Tx0PshPull | NormalMode;

  do {
    Can0_ModeControlReg = ClrByte;
  } while ((Can0_ModeControlReg & RM_RR_Bit) != ClrByte); // wait until reset mode bit is cleared
  
  // INTERRUPT do later
  Can0_InterruptReg = ENABLE; /* enable external interrupt from SJA1000 */
  Can0_InterruptEnReg = ENABLE; /* enable all interrupts */

}

void Init_CanBus_Controller1(void)
{

  // TODO - put your Canbus initialisation code for CanController 1 here
  // See section 4.2.1 in the application note for details (PELICAN MODE)
  // INTERRUPT do later
  /* disable interrupts, if used (not necessary after power-on) */
  //EA = DISABLE; /* disable all interrupts */
  //SJAIntEn = DISABLE; /* disable external interrupt from SJA1000 */
  while((Can1_ModeControlReg & RM_RR_Bit ) == ClrByte)

  Can1_InterruptReg = DISABLE; /* enable external interrupt from SJA1000 */
  Can1_InterruptEnReg = DISABLE; /* enable all interrupts */


  {
    /* other bits than the reset mode/request bit are unchanged */
    Can1_ModeControlReg = Can1_ModeControlReg | RM_RR_Bit ;
  }

  Can1_ClockDivideReg = CANMode_Bit | CBP_Bit | DivBy2;
  Can1_InterruptEnReg = ClrIntEnSJA; // disable all interrupts
  Can1_AcceptCode0Reg = ClrByte; // clear acceptance code registers
  Can1_AcceptCode1Reg = ClrByte;
  Can1_AcceptCode2Reg = ClrByte;
  Can1_AcceptCode3Reg = ClrByte;
  Can1_AcceptMask0Reg = DontCare; // clear acceptance mask registers
  Can1_AcceptMask1Reg = DontCare;
  Can1_AcceptMask2Reg = DontCare;
  Can1_AcceptMask3Reg = DontCare;

  //25
  Can1_BusTiming0Reg = 0x04;
  Can1_BusTiming1Reg = 0x7f;

  //45
  // Can1_BusTiming0Reg = 0x08;
  // Can1_BusTiming1Reg = 0x7f;

  Can1_OutControlReg = Tx1Float | Tx0PshPull | NormalMode;

  do {
    Can1_ModeControlReg = ClrByte;
  } while ((Can1_ModeControlReg & RM_RR_Bit) != ClrByte); // wait until reset mode bit is cleared
  
  // INTERRUPT do laters
  //SJAIntEn = ENABLE; /* enable external interrupt from SJA1000 */
  //EA = ENABLE; /* enable all interrupts
  Can1_InterruptReg = ENABLE; /* enable external interrupt from SJA1000 */
  Can1_InterruptEnReg = ENABLE; /* enable all interrupts */


}

/*
Has to transmit into transfer buffer and set Transmit Request flag in cmd register
request: transmit a message

is transmit buffer released?
  if yes:
  write into transmit buffer
  set transmit request bit (TR) in command register

  if no: 
  poll status register until transmit buffer is released
  temporary storage of message to be transmitted
  set flag "further message"

  When transmitting, transmit buffer is locked

*/
// Transmit for sending a message via Can controller 0
void CanBus0_Transmit(unsigned char sensorId, unsigned char sensorValue)
{
  // TODO - put your Canbus transmit code for CanController 0 here
  // See section 4.2.2 in the application note for details (PELICAN MODE)

  do
  {
  /* start a polling timer and run some tasks while waiting
  break the loop and signal an error if time too long */

  } while((Can0_StatusReg & TBS_Bit ) != TBS_Bit );

/* Transmit Buffer is released, a message may be written into the buffer */
/* in this example a Standard Frame message shall be transmitted */
  Can0_TxFrameInfo = 0x08; /* SFF (data), DLC=8 */
  Can0_TxBuffer1 = 0xA5; /* ID1 = A5, (1010 0101) */
  Can0_TxBuffer2 = 0x20; /* ID2 = 20, (0010 0000) */
  Can0_TxBuffer3 = sensorValue; /* DATA */
  Can0_TxBuffer4 = sensorId; /* RecieveID */

  /* Start the transmission */
  Can0_CommandReg = TR_Bit ; /* Set Transmission Request bit */
}

// Transmit for sending a message via Can controller 1
void CanBus1_Transmit(unsigned char sensorId, unsigned char sensorValue)
{
  // TODO - put your Canbus transmit code for CanController 1 here
  // See section 4.2.2 in the application note for details (PELICAN MODE)

  do
  {
  /* start a polling timer and run some tasks while waiting
  break the loop and signal an error if time too long */
  } while((Can1_StatusReg & TBS_Bit) != TBS_Bit);

  /* Transmit Buffer is released, a message may be written into the buffer */
  /* in this example a Standard Frame message shall be transmitted */
  Can1_TxFrameInfo = 0x08; /* SFF (data), DLC=8 */
  Can1_TxBuffer1 = 0xA5; /* ID1 = A5, (1010 0101) */
  Can1_TxBuffer2 = 0x20; /* ID2 = 20, (0010 0000) */
  Can0_TxBuffer3 = sensorValue; /* DATA */
  Can0_TxBuffer4 = sensorId; /* RecieveID */
  Can1_CommandReg = TR_Bit; /* Set Transmission Request bit */
}

// Receive for reading a received message via Can controller 0
void CanBus0_Receive(void)
{
    unsigned char sensorId;
    unsigned char sensorValue;
    int i;
    
    while (!(Can0_StatusReg & RBS_Bit)) {
    }

    sensorId = Can0_RxBuffer4;
    sensorValue = Can0_RxBuffer3;

    // switch(sensorId) {
    //     case SENSOR_ID_THERMISTOR:
    //         printf("\rC0: T=%3d", sensorValue);
    //         break;
    //     case SENSOR_ID_POTENTIOMETER:
    //         printf(" P=%3d", sensorValue);
    //         break;
    //     case SENSOR_ID_LIGHT:
    //         printf(" L=%3d", sensorValue);
    //         break;
    //     case SENSOR_ID_SWITCHES:
    //         printf(" SW=");
    //         for(i = 7; i >= 0; i--) {
    //             printf("%d", (sensorValue >> i) & 0x01);
    //         }
    //         break;
    // }
    
    Can0_CommandReg = RRB_Bit;
}

void CanBus1_Receive(void)
{
    unsigned char sensorId;
    unsigned char sensorValue;
    int i;
    
    while (!(Can1_StatusReg & RBS_Bit)) {
    }

    sensorId = Can1_RxBuffer4;
    sensorValue = Can1_RxBuffer3;

    // switch(sensorId) {
    //     case SENSOR_ID_THERMISTOR:
    //         printf("\rC1: T=%3d", sensorValue);
    //         break;
    //     case SENSOR_ID_POTENTIOMETER:
    //         printf(" P=%3d", sensorValue);
    //         break;
    //     case SENSOR_ID_LIGHT:
    //         printf(" L=%3d", sensorValue);
    //         break;
    //     case SENSOR_ID_SWITCHES:
    //         printf(" SW=");
    //         for(i = 7; i >= 0; i--) {
    //             printf("%d", (sensorValue >> i) & 0x01);
    //         }
    //         break;
    // }
    
    Can1_CommandReg = RRB_Bit;
}

void delay(void)
{
  // TODO - put your delay code here
  // This is a simple delay routine for 1/2 second
  // You can use a loop or a timer to create the delay
  OSTimeDly(50);
}

void CanBusTest(void)
{
    Init_CanBus_Controller0();
    Init_CanBus_Controller1();

    printf("\r\n\r\n---- CANBUS Test with Real Sensor Values ----\r\n");
    printf("\rC0: T=Thermistor P=Potentiometer L=Light SW=Switches\r\n");

    while(1) {


        OSTimeDly(100);
    }
}

void ADCRead(void) {

  int i ;
  long int  j ;
  int k;

  unsigned int readData;

  // printf("Performing ADC Read\n");
  
  IIC_Init();
  checkTIP();

  IIC_TXRX = ((PCF8591 << 1) & 0xFE); // Send EEPROM address with read bit
  IIC_CRSR = START | WRITE | IACK; // Start condition with write bit
  checkTIP();
  checkAck();

  // Send Control byte for ADC function: 0x0000_0100 (Auto Increment Mode)
  IIC_TXRX = 0x4; // Send EEPROM address with write bit
  IIC_CRSR = WRITE | IACK; // Start condition with write bit
  checkTIP();
  checkAck();

  IIC_TXRX = ((PCF8591 << 1) | 0x1); // Send EEPROM address with read bit
  IIC_CRSR = START | WRITE | IACK; // Start condition with write bit
  checkTIP();
  checkAck();

  // Read data from ADC continously 

  // Load the triangle wave sample into the I2C transmit register
  IIC_CRSR = (READ | IACK) & (~NACK);  // Initiate I2C write for the data byte
  checkTIP();  // Wait until the transmission is complete
  while (!(IIC_CRSR & 0x1)); // Wait for IF flag to be set
  IIC_CRSR = 0; // Clear IF flag
  thermistorVal = IIC_TXRX; // Read data from EEPROM
  // printf("ADC Thermistor: %d\n", thermistorVal); // Debug: Indicate the address being read and the data read
  
  IIC_CRSR = (READ | IACK) & (~NACK);  // Initiate I2C write for the data byte
  checkTIP();  // Wait until the transmission is complete
  while (!(IIC_CRSR & 0x1)); // Wait for IF flag to be set
  IIC_CRSR = 0; // Clear IF flag
  readData = IIC_TXRX; // Read data from EEPROM
  
  IIC_CRSR = (READ | IACK) & (~NACK);  // Initiate I2C write for the data byte
  checkTIP();  // Wait until the transmission is complete
  while (!(IIC_CRSR & 0x1)); // Wait for IF flag to be set
  IIC_CRSR = 0; // Clear IF flag
  potentiometerVal = IIC_TXRX; // Read data from EEPROM
  // printf("ADC Potentiometer: %d\n", potentiometerVal); // Debug: Indicate the address being read and the data read

  IIC_CRSR = (READ | IACK) & (~NACK);  // Initiate I2C write for the data byte
  checkTIP();  // Wait until the transmission is complete
  while (!(IIC_CRSR & 0x1)); // Wait for IF flag to be set
  IIC_CRSR = 0; // Clear IF flag
  lightSensorVal = IIC_TXRX; // Read data from EEPROM
  // printf("ADC Light Sensor: %d\n", lightSensorVal); // Debug: Indicate the address being read and the data read

  IIC_CRSR = STOP | READ | IACK | NACK; // STOP + READ + IACK + NACK
  checkTIP();

  wait5ms(); wait5ms();
}

void Timer_ISR(void)
{
    static unsigned char lastT = 0, lastP = 0, lastL = 0, lastSW = 0;
    static char needsUpdate = 1;
    int i;

    if(Timer1Status == 1) {       
        Timer1Control = 3;      
        Timer1Count++;           

        if(needsUpdate) {
            printf("\rC0: T=--- P=--- L=--- SW=--------    ");
            needsUpdate = 0;
        }

        if (Timer1Count % 200 == 0) {
            ADCRead();
            if(lastT != thermistorVal) {
                printf("\rC0: T=%3d", thermistorVal);
                CanBus0_Transmit(SENSOR_ID_THERMISTOR, thermistorVal);
                lastT = thermistorVal;
            }
        }

        if (Timer1Count % 20 == 0) {
            ADCRead();
            if(lastP != potentiometerVal) {
                printf("\rC0: T=%3d P=%3d", lastT, potentiometerVal);
                CanBus0_Transmit(SENSOR_ID_POTENTIOMETER, potentiometerVal);
                lastP = potentiometerVal;
            }
        }

        if (Timer1Count % 50 == 0) {
            ADCRead();
            if(lastL != lightSensorVal) {
                printf("\rC0: T=%3d P=%3d L=%3d", lastT, lastP, lightSensorVal);
                CanBus0_Transmit(SENSOR_ID_LIGHT, lightSensorVal);
                lastL = lightSensorVal;
            }
        }

        if (Timer1Count % 10 == 0) {
            unsigned char switches = GetSwitches();
            if(lastSW != switches) {
                printf("\rC0: T=%3d P=%3d L=%3d SW=", lastT, lastP, lastL);
                for(i = 7; i >= 0; i--) {
                    printf("%d", (switches >> i) & 0x01);
                }
                CanBus0_Transmit(SENSOR_ID_SWITCHES, switches);
                lastSW = switches;
            }
        }

        if (Timer1Count >= 200) {
            Timer1Count = 0;
        }
    }
}

void main(void)
{  
    Timer1Count = 0;
    thermistorVal = 0;
    potentiometerVal = 0;
    lightSensorVal = 0;

    printf("Starting...\n");
    Init_CanBus_Controller0();
    Init_CanBus_Controller1();
    printf("CAN Controllers Initialized\n");
    OSInit();
    printf("RTOS Initialized\n");

    InstallExceptionHandler(Timer_ISR, 30);
    Timer1_Init();
    printf("Timer Initialized\n");

    printf("\r\n---- Lab 6B CANBUS Test ----\r\n");
    printf("C0/C1: T=Thermistor P=Potentiometer L=Light SW=Switches\r\n");

    OSStart();
}

void ADCThread(void *pdata) {
    while(1) {
        ADCRead();
        OSTimeDly(10);
    }
}