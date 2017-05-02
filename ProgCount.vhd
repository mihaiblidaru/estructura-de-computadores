----------------------------------------------------------------------
-- Fichero: ProgCount.vhd
-- Descripción: Program Counter: FF tipo D con reset asincrono a nivel bajo.
-- Fecha última modificación: 02/03/2017
-- Autores: Juan Felipe Carreto & Mihai Blidaru
-- Pareja: 06
-- Asignatura: E.C. 1º grado
-- Grupo de Prácticas: 2121
-- Grupo de Teoría: 212
-- Práctica: 2
-- Ejercicio: 2
----------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;


entity ProgCount is
    Port ( Q    : out STD_LOGIC_VECTOR (31 downto 0);        -- Salida Q del registro
           D    : in  STD_LOGIC_VECTOR (31 downto 0);        -- Entrada D del registro
           Clk  : in  STD_LOGIC;                             -- Reloj
           NRst : in  STD_LOGIC                              -- Reset a nivel bajo
    );
end ProgCount;

architecture Practica of ProgCount is

begin
    
    -- FF tipo D con reset asincrono a nivel bajo
	process(NRst, Clk)
	begin
		if NRst = '0' then
			Q <= (others => '0');
		elsif rising_edge(Clk) then
			Q <= D;
		end if;
	end process;

end Practica;

