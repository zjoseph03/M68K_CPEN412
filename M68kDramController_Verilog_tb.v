`timescale 1ns / 1ps

module tb_M68kDramController;

    // Declare testbench signals to drive the DUT.
    // (Note: many ports are active low.)
    reg           Clock;
    reg           Reset_L;
    reg  [31:0]   Address;
    reg  [15:0]   DataIn;
    reg           UDS_L;
    reg           LDS_L;
    reg           DramSelect_L;
    reg           WE_L;
    reg           AS_L;
    
    // The outputs from the DUT
    wire [15:0]   DataOut;
    wire          SDram_CKE_H;
    wire          SDram_CS_L;
    wire          SDram_RAS_L;
    wire          SDram_CAS_L;
    wire          SDram_WE_L;
    wire [12:0]   SDram_Addr;
    wire [1:0]    SDram_BA;
    wire          Dtack_L;
    wire          ResetOut_L;
    wire [4:0]    DramState;
    
    // For the bidirectional SDRAM data bus, we declare a net.
    // (In this simple testbench we leave the bus un-driven externally.)
    wire [15:0]   SDram_DQ;
    
    // Instantiate the SDRAM controller DUT.
    // (Make sure the module name and port order match your design.)
    M68kDramController_Verilog uut (
        .Clock         (Clock),
        .Reset_L       (Reset_L),
        .Address       (Address),
        .DataIn        (DataIn),
        .UDS_L         (UDS_L),
        .LDS_L         (LDS_L),
        .DramSelect_L  (DramSelect_L),
        .WE_L          (WE_L),
        .AS_L          (AS_L),
        .DataOut       (DataOut),
        .SDram_CKE_H   (SDram_CKE_H),
        .SDram_CS_L    (SDram_CS_L),
        .SDram_RAS_L   (SDram_RAS_L),
        .SDram_CAS_L   (SDram_CAS_L),
        .SDram_WE_L    (SDram_WE_L),
        .SDram_Addr    (SDram_Addr),
        .SDram_BA      (SDram_BA),
        .SDram_DQ      (SDram_DQ),
        .Dtack_L       (Dtack_L),
        .ResetOut_L    (ResetOut_L),
        .DramState     (DramState)
    );
    
    // Clock generation: toggle every 10ns (i.e. 20ns period).
    initial begin
        Clock = 0;
        forever #10 Clock = ~Clock;
    end

    // Stimulus process: drive reset, then perform a read followed by a write.
    initial begin
        // Initialize all inputs.
        Reset_L       = 0;          // Assert reset (active low)
        Address       = 32'h00000000;
        DataIn        = 16'h0000;
        UDS_L         = 1;          // Not active (inactive high)
        LDS_L         = 1;
        DramSelect_L  = 1;          // Not selected (active low)
        WE_L          = 1;          // Read mode (write is active low)
        AS_L          = 1;          // Inactive address strobe
        
        // Wait 100 ns for global reset conditions.
        #100;
        Reset_L = 1;              // Release reset

        // Wait for a short time to allow the controller's initialization sequence.
        #5000;
        
        // -----------------------
        // Simulate a READ transaction:
        // The 68000 will drive Address, UDS/LDS and assert AS_L and DramSelect_L.
        // (WE_L remains high for a read.)
        // -----------------------
        $display("Starting a simulated READ transaction at time %t", $time);
        DramSelect_L = 0;         // Activate SDRAM selection (active low)
        AS_L         = 0;         // Assert address strobe to indicate bus cycle start
        Address      = 32'h00A00000; // Example address (the controller will extract row, column, bank)
        WE_L         = 1;         // Read operation (WE_L inactive)
        UDS_L        = 0;         // Assert UDS and LDS (active low) to indicate a full word read
        LDS_L        = 0;
        
        // Hold the bus for a few clock cycles (e.g. 40 ns).
        #40;
        
        // End the bus cycle.
        AS_L         = 1;
        DramSelect_L = 1;
        UDS_L        = 1;
        LDS_L        = 1;
        
        
        // Wait a little before next transaction.
        #100;
        
        // -----------------------
        // Simulate a WRITE transaction:
        // For a write, the 68k asserts WE_L low and drives DataIn.
        // -----------------------
        $display("Starting a simulated WRITE transaction at time %t", $time);
        DramSelect_L = 0;         // Activate SDRAM selection
        AS_L         = 0;         // Assert address strobe
        Address      = 32'h00B00010; // Example write address
        WE_L         = 0;         // Write operation (active low)
        DataIn       = 16'hABCD;   // Example data to write
        UDS_L        = 0;         // Assert UDS and LDS (active low)
        LDS_L        = 0;
        
        // Hold the bus for a short period.
        #40;
        
        // End the bus cycle.
        AS_L         = 1;
        DramSelect_L = 1;
        WE_L         = 1;         // Return to read mode
        UDS_L        = 1;
        LDS_L        = 1;
        
        // Allow time to observe any subsequent refresh activity.
        #200;
        
        $display("Testbench simulation complete at time %t", $time);
        $finish;
    end

endmodule
