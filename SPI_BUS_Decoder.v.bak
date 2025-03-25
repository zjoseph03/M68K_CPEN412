module SPI_BUS_Decoder(
   input [31:0] Address,      // Changed from unsigned to standard Verilog format
   input SPI_Select_H,
   input AS_L,
   output reg SPI_Enable_H
);

always @(*) begin    
    // Default: SPI disabled
    SPI_Enable_H = 1'b0;   

    // 0x[0040_8020 - 0x0040_802F
    // Check if we're in SPI range 0x8020-0x802F
    if(SPI_Select_H == 1'b1 &&        // Upper address range valid
       Address[15:4] == 12'h802 &&    // Match 0x802x
       AS_L == 1'b0) begin            // Address Strobe active
        SPI_Enable_H = 1'b1;
    end
end

endmodule