library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ascii_input is
    Port (
        clk         : in  STD_LOGIC;
        reset       : in  STD_LOGIC;
        sw          : in  STD_LOGIC_VECTOR (7 downto 0); -- Переключатели
        btn_enter   : in  STD_LOGIC;  -- BTNC: подтвердить символ
        btn_clear   : in  STD_LOGIC;  -- BTND: сброс символа
        ascii_out   : out STD_LOGIC_VECTOR (7 downto 0); -- Выходной ASCII символ
        valid       : out STD_LOGIC  -- Флаг: символ введён
    );
end ascii_input;

architecture Behavioral of ascii_input is
    signal stored_ascii : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal is_valid     : STD_LOGIC := '0';
begin

    process(clk, reset)
    begin
        if reset = '1' then
            stored_ascii <= (others => '0');
            is_valid <= '0';

        elsif rising_edge(clk) then
            if btn_clear = '1' then
                stored_ascii <= (others => '0');
                is_valid <= '0';

            elsif btn_enter = '1' then
                stored_ascii <= sw;
                is_valid <= '1';
            end if;
        end if;
    end process;

    ascii_out <= stored_ascii;
    valid <= is_valid;

end Behavioral;
