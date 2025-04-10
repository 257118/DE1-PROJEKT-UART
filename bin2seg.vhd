library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity bin2seg is
    Port (
        ascii_in : in  STD_LOGIC_VECTOR(7 downto 0); -- Входной ASCII-байт
        seg_out  : out STD_LOGIC_VECTOR(6 downto 0)  -- Выход на 7 сегментов (a–g)
    );
end bin2seg;

architecture Behavioral of bin2seg is
begin
    process(ascii_in)
    begin
        case ascii_in is
            -- Цифры 0–9
            when x"30" => seg_out <= "0000001"; -- 0
            when x"31" => seg_out <= "1001111"; -- 1
            when x"32" => seg_out <= "0010010"; -- 2
            when x"33" => seg_out <= "0000110"; -- 3
            when x"34" => seg_out <= "1001100"; -- 4
            when x"35" => seg_out <= "0100100"; -- 5
            when x"36" => seg_out <= "0100000"; -- 6
            when x"37" => seg_out <= "0001111"; -- 7
            when x"38" => seg_out <= "0000000"; -- 8
            when x"39" => seg_out <= "0000100"; -- 9

            -- Большие буквы A–F
            when x"41" => seg_out <= "0001000"; -- A
            when x"42" => seg_out <= "1100000"; -- B
            when x"43" => seg_out <= "0110001"; -- C
            when x"44" => seg_out <= "1000010"; -- D
            when x"45" => seg_out <= "0110000"; -- E
            when x"46" => seg_out <= "0111000"; -- F

            -- Буквы (добавь другие при необходимости)
            -- Можно добавить больше: G, H, L, P, S, U, и т.д.

            -- Пустой символ или нераспознанный
            when others => seg_out <= "1111111"; -- Все сегменты выключены
        end case;
    end process;
end Behavioral;
