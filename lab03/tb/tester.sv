module tester(mult_bfm bfm);

function bit signed [15:0] get_data();
	bit [2:0] zero_ones;
	zero_ones = 3'($random);
	if (zero_ones == 3'b000)
		return 16'sh8000;
	else if (zero_ones == 3'b111)
		return 16'sh7FFF;
	else
		return 16'($random);
endfunction : get_data

initial begin
	bit signed [15:0] iarg_a;
	bit signed [15:0] iarg_b;
	bit iarg_a_parity;
	bit iarg_b_parity;
	
	bfm.reset_alu();
	repeat (10000) begin : random_loop
		iarg_a = get_data();
		iarg_b = get_data();
		iarg_a_parity = 1'($random);
		iarg_b_parity = 1'($random);
		bfm.send_data(iarg_a, iarg_b, iarg_a_parity, iarg_b_parity);
	end : random_loop
	$finish;
end // initial begin

endmodule : tester
