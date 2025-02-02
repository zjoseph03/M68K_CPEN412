
//////////////////////////////////////////////////////////////////////////////////////-
// Simple DRAM controller for the DE1 board, assuming a 50MHz controller/memory clock
// Assuming 64Mbytes SDRam organised as 32Meg x16 bits with 8192 rows (13 bit row addr
// 1024 columns (10 bit column address) and 4 banks (2 bit bank address)
// CAS latency is 2 clock periods
//
// designed to work with 68000 cpu using 16 bit data bus and 32 bit address bus
// separate upper and lower data stobes for individual byte and 16 bit word access
//
// Copyright PJ Davies June 2020
//////////////////////////////////////////////////////////////////////////////////////-

module M68kDramController_Verilog (
            input Clock,                                // used to drive the state machine- stat changes occur on positive edge
            input Reset_L,                          // active low reset 
            input unsigned [31:0] Address,      // address bus from 68000
            input unsigned [15:0] DataIn,           // data bus in from 68000
            input UDS_L,                                // active low signal driven by 68000 when 68000 transferring data over data bit 15-8
            input LDS_L,                                // active low signal driven by 68000 when 68000 transferring data over data bit 7-0
            input DramSelect_L,                     // active low signal indicating dram is being addressed by 68000
            input WE_L,                                 // active low write signal, otherwise assumed to be read
            input AS_L,                                 // Address Strobe
            
            output reg unsigned[15:0] DataOut,              // data bus out to 68000
            output reg SDram_CKE_H,                             // active high clock enable for dram chip
            output reg SDram_CS_L,                              // active low chip select for dram chip
            output reg SDram_RAS_L,                             // active low RAS select for dram chip
            output reg SDram_CAS_L,                             // active low CAS select for dram chip      
            output reg SDram_WE_L,                              // active low Write enable for dram chip
            output reg unsigned [12:0] SDram_Addr,          // 13 bit address bus dram chip 
            output reg unsigned [1:0] SDram_BA,             // 2 bit bank address
            inout  reg unsigned [15:0] SDram_DQ,            // 16 bit bi-directional data lines to dram chip
            
            output reg Dtack_L,                                 // Dtack back to CPU at end of bus cycle
            output reg ResetOut_L,                              // reset out to the CPU
    
            // Use only if you want to simulate dram controller state (e.g. for debugging)
            output reg [4:0] DramState
        );  
        
        // WIRES and REGs
        
        reg     [4:0] Command;                                      // 5 bit signal containing Dram_CKE_H, SDram_CS_L, SDram_RAS_L, SDram_CAS_L, SDram_WE_L
        reg TimerLoad_H ;                                       // logic 1 to load Timer on next clock
        reg   TimerDone_H ;                                     // set to logic 1 when timer reaches 0
        reg     unsigned    [15:0] Timer;                           // 16 bit timer value
        reg     unsigned    [15:0] TimerValue;                  // 16 bit timer preload value
        reg RefreshTimerLoad_H;                             // logic 1 to load refresh timer on next clock
        reg   RefreshTimerDone_H ;                              // set to 1 when refresh timer reaches 0
        reg     unsigned    [15:0] RefreshTimer;                    // 16 bit refresh timer value
        reg     unsigned    [15:0] RefreshTimerValue;           // 16 bit refresh timer preload value
        reg   unsigned [4:0] CurrentState;                  // holds the current state of the dram controller
        reg   unsigned [4:0] NextState;                     // holds the next state of the dram controller
        
        reg     unsigned [1:0] BankAddress;
        reg     unsigned [12:0] DramAddress;
        
        reg DramDataLatch_H;                                    // used to indicate that data from SDRAM should be latched and held for 68000 after the CAS latency period
        reg     unsigned [15:0]SDramWriteData;
        
        reg  FPGAWritingtoSDram_H;                              // When '1' enables FPGA data out lines leading to SDRAM to allow writing, otherwise they are set to Tri-State "Z"
        reg  CPU_Dtack_L;                                           // Dtack back to CPU
        reg  CPUReset_L;        
        reg unsigned [15:0] AutoRefreshCount;                       // refresh count for the dram controller
        // 5 bit Commands to the SDRam
        // CK_E [4]
        // CS   [3]
        // RAS  [2]
        // CAS  [1]
        // WE   [0]
        parameter PoweringUp = 5'b00000 ;                   // take CKE & CS low during power up phase, address and bank address = dont'care
        parameter DeviceDeselect  = 5'b11111;               // address and bank address = dont'care
        parameter NOP = 5'b10111;                               // address and bank address = dont'care
        parameter BurstStop = 5'b10110;                     // address and bank address = dont'care
        parameter ReadOnly = 5'b10101;                      // A10 should be logic 0, BA0, BA1 should be set to a value, other addreses = value
        parameter ReadAutoPrecharge = 5'b10101;             // A10 should be logic 1, BA0, BA1 should be set to a value, other addreses = value
        parameter WriteOnly = 5'b10100;                         // A10 should be logic 0, BA0, BA1 should be set to a value, other addreses = value
        parameter WriteAutoPrecharge = 5'b10100 ;           // A10 should be logic 1, BA0, BA1 should be set to a value, other addreses = value
        parameter AutoRefresh = 5'b10001;
    
        parameter BankActivate = 5'b10011;                  // BA0, BA1 should be set to a value, address A11-0 should be value
        parameter PrechargeSelectBank = 5'b10010;           // A10 should be logic 0, BA0, BA1 should be set to a value, other addreses = don't care
        
        parameter PrechargeAllBanks = 5'b10010;             // A10 should be logic 1, BA0, BA1 are dont'care, other addreses = don't care
        parameter ExtModeRegisterSet = 5'b10000;            // A10=0, BA1=1, BA0=0, Address = value
        
    
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////-
// Define some states for our dram controller add to these as required - only 5 will be defined at the moment - add your own as required
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////-
    
        parameter InitialisingState = 5'h00;                // power on initialising state
        parameter WaitingForPowerUpState = 5'h01;           // waiting for power up state to complete
        parameter IssueFirstNOP = 5'h02;                    // issuing 1st NOP after power up
        parameter PrechargingAllBanks = 5'h03;              // precharging all banks (used after first NOP during initialisation)   
        parameter InitIdle = 5'h04;                             // idle state - NOP         
        parameter InitRefreshLoop = 5'h05;                  // initialising refresh loop (10 refreshes with 3 NOP's after each refresh)
        parameter LoadModeRegister = 5'h06;                 // load mode register
        parameter IssueMrNOP = 5'h07;                           // issue 3 NOPs after loading mode register
        parameter Idle = 5'h08;                                 // idle state - waiting for refresh timer to expire
        parameter ProgramRefreshTimer = 5'h09;              // program the refresh timer to 7us and issue auto refresh
        parameter PostPreChargeNOP = 5'h0A;                 // issue a NOP after precharging all banks
        parameter IssueRefresh = 5'h0B;                         // issue a refresh after the NOP
        parameter PostRefreshNOP = 5'h0C;                       // issue 3 NOPs after the refresh
        parameter PostInitPrechargeAllBanks = 5'h0D;        // issue a precharge all banks after the NOP
        
        // TODO - Add your own states as per your own design
        
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// General Timer for timing and counting things: Loadable and counts down on each clock then produced a TimerDone signal and stops counting
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    always@(posedge Clock)
        if(TimerLoad_H == 1)                // if we get the signal from another process to load the timer
            Timer <= TimerValue ;           // Preload timer
        else if(Timer != 16'd0)             // otherwise, provided timer has not already counted down to 0, on the next rising edge of the clock        
            Timer <= Timer - 16'd1 ;        // subtract 1 from the timer value
    always@(Timer) begin
        TimerDone_H <= 0 ;                  // default is not done
    
        if(Timer == 16'd0)                  // if timer has counted down to 0
            TimerDone_H <= 1 ;              // output '1' to indicate time has elapsed
    end
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Refresh Timer: Loadable and counts down on each clock then produces a RefreshTimerDone signal and stops counting
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    always@(posedge Clock)
        if(RefreshTimerLoad_H == 1)                         // if we get the signal from another process to load the timer
            RefreshTimer  <= RefreshTimerValue ;        // Preload timer
        else if(RefreshTimer != 16'd0)                  // otherwise, provided timer has not already counted down to 0, on the next rising edge of the clock        
            RefreshTimer <= RefreshTimer - 16'd1 ;      // subtract 1 from the timer value
    always@(RefreshTimer) begin
        RefreshTimerDone_H <= 0 ;                           // default is not done
        if(RefreshTimer == 16'd0)                               // if timer has counted down to 0
            RefreshTimerDone_H <= 1 ;                       // output '1' to indicate time has elapsed
    end
    
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////-
// concurrent process state registers
// this process RECORDS the current state of the system.
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
   always@(posedge Clock, negedge Reset_L)
    begin
        if(Reset_L == 0)                            // asynchronous reset
            CurrentState <= InitialisingState ;
            
        else    begin                                   // state can change only on low-to-high transition of clock
            CurrentState <= NextState;      
            // these are the raw signals that come from the dram controller to the dram memory chip. 
            // This process expects the signals in the form of a 5 bit bus within the signal Command. The various Dram commands are defined above just beneath the architecture)
            SDram_CKE_H <= Command[4];          // produce the Dram clock enable
            SDram_CS_L  <= Command[3];          // produce the Dram Chip select
            SDram_RAS_L <= Command[2];          // produce the dram RAS
            SDram_CAS_L <= Command[1];          // produce the dram CAS
            SDram_WE_L  <= Command[0];          // produce the dram Write enable
            
            SDram_Addr  <= DramAddress;     // output the row/column address to the dram
            SDram_BA    <= BankAddress;     // output the bank address to the dram
            // signals back to the 68000
            Dtack_L         <= CPU_Dtack_L ;            // output the Dtack back to the 68000
            ResetOut_L  <= CPUReset_L ;         // output the Reset out back to the 68000
            
            // The signal FPGAWritingtoSDram_H can be driven by you when you need to turn on or tri-state the data bus out signals to the dram chip data lines DQ0-15
            // when you are reading from the dram you have to ensure they are tristated (so the dram chip can drive them)
            // when you are writing, you have to drive them to the value of SDramWriteData so that you 'present' your data to the dram chips
            // of course during a write, the dram WE signal will need to be driven low and it will respond by tri-stating its outputs lines so you can drive data in to it
            // remember the Dram chip has bi-directional data lines, when you read from it, it turns them on, when you write to it, it turns them off (tri-states them)
            if(FPGAWritingtoSDram_H == 1)           // if CPU is doing a write, we need to turn on the FPGA data out lines to the SDRam and present Dram with CPU data 
                SDram_DQ    <= SDramWriteData ;
            else
                SDram_DQ    <= 16'bZZZZZZZZZZZZZZZZ;            // otherwise tri-state the FPGA data output lines to the SDRAM for anything other than writing to it
        
            DramState <= CurrentState ;                 // output current state - useful for debugging so you can see you state machine changing states etc
        end
    end 
    
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////-
// Concurrent process to Latch Data from Sdram after Cas Latency during read
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////-
// this process will latch whatever data is coming out of the dram data lines on the FALLING edge of the clock you have to drive DramDataLatch_H to logic 1
// remember there is a programmable CAS latency for the Zentel dram chip on the DE1 board it's 2 or 3 clock cycles which has to be programmed by you during the initialisation
// phase of the dram controller following a reset/power on
//
// During a read, after you have presented CAS command to the dram chip you will have to wait 2 clock cyles and then latch the data out here and present it back
// to the 68000 until the end of the 68000 bus cycle
    always@(negedge Clock)
    begin
        if(DramDataLatch_H == 1)                // asserted during the read operation
            DataOut <= SDram_DQ ;                   // store 16 bits of data regardless of width - don't worry about tri state since that will be handled by buffers outside dram controller
    end
    
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////-
// next state and output logic
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////  
    
    always@(*)
    begin
    
    // In Verilog/VHDL - you will recall - that combinational logic (i.e. logic with no storage) is created as long as you
    // provide a specific value for a signal in each and every possible path through a process
    // 
    // You can do this of course, but it gets tedious to specify a value for each signal inside every process state and every if-else test within those states
    // so the common way to do this is to define default values for all your signals and then override them with new values as and when you need to.
    // By doing this here, right at the start of a process, we ensure the compiler does not infer any storage for the signal, i.e. it creates
    // pure combinational logic (which is what we want)
    //
    // Let's start with default values for every signal and override as necessary, 
    //
    
        Command     <= NOP ;                                                // assume no operation command for Dram chip
        NextState <= InitialisingState ;                            // assume next state will always be idle state unless overridden the value used here is not important, we cimple have to assign something to prevent storage on the signal so anything will do
        
        TimerValue <= 16'h0000;                                     // no timer value 
        RefreshTimerValue <= 16'h0000 ;                         // no refresh timer value
        TimerLoad_H <= 0;                                               // don't load Timer
        RefreshTimerLoad_H <= 0 ;                                   // don't load refresh timer
        DramAddress <= 13'h0000 ;                                   // no particular dram address
        BankAddress <= 2'b00 ;                                      // no particular dram bank address
        DramDataLatch_H <= 0;                                       // don't latch data yet
        CPU_Dtack_L <= 1 ;                                          // don't acknowledge back to 68000
        SDramWriteData <= 16'h0000 ;                                // nothing to write in particular
        CPUReset_L <= 0 ;                                               // default is reset to CPU (for the moment, though this will change when design is complete so that reset-out goes high at the end of the dram initialisation phase to allow CPU to resume)
        FPGAWritingtoSDram_H <= 0 ;                             // default is to tri-state the FPGA data lines leading to bi-directional SDRam data lines, i.e. assume a read operation
        AutoRefreshCount <= 16'h0000 ;                              // no refresh count set yet
        // put your current state/next state decision making logic here - here are a few states to get you started
        // during the initialising state, the drams have to power up and we cannot access them for a specified period of time (100 us)
        // we are going to load the timer above with a value equiv to 100us and then wait for timer to time out
    
        if(CurrentState == InitialisingState ) begin
            TimerValue <= 16'd8;                                    // chose a value equivalent to 100us at 50Mhz clock - you might want to shorten it to somthing small for simulation purposes (We can take it to 8 clock cycles for simulation) 50 Mhz = 20ns per clock cycle == 0.02us. 100us = 5000 clock cycles. 8 Clock Cycles = 160ns == 0.16us
                                                                    // Setting delay to 500 cycles == 10us for sim porposes
            TimerLoad_H <= 1 ;                                      // on next edge of clock, timer will be loaded and start to time out
            Command <= PoweringUp ;                                 // clock enable and chip select to the Zentel Dram chip must be held low (disabled) during a power up phase
            NextState <= WaitingForPowerUpState ;                   // once we have loaded the timer, go to a new state where we wait for the 100us to elapse
        end
        
        else if(CurrentState == WaitingForPowerUpState) begin
            Command <= PoweringUp ;                                 // no DRAM clock enable or CS while witing for 100us timer
            
            if(TimerDone_H == 1)                                    // if timer has timed out i.e. 100us have elapsed (8us for simulation)
                NextState <= IssueFirstNOP ;                        // take CKE and CS to active and issue a 1st NOP command
            else
                NextState <= WaitingForPowerUpState ;               // otherwise stay here until power up time delay finished
        end
        
        else if(CurrentState == IssueFirstNOP) begin                // issue a valid NOP
            Command <= NOP ;                                        // send a valid NOP command to the dram chip
            NextState <= PrechargingAllBanks;
        end
        else if (CurrentState == PrechargingAllBanks) begin
            Command <= PrechargeAllBanks ;                          // precharge all banks
            DramAddress <=  13'h0400;                               // Set A10 on address bus to logic 1 (0x400)
            RefreshTimerValue <= 16'h0029 ;                         // set refresh count to 41 (since we decrement by 1 in the IDLE state right when we enter)
            RefreshTimerLoad_H <= 1;                                // load refresh timer
            NextState <= InitIdle ;                                     // go to idle state and set refresh count here
        end
        
        else if (CurrentState == InitRefreshLoop) begin             
            if (RefreshTimerDone_H == 1) begin
                NextState <= LoadModeRegister;                      // go to load mode register
            end else begin
                Command <= AutoRefresh ;                                // auto refresh
                TimerValue <= 16'h0003 ;                                // 3 clock cycles for 3 NOPs
                TimerLoad_H <= 1 ;                                      // load timer
                NextState <= InitIdle ;                                     // stay in refresh loop
            end
        end
        
        else if (CurrentState == InitIdle) begin                        // no operation (40ns delay for step 4 of initiailization)
            Command <= NOP ;
            if (TimerDone_H == 1) begin
                NextState <= InitRefreshLoop ;                      // go to refresh loop
            end else begin
                NextState <= InitIdle ;                                 // stay in idle state
            end                                 
        end
        
        // TODO: For some reason TimerValue of 3 is lasting 4 cycles until the timer condition occurs? Easy enough to just set the timer to 1 less but why?
        else if (CurrentState == LoadModeRegister) begin        // load mode register according to spec
            Command <= ExtModeRegisterSet;
            DramAddress <= 13'h220;                         // Set A10 on address bus to logic 1 (0x220)
            TimerValue <= 16'h0003;
            TimerLoad_H <= 1;                                                                   
            NextState <= IssueMrNOP ;                       // Next state will be issueing 3 NOPs   
        end
        else if (CurrentState == IssueMrNOP) begin
            Command <= NOP;
            if (TimerDone_H == 1) begin
                NextState <= Idle;                          // Enter the Idle state after setting the Refresh Timer wait value
                RefreshTimerValue <= 16'd375;               // Wait 7.5 us == 375 clock cycles
                RefreshTimerLoad_H <= 1;
            end else begin
                NextState <= IssueMrNOP;                    // stay in this state
            end
        end
        // We only need 1 NOP after the MR, but we do 3 of them so we can immidietely issue a refresh right after 
        // Idle state is where we wait for the refresh timer to expire
        // When refresh timer is done we do the following
        // Issue a precharge all bank
        // Issue a NOP
        // Issue a refresh
        // Issue 3 NOP's
        // Set the Refresh Timer again to 7us
        else if (CurrentState == Idle) begin            // Stay in the state for the 7-7.5 us between Refreshes
            if (RefreshTimerDone_H == 1) begin
                Command <= PrechargeAllBanks;
                NextState <= PostInitPrechargeAllBanks;         // begin refresh by issueing precharge all bank command
            end else begin
                Command <= NOP;
                NextState <= Idle;
            end
        end
        else if (CurrentState == PostInitPrechargeAllBanks) begin
            Command <= PrechargeAllBanks;
            DramAddress <= 16'h0400;
            NextState <= PostPreChargeNOP;
        end
        else if (CurrentState == PostPreChargeNOP) begin
            Command <= NOP;
            NextState <= IssueRefresh;
        end
        else if (CurrentState == IssueRefresh) begin
            Command <= AutoRefresh;
            TimerValue <= 16'h0003;
            TimerLoad_H <= 1;
            NextState <= PostRefreshNOP;
        end
        else if (CurrentState == PostRefreshNOP) begin
            Command <= NOP;
            if (TimerDone_H == 1) begin
                NextState <= ProgramRefreshTimer;
            end else begin
                NextState <= PostRefreshNOP;
            end
        end
        else if (CurrentState == ProgramRefreshTimer) begin     // Program the refresh timer to 7us and issue auto refresh here
            Command <= AutoRefresh;
            RefreshTimerValue <= 16'h015E;                      // 7.5us == 350 clock cycles
            NextState <= Idle;
        end
        else begin
            NextState <= InitialisingState ;                        // default state
        end
        
    end // always@ block
endmodule
