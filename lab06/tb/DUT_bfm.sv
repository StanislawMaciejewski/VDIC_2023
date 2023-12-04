import mult_pkg::*;

//------------------------------------------------------------------------------
// the interface
//------------------------------------------------------------------------------

interface mult_bfm;

//------------------------------------------------------------------------------
// dut connections
//------------------------------------------------------------------------------
	
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

//------------------------------------------------------------------------------
// local variables
//------------------------------------------------------------------------------

command_monitor command_monitor_h;
result_monitor result_monitor_h;
	
//------------------------------------------------------------------------------
// DUT reset task
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

task send_data(input bit signed[15:0] iarg_a, input bit signed[15:0] iarg_b, input bit iarg_a_parity, input bit iarg_b_parity, input bit irst_n, bit signed [31:0] iresult, bit iresult_parity, bit iarg_parity_error);
	if (irst_n)begin
		reset_alu();
	end
	else begin
	    arg_a             = iarg_a;
    	arg_b      		  = iarg_b;
		arg_a_parity      = iarg_a_parity;
    	arg_b_parity      = iarg_b_parity;
		
 		req  = 1'b1;
    	while(!ack) @(negedge clk);
    	req = 1'b0;
    	while(!result_rdy) @(negedge clk);
	end
endtask

//------------------------------------------------------------------------------
// write command monitor
//------------------------------------------------------------------------------

always @(posedge clk) begin : op_monitor
    static bit in_command = 0;
    command_s command;
    if (req) begin : start_high
        if (!in_command) begin : new_command
            command.arg_a  		  = arg_a;
            command.arg_b  		  = arg_b;
	        command.arg_a_parity  = arg_a_parity;
            command.arg_b_parity  = arg_b_parity;
            command.rst_n = rst_n;
            command_monitor_h.write_to_monitor(command);
        end : new_command
    end : start_high
    else // start low
        in_command = 0;
end : op_monitor

always @(negedge rst_n) begin : rst_monitor
    command_s command;
    command.rst_n = 0;
    if (command_monitor_h != null) //guard against VCS time 0 negedge
        command_monitor_h.write_to_monitor(command);
end : rst_monitor


//------------------------------------------------------------------------------
// write result monitor
//------------------------------------------------------------------------------

initial begin : result_monitor_thread
	result_s res;
	
    forever begin
        @(posedge clk) ;
        if (result_rdy) begin
	        res.result = result;
	        res.result_parity = result_parity;
	        res.arg_parity_error = arg_parity_error;
            result_monitor_h.write_to_monitor(res);
	    end
    end
end : result_monitor_thread

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

