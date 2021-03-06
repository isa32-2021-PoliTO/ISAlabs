-- VHDL Entity HAVOC.FPmul.symbol
--
-- Created by
-- Guillermo Marcus, gmarcus@ieee.org
-- using Mentor Graphics FPGA Advantage tools.
--
-- Visit "http://fpga.mty.itesm.mx" for more info.
--
-- 2003-2004. V1.0
--

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;

ENTITY FPmul IS
   PORT( 
      FP_A : IN     std_logic_vector (31 DOWNTO 0);
      FP_B : IN     std_logic_vector (31 DOWNTO 0);
      clk  : IN     std_logic;
      FP_Z : OUT    std_logic_vector (31 DOWNTO 0)
   );

-- Declarations

END FPmul ;

--
-- VHDL Architecture HAVOC.FPmul.pipeline
--
-- Created by
-- Guillermo Marcus, gmarcus@ieee.org
-- using Mentor Graphics FPGA Advantage tools.
--
-- Visit "http://fpga.mty.itesm.mx" for more info.
--
-- Copyright 2003-2004. V1.0
--


LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;

ARCHITECTURE pipeline OF FPmul IS

   -- Architecture declarations

   -- Internal signal declarations
   SIGNAL A_EXP           : std_logic_vector(7 DOWNTO 0);
   SIGNAL A_SIG           : std_logic_vector(31 DOWNTO 0);
   SIGNAL B_EXP           : std_logic_vector(7 DOWNTO 0);
   SIGNAL B_SIG           : std_logic_vector(31 DOWNTO 0);
   --SIGNAL EXP_in          : std_logic_vector(7 DOWNTO 0); --Replaced
   SIGNAL EXP_neg         : std_logic;
   --SIGNAL EXP_neg_stage2  : std_logic;                    --Replaced
   SIGNAL EXP_out_round   : std_logic_vector(7 DOWNTO 0);
   SIGNAL EXP_pos         : std_logic;
   --SIGNAL EXP_pos_stage2  : std_logic;                    --Replaced
   SIGNAL SIGN_out        : std_logic;
   SIGNAL SIGN_out_stage1 : std_logic;
   --SIGNAL SIGN_out_stage2 : std_logic;                    --Replaced
   --SIGNAL SIG_in          : std_logic_vector(27 DOWNTO 0);--Replaced
   SIGNAL SIG_out_round   : std_logic_vector(27 DOWNTO 0);
   SIGNAL isINF_stage1    : std_logic;
   --SIGNAL isINF_stage2    : std_logic;                    --Replaced
   SIGNAL isINF_tab       : std_logic;
   SIGNAL isNaN           : std_logic;
   SIGNAL isNaN_stage1    : std_logic;
   --SIGNAL isNaN_stage2    : std_logic;                    --Replaced
   SIGNAL isZ_tab         : std_logic;
   SIGNAL isZ_tab_stage1  : std_logic;
   --SIGNAL isZ_tab_stage2  : std_logic;                    --Replaced

   -- Component Declarations
   COMPONENT FPmul_stage1
   PORT (
      FP_A            : IN     std_logic_vector (31 DOWNTO 0);
      FP_B            : IN     std_logic_vector (31 DOWNTO 0);
      clk             : IN     std_logic ;
      A_EXP           : OUT    std_logic_vector (7 DOWNTO 0);
      A_SIG           : OUT    std_logic_vector (31 DOWNTO 0);
      B_EXP           : OUT    std_logic_vector (7 DOWNTO 0);
      B_SIG           : OUT    std_logic_vector (31 DOWNTO 0);
      SIGN_out_stage1 : OUT    std_logic ;
      isINF_stage1    : OUT    std_logic ;
      isNaN_stage1    : OUT    std_logic ;
      isZ_tab_stage1  : OUT    std_logic 
   );
   END COMPONENT;
   COMPONENT FPmul_stage2
   PORT (
      A_EXP           : IN     std_logic_vector (7 DOWNTO 0);
      A_SIG           : IN     std_logic_vector (31 DOWNTO 0);
      B_EXP           : IN     std_logic_vector (7 DOWNTO 0);
      B_SIG           : IN     std_logic_vector (31 DOWNTO 0);
      SIGN_out_stage1 : IN     std_logic ;
      clk             : IN     std_logic ;
      isINF_stage1    : IN     std_logic ;
      isNaN_stage1    : IN     std_logic ;
      isZ_tab_stage1  : IN     std_logic ;
      EXP_in          : OUT    std_logic_vector (7 DOWNTO 0);
      EXP_neg_stage2  : OUT    std_logic ;
      EXP_pos_stage2  : OUT    std_logic ;
      SIGN_out_stage2 : OUT    std_logic ;
      SIG_in          : OUT    std_logic_vector (27 DOWNTO 0);
      isINF_stage2    : OUT    std_logic ;
      isNaN_stage2    : OUT    std_logic ;
      isZ_tab_stage2  : OUT    std_logic 
   );
   END COMPONENT;
   COMPONENT FPmul_stage3
   PORT (
      EXP_in          : IN     std_logic_vector (7 DOWNTO 0);
      EXP_neg_stage2  : IN     std_logic ;
      EXP_pos_stage2  : IN     std_logic ;
      SIGN_out_stage2 : IN     std_logic ;
      SIG_in          : IN     std_logic_vector (27 DOWNTO 0);
      clk             : IN     std_logic ;
      isINF_stage2    : IN     std_logic ;
      isNaN_stage2    : IN     std_logic ;
      isZ_tab_stage2  : IN     std_logic ;
      EXP_neg         : OUT    std_logic ;
      EXP_out_round   : OUT    std_logic_vector (7 DOWNTO 0);
      EXP_pos         : OUT    std_logic ;
      SIGN_out        : OUT    std_logic ;
      SIG_out_round   : OUT    std_logic_vector (27 DOWNTO 0);
      isINF_tab       : OUT    std_logic ;
      isNaN           : OUT    std_logic ;
      isZ_tab         : OUT    std_logic 
   );
   END COMPONENT;
   COMPONENT FPmul_stage4
   PORT (
      EXP_neg       : IN     std_logic ;
      EXP_out_round : IN     std_logic_vector (7 DOWNTO 0);
      EXP_pos       : IN     std_logic ;
      SIGN_out      : IN     std_logic ;
      SIG_out_round : IN     std_logic_vector (27 DOWNTO 0);
      clk           : IN     std_logic ;
      isINF_tab     : IN     std_logic ;
      isNaN         : IN     std_logic ;
      isZ_tab       : IN     std_logic ;
      FP_Z          : OUT    std_logic_vector (31 DOWNTO 0)
   );
   END COMPONENT;

   -- Optional embedded configurations
   -- pragma synthesis_off
   FOR ALL : FPmul_stage1 USE ENTITY work.FPmul_stage1;
   FOR ALL : FPmul_stage2 USE ENTITY work.FPmul_stage2;
   FOR ALL : FPmul_stage3 USE ENTITY work.FPmul_stage3;
   FOR ALL : FPmul_stage4 USE ENTITY work.FPmul_stage4;
   -- pragma synthesis_on

   
   -- Signals for pipeline registers
    SIGNAL pipe_reg_in_1: std_logic_vector(7 downto 0);
	SIGNAL pipe_reg_in_2: std_logic;
	SIGNAL pipe_reg_in_3: std_logic;
	SIGNAL pipe_reg_in_4: std_logic;
	SIGNAL pipe_reg_in_5: std_logic_vector(27 downto 0);
	SIGNAL pipe_reg_in_6: std_logic;
	SIGNAL pipe_reg_in_7: std_logic;
	SIGNAL pipe_reg_in_8: std_logic;
	
	SIGNAL pipe_reg_out_1: std_logic_vector(7 downto 0);
	SIGNAL pipe_reg_out_2: std_logic;
	SIGNAL pipe_reg_out_3: std_logic;
	SIGNAL pipe_reg_out_4: std_logic;
	SIGNAL pipe_reg_out_5: std_logic_vector(27 downto 0);
	SIGNAL pipe_reg_out_6: std_logic;
	SIGNAL pipe_reg_out_7: std_logic;
	SIGNAL pipe_reg_out_8: std_logic;
	
   -- Input register signals
    SIGNAL FP_A_internal: std_logic_vector(31 DOWNTO 0);
    SIGNAL FP_B_internal: std_logic_vector(31 DOWNTO 0);
	
BEGIN
	
   -- Register to synchronize and filter input data
   PROCESS(clk)
   BEGIN
      IF RISING_EDGE(clk) THEN
        FP_A_internal <= FP_A;
		FP_B_internal <= FP_B;
      END IF;
   END PROCESS;
	
   -- Instance port mappings.
   I1 : FPmul_stage1
      PORT MAP (
         FP_A            => FP_A_internal,
         FP_B            => FP_B_internal,
         clk             => clk,
         A_EXP           => A_EXP,
         A_SIG           => A_SIG,
         B_EXP           => B_EXP,
         B_SIG           => B_SIG,
         SIGN_out_stage1 => SIGN_out_stage1,
         isINF_stage1    => isINF_stage1,
         isNaN_stage1    => isNaN_stage1,
         isZ_tab_stage1  => isZ_tab_stage1
      );
   I2 : FPmul_stage2
      PORT MAP (
         A_EXP           => A_EXP,
         A_SIG           => A_SIG,
         B_EXP           => B_EXP,
         B_SIG           => B_SIG,
         SIGN_out_stage1 => SIGN_out_stage1,
         clk             => clk,
         isINF_stage1    => isINF_stage1,
         isNaN_stage1    => isNaN_stage1,
         isZ_tab_stage1  => isZ_tab_stage1,
         EXP_in          => pipe_reg_in_1,
         EXP_neg_stage2  => pipe_reg_in_2,
         EXP_pos_stage2  => pipe_reg_in_3,
         SIGN_out_stage2 => pipe_reg_in_4,
         SIG_in          => pipe_reg_in_5,
         isINF_stage2    => pipe_reg_in_6,
         isNaN_stage2    => pipe_reg_in_7,
         isZ_tab_stage2  => pipe_reg_in_8
      );
	  
	-- pipe register at the output of stage2
    PROCESS(clk)
    BEGIN
      IF RISING_EDGE(clk) THEN
        pipe_reg_out_1 <= pipe_reg_in_1;
		pipe_reg_out_2 <= pipe_reg_in_2;
		pipe_reg_out_3 <= pipe_reg_in_3;
		pipe_reg_out_4 <= pipe_reg_in_4;
		pipe_reg_out_5 <= pipe_reg_in_5;
		pipe_reg_out_6 <= pipe_reg_in_6;
		pipe_reg_out_7 <= pipe_reg_in_7;
		pipe_reg_out_8 <= pipe_reg_in_8;
      END IF;
    END PROCESS;
	
	  
   I3 : FPmul_stage3
      PORT MAP (
         EXP_in          => pipe_reg_out_1,
         EXP_neg_stage2  => pipe_reg_out_2,
         EXP_pos_stage2  => pipe_reg_out_3,
         SIGN_out_stage2 => pipe_reg_out_4,
         SIG_in          => pipe_reg_out_5,
         clk             => clk,
         isINF_stage2    => pipe_reg_out_6,
         isNaN_stage2    => pipe_reg_out_7,
         isZ_tab_stage2  => pipe_reg_out_8,
         EXP_neg         => EXP_neg,
         EXP_out_round   => EXP_out_round,
         EXP_pos         => EXP_pos,
         SIGN_out        => SIGN_out,
         SIG_out_round   => SIG_out_round,
         isINF_tab       => isINF_tab,
         isNaN           => isNaN,
         isZ_tab         => isZ_tab
      );
   I4 : FPmul_stage4
      PORT MAP (
         EXP_neg       => EXP_neg,
         EXP_out_round => EXP_out_round,
         EXP_pos       => EXP_pos,
         SIGN_out      => SIGN_out,
         SIG_out_round => SIG_out_round,
         clk           => clk,
         isINF_tab     => isINF_tab,
         isNaN         => isNaN,
         isZ_tab       => isZ_tab,
         FP_Z          => FP_Z
      );

END pipeline;
