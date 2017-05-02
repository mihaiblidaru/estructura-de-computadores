----------------------------------------------------------------------
-- Fichero: RegsMIPS.vhd
-- Descripción: Banco de 31 registros con lectura de dos registros asíncrona 
--              y escritura síncrona con Write Enable
-- Fecha última modificación: 13/03/2017
-- Autores: Juan Felipe Carreto & Mihai Blidaru
-- Pareja: 06
-- Asignatura: E.C. 1º grado
-- Grupo de Prácticas: 2121
-- Grupo de Teoría: 212
-- Práctica: 3
-- Ejercicio: 2
----------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;

entity RegsMIPS is
    Port ( Clk  : in   STD_LOGIC;                      -- Reloj
           NRst : in   STD_LOGIC;                      -- Reset a nivel bajo
           A1   : in   STD_LOGIC_VECTOR (4 downto 0);  -- Dirreccion del registro de lectura 1
           A2   : in   STD_LOGIC_VECTOR (4 downto 0);  -- Dirreccion del registro de lectura 2
           A3   : in   STD_LOGIC_VECTOR (4 downto 0);  -- Dirreccion del registro de escritura
           Wd3  : in   STD_LOGIC_VECTOR (31 downto 0); -- Dato a escribir en el registro A3
           We3  : in   STD_LOGIC;                      -- Write Enable
           Rd1  : out  STD_LOGIC_VECTOR (31 downto 0); -- Registro leido 1
           Rd2  : out  STD_LOGIC_VECTOR (31 downto 0)  -- Registro leido 2
    );
end RegsMIPS;

architecture Practica of RegsMIPS is

    -- Tipo para almacenar los registros
    type regs_t is array (0 to 31) of std_logic_vector(31 downto 0);
    
	signal regs : regs_t;

begin

    ------------------------------------------------------
    -- Lectura de los registros Rd1 y Rd2
    ------------------------------------------------------
    
    Rd1 <= regs(conv_integer(A1));
    Rd2 <= regs(conv_integer(A2));
        
    ------------------------------------------------------
    -- Escritura en el registro
    ------------------------------------------------------
    process(Clk,NRst)
    begin
        if NRst = '0' then
            for i in 0 to 31 loop
                regs(i) <= (others =>'0');
            end loop;
        elsif rising_edge(Clk) then
            if We3 = '1' then
                if conv_integer(A3) /= 0 then          -- Escribir en los registros solo si el Write Enable 
                    regs(conv_integer(A3)) <= Wd3;     -- está activado y la dirección es diferente de 0
                end if;
            end if;
        end if;
    end process;
	
end Practica;

