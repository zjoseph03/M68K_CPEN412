# Writes
- TODO: function to write specified size block of data up to 128K bytes
- For testing: use incremental 8 bit values as data (could possibly use array)
## Notes
- Page write: write multiple cycles in a single write cycle
- Organized in 2x 64KB blocks
- Need different I2C Address to access each block
- CANNOT treat it as a single 128kb device

## 2x 64K Blocks
- 00000 – 0FFFF
- 10000 - 1FFFF

Need to generate new physical + internal address when crossing 64k boundary (confirm what this means)

## Write Operation    
- Control bits: block select bit (B0)
- Instead of stop condition after every byte, transmit 127 more bytes and then send stop condition
- After you write each word (byte), 7 lower address pointer bits + 1
- So each page write is 128 bytes (stored on buffer)
- If transmit > 128 bytes prior to generating stop condition, address counter rolls over and previously recieved data is overwritten

# Write Steps
1. Start condition
2. Control byte with block select bit for which block
3. High address, low address
4. Send 128 bytes in sequence
5. 128 bytes stored in page write buffer
6. Stop condition
7. EEProm writes buffered bytes to memory all at once

# Waveform
Start condition
Contol byte (block select picked)
checkACK()
checkTIP()

Addresshigh()
CheckACK()
CheckTIP()

AddressLow()
CheckACK()
CheckTIP()

for (int i = 0; i < 128; i++>)
    Writedatabyte
    CheckACK()
    CheckTIP()

# Pseudocode
```C
function blockWrites128kb
function EEPromBlockWrite(int startingAddress, size, data)
    currentAddress = startingAddress
    bytesWritten = 0
    BytesLefttoWrite
    int size
    int data

// determine which block we are in
    if bytesWritten < length
        if currentAddress >= 0x10000
            set b0 to 1 //for upper block
            
        else
            set b0 to 0 //for lower block

        

    // Calculate how many bytes in current page
    // Limit each page to end at a boundary 
    // Start new page writes for next page

    determine how many bytes to write 
        Set bytesToWrite = minimum of:
            - remaining bytes in data (length - bytesWritten)
            - remaining bytes in current page (bytesRemainingInPage)
            - bytes until 64KB boundary (if approaching boundary)

    page 
        






```


# Reads
- What We Need For This Lab:
  - Read block of specified size up to 128K bytes starting at any possible address (We need to do page read for this)
  - We need to consider block boundaries
  - Need to consider wrap around when we reach the upper boundary for either block
  - We can do indefinite sequential reads without needing to give a new address

- How Addressing Will Work:
  - Two different slave addresses for each 64K block
  - Does the internal memory address change? When accessing the first element of the second block what internal memory address do we provide?

- When you choose a READ on the controller side, set either an ACK or NACK on command register
- Poll IF before you can from RX register


# Sequential Read Operation Steps
- Initiated the same way as a random read
- After the first data byte, master issues an ACK instead of a STOP
- This will cause the slave to transmit the next 8-bit word
- After the final byte gets transmitted,, the master will not ACK and will STOP

# Sequential Read: Handling roll-over
- Given the size of a read, and the start address, we need to determine wether we will ACK or NACK/STOP 
- based on what the next address being read will be.
- In the case that we need to roll over:
  - Send a STOP and a NACK for the current recieve
  - Send a new command with the next block slave address, a starting address of 10000h, and a size of the remaining amount of bits we need to read

# Sequential Read: Functions
- startReadBlock0(int readBytes, int startAddr)
  - This function will send the START condition, and the block0 slave address
  - This function will then call runReadBlock0()
  
- runReadBlock0(int readBytes, int startAddr)
  - Here we will continously evaluate and print reads
  - This function will need to check the current internal addr and check if it is 0FFFFh.
    - If it is, then we will do a NACK/STOP and call startReadBlock1(), providing the remaining bytes and 1FFFFh as the parameters 
  
- startReadBlock1(int readBytes, int startAddr)
  - similair to startReadBlock1, we will send the START condition at the block1 slave address
  - We  then call runReadBlock1()

- runReadBlock1(int readBytes, int startAddr)
  - similair to block0, we will continously evaluate the current addr to determine if we send ACK or NACK/STOP
  - If current address is 1FFFF'h, then that means that is the end of the read and we will need to send the NACK/STOP condition


# Pseudo Code:
```C
  void readBlock0(int startAddr, int* readLen) {
    int currAddr = startAddr;

    TXRX = (EEPROM0 << 1);
    SRCR = START | WRITE | IACK
    checkTIP();
    checkACK();

    // Start evaluating and printing back the data here
    // MSB Address
    TXRX = MSB_ADDRESS;
    SRCR = WRITE | IACK;
    checkTIP();
    checkACK();

    // LSB Address
    TXRX = LSB_ADDRESS;
    SRCR = WRITE | IACK;
    checkTIP();
    checkACK();

    //Repeated start condition
    IIC_TXRX = 0xA3; //((deviceAddr << 1) | 0x01);
    IIC_CRSR = START | WRITE | IACK;
    checkTIP();
    checkAck();

    // Continously evaluate current addr:
    for (currentAddr = startAddr; currentAddr <= startAddr + readLen; currentAddr++) {
        if (currentAddr == 0xFFFF) {
        CRSR = STOP | READ | IACK & | NACK; // Send a NACK and STOP because were at the end of block 1
      } else {
        CRSR = READ | IACK | ACK;
      }

      // Poll for available data
      while (~IF_FLAG) {}
      readData = TXRX;
      printf(readData);
      readLen--;

      // If readLen > 0 at the top level, then we need to proceed to the next block
      return;
    }

    
  }

  void readBlock1(int startAddr, int readLen) {
    // Similair to block0
  }

  void topLevel(int startAddr, int readLen) {
    if (startAddr <= 0xFFFF) {
      readBlock0(startAddr, &readLen);
      if (readLen > 0) {
        readBlock1(0x10000, &readLen);
      }
    } else {
      readBlock1(startAddr, readLen);
    }
  }

```



# Things TO Test For Part A
x Wrap Around Reads and Writes
x Can We Right/Read An Entire Page
- Can We right and read multiple pages
- Can we right and read the 128K

