----------------------------------------------------------------------
-- Fichero: UnidadControl.vhd
-- Descripción: Unidad de control de un procesador MIPS con juego
-- de intrucciones reducido
-- Fecha última modificación: 16/04/2017
-- Autores: Juan Felipe Carreto & Mihai Blidaru
-- Pareja: 06
-- Asignatura: E.C. 1º grado
-- Grupo de Prácticas: 2121
-- Grupo de Teoría: 212
-- Práctica: 4
-- Ejercicio: 2
----------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

entity UnidadControl is
    Port ( OPCode     : in   STD_LOGIC_VECTOR (5 downto 0);       -- Codigo de operacion
           Funct      : in   STD_LOGIC_VECTOR (5 downto 0);       -- Codigo de funcion
           ALUControl : out  STD_LOGIC_VECTOR (2 downto 0);       -- Señal de control de la ALU
           MemToReg   : out  STD_LOGIC;                           -- Se activa cuando se lleva un dato de memoria a un registro
           MemWrite   : out  STD_LOGIC;                           -- Controla la escritura en memoria
           Branch     : out  STD_LOGIC;                           -- Se activa cuando hay un salto condicional
           ALUSrc     : out  STD_LOGIC;                           -- Elige entre un registro y un dato inmediato como operando de la ALU
           RegDest    : out  STD_LOGIC;                           -- Controla cual es el registro de destino
           RegWrite   : out  STD_LOGIC;                           -- Controla la escritura en registros
           RegToPC    : out  STD_LOGIC;                           -- Lleva el contenido de un registro al PC. ej: jr
           ExtCero    : out  STD_LOGIC;                           -- Elige entre extender en signo o en ceros
           Jump       : out  STD_LOGIC;                           -- Se activa con instrucciones de salto
           PCToReg    : out  STD_LOGIC);                          -- Lleva el contenido del PC a un registro. ej: jal
end UnidadControl;

architecture Behavioral of UnidadControl is
        signal ALUFunct: std_logic_vector(2 downto 0);            -- Señal auxiliar para el codigo de operacion de la ALU cuando la instruccion es R-Type
begin

    with OPCode select
        ALUControl  <= ALUFunct when "000000",                    -- Si en una instruccion R-Type
                      "000" when "001100",                        -- andi 
                      "001" when "001101",                        -- ori
                      "010" when "001000" | "100011" | "101011",  -- addi, lw, sw
                      "110" when "000100",                        -- beq
                      "111" when "001010",                        -- slti
                      "011" when others;
                      
    with Funct select
        ALUFunct   <= "000" when "100100",                        -- and
                      "001" when "100101",                        -- or
                      "010" when "100000",                        -- add
                      "110" when "100010",                        -- sub
                      "101" when "100111",                        -- nor
                      "111" when "101010",                        -- slt
                      "011" when others;

    Branch     <= '1' when OPCode = "000100" else '0';                           -- Si OPCode = beq
    
    MemToReg   <= '1' when OPCode = "100011" else '0';                           -- Si OPCode = lw
    
    MemWrite   <= '1' when OPCode = "101011" else '0';                           -- Si OPCode = sw
    
    ALUSrc     <= '0' when (OPCode = "000000" or OPCode = "000100") else '1';    -- Si R-Type o beq
    
    RegDest    <= '1' when OPCode = "000000" else '0';                           -- Si R-Type
    
    RegWrite   <= '1' when (OPCode = "000000" or OPCode = "001000"               -- Activa cuando: R-Type, addi
                         or OPCode = "001100" or OPCode = "001101"               -- andi, ori
                         or OPCode = "100011" or OPCode = "000011"               -- lw, jal
                         or OPCode = "001010") else '0';                         -- slti. Cero en otros casos.

    RegToPC    <= '1' when (Funct = "001000" and OPCode = "000000") else '0';    -- Activo cuando la instruccion es jr
    
    ExtCero    <= '1' when (OPCode = "001100" or OPCode = "001101") else '0';    -- Activo cuando las instrucciones son logicas inmediatas
    
    Jump       <= '1' when (OPCode = "000010" or OPCode = "000011") else '0';    -- Activa em: j o jal
    
    PCToReg    <= '1' when OPCode = "000011" else '0';                           -- Activa en: jal

end Behavioral;
