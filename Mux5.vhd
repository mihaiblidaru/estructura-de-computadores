----------------------------------------------------------------------
-- Fichero: Mux5.vhd
-- Descripción:
-- Fecha última modificación: 02/05/2017
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

entity Mux5 is
    Port ( D0  : in  STD_LOGIC_VECTOR (4 downto 0);   -- Entrada 0
			     D1  : in  STD_LOGIC_VECTOR (4 downto 0);   -- Entrada 1
			     Sel : in  STD_LOGIC;                       -- Señal de control
           Z   : out STD_LOGIC_VECTOR (4 downto 0)    -- Salida
    );
end Mux5;

architecture Behavioral of Mux5 is

begin

     Z <= D0 when Sel = '0' else D1;                  -- Si Sel = 0, la saida vale D0, si Sel = 1, la salida vale D1


end Behavioral;
