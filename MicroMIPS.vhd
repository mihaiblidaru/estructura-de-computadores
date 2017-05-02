----------------------------------------------------------------------
-- Fichero: MicroMIPS.vhd
-- Descripción: Microprocesador MIPS Uniciclo con juego de instrucciones reducido
-- Fecha última modificación: 02/05/2017
-- Autores: Juan Felipe Carreto & Mihai Blidaru
-- Pareja: 06
-- Asignatura: E.C. 1º grado
-- Grupo de Prácticas: 2121
-- Grupo de Teoría: 212
-- Práctica: 4
-- Ejercicio: 3
----------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_signed.all;

entity MicroMIPS is
    Port (  Clk              : in  std_logic;                     -- Reloj
            NRst             : in  std_logic;                     -- Reset activo a nivel bajo
            MemProgData      : in  std_logic_vector(31 downto 0); -- Instruccion
            MemDataDataRead  : in  std_logic_vector(31 downto 0); -- Dato a leer en la memoria de datos
            MemDataAddr      : out std_logic_vector(31 downto 0); -- Direccion para la memoria de datos
            MemProgAddr      : out std_logic_vector(31 downto 0); -- Direccion para la memoria de programa
            MemDataDataWrite : out std_logic_vector(31 downto 0); -- Dato a guardar en la memoria de datos
            MemDataWE        : out std_logic
    );
end MicroMIPS;

architecture Practica of MicroMIPS is

    -- salidas registros
    signal Rd1  : std_logic_vector(31 downto 0);
    signal Rd2  : std_logic_vector(31 downto 0);

    --salidas multiplexores 32 bits
    signal PCSrcMux32Sal    : std_logic_vector(31 downto 0);
    signal JumpMux32Sal     : std_logic_vector(31 downto 0);
    signal RegToPcMux32Sal  : std_logic_vector(31 downto 0);
    signal ExtCeroMux32Sal  : std_logic_vector(31 downto 0);
    signal ALUSrcMux32Sal   : std_logic_vector(31 downto 0);
    signal MemToRegMux32Sal : std_logic_vector(31 downto 0);
    signal PCToRegMux32Sal  : std_logic_vector(31 downto 0);

    -- salidas multiplexores 5 bits
    signal RegDestMux5Sal   : std_logic_vector(4  downto 0);
    signal PCToRegMux5Sal   : std_logic_vector(4  downto 0);

    -- entradas auxiliares multiplexores
    signal JumpMux32D1      : std_logic_vector(31 downto 0);
    signal PCSrcMux32D1     : std_logic_vector(31 downto 0);

    -- salidas Unidad de control
    signal ALUControlCtrl   : std_logic_vector(2  downto 0);
    signal MemToRegCtrl     : std_logic;
    signal BranchCtrl       : std_logic;
    signal ALUSrcCtrl       : std_logic;
    signal RegDestCtrl      : std_logic;
    signal RegWriteCtrl     : std_logic;
    signal RegToPCCtrl      : std_logic;
    signal ExtCeroCtrl      : std_logic;
    signal JumpCtrl         : std_logic;
    signal PCToRegCtrl      : std_logic;

    -- senales control auxiliares
    signal PCSrcCtrl : std_logic;

    -- salidas ALU
    signal ALUResSal : std_logic_vector(31 downto 0);
    signal ALUZSal   : std_logic;

    -- salida ProgramCounter
    signal ProgCountSal : std_logic_vector(31 downto 0);

    -- salida Suma4 del Program Counter
    signal Suma4Sal :  std_logic_vector(31 downto 0);

    -- salidas extensores signo - ceros
    signal ExtSignSal : std_logic_vector(31 downto 0);
    signal ExtCeroSal : std_logic_vector(31 downto 0);

    -- Declaración de la Uniddad de Control
    COMPONENT UnidadControl
    PORT(
        OPCode     : IN  std_logic_vector(5 downto 0);
        Funct      : IN  std_logic_vector(5 downto 0);
        ALUControl : OUT std_logic_vector(2 downto 0);
        MemToReg   : OUT std_logic;
        MemWrite   : OUT std_logic;
        Branch     : OUT std_logic;
        ALUSrc     : OUT std_logic;
        RegDest    : OUT std_logic;
        RegWrite   : OUT std_logic;
        RegToPC    : OUT std_logic;
        ExtCero    : OUT std_logic;
        Jump       : OUT std_logic;
        PCToReg    : OUT std_logic
        );
    END COMPONENT;

    -- Declaracion del multiplexor de 32 bits
    COMPONENT Mux32
    PORT(
        D0  : IN std_logic_vector(31 downto 0);
        D1  : IN std_logic_vector(31 downto 0);
        Sel : IN std_logic;
        Z   : OUT std_logic_vector(31 downto 0)
        );
    END COMPONENT;

    -- Declaracion del multiplexor de 5 bits
    COMPONENT Mux5
    PORT(
        D0  : IN std_logic_vector(4 downto 0);
        D1  : IN std_logic_vector(4 downto 0);
        Sel : IN std_logic;
        Z   : OUT std_logic_vector(4 downto 0)
        );
    END COMPONENT;

    -- Declaracion del Program Counter
    COMPONENT ProgCount
    PORT(
        D    : IN std_logic_vector(31 downto 0);
        Clk  : IN std_logic;
        NRst : IN std_logic;
        Q    : OUT std_logic_vector(31 downto 0)
        );
    END COMPONENT;

    -- Declaracion del Banco de registros
    COMPONENT RegsMIPS
    PORT(
        Clk  : IN std_logic;
        NRst : IN std_logic;
        A1   : IN std_logic_vector(4  downto 0);
        A2   : IN std_logic_vector(4  downto 0);
        A3   : IN std_logic_vector(4  downto 0);
        Wd3  : IN std_logic_vector(31 downto 0);
        We3  : IN std_logic;
        Rd1  : OUT std_logic_vector(31 downto 0);
        Rd2  : OUT std_logic_vector(31 downto 0)
        );
    END COMPONENT;

    -- Declaracion del Sumador +4 del para el Program Counter
    COMPONENT Suma4
    PORT(
        D : IN  std_logic_vector(31 downto 0);
        Q : OUT std_logic_vector(31 downto 0)
        );
    END COMPONENT;

    -- Declaracion del extensor de signo
    COMPONENT ExtSign
    PORT(
        Ent : IN  std_logic_vector(15 downto 0);
        Sal : OUT std_logic_vector(31 downto 0)
        );
    END COMPONENT;

    -- Declaracion del extensor de ceros
    COMPONENT ExtCero
    PORT(
        Ent : IN  std_logic_vector(15 downto 0);
        Sal : OUT std_logic_vector(31 downto 0)
        );
    END COMPONENT;

    -- Declaracion de la ALU
    COMPONENT ALUMIPS
    PORT(
        Op1        : IN  std_logic_vector(31 downto 0);
        Op2        : IN  std_logic_vector(31 downto 0);
        ALUControl : IN  std_logic_vector(2  downto 0);
        Res        : OUT std_logic_vector(31 downto 0);
        Z          : OUT std_logic
        );
    END COMPONENT;

begin

    PCSrcCtrl        <= BranchCtrl and ALUZSal;
    MEMProgAddr      <= ProgCountSal;
    MemDataAddr      <= ALUResSal;
    MemDataDataWrite <= Rd2;
    JumpMux32D1      <= (Suma4Sal(31 downto 28) & MemProgData(25 downto 0) & "00"); -- Calcular JumpTarget
    PCSrcMux32D1     <= ((ExtSignSal(29 downto 0) & "00") + Suma4Sal);    --Calcular Branch Target

    -- Instancia de la unidad de control
    Inst_UnidadControl: UnidadControl PORT MAP(
        OPCode     => MemProgData(31 downto 26), -- Codigo de operacion
        Funct      => MemProgData(5  downto 0),  -- Codigo de funcion
        ALUControl => ALUControlCtrl,            -- Señal de control de la ALU
        MemToReg   => MemToRegCtrl,              -- Se activa cuando se lleva un dato de memoria a un registro
        MemWrite   => MemDataWE,                 -- Enable de escritura de la memoria de datos
        Branch     => BranchCtrl,                -- Controla la escritura en memoria
        ALUSrc     => ALUSrcCtrl,                -- Se activa cuando hay un salto condicional
        RegDest    => RegDestCtrl,               -- Elige entre un registro y un dato inmediato como operando de la ALU
        RegWrite   => RegWriteCtrl,              -- Enable de la escritura en los registros
        RegToPC    => RegToPCCtrl,               -- Controla cual es el registro de destino
        ExtCero    => ExtCeroCtrl,               -- 0 = dato inmediato extendido en signo, 1 = dato inmediato extendido en ceros
        Jump       => JumpCtrl,                  -- Salto (jal, j)
        PCToReg    => PCToRegCtrl                -- ProgramCounter => Registros (jal)
    );

    -- Instancia de la ALU
    Inst_ALUMIPS: ALUMIPS PORT MAP(
        Op1        => Rd1,                       -- Operando 1 <= Rd1
        Op2        => ALUSrcMux32Sal,            -- Operando 2 <= dato inmediato o Rd2
        ALUControl => ALUControlCtrl,            -- Señad de la unidad de control
        Res        => ALUResSal,                 -- Salida resultado
        Z          => ALUZSal                    -- Salida z
    );

    -- Instancia del Banco de Registros
    Inst_RegsMIPS: RegsMIPS PORT MAP(
        Clk  => Clk,                             -- Reloj
        NRst => NRst,                            -- Reset activo en bajo
        A1   => MemProgData(25 downto 21),       -- Direccion del registro de lectura 1
        A2   => MemProgData(20 downto 16),       -- Dirrecion del registro de Lectura 1
        A3   => PCToRegMux5Sal,                  -- Direccion del registro de escritura
        Wd3  => PCToRegMux32Sal,                 -- Dato a escribir en el registro
        We3  => RegWriteCtrl,                    -- Write enable
        Rd1  => Rd1,                             -- Salida dato registro de lectura 1
        Rd2  => Rd2                              -- Salida dato registro de Lectura 2
    );

    -- Insancia del extesor de ceros
    Inst_ExtCero: ExtCero PORT MAP(
        Ent  => MemProgData(15 downto 0),        -- Entrada los 16 LSB de la instruccion
        Sal  => ExtCeroSal                       -- Salida  = entrada y 16 ceros delante
    );

    -- Instancia del extesor de signo
    Inst_ExtSign: ExtSign PORT MAP(
        Ent  => MemProgData(15 downto 0),        -- Entrada los 16 LSB de la instruccion
        Sal  => ExtSignSal                       -- El número de la entrada extendido en signo
    );

    -- Instancia del Program Counter: Registro de 32 bits
    Inst_ProgCount: ProgCount PORT MAP(
        Q    => ProgCountSal,                    -- Entrada del registro
        D    => RegToPCMux32Sal,                 -- Salida del registro
        Clk  => Clk,                             -- Reloj
        NRst => NRst                             -- Reset activo en bajo
    );

    -- Instancia del Sumador + 4
    Inst_Suma4: Suma4 PORT MAP(
        D   => ProgCountSal,                     -- Entrada = Salida del ProgramCounter
        Q   => Suma4Sal                          -- Salida = Entrada + 4
    );

    -- Instancia Mux32 - Cuando la señal de control está activa (instruccion beq) al ProgramCounter le llega el BTA
    Inst_PCSrcMux32: Mux32 PORT MAP(
        D0  => Suma4Sal,                         -- DO = Salida_Suma4 = PC + 4
        D1  => PCSrcMux32D1,                     -- D1 = BranchTarget
        Sel => PCSrcCtrl,                        -- Señal de la unidad de control
        Z   =>  PCSrcMux32Sal                    -- Salida del multiplexor
    );

    -- Instancia Mux32 - Cuando la señal de control está activa (instruccion jump) al ProgramCounter le llega el JumpTargetH
    Inst_JumpMux32: Mux32 PORT MAP(
        D0  => PCSrcMux32Sal,                    -- Salida_Suma4 o BranchTarget
        D1  => JumpMux32D1,                      -- JumpTarget
        Sel => JumpCtrl,                         -- Señal de la undiad de control
        Z   => JumpMux32Sal                      -- Salida del multiplexor
    );

    -- Instancia Mux32 - Cuando la señal de control está a '1' RD1 se conecta el Program Counter (en instrucciones jr)
    Inst_RegToPcMux32: Mux32 PORT MAP(
        D0  => JumpMux32Sal,                     -- JumpTarget o Salida_Suma4 o BranchTarget
        D1  => Rd1,                              -- Salida del registro de lectura 1
        Sel => RegToPCCtrl,                      -- Señal de control de la alu
        Z   => RegToPcMux32Sal                   -- Salida del multiplexor
    );

    -- Instancia Mux32 - Elige como opedando de la ALU entre la salida del extensor de signo o la salida del extensor de ceros
    Inst_ExtCeroMux32: Mux32 PORT MAP(
        D0  => ExtSignSal,                       -- Salida del extensor se signo
        D1  => ExtCeroSal,                       -- Salida del extensor de ceros
        Sel => ExtCeroCtrl,                      -- Señal de la unidad de control
        Z   => ExtCeroMux32Sal                   -- Salida del multiplexor
    );

    -- Instancia Mux32 - Elije como segundo opedando para la ALU entre la salida RD2 del registro o un dato inmediato
    Inst_ALUSrcMux32: Mux32 PORT MAP(
        D0  => Rd2,                              -- Segundo registro leido del banco de registro
        D1  => ExtCeroMux32Sal,                  -- Dato extenido en signo o en ceros
        Sel => ALUSrcCtrl,                       -- Señal de la unidad de control
        Z   => ALUSrcMux32Sal                    -- Salida del multiplexor
    );

    -- Instancia Mux32 - Elije como dato para escribir  en los registros emtre el resultado de la ALU y la salida de memoria de datos
    Inst_MemToRegMux32: Mux32 PORT MAP(
        D0  => ALUResSal,                        -- Resultado de la ALU
        D1  => MemDataDataRead,                  -- Dato de la memoria
        Sel => MemToRegCtrl,                     -- Señal de control de la ALU
        Z   => MemToRegMux32Sal                  -- Salida del multiplexor
    );

    -- Instancia Mux32 - Cuando está activo, lleva el Program Counter a los registros
    Inst_PCToRegMux32: Mux32 PORT MAP(
        D0  => MemToRegMux32Sal,                 -- Dato de la memoria o el resultado de la ALU
        D1  => Suma4Sal,                         -- Salida_Suma4
        Sel => PCToRegCtrl,                      -- Señal de control de la ALU
        Z   => PCToRegMux32Sal                   -- Salida del multiplexor
    );

    -- Instancia Mux5 Elije como direccion del registro de destino los bits(20-16) o los bits(15-11) de la instruccion
    Inst_RegDestMux5: Mux5 PORT MAP(
        D0  => MemProgData(20 downto 16),        -- Los bits 20-16 de la instruccion
        D1  => MemProgData(15 downto 11),        -- los bits 15-11 de la instruccion
        Sel => RegDestCtrl,                      -- Señal de control de la ALU
        Z   => RegDestMux5Sal                    -- Salida del multiplexor
        );

    -- Instancia Mux5 Elige como registro de destino entre la señal suministrda por el multiplexor RegDest y el registro 31
    Inst_PCToRegMux5: Mux5 PORT MAP(
        D0  => RegDestMux5Sal,                   -- Los bits 20-16 o los bits 15-11 de la instruccion
        D1  => "11111",                          -- 31
        Sel => PCToRegCtrl,                      -- Señal de control de la ALU
        Z   => PCToRegMux5Sal                    -- Salida del multiplexor
    );

end Practica;
