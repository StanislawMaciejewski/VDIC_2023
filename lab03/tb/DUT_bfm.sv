interface DUT_bfm;
	
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
	
	
modport tlm (import reset_alu);

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

endinterface : DUT_bfm

