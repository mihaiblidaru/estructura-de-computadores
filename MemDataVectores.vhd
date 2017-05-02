----------------------------------------------------------------------
-- Fichero: MemDataVectores.vhd
-- Descripci�n: Memoria de datos para el MIPS del ejercicio Vectores.asm
-- Fecha �ltima modificaci�n: 2017-04-16
-- Autores: Alberto S�nchez (2012-2017), �ngel de Castro (2010)
-- Autores: Juan Felipe Carreto & Mihai Blidaru
-- Pareja: 06
-- Asignatura: E.C. 1� grado
-- Grupo de Pr�cticas: 2121
-- Grupo de Teor�a: 212
-- Pr�ctica: 4
-- Ejercicio: 2
----------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity MemDataVectores is
	port (
		Clk : in std_logic;
		NRst : in std_logic;
		MemDataAddr : in std_logic_vector(31 downto 0);
		MemDataDataWrite : in std_logic_vector(31 downto 0);
		MemDataWE : in std_logic;
		MemDataDataRead : out std_logic_vector(31 downto 0)
	);
end MemDataVectores;

architecture Simple of MemDataVectores is

  -- 4 GB son 1 gigapalabras, pero el simulador no deja tanta memoria
  -- Dejamos 64 kB (16 kpalabras), usamos los 16 LSB
  type Memoria is array (0 to (2**13)-1) of std_logic_vector(31 downto 0);
  signal memData : Memoria;

begin

	EscrituraMemProg: process(Clk, NRst)
	begin
	if NRst = '0' then
		-- Se inicializa a ceros, salvo los valores de las direcciones que
		-- tengan un valor inicial distinto de cero (datos ya cargados en
		-- memoria de datos desde el principio)
		for i in 0 to (2**13)-1 loop
			memData(i) <= (others => '0');
		end loop;
		-- Cada palabra ocupa 4 bytes
		memData(conv_integer(X"00002000")/4) <= X"00000002";    -- 2
		memData(conv_integer(X"00002004")/4) <= X"00000002";    -- 2
		memData(conv_integer(X"00002008")/4) <= X"00000004";    -- 4
		memData(conv_integer(X"0000200C")/4) <= X"00000006";    -- 6
		memData(conv_integer(X"00002010")/4) <= X"00000005";    -- 5
		memData(conv_integer(X"00002014")/4) <= X"00000006";    -- 5
		memData(conv_integer(X"00002018")/4) <= X"00000007";    -- 7
		memData(conv_integer(X"0000201C")/4) <= X"00000008";    -- 8
		memData(conv_integer(X"00002020")/4) <= X"00000009";    -- 9
		memData(conv_integer(X"00002024")/4) <= X"0000000a";    -- 10
    -- los para poder cambiar datos facilmente
		memData(conv_integer(X"00002028")/4) <= X"00000000";    -- 0
		memData(conv_integer(X"0000202C")/4) <= X"00000000";    -- 0
		memData(conv_integer(X"00002030")/4) <= X"00000000";    -- 0
		memData(conv_integer(X"00002034")/4) <= X"00000000";    -- 0
		memData(conv_integer(X"00002038")/4) <= X"00000000";    -- 0
		memData(conv_integer(X"0000203C")/4) <= X"00000000";    -- 0
		memData(conv_integer(X"00002040")/4) <= X"00000000";    -- 0
		memData(conv_integer(X"00002044")/4) <= X"00000000";    -- 0
		memData(conv_integer(X"00002048")/4) <= X"00000000";    -- 0
		memData(conv_integer(X"0000204C")/4) <= X"00000000";    -- 0
		---------------------------------------------------
		memData(conv_integer(X"00002050")/4) <= X"ffffffff";    -- -1
		memData(conv_integer(X"00002054")/4) <= X"fffffffb";    -- -5
		memData(conv_integer(X"00002058")/4) <= X"00000004";    -- 4
		memData(conv_integer(X"0000205C")/4) <= X"0000000a";    -- 10
		memData(conv_integer(X"00002060")/4) <= X"00000001";    -- 1
		memData(conv_integer(X"00002064")/4) <= X"fffffffe";    -- -2
		memData(conv_integer(X"00002068")/4) <= X"00000005";    -- 5
		memData(conv_integer(X"0000206C")/4) <= X"0000000a";    -- 10
		memData(conv_integer(X"00002070")/4) <= X"fffffff6";    -- -10
		memData(conv_integer(X"00002074")/4) <= X"00000000";    -- 0
		-- los para poder cambiar datos facilmente
		memData(conv_integer(X"00002078")/4) <= X"00000000";    -- 0
		memData(conv_integer(X"0000207C")/4) <= X"00000000";    -- 0
		memData(conv_integer(X"00002080")/4) <= X"00000000";    -- 0
		memData(conv_integer(X"00002084")/4) <= X"00000000";    -- 0
		memData(conv_integer(X"00002088")/4) <= X"00000000";    -- 0
		memData(conv_integer(X"0000208C")/4) <= X"00000000";    -- 0
		memData(conv_integer(X"00002090")/4) <= X"00000000";    -- 0
		memData(conv_integer(X"00002094")/4) <= X"00000000";    -- 0
		memData(conv_integer(X"00002098")/4) <= X"00000000";    -- 0
		memData(conv_integer(X"0000209C")/4) <= X"00000000";    -- 0
		---------------------------------------------------
		memData(conv_integer(X"000020F0")/4) <= X"0000000a";    -- N = 10

	elsif rising_edge(Clk) then
		-- En este caso se escribe por flanco de bajada para que sea
		-- a mitad de ciclo y todas las se�ales est�n estables
		if MemDataWE = '1' then
			memData(conv_integer(MemDataAddr)/4) <= MemDataDataWrite;
		end if;
	end if;
	end process EscrituraMemProg;

	-- Lectura combinacional siempre activa
	-- Cada vez se devuelve una palabra completa, que ocupa 4 bytes
	LecturaMemProg: process(MemDataAddr, memData)
	begin
		-- Parte baja de la memoria s� est�, se lee tal cual
		if MemDataAddr(31 downto 16)=X"0000" then
			MemDataDataRead <= MemData(conv_integer(MemDataAddr)/4);
		else -- Parte alta no existe, se leen ceros
			MemDataDataRead <= (others => '0');
		end if;
	end process LecturaMemProg;

end Simple;
