----------------------------------------------------------------------
-- Fichero: MemProgVectores.vhd
-- Descripción: Memoria de programa para el MIPS del ejercicio Vectores.asm
-- Fecha última modificación: 2017-04-16
-- Autores: Alberto Sánchez (2012-2017), Ángel de Castro (2010)
-- Autores: Juan Felipe Carreto & Mihai Blidaru
-- Pareja: 06
-- Asignatura: E.C. 1º grado
-- Grupo de Prácticas: 2121
-- Grupo de Teoría: 212
-- Práctica: 4
-- Ejercicio: 2
----------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.std_LOGIC_arith.ALL;
use IEEE.std_logic_unsigned.ALL;

entity MemProgVectores is
    port (
        MemProgAddr : in std_logic_vector(31 downto 0); -- Dirección para la memoria de programa
        MemProgData : out std_logic_vector(31 downto 0) -- Código de operación
    );
end MemProgVectores;

architecture Simple of MemProgVectores is

begin

    LecturaMemProg: process(MemProgAddr)
    begin
        -- La memoria devuelve un valor para cada dirección.
        -- Estos valores son los códigos de programa de cada instrucción,
        -- estando situado cada uno en su dirección.
        case MemProgAddr is
            when X"00000000" => MemProgData <= X"8c0920f0";          -- lw $t1, N
            when X"00000004" => MemProgData <= X"01294820";          -- add $t1, $t1, $t1
            when X"00000008" => MemProgData <= X"01294820";          -- add $t1, $t1, $t1
            when X"0000000C" => MemProgData <= X"11890008";          -- for: beq $t4, $t1, Fin
            when X"00000010" => MemProgData <= X"8d8a2000";          -- lw $t2, A($t4)
            when X"00000014" => MemProgData <= X"8d8b2050";          -- lw $t3, B($t4)
            when X"00000018" => MemProgData <= X"016b5820";          -- add $t3, $t3, $t3
            when X"0000001C" => MemProgData <= X"016b5820";          -- add $t3, $t3, $t3
            when X"00000020" => MemProgData <= X"014b5020";          -- add $t2, $t2, $t3
            when X"00000024" => MemProgData <= X"ad8a20a0";          -- sw $t2, C($t4)
            when X"00000028" => MemProgData <= X"218c0004";          -- addi $t4, $t4, 4
            when X"0000002C" => MemProgData <= X"08000003";          -- j for
            when X"00000030" => MemProgData <= X"0800000c";          -- Fin: j Fin
            
            when others => MemProgData <= X"00000000";               -- Resto de memoria vacía
        end case;
    end process LecturaMemProg;

end Simple;

