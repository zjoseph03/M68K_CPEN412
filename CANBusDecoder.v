module CanBusDecoder (
    input [31:0] Address,
    input CanBusSelect_H,    // active when 68k accesses range 0x00500000-0050FFFF
    input AS_L,
    output reg CAN_Enable0_H,
    output reg CAN_Enable1_H
);

    // Address decoding logic with direct range comparison
    always @(Address or CanBusSelect_H or AS_L) begin
        // Default values (inactive)
        CAN_Enable0_H = 1'b0;
        CAN_Enable1_H = 1'b0;
        
        // Only decode when CanBusSelect_H is active and AS_L is asserted (active low)
        if (CanBusSelect_H && !AS_L) begin
            // Direct range comparison for CAN0: $00500000 - $005001FF
            if (Address >= 32'h00500000 && Address <= 32'h005001FF) begin
                CAN_Enable0_H = 1'b1;
            end
            // Direct range comparison for CAN1: $00500200 - $005003FF
            else if (Address >= 32'h00500200 && Address <= 32'h005003FF) begin
                CAN_Enable1_H = 1'b1;
            end
        end
    end
    
endmodule