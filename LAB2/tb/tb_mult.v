module tb_mult ();

   wire CLK_i;
  // wire RST_n_i;
   wire [31:0] DIN_i;
   wire [31:0] DOUT_i;
  // wire END_SIM_i;


   clk_gen CG(	//.END_SIM(END_SIM_i),
				// .RST_n(RST_n_i)
				.CLK(CLK_i)
				);

   data_maker SM(.CLK(CLK_i),
	    //    	 .RST_n(RST_n_i),
				 .DOUT(DIN_i)
		//       .END_SIM(END_SIM_i)
				);

   FPmul UUT(.clk(CLK_i),
	     .FP_A(DIN_i),
	     .FP_B(DIN_i),
         .FP_Z(DOUT_i));

   data_sink DS(.CLK(CLK_i),
		//.RST_n(RST_n_i),
		.DIN(DOUT_i));   
		
endmodule