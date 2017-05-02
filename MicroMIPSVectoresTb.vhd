----------------------------------------------------------------------
-- Fichero: MicroMIPSVectoresTb.vhd
-- Descripción: Banco de pruebas para el microprocesador MIPS
--              con las memorias del programa vectores
-- Fecha última modificación: 2017-03-27

-- Autores: Alberto Sánchez (2012-2017) Miguel Company (2016)
-- Asignatura: EC 1º grado
-- Grupo de Prácticas:
-- Grupo de Teoría:
-- Práctica: 5
-- Ejercicio: 3
----------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity MicroMIPSVectoresTb is
end MicroMIPSVectoresTb;
 
architecture Test OF MicroMIPSVectoresTb is
 
  -- Declaración del micro (sin memoria)
	component MicroMIPS
	port (
		Clk : in std_logic; -- Reloj
		NRst : in std_logic; -- Reset activo a nivel bajo
		MemProgAddr : out std_logic_vector(31 downto 0); -- Dirección para la memoria de programa
		MemProgData : in std_logic_vector(31 downto 0); -- Código de operación
		MemDataAddr : out std_logic_vector(31 downto 0); -- Dirección para la memoria de datos
		MemDataDataRead : in std_logic_vector(31 downto 0); -- Dato a leer en la memoria de datos
		MemDataDataWrite : out std_logic_vector(31 downto 0); -- Dato a guardar en la memoria de datos
		MemDataWE : out std_logic
	);
	end component;

	-- Declaración de la memoria de código/programa
	component MemProgVectores
	port (
		MemProgAddr : in std_logic_vector(31 downto 0); -- Dirección para la memoria de programa
		MemProgData : out std_logic_vector(31 downto 0) -- Código de operación
	);
	end component;
	
	-- Declaración de la memoria de código/programa
	component MemDataVectores
	port (
		Clk : in std_logic;
		NRst : in std_logic;
		MemDataAddr : in std_logic_vector(31 downto 0); -- Dirección para la memoria de datos
		MemDataDataRead : out std_logic_vector(31 downto 0); -- Dato a leer de la memoria de datos
		MemDataDataWrite : in std_logic_vector(31 downto 0); -- Dato a escribir de la memoria de datos
		MemDataWE : in std_logic -- Habilitación de la escritura en la memoria de datos
	);
	end component;

	-- Entradas al micro
	-- En los bancos de prueba se pueden usar valores iniciales en las
	-- declaraciones, pero en los módulos no porque no son sintetizables
	signal memProgData : std_logic_vector(31 downto 0) := (others => '0');
	signal memDataDataRead : std_logic_vector(31 downto 0) := (others => '0');
	signal nRst : std_logic := '0';
	signal clk : std_logic := '0';

	-- Salidas del micro
	signal memProgAddr, memDataAddr : std_logic_vector(31 downto 0);
	signal memDataDataWrite : std_logic_vector(31 downto 0) := (others => '0');
	signal memDataWE : std_logic := '0';

	-- Periodo de reloj
	constant CLKPERIOD : time := 10 ns;

	-- Fin simulación, por si queremos matar la simulación por falta de eventos
	signal finSimu : boolean := false;

begin
 
	-- Instancia del micro
	uut: MicroMIPS
	port map(
		Clk => Clk,
		NRst => NRst,
		MemProgAddr => memProgAddr,
		MemProgData => memProgData,
		MemDataAddr => memDataAddr,
		MemDataDataRead => memDataDataRead,
		MemDataDataWrite => memDataDataWrite,
		MemDataWE => memDataWE
	);

	-- Instancia de la memoria de código/programa
	mprog: MemProgVectores
	port map (
		MemProgAddr => memProgAddr,
		MemProgData => memProgData
	);

	-- Instancia de la memoria de datos
	mdata: MemDataVectores
	port map (
		Clk => Clk,
		NRst => NRst,
		MemDataAddr => memDataAddr,
		MemDataDataRead => memDataDataRead,
		MemDataDataWrite => memDataDataWrite,
		MemDataWE => memDataWE
		
	);
	
	CLKPROCESS: process
	begin
	while (not finSimu) loop
		clk <= '0';
		wait for CLKPERIOD/2;
		clk <= '1';
		wait for CLKPERIOD/2;
	end loop;
	wait;
	end process;

	-- Proceso principal de activar señales.
	-- Sólo hay que activar el reset. El resto del banco de pruebas
	-- se cambia a través del valor inicial de las memorias, que
	-- constituyen el programa a ejecutar.
	StimProc: process
	begin
		nRST <= '0'; -- Reset empieza activo
		wait for CLKPERIOD*2;
		nRST <= '1'; -- Se desactiva el reset y empieza la ejecución
		wait for CLKPERIOD*1000;
		finSimu <= true; -- Si la simulación tiene más de 100 instrucciones
		-- habría que esperar más antes de matar la simulación
		wait; -- No se vuelve a hacer nada con el reset
	end process;

end Test;
