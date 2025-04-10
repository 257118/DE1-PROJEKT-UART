library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity uart_rx is
    Port (
        clk         : in  STD_LOGIC;                         -- Системный такт (100 МГц)
        reset       : in  STD_LOGIC;
        rx          : in  STD_LOGIC;                         -- UART RX линия
        baud_select : in  STD_LOGIC;                         -- '0' = 4800, '1' = 9600
        data_out    : out STD_LOGIC_VECTOR(7 downto 0);      -- Принятый байт
        rx_done     : out STD_LOGIC                          -- Флаг: байт принят
    );
end uart_rx;

architecture Behavioral of uart_rx is
    type state_type is (IDLE, START, DATA, STOP);
    signal state       : state_type := IDLE;

    signal bit_index   : integer range 0 to 7 := 0;
    signal rx_shift    : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal sample_tick : STD_LOGIC := '0';
    signal baud_cnt    : integer := 0;

    constant CLK_FREQ       : integer := 100_000_000;
    constant BAUD_4800_TICK : integer := CLK_FREQ / 4800;
    constant BAUD_9600_TICK : integer := CLK_FREQ / 9600;

    signal mid_bit_cnt : integer := 0;
    signal rx_done_int : STD_LOGIC := '0';

begin

    -- Baud tick generator
    process(clk, reset)
        variable baud_limit : integer;
    begin
        if reset = '1' then
            baud_cnt    <= 0;
            sample_tick <= '0';
        elsif rising_edge(clk) then
            if baud_select = '0' then
                baud_limit := BAUD_4800_TICK;
            else
                baud_limit := BAUD_9600_TICK;
            end if;

            if baud_cnt >= baud_limit - 1 then
                baud_cnt    <= 0;
                sample_tick <= '1';
            else
                baud_cnt    <= baud_cnt + 1;
                sample_tick <= '0';
            end if;
        end if;
    end process;

    -- UART RX state machine
    process(clk, reset)
    begin
        if reset = '1' then
            state       <= IDLE;
            bit_index   <= 0;
            rx_shift    <= (others => '0');
            rx_done_int <= '0';
        elsif rising_edge(clk) then
            rx_done_int <= '0'; -- сбрасывается каждый такт

            if sample_tick = '1' then
                case state is
                    when IDLE =>
                        if rx = '0' then  -- Детект старт-бита
                            state <= START;
                        end if;

                    when START =>
                        state <= DATA;
                        bit_index <= 0;

                    when DATA =>
                        rx_shift(bit_index) <= rx;
                        if bit_index = 7 then
                            state <= STOP;
                        else
                            bit_index <= bit_index + 1;
                        end if;

                    when STOP =>
                        if rx = '1' then  -- Проверка стоп-бита
                            rx_done_int <= '1';
                        end if;
                        state <= IDLE;
                end case;
            end if;
        end if;
    end process;

    data_out <= rx_shift;
    rx_done <= rx_done_int;

end Behavioral;
