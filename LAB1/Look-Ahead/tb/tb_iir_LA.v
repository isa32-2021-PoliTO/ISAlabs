//`timescale 1ns

module tb_iir_LA ();

   wire CLK_i;
   wire RST_n_i;
   wire [13:0] DIN_i;
   wire VIN_i;
   wire [13:0] B0_i;
   wire [13:0] B1_i;
   wire [13:0] A1_i;
   // wire [13:0] A1A1_i;
   wire [13:0] DOUT_i;
   wire VOUT_i;
   wire END_SIM_i;


   clk_gen CG(.END_SIM(END_SIM_i),
  	      .CLK(CLK_i),
	      .RST_n(RST_n_i));

   data_maker_LA SM(.CLK(CLK_i),
   .RST_n(RST_n_i),
	 .VOUT(VIN_i),
	 .DOUT(DIN_i),
	 .B0(B0_i),
	 .B1(B1_i),
	 .A1(A1_i),
	 // .A1A1(A1A1_i),
	 .END_SIM(END_SIM_i));

   IIR_filter_LA UUT(.CLK(CLK_i),
   .RST_n(RST_n_i),
	 .VIN(VIN_i),
	 .VOUT(VOUT_i),
   .DIN(DIN_i),
   .B0(B0_i),
   .B1(B1_i),
   .A1(A1_i),
   // .A1A1(A1A1_i),
   .DOUT(DOUT_i));


   data_sink DS(.CLK(CLK_i),
  	.RST_n(RST_n_i),
  	.VIN(VOUT_i),
  	.DIN(DOUT_i));

endmodule
