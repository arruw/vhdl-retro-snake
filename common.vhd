library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

package common is

    --TYPES
    type block_address_t is
    record
        address : integer range 0 to 29;
        offset : integer range 0 to 79;
    end record;

    --FUNCTIONS
    function get_next_block_address(
        signal curr_block_address : in block_address_t;
        signal direction : in std_logic_vector (3 downto 0)) return block_address_t;

--  function get_prev_block_address(
--      signal curr_block_address : in block_address_t;
--      signal direction : in std_logic_vector (3 downto 0)) return block_address_t;

-- type <new_type> is
--  record
--    <type_name>        : std_logic_vector( 7 downto 0);
--    <type_name>        : std_logic;
-- end record;
--
-- Declare constants
--
-- constant <constant_name>		: time := <time_unit> ns;
-- constant <constant_name>		: integer := <value;
--
-- Declare functions and procedure
--
-- function <function_name>  (signal <signal_name> : in <type_declaration>) return <type_declaration>;
-- procedure <procedure_name> (<type_declaration> <constant_name>	: in <type_declaration>);
--

end common;

package body common is

    function get_next_block_address(
        signal curr_block_address : in block_address_t;
        signal direction : in std_logic_vector (3 downto 0)) return block_address_t is
        variable next_block_address : block_address_t;
    begin
        case( direction ) is
            when "1000" =>
                next_block_address.address := curr_block_address.address;
                next_block_address.offset := curr_block_address.offset - 2;
            when "0010" =>
                next_block_address.address := curr_block_address.address;
                next_block_address.offset := curr_block_address.offset + 2;
            when "0100" =>
                next_block_address.address := curr_block_address.address - 1;
                next_block_address.offset := curr_block_address.offset;
            when "0001" =>
                next_block_address.address := curr_block_address.address + 1;
                next_block_address.offset := curr_block_address.offset;
            when others =>
                next_block_address := curr_block_address;
        end case ;

        if curr_block_address.address = 29 and next_block_address.address > 29 then
            next_block_address.address := 0;
        elsif curr_block_address.address = 0 and next_block_address.address > 29 then
            next_block_address.address := 29;
        end if;

        if curr_block_address.offset = 78 and next_block_address.offset > 78 then
            next_block_address.offset := 0;
        elsif curr_block_address.offset = 0 and next_block_address.offset > 78 then
            next_block_address.offset := 78;
        end if;

        return next_block_address;
    end get_next_block_address;

--    function get_prev_block_address(
--        signal curr_block_address : in block_address_t;
--        signal direction : in std_logic_vector (3 downto 0)) return block_address_t is
--        variable prev_block_address : block_address_t;
--    begin
--        case( direction ) is
--            when "1000" =>
--                prev_block_address.address := curr_block_address.address;
--                prev_block_address.offset := curr_block_address.offset + 2;
--            when "0010" =>
--                prev_block_address.address := curr_block_address.address;
--                prev_block_address.offset := curr_block_address.offset - 2;
--            when "0100" =>
--                prev_block_address.address := curr_block_address.address + 1;
--                prev_block_address.offset := curr_block_address.offset;
--            when "0001" =>
--                prev_block_address.address := curr_block_address.address - 1;
--                prev_block_address.offset := curr_block_address.offset;
--            when others =>
--                prev_block_address := curr_block_address;
--        end case ;
--        return prev_block_address;
--    end get_prev_block_address;

---- Example 1
--  function <function_name>  (signal <signal_name> : in <type_declaration>  ) return <type_declaration> is
--    variable <variable_name>     : <type_declaration>;
--  begin
--    <variable_name> := <signal_name> xor <signal_name>;
--    return <variable_name>; 
--  end <function_name>;

---- Example 2
--  function <function_name>  (signal <signal_name> : in <type_declaration>;
--                         signal <signal_name>   : in <type_declaration>  ) return <type_declaration> is
--  begin
--    if (<signal_name> = '1') then
--      return <signal_name>;
--    else
--      return 'Z';
--    end if;
--  end <function_name>;

---- Procedure Example
--  procedure <procedure_name>  (<type_declaration> <constant_name>  : in <type_declaration>) is
--    
--  begin
--    
--  end <procedure_name>;
 
end common;
