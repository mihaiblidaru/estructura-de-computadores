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
    --salidas registros
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
    signal ExtCeroSal : std_logic_vector(31 downto 0);
    signal ExtSignSal : std_logic_vector(31 downto 0);

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
        OPCode     => MemProgData(31 downto 26),
        Funct      => MemProgData(5  downto 0),
        ALUControl => ALUControlCtrl,
        MemToReg   => MemToRegCtrl,
        MemWrite   => MemDataWE,
        Branch     => BranchCtrl,
        ALUSrc     => ALUSrcCtrl,
        RegDest    => RegDestCtrl,
        RegWrite   => RegWriteCtrl,
        RegToPC    => RegToPCCtrl,
        ExtCero    => ExtCeroCtrl,
        Jump       => JumpCtrl,
        PCToReg    => PCToRegCtrl
    );

    -- Instancia de la ALU
    Inst_ALUMIPS: ALUMIPS PORT MAP(
        Op1        => Rd1,
        Op2        => ALUSrcMux32Sal,
        ALUControl => ALUControlCtrl,
        Res        => ALUResSal,
        Z          => ALUZSal
    );

    -- Instancia del Banco de Registros
    Inst_RegsMIPS: RegsMIPS PORT MAP(
        Clk  => Clk,
        NRst => NRst,
        A1   => MemProgData(25 downto 21),
        A2   => MemProgData(20 downto 16),
        A3   => PCToRegMux5Sal,
        Wd3  => PCToRegMux32Sal,
        We3  => RegWriteCtrl,
        Rd1  => Rd1,
        Rd2  => Rd2
    );

    -- Insancia del extesor de ceros
    Inst_ExtCero: ExtCero PORT MAP(
        Ent  => MemProgData(15 downto 0),
        Sal  => ExtCeroSal
    );

    -- Instancia del extesor de signo
    Inst_ExtSign: ExtSign PORT MAP(
        Ent  => MemProgData(15 downto 0),
        Sal  => ExtSignSal
    );

    -- Instancia del Program Counter
    Inst_ProgCount: ProgCount PORT MAP(
        Q    => ProgCountSal,
        D    => RegToPCMux32Sal,
        Clk  => Clk,
        NRst => NRst
    );

    -- Instancia del Sumador + 4
    Inst_Suma4: Suma4 PORT MAP(
        D   => ProgCountSal,
        Q   => Suma4Sal
    );


    Inst_PCSrcMux32: Mux32 PORT MAP(
        D0  => Suma4Sal,
        D1  => PCSrcMux32D1,
        Sel => PCSrcCtrl,
        Z   =>  PCSrcMux32Sal
    );

    Inst_JumpMux32: Mux32 PORT MAP(
        D0  => PCSrcMux32Sal,
        D1  => JumpMux32D1,
        Sel => JumpCtrl,
        Z   => JumpMux32Sal
    );

    Inst_RegToPcMux32: Mux32 PORT MAP(
        D0  => JumpMux32Sal,
        D1  => Rd1,
        Sel => RegToPCCtrl,
        Z   => RegToPcMux32Sal
    );

    Inst_ExtCeroMux32: Mux32 PORT MAP(
        D0  => ExtSignSal,
        D1  => ExtCeroSal,
        Sel => ExtCeroCtrl,
        Z   => ExtCeroMux32Sal
    );

    Inst_ALUSrcMux32: Mux32 PORT MAP(
        D0  => Rd2,
        D1  => ExtCeroMux32Sal,
        Sel => ALUSrcCtrl,
        Z   => ALUSrcMux32Sal
    );

    Inst_MemToRegMux32: Mux32 PORT MAP(
        D0  => ALUResSal,
        D1  => MemDataDataRead,
        Sel => MemToRegCtrl,
        Z   => MemToRegMux32Sal
    );

    Inst_PCToRegMux32: Mux32 PORT MAP(
        D0  => MemToRegMux32Sal,
        D1  => Suma4Sal,
        Sel => PCToRegCtrl,
        Z   => PCToRegMux32Sal
    );

    Inst_RegDestMux5: Mux5 PORT MAP(
        D0  => MemProgData(20 downto 16),
        D1  => MemProgData(15 downto 11),
        Sel => RegDestCtrl,
        Z   => RegDestMux5Sal
        );

    Inst_PCToRegMux5: Mux5 PORT MAP(
        D0  => RegDestMux5Sal,
        D1  => "11111",
        Sel => PCToRegCtrl,
        Z   => PCToRegMux5Sal
    );

end Practica;
