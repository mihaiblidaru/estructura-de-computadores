----------------------------------------------------------------------
-- Fichero: ExtSign.vhd
-- Descripción: 
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
use IEEE.std_logic_1164.ALL;
use IEEE.std_LOGIC_arith.ALL;
use IEEE.std_logic_signed.ALL;

entity ExtSign is
    Port ( Ent : in  STD_LOGIC_VECTOR (15 downto 0);    -- Entrada de 16 bits 
           Sal : out STD_LOGIC_VECTOR (31 downto 0)     -- Salida de 32 bits
    );
end ExtSign;

architecture Behavioral of ExtSign is

begin

    Sal <= (31 downto 16 => Ent(15)) & Ent;             -- Añade 16 bits del mismo valor que el MSB de la entrada en los primeros 16 bits de la salida

end Behavioral;

