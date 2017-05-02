----------------------------------------------------------------------
-- Fichero: MemProgMIPS.vhd
-- Descripci�n: Memoria de programa para el MIPS
-- Fecha �ltima modificaci�n: 2016-03-28

-- Autores: Alberto S�nchez (2012-2017), �ngel de Castro (2010-2015) 
-- Asignatura: E.C. 1� grado
-- Grupo de Pr�cticas:
-- Grupo de Teor�a:
-- Pr�ctica: 5
-- Ejercicio: 3
----------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.std_LOGIC_arith.ALL;
use IEEE.std_logic_unsigned.ALL;

entity MemProgMIPS is
	port (
		MemProgAddr : in std_logic_vector(31 downto 0); -- Direcci�n para la memoria de programa
		MemProgData : out std_logic_vector(31 downto 0) -- C�digo de operaci�n
	);
end MemProgMIPS;

architecture Simple of MemProgMIPS is

begin

	LecturaMemProg: process(MemProgAddr)
	begin
		-- La memoria devuelve un valor para cada direcci�n.
		-- Estos valores son los c�digos de programa de cada instrucci�n,
		-- estando situado cada uno en su direcci�n.
		case MemProgAddr is
			when X"00000000" => MemProgData <= X"20010004";
			when X"00000004" => MemProgData <= X"3402000f";
			when X"00000008" => MemProgData <= X"30430004";
			when X"0000000C" => MemProgData <= X"2064ffec";
			when X"00000010" => MemProgData <= X"28057fff";
			when X"00000014" => MemProgData <= X"2805ffff";
			when X"00000018" => MemProgData <= X"0081302a";
			when X"0000001C" => MemProgData <= X"0c000013";
			when X"00000020" => MemProgData <= X"10240001";
			when X"00000024" => MemProgData <= X"11090001";
			when X"00000028" => MemProgData <= X"00005020";
			when X"0000002C" => MemProgData <= X"214b0002";
			when X"00000030" => MemProgData <= X"00016020";
			when X"00000034" => MemProgData <= X"ac0c200c";
			when X"00000038" => MemProgData <= X"8c0d200c";
			when X"0000003C" => MemProgData <= X"00217027";
			when X"00000040" => MemProgData <= X"01c07024";
			when X"00000044" => MemProgData <= X"00227825";
			when X"00000048" => MemProgData <= X"08000012";
			when X"0000004C" => MemProgData <= X"8c072000";
			when X"00000050" => MemProgData <= X"8c282000";
			when X"00000054" => MemProgData <= X"8c092008";
			when X"00000058" => MemProgData <= X"01075022";
			when X"0000005C" => MemProgData <= X"03e00008";		
			when others => MemProgData <= X"00000000"; -- Resto de memoria vac�a
		end case;
	end process LecturaMemProg;

end Simple;

