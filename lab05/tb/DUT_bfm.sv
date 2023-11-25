interface mult_bfm;
import mult_pkg::*;
	
bit                  clk;
bit                  rst_n;
bit signed	  [15:0] arg_a;
bit			         arg_a_parity;
bit	signed	  [15:0] arg_b;
bit			         arg_b_parity;
bit					 req;
wire				 ack;
wire signed	  [31:0] result; 
wire                 result_parity;
wire                 result_rdy;
wire                 arg_parity_error;	
	
	
//modport tlm (import reset_alu, send_data);

//------------------------------------------------------------------------------
// reset_alu
//------------------------------------------------------------------------------

task reset_alu();
	`ifdef DEBUG
    $display("%0t DEBUG: reset_alu", $time);
    `endif
    rst_n = 1'b0;
    @(negedge clk);
    rst_n = 1'b1;
endtask : reset_alu


//------------------------------------------------------------------------------
// send_data
//------------------------------------------------------------------------------

task send_data(input bit signed[15:0] iarg_a, input bit signed[15:0] iarg_b, input bit iarg_a_parity, input bit iarg_b_parity, output bit signed [31:0] iresult, output bit iresult_parity, output bit iarg_parity_error);

    arg_a             = iarg_a;
    arg_b      		  = iarg_b;
	arg_a_parity      = iarg_a_parity;
    arg_b_parity      = iarg_b_parity;

    req  = 1'b1;

    while(!ack) @(negedge clk);
    req = 1'b0;
    while(!result_rdy) @(negedge clk);

endtask : send_data

//------------------------------------------------------------------------------
// Clock generator
//------------------------------------------------------------------------------

initial begin : clk_gen_blk
    clk = 0;
    forever begin : clk_frv_blk
        #10;
        clk = ~clk;
    end
end

endinterface : mult_bfm

