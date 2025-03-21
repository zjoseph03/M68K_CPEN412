LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;

ENTITY SCL_SDA_OPEN_DRAIN_DRIVER IS
    PORT (
        -- i2c lines
        scl_pad_i    : OUT   std_logic;  -- i2c clock line input
        scl_pad_o    : IN    std_logic;  -- i2c clock line output
        scl_padoen_o : IN    std_logic;  -- i2c clock line output enable, active low
        sda_pad_i    : OUT   std_logic;  -- i2c data line input
        sda_pad_o    : IN    std_logic;  -- i2c data line output
        sda_padoen_o : IN    std_logic;  -- i2c data line output enable, active low
        SCL          : INOUT std_logic;
        SDA          : INOUT std_logic
    );
END ENTITY SCL_SDA_OPEN_DRAIN_DRIVER;

ARCHITECTURE structural OF SCL_SDA_OPEN_DRAIN_DRIVER IS
BEGIN
    SCL <= scl_pad_o WHEN (scl_padoen_o = '0') ELSE 'Z';
    SDA <= sda_pad_o WHEN (sda_padoen_o = '0') ELSE 'Z';
    
    scl_pad_i <= SCL;
    sda_pad_i <= SDA;
END ARCHITECTURE;