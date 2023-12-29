/*
 Copyright 2013 Ray Salemi

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */
module mult_tpgen_module(mult_bfm bfm);
import mult_pkg::*;

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
	bit irst_n;
	bit signed[31:0] iresult; 
	bit iresult_parity;
	bit iarg_parity_error;	
	
	bfm.reset_alu();
	repeat (1000) begin : random_loop
		iarg_a = get_data();
		iarg_b = get_data();
		iarg_a_parity = 1'($random);
		iarg_b_parity = 1'($random);
		bfm.send_data(iarg_a, iarg_b, iarg_a_parity, iarg_b_parity, irst_n, iresult, iresult_parity, iarg_parity_error);
	end : random_loop
	
	bfm.send_data(iarg_a, iarg_b, iarg_a_parity, iarg_b_parity, irst_n, iresult, iresult_parity, iarg_parity_error);
	bfm.reset_alu();
	
end // initial begin
endmodule : mult_tpgen_module





