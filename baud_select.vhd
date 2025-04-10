library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity baud_select is
    Port (
        clk       : in  STD_LOGIC;
        reset     : in  STD_LOGIC;
        btn       : in  STD_LOGIC;              -- Кнопка переключения (например, BTNL)
        baud_sel  : out STD_LOGIC               -- '0' = 4800, '1' = 9600
    );
end baud_select;

architecture Behavioral of baud_select is
    signal current_baud : STD_LOGIC := '0';
    signal btn_prev     : STD_LOGIC := '0';
begin

    process(clk, reset)
    begin
        if reset = '1' then
            current_baud <= '0';
            btn_prev <= '0';
        elsif rising_edge(clk) then
            if btn = '1' and btn_prev = '0' then  -- фронт кнопки
                current_baud <= not current_baud;
            end if;
            btn_prev <= btn;
        end if;
    end process;

    baud_sel <= current_baud;

end Behavioral;
