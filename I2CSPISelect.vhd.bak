library ieee;
use ieee.std_logic_1164.all;

entity I2CSPISelect is
    port (
        SPI_Enable_H : in  std_logic;
        I2C_Enable_H : in  std_logic;
        SPI_Data     : in  std_logic_vector(7 downto 0);
        I2C_Data     : in  std_logic_vector(7 downto 0);
        DataOut      : out std_logic_vector(7 downto 0)
    );
end I2CSPISelect;

architecture bhvr of I2CSPISelect is
begin
    process(SPI_Enable_H, I2C_Enable_H, SPI_Data, I2C_Data)
    begin
        if (I2C_Enable_H = '1') then
            DataOut <= I2C_Data;  -- I2C has priority
        elsif (SPI_Enable_H = '1') then
            DataOut <= SPI_Data;
        else
            DataOut <= (others => '0');  -- Default value when neither enabled
        end if;
    end process;
end bhvr;