module DUT(dut_if.port_in in_inter, dut_if.port_out out_inter, output enum logic [1:0] {INITIAL,WAIT,SEND} state);
    
    FPmul mbe_under_test(.FP_A(in_inter.A),.FP_B(in_inter.B),.clk(in_inter.clk),.FP_Z(out_inter.data));
    bit [31:0] A;
    bit [31:0] B;

    always_ff @(posedge in_inter.clk)
    begin
        if(in_inter.rst) begin
            in_inter.ready <= 0;
            out_inter.data <= 'x;
            out_inter.valid <= 0;
            state <= INITIAL;
        end
        else case(state)
                INITIAL: begin
                    in_inter.ready <= 1;
                    state <= WAIT;
                end
                
                WAIT: begin
                    if(in_inter.valid) begin
                        in_inter.ready <= 0;
			A <= in_inter.A;
                        B <= in_inter.B;
			@(posedge in_inter.clk)
			@(posedge in_inter.clk)
			@(posedge in_inter.clk)
			@(posedge in_inter.clk)
                        $display("mbe: input A = %.3e, input B = %.3e, output OUT = %.3e",$bitstoshortreal(A),$bitstoshortreal(B),$bitstoshortreal(out_inter.data));
                        $display("mbe: input A = %b, input B = %b, output OUT = %b",A,B,out_inter.data);
                        out_inter.valid <= 1;
                        state <= SEND;
                    end
                end
                
                SEND: begin
                    if(out_inter.ready) begin
                        out_inter.valid <= 0;
                        in_inter.ready <= 1;
                        state <= WAIT;
                    end
                end
        endcase
    end
endmodule: DUT