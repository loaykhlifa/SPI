library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity SPI_Master is
    Port ( clk : in STD_LOGIC;--Horloge principale utilisée pour synchroniser toutes les opérations.
           reset : in STD_LOGIC;--Réinitialisation active haut pour remettre tous les signaux internes à zéro.
           MOSI : out STD_LOGIC;--Ligne de données pour transmettre du maître à l’esclave.
           MISO : in STD_LOGIC;--Ligne de données pour recevoir de l’esclave au maître.
           SS : inout STD_LOGIC;--Signal pour activer l'esclave (active bas).
           SCK : out STD_LOGIC;--Signal d'horloge SPI généré par le maître pour synchroniser le transfert.
           data_in : in STD_LOGIC_VECTOR (7 downto 0);--Données à transmettre vers l'esclave (8 bits).
           data_out : inout STD_LOGIC_VECTOR (7 downto 0);--Données reçues de l'esclave (8 bits).
           valid : inout STD_LOGIC;--Indique que des données en entrée sont prêtes à être envoyées.
           ready : inout STD_LOGIC);--Indique que le module SPI est prêt à initier un transfert.
end SPI_Master;

architecture Behavioral of SPI_Master is
    signal clk_div    : integer := 0;               -- Diviseur d'horloge
    signal bit_count  : integer range 0 to 7 := 0;  -- Compteur de bits pour le transfert SPI
    signal data_shift : std_logic_vector(7 downto 0); -- Registre de décalage pour MOSI
    signal sck_toggle : std_logic := '0';           -- Toggle pour générer SCK

begin
    -- Diviseur d'horloge pour générer SCK
    process (clk, reset)
    begin
        if reset = '1' then
            clk_div <= 0;
            sck_toggle <= '0';
        elsif rising_edge(clk) then
            if clk_div = 4 then                -- Ajustez ce paramètre pour SCK
                sck_toggle <= not sck_toggle; -- Toggle SCK
                clk_div <= 0;
            else
                clk_div <= clk_div + 1;
            end if;
        end if;
    end process;

    -- Génération de MOSI et gestion du transfert
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
            --Démarrage du transfert  
            if valid = '1' and ready = '1' then
                SS <= '0'; -- Active le périphérique esclave
                data_shift <= data_in; -- Charge les données à envoyer
                bit_count <= 0;
                ready <= '0';
            --Transmission des bits
            elsif bit_count < 8 then
                MOSI <= data_shift(7);  -- Envoie le bit le plus significatif
                data_shift <= data_shift(6 downto 0) & '0'; -- Décale
                bit_count <= bit_count + 1;
            --Fin du transfert
            else
                SS <= '1'; -- Désactive le périphérique esclave
                ready <= '1';--le module est prêt pour un nouveau transfert
            end if;
        end if;
    end process;

    -- Lecture de MISO (pendant SCK haute)
    process (clk)
    begin
        if rising_edge(sck_toggle) and SS = '0' then
            data_out <= data_out(6 downto 0) & MISO; -- Récupère les données
        end if;
    end process;

    -- Génération de SCK
    SCK <= sck_toggle;
end Behavioral;
