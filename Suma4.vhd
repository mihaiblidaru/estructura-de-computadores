----------------------------------------------------------------------
-- Fichero: Suma4.vhd
-- Descripción: Circuito combinacionar que añade +4 al numero que recibe como entrada
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
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity Suma4 is
    Port ( D : in  STD_LOGIC_VECTOR(31 downto 0);         -- Entrada
           Q : out STD_LOGIC_VECTOR(31 downto 0)          -- Salida
    );
end Suma4;

architecture Practica of Suma4 is

begin

    Q <= D + 4;    -- Salida = Entrada + 4 (Suma sin signo)
	
end Practica;

