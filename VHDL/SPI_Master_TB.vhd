
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity SPI_Master_TB is
    
end SPI_Master_TB;

architecture Testbench of SPI_Master_TB is
    signal clk       : std_logic := '0';
    signal reset     : std_logic := '0';
    signal MOSI      : std_logic;
    signal MISO      : std_logic := '0'; -- Données renvoyées par l'esclave
    signal SS        : std_logic;
    signal SCK       : std_logic;
    signal data_in   : std_logic_vector(7 downto 0);
    signal data_out  : std_logic_vector(7 downto 0);
    signal valid     : std_logic := '0';
    signal ready     : std_logic;

begin
    -- Instanciation du SPI_Master
    DUT: entity work.SPI_Master
        port map (
            clk       => clk,
            reset     => reset,
            MOSI      => MOSI,
            MISO      => MISO,
            SS        => SS,
            SCK       => SCK,
            data_in   => data_in,
            data_out  => data_out,
            valid     => valid,
            ready     => ready
        );

    -- Génération de l'horloge
    clk_process : process
    begin
        clk <= not clk after 10 ns;
        wait for 10 ns;
    end process;

    -- Simulation
    stimulus: process
    begin
        reset <= '1';
        wait for 50 ns;
        reset <= '0';

        -- Transfert de données
        data_in <= "10101010";
        valid <= '1';
        wait for 100 ns;
        valid <= '0';

        wait for 500 ns;
        assert false report "Simulation terminée" severity note;
        wait;
    end process;
end Testbench;
