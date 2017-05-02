----------------------------------------------------------------------
-- Fichero: ALUMIPS.vhd
-- Descripción: Unidad Aritmetico-Logica de 6 instrucciones y bandera Z.
--              Permite realizar las operacioes: suma, resta, and, or, nor y SLT.
-- Fecha última modificación: 12/03/2017
-- Autores: Juan Felipe Carreto & Mihai Blidaru
-- Pareja: 06
-- Asignatura: E.C. 1º grado
-- Grupo de Prácticas: 2121
-- Grupo de Teoría: 212
-- Práctica: 3
-- Ejercicio: 1
----------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_signed.all;
use IEEE.std_logic_arith.all;

entity ALUMIPS is
    Port ( Op1        : in   STD_LOGIC_VECTOR (31 downto 0);  -- Operando 1
           Op2        : in   STD_LOGIC_VECTOR (31 downto 0);  -- Operando 2
           ALUControl : in   STD_LOGIC_VECTOR (2  downto 0);  -- Codigo de operacion
           Res        : out  STD_LOGIC_VECTOR (31 downto 0);  -- Resultado
           Z          : out  STD_LOGIC);                      -- Bandera Z
end ALUMIPS;

architecture Practica of ALUMIPS is
    signal SLT    : std_logic_vector(31 downto 0);            -- Señal auxiliar para calcular el resultado de la operacion SLT
    signal ResAux : std_logic_vector(31 downto 0);            -- Señal auxiliar para poder calcular el estado de la bandera Z
begin

    Res <= ResAux;
    
    with ALUControl select
        ResAux <= (Op1 and Op2) when "000",                   -- And
                  (Op1 or  Op2) when "001",                   -- Or
                  (Op1  +  Op2) when "010",                   -- Suma
                  (Op1 nor Op2) when "101",                   -- Nor
                  (Op1  -  Op2) when "110",                   -- Resta
                   SLT          when "111",                   -- SLT
                  (others => 'Z') when others;                -- Operaciones indefinidas

    SLT <= x"00000001" when Op1 < Op2 else (others =>'0');    -- Si Op1 < Op2, SLT vale 1, en caso contrario vale 0
    
    Z <= '1' when ResAux = x"00000000" else '0';              -- Z vale 1 cuando todos los bits del resultado son ceros
    
end Practica;

