LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
USE ieee.std_logic_arith.all;

ENTITY CacheDataMux IS
    PORT (
        ValidHit0_H, ValidHit1_H, ValidHit2_H, ValidHit3_H : IN std_logic;
        Block0_In                                          : IN std_logic_vector(15 DOWNTO 0);
        Block1_In                                          : IN std_logic_vector(15 DOWNTO 0);
        Block2_In                                          : IN std_logic_vector(15 DOWNTO 0);
        Block3_In                                          : IN std_logic_vector(15 DOWNTO 0);
        DataOut                                            : OUT std_logic_vector(15 DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE bhvr OF CacheDataMux IS
BEGIN
    PROCESS(ValidHit0_H, ValidHit1_H, ValidHit2_H, ValidHit3_H, 
            Block0_In, Block1_In, Block2_In, Block3_In)
    BEGIN
        IF (ValidHit0_H = '1') THEN
            DataOut <= Block0_In;
        ELSIF (ValidHit1_H = '1') THEN
            DataOut <= Block1_In;
        ELSIF (ValidHit2_H = '1') THEN
            DataOut <= Block2_In;
        ELSE
            DataOut <= Block3_In;
        END IF;
    END PROCESS;
END ARCHITECTURE;