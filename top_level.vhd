library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity top_level is
    Port (
        clk       : in  STD_LOGIC;
        reset     : in  STD_LOGIC;

        sw        : in  STD_LOGIC_VECTOR(7 downto 0);
        btnu      : in  STD_LOGIC; -- режим передачи (не используется в этой версии)
        btnl      : in  STD_LOGIC; -- переключение скорости
        btnc      : in  STD_LOGIC; -- подтвердить символ
        btnr      : in  STD_LOGIC; -- передать символ
        btnd      : in  STD_LOGIC; -- сброс ввода

        tx        : out STD_LOGIC;
        rx        : in  STD_LOGIC;

        seg_tx    : out STD_LOGIC_VECTOR(6 downto 0); -- сегменты для передаваемого символа
        seg_rx    : out STD_LOGIC_VECTOR(6 downto 0)  -- сегменты для принятого символа
    );
end top_level;

architecture Structural of top_level is
    -- internal signals
    signal ascii_in     : STD_LOGIC_VECTOR(7 downto 0);
    signal ascii_valid  : STD_LOGIC;
    signal baud_sel     : STD_LOGIC;
    signal rx_data      : STD_LOGIC_VECTOR(7 downto 0);
    signal rx_done      : STD_LOGIC;
    signal tx_busy      : STD_LOGIC;
begin

    -- Модуль выбора скорости
    baud_sel_module: entity work.baud_select
        port map (
            clk       => clk,
            reset     => reset,
            btn       => btnl,
            baud_sel  => baud_sel
        );

    -- Модуль ввода ASCII символа с переключателей
    ascii_input_module: entity work.ascii_input
        port map (
            clk       => clk,
            reset     => reset,
            sw        => sw,
            btn_enter => btnc,
            btn_clear => btnd,
            ascii_out => ascii_in,
            valid     => ascii_valid
        );

    -- UART передатчик
    uart_tx_module: entity work.uart_tx
        port map (
            clk         => clk,
            reset       => reset,
            tx_start    => btnr,
            baud_select => baud_sel,
            data_in     => ascii_in,
            tx          => tx,
            tx_busy     => tx_busy
        );

    -- UART приёмник
    uart_rx_module: entity work.uart_rx
        port map (
            clk         => clk,
            reset       => reset,
            rx          => rx,
            baud_select => baud_sel,
            data_out    => rx_data,
            rx_done     => rx_done
        );

    -- Отображение передаваемого символа
    bin2seg_tx: entity work.bin2seg
        port map (
            ascii_in => ascii_in,
            seg_out  => seg_tx
        );

    -- Отображение принятого символа
    bin2seg_rx: entity work.bin2seg
        port map (
            ascii_in => rx_data,
            seg_out  => seg_rx
        );

end Structural;
