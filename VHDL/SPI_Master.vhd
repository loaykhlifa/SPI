library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity SPI_Master is
    Port ( clk : in STD_LOGIC;--Horloge principale utilis�e pour synchroniser toutes les op�rations.
           reset : in STD_LOGIC;--R�initialisation active haut pour remettre tous les signaux internes � z�ro.
           MOSI : out STD_LOGIC;--Ligne de donn�es pour transmettre du ma�tre � l�esclave.
           MISO : in STD_LOGIC;--Ligne de donn�es pour recevoir de l�esclave au ma�tre.
           SS : inout STD_LOGIC;--Signal pour activer l'esclave (active bas).
           SCK : out STD_LOGIC;--Signal d'horloge SPI g�n�r� par le ma�tre pour synchroniser le transfert.
           data_in : in STD_LOGIC_VECTOR (7 downto 0);--Donn�es � transmettre vers l'esclave (8 bits).
           data_out : inout STD_LOGIC_VECTOR (7 downto 0);--Donn�es re�ues de l'esclave (8 bits).
           valid : inout STD_LOGIC;--Indique que des donn�es en entr�e sont pr�tes � �tre envoy�es.
           ready : inout STD_LOGIC);--Indique que le module SPI est pr�t � initier un transfert.
end SPI_Master;

architecture Behavioral of SPI_Master is
    signal clk_div    : integer := 0;               -- Diviseur d'horloge
    signal bit_count  : integer range 0 to 7 := 0;  -- Compteur de bits pour le transfert SPI
    signal data_shift : std_logic_vector(7 downto 0); -- Registre de d�calage pour MOSI
    signal sck_toggle : std_logic := '0';           -- Toggle pour g�n�rer SCK

begin
    -- Diviseur d'horloge pour g�n�rer SCK
    process (clk, reset)
    begin
        if reset = '1' then
            clk_div <= 0;
            sck_toggle <= '0';
        elsif rising_edge(clk) then
            if clk_div = 4 then                -- Ajustez ce param�tre pour SCK
                sck_toggle <= not sck_toggle; -- Toggle SCK
                clk_div <= 0;
            else
                clk_div <= clk_div + 1;
            end if;
        end if;
    end process;

    -- G�n�ration de MOSI et gestion du transfert
    process (clk, reset)
    begin
        --Initialisation (reset)
        if reset = '1' then
            bit_count <= 0;
            data_shift <= (others => '0');
            MOSI <= '0';
            SS <= '1';
            ready <= '1';
        --gestion du transfert 
        elsif rising_edge(sck_toggle) then
            --D�marrage du transfert  
            if valid = '1' and ready = '1' then
                SS <= '0'; -- Active le p�riph�rique esclave
                data_shift <= data_in; -- Charge les donn�es � envoyer
                bit_count <= 0;
                ready <= '0';
            --Transmission des bits
            elsif bit_count < 8 then
                MOSI <= data_shift(7);  -- Envoie le bit le plus significatif
                data_shift <= data_shift(6 downto 0) & '0'; -- D�cale
                bit_count <= bit_count + 1;
            --Fin du transfert
            else
                SS <= '1'; -- D�sactive le p�riph�rique esclave
                ready <= '1';--le module est pr�t pour un nouveau transfert
            end if;
        end if;
    end process;

    -- Lecture de MISO (pendant SCK haute)
    process (clk)
    begin
        if rising_edge(sck_toggle) and SS = '0' then
            data_out <= data_out(6 downto 0) & MISO; -- R�cup�re les donn�es
        end if;
    end process;

    -- G�n�ration de SCK
    SCK <= sck_toggle;
end Behavioral;
