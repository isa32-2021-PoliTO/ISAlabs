module tb_riscv ();

    wire CLK_i;
    wire RST_n_i;
	// wire END_SIM_i;
	
	// signals for instruction memory
    wire [31:0] IM_ADDR_IN_i;
    wire [31:0] IM_DATA_OUT_i;
	
	// signals for data memory
	wire [31:0] DM_ADDR_IN_i;
	wire [31:0] DM_DATA_IN_i;
    wire [31:0] DM_DATA_OUT_i;
	wire DM_WE_IN_i;
	wire DM_RE_IN_i;
    

    clk_gen CG(	//.END_SIM(END_SIM_i),
		.RST_n(RST_n_i),
		.CLK(CLK_i)
	);
				
	inst_MEM IM(
		.rst_n(RST_n_i),
		.address(IM_ADDR_IN_i),
		.dout(IM_DATA_OUT_i)
	);
	
	data_MEM DM(
		.clock(CLK_i),
		.rst_n(RST_n_i),
		.din(DM_DATA_IN_i),
		.address(DM_ADDR_IN_i),
		.dout(DM_DATA_OUT_i),
		.we(DM_WE_IN_i),
		.re(DM_RE_IN_i)
	);

    riscv UUT(
		.CLK(CLK_i),
		.RST_N(RST_n_i),
	
	    .PC_OUT(IM_ADDR_IN_i),
		.IMem_IN(IM_DATA_OUT_i),
		
		.RM_OUT(DM_RE_IN_i),
		.WM_OUT(DM_WE_IN_i),
		.DM_ADD(DM_ADDR_IN_i),
		.DM_DIN(DM_DATA_IN_i),
		.DM_DOUT(DM_DATA_OUT_i)
	
	);
 
endmodule