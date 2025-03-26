// I2CSPISelect.v - 2:1 Multiplexer for selecting between I2C and SPI data

module I2CSPISelect(
    input        SPI_Enable_H,   // Active high enable for SPI
    input        I2C_Enable_H,   // Active high enable for I2C
	 input  [7:0] SPI_Data,       // 8-bit input data from SPI
    input  [7:0] I2C_Data,       // 8-bit input data from I2C
    output [7:0] DataOut         // 8-bit output data
);

    // Internal select signal
    wire select;
    
    // Determine select based on enable signals
    // When SPI_Enable_H is active, select = 0 (select SPI data)
    // When I2C_Enable_H is active, select = 1 (select I2C data)
    assign select = I2C_Enable_H;
    
    // Output multiplexer
    assign DataOut = (select) ? I2C_Data : SPI_Data;

endmodule