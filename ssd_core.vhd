----------------------------------------------------------------------------------
-- Company:        Matjaz Mav
-- Create Date:    02/12/2017 
-- Module Name:    ssd_core - Behavioral 
-- Target Devices: 
-- Description: 
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity ssd_core is
    port(
        clk_i : in std_logic;
        reset_i : in std_logic;
        number_i : in std_logic_vector (15 downto 0);
        cathode_o : out std_logic_vector (6 downto 0);
        anode_o : out std_logic_vector(3 downto 0)
    );
end ssd_core;

architecture Behavioral of ssd_core is
    signal cathode : std_logic_vector (6 downto 0);
    signal anode : std_logic_vector (3 downto 0);
    signal anode_enable : std_logic;

    component prescaler is
        generic (
            value : integer := 255
        );
        port (
            clk_i : in std_logic;
            reset_i : in std_logic;
            enable_o : out std_logic
        );
    end component;
begin

    anode_o <= anode;
	cathode_o <= cathode;

    p: prescaler
    generic map (
        value =>50000  -- 1ms
    )
    port map(
        clk_i => clk_i,
        reset_i => reset_i,
        enable_o => anode_enable
    );

    set_anode : process( anode_enable )
    begin
        if rising_edge( anode_enable ) then
            case anode is
                when "1110" => anode <= "1101";
                when "1101" => anode <= "1011";
                when "1011" => anode <= "0111";
                when "0111" => anode <= "1110";
                when others => anode <= "1110";
            end case;
        end if ;
    end process ; -- set_anode

    set_cathode : process( anode, number_i )
        variable number : std_logic_vector(3 downto 0);
    begin
        case anode is
			when "1110" => number := number_i(3 downto 0);
			when "1101" => number := number_i(7 downto 4);
			when "1011" => number := number_i(11 downto 8);
			when "0111" => number := number_i(15 downto 12);
			when others => number := number_i(3 downto 0);
		end case ;

        case number is
			when "0000" => cathode <= "1000000"; -- 0
			when "0001" => cathode <= "1111001"; -- 1
			when "0010" => cathode <= "0100100"; -- 2
			when "0011" => cathode <= "0110000"; -- 3
			when "0100" => cathode <= "0011001"; -- 4
			when "0101" => cathode <= "0010010"; -- 5
			when "0110" => cathode <= "0000010"; -- 6
			when "0111" => cathode <= "1111000"; -- 7
			when "1000" => cathode <= "0000000"; -- 8
			when "1001" => cathode <= "0011000"; -- 9
			when "1010" => cathode <= "0001000"; -- A
			when "1011" => cathode <= "0000011"; -- B
			when "1100" => cathode <= "1000110"; -- C
			when "1101" => cathode <= "0100001"; -- D
			when "1110" => cathode <= "0000110"; -- E
			when "1111" => cathode <= "0001110"; -- F
			when others => cathode <= "1000000"; -- 0
		end case ;
    end process ; -- set_cathode

end Behavioral;

