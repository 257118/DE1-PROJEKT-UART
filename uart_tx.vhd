library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity uart_tx is
    Port (
        clk         : in  STD_LOGIC;                             -- Системный тактовый сигнал
        reset       : in  STD_LOGIC;                             -- Сброс
        tx_start    : in  STD_LOGIC;                             -- Начать передачу
        baud_select : in  STD_LOGIC;                             -- '0' = 4800, '1' = 9600
        data_in     : in  STD_LOGIC_VECTOR(7 downto 0);          -- Входные данные
        tx          : out STD_LOGIC;                             -- UART TX линия
        tx_busy     : out STD_LOGIC                              -- Флаг: передаёт ли сейчас
    );
end uart_tx;

architecture Behavioral of uart_tx is
    type state_type is (IDLE, START, DATA, STOP);
    signal state       : state_type := IDLE;
    signal bit_index   : integer range 0 to 7 := 0;
    signal shift_reg   : STD_LOGIC_VECTOR(7 downto 0);
    signal tick_cnt    : integer := 0;
    signal baud_tick   : STD_LOGIC := '0';
    signal tx_reg      : STD_LOGIC := '1';

    constant CLK_FREQ       : integer := 100_000_000; -- 100 MHz
    constant BAUD_4800_TICK : integer := CLK_FREQ / 4800;
    constant BAUD_9600_TICK : integer := CLK_FREQ / 9600;
begin

    -- Baud rate tick generator
    process(clk, reset)
    begin
        if reset = '1' then
            tick_cnt  <= 0;
            baud_tick <= '0';
        elsif rising_edge(clk) then
            tick_cnt <= tick_cnt + 1;
            if (baud_select = '0' and tick_cnt >= BAUD_4800_TICK) or
               (baud_select = '1' and tick_cnt >= BAUD_9600_TICK) then
                tick_cnt  <= 0;
                baud_tick <= '1';
            else
                baud_tick <= '0';
            end if;
        end if;
    end process;

    -- UART transmitter state machine
    process(clk, reset)
    begin
        if reset = '1' then
            state     <= IDLE;
            tx_reg    <= '1';
            tx_busy   <= '0';
            bit_index <= 0;
        elsif rising_edge(clk) then
            if baud_tick = '1' then
                case state is
                    when IDLE =>
                        tx_reg <= '1';
                        tx_busy <= '0';
                        if tx_start = '1' then
                            shift_reg <= data_in;
                            state <= START;
                            tx_busy <= '1';
                        end if;

                    when START =>
                        tx_reg <= '0';  -- Старт-бит
                        state <= DATA;
                        bit_index <= 0;

                    when DATA =>
                        tx_reg <= shift_reg(bit_index);
                        if bit_index = 7 then
                            state <= STOP;
                        else
                            bit_index <= bit_index + 1;
                        end if;

                    when STOP =>
                        tx_reg <= '1';  -- Стоп-бит
                        state <= IDLE;
                end case;
            end if;
        end if;
    end process;

    tx <= tx_reg;

end Behavioral;
