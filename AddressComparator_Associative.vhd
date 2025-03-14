LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;

ENTITY AddressComparator_Associative IS
    PORT (
        AddressBus : IN std_logic_vector(20 DOWNTO 0);
        TagData    : IN std_logic_vector(20 DOWNTO 0);
        Hit_H      : OUT std_logic
    );
END ENTITY;

ARCHITECTURE bhvr OF AddressComparator_Associative IS
BEGIN
    PROCESS(AddressBus, TagData)
    BEGIN
        IF (AddressBus = TagData) THEN
            Hit_H <= '1';
        ELSE
            Hit_H <= '0';
        END IF;
    END PROCESS;
END ARCHITECTURE;