----------------------------------------------------------------------
-- Fichero: UnidadControlTb.vhd
-- Descripción: Testbench para la unidad de Control para el microprocesador MIPS
-- Fecha última modificación: 2017-03-27

-- Autores: Alberto Sánchez (2012-2017), Fernando López Colino (2010), AdC (2014-2015)
-- Asignatura: E.C. 1º grado
-- Grupo de Prácticas:
-- Grupo de Teoría:
-- Práctica: 5
-- Ejercicio: 1
----------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
 
entity UnidadControlTb is
end UnidadControlTb;
 
architecture behavior of UnidadControlTb is
 
   type CasosPruebaT is record
		instruccion : std_logic_vector(31 downto 0);
		sigControl :  std_logic_vector(9 downto 0);
		aluControl : std_logic_vector(2 downto 0);
	end record;

	component UnidadControl
	port(
		OPCode : in  std_logic_vector (5 downto 0); -- OPCode de la instrucción
		Funct : in std_logic_vector(5 downto 0); -- Funct de la instrucción
		-- Señales para el PC
		Jump : out  std_logic;
		RegToPC : out std_logic;
		Branch : out  std_logic;
		PCToReg : out std_logic;
		-- Señales para la memoria
		MemToReg : out  std_logic;
		MemWrite : out  std_logic;
		
		-- Señales para la ALU
		ALUSrc : out  std_logic;
		ALUControl : out  std_logic_vector (2 downto 0);
		ExtCero : out std_logic;
		
		-- Señales para el GPR
		RegWrite : out  std_logic;
		RegDest : out  std_logic
        );
	end component;

	
   --Inputs
   signal OPCode : std_logic_vector(5 downto 0) := (others => '0');
   signal funct : std_logic_vector(5 downto 0) := (others => '0');
   

 	--Outputs
   signal regWrite, ALUSrc, branch, memWrite, memToReg, jump, pcToReg, extCero, regToPC, RegDest : std_logic;
	signal ALUControl : std_logic_vector(2 downto 0);
   
	
	signal controlFlags : std_logic_vector(9 downto 0);
	
	signal instruc : std_logic_vector(31 downto 0);
	
	-- numero de casos de prueba
	constant NUMCASOSPRUEBA : integer := 16;

	-- matriz de casos de prueba
	type CasosPruebaT2 is array (1 to NUMCASOSPRUEBA) of CasosPruebaT;

  
  constant casos_prueba : CasosPruebaT2 := (

	-- 1 INSTRUCCION: lw
	--	INSTRUCCION		SENIALES_CTRL	ALU_OP
	(	x"8c012000",	"1100100000",	"010"),
	-- 2 INSTRUCCION: sw
	--	INSTRUCCION		SENIALES_CTRL	ALU_OP
	(	x"ac012004",	"0101-0-00-",	"010"),
	-- 3 INSTRUCCION: add
	--	INSTRUCCION		SENIALES_CTRL	ALU_OP
	(	x"00430820",	"1000000-01",	"010"),
	-- 4 INSTRUCCION: sub
	--	INSTRUCCION		SENIALES_CTRL	ALU_OP
	(	x"00430822",	"1000000-01",	"110"),
	-- 5 INSTRUCCION: xor
	--	INSTRUCCION		SENIALES_CTRL	ALU_OP
	--(	x"00221826",	"1000000-01",	"011"),
	-- 5 INSTRUCCION: and
	--	INSTRUCCION		SENIALES_CTRL	ALU_OP
	(	x"00000024",	"1000000-01",	"000"),
	-- 6 INSTRUCCION: or
	--	INSTRUCCION		SENIALES_CTRL	ALU_OP
	(	x"00221825",	"1000000-01",	"001"),
	-- 7 INSTRUCCION: slt
	--	INSTRUCCION		SENIALES_CTRL	ALU_OP
	(	x"0000002a",	"1000000-01",	"111"),
	-- 8 INSTRUCCION: nor
	--	INSTRUCCION		SENIALES_CTRL	ALU_OP
	(	x"00250827",	"1000000-01",	"101"),
	-- 9 INSTRUCCION: jal
	--	INSTRUCCION		SENIALES_CTRL	ALU_OP
	(	x"0c00000b",	"1--0-11-0-",	"---"),
	-- 10 INSTRUCCION: beq
	--	INSTRUCCION		SENIALES_CTRL	ALU_OP
	(	x"10000002",	"0010-0--0-",	"110"),
	-- 11 INSTRUCCION: j
	--	INSTRUCCION		SENIALES_CTRL	ALU_OP
	(	x"0800000b",	"0--0-1--0-",	"---"),
	-- 12 INSTRUCCION: jr  -- La instrucción 12 siempre debe ser jr. Si no, hay un "if" en el bucle que dejará de funcionar
	--	INSTRUCCION		SENIALES_CTRL	ALU_OP
	(	x"03e00008",	"---0----1-",	"---"),
	-- INSTRUCCIONES ALU INMEDIATAS
	-- 13 INSTRUCCION: addi
	--	INSTRUCCION		SENIALES_CTRL	ALU_OP
	(	x"20410005",	"1100000000",	"010"),
	-- 14 INSTRUCCION: andi
	--	INSTRUCCION		SENIALES_CTRL	ALU_OP
	(	x"30410005",	"1100000100",	"000"),
	-- 15 INSTRUCCION: ori
	--	INSTRUCCION		SENIALES_CTRL	ALU_OP
	(	x"34230001",	"1100000100",	"001"),
	-- 15 INSTRUCCION: xori
	--	INSTRUCCION		SENIALES_CTRL	ALU_OP
	--(	x"38238000",	"1100000100",	"011"),
	-- 16 INSTRUCCION: slti
	--	INSTRUCCION		SENIALES_CTRL	ALU_OP
	(	x"28410005",	"1100000000",	"111")
	);
	
	 -- Tiempo que vamos a esperar a que conteste la UC  
  constant tdelay : time := 10 ns;
  
  signal fallos : integer := 0;
  
BEGIN
 

   uut: UnidadControl PORT MAP (
      OPCode => OPCode,
		Funct => funct,
		jump => jump,
		RegToPC => regToPC,
		Branch => branch,
		PCToReg => pcToReg,
		MemToReg => memToReg,
		MemWrite => memWrite,
		ALUSrc => ALUSrc,
		ALUControl => ALUControl,
		ExtCero => extCero,
		RegWrite => regWrite,
		RegDest => RegDest
	);
 
   
	controlFlags <= regWrite & ALUSrc & branch & memWrite & memToReg & jump & pcToReg & extCero & regToPC & RegDest;

   -- Stimulus process
	stim_proc: process
   begin		
	     
		for i in 1 to NUMCASOSPRUEBA loop
		
			OPCode <= casos_prueba(i).INSTRUCCION(31 downto 26);
			funct <= casos_prueba(i).INSTRUCCION(5 downto 0);
			
			instruc <= casos_prueba(i).INSTRUCCION;
			
			wait for tdelay;
			
			assert std_match(controlFlags,casos_prueba(i).sigControl)
			report "fallo en seniales caso " & integer'image(i) & " de instrucciones"
			severity warning;
			
			if not std_match(controlFlags,casos_prueba(i).sigControl) then
				fallos <= fallos + 1;
			end if;
			
			assert std_match(aluControl,casos_prueba(i).aluControl)
			report "fallo en ALUControl caso " & integer'image(i) & " de instrucciones"
			severity warning;
			
			if not std_match(ALUControl,casos_prueba(i).aluControl) then
				fallos <= fallos + 1;
			end if;
			
			if i = 12 then -- Instrucción jr.
				if regWrite = '1' and PCToReg = '1' then
					report "Fallo en jr (i=12), porque regWrite='1' y PCToReg='1'"; -- Se puede poner RegWrite='1' mientras que PCToReg no sea 1. Porque si no, se escribiria el PC en $31
					fallos <= fallos + 1;
				end if;
			end if;
			
		end loop;
		
		wait for tdelay;
		
		report "Simulación finalizada. Si no hay errores previos, la simulación es correcta";
		wait;
	end process;

END;
