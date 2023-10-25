module top;
	
typedef enum bit {
    TEST_PASSED,
    TEST_FAILED
} test_result_t;
	
typedef enum {
    COLOR_BOLD_BLACK_ON_GREEN,
    COLOR_BOLD_BLACK_ON_RED,
    COLOR_BOLD_BLACK_ON_YELLOW,
    COLOR_BOLD_BLUE_ON_WHITE,
    COLOR_BLUE_ON_WHITE,
    COLOR_DEFAULT
} print_color_t;
	
//------------------------------------------------------------------------------
// Local variables
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
	
test_result_t        test_result = TEST_PASSED;

//------------------------------------------------------------------------------
// DUT instantiation
//------------------------------------------------------------------------------
	
vdic_dut_2023 DUT (.clk, .rst_n, .arg_a, .arg_a_parity, .arg_b, .arg_b_parity, .req, .ack, .result, .result_parity, .result_rdy, .arg_parity_error);
	
//------------------------------------------------------------------------------
// Coverage block
//------------------------------------------------------------------------------

// Covergroup checking for min and max arguments of the ALU
covergroup mins_or_maxs;
	
	option.name = "cg_mins_or_maxs";
	
	a_leg: coverpoint arg_a {
		bins min = {16'sh8000};
		bins others = {[16'sh8001:16'sh7FFE]};
		bins max = {16'sh7FFF};
	}
	
	b_leg: coverpoint arg_b {
		bins min = {16'sh8000};
		bins others = {[16'sh8001:16'sh7FFE]};
		bins max = {16'sh7FFF};
	}
	
	a_parity_leg: coverpoint arg_a_parity {
		bins parity = {1'b0};
		bins nonparity  = {1'b1};
	}
	
	b_parity_leg: coverpoint arg_b_parity {
		bins parity = {1'b0};
		bins nonparity  = {1'b1};
	}
	
	B_8000_7FFF: cross a_leg, b_leg, a_parity_leg, b_parity_leg{
		// #B1 simulate all min input for parity and nonparity
		bins B1_pp_8000 = (binsof(a_parity_leg.parity) || binsof(b_parity_leg.parity))&&
		(binsof(a_leg.min) || binsof(b_leg.min));
		bins B1_nn_8000 = (binsof(a_parity_leg.nonparity) || binsof(b_parity_leg.nonparity))&&
		(binsof(a_leg.min) || binsof(b_leg.min));
		bins B1_pn_8000 = (binsof(a_parity_leg.parity) || binsof(b_parity_leg.nonparity))&&
		(binsof(a_leg.min) || binsof(b_leg.min));
		bins B1_np_8000 = (binsof(a_parity_leg.nonparity)||binsof(b_parity_leg.parity))&&
		(binsof(a_leg.min) || binsof(b_leg.min));
		
		// #B2 simulate all max input for parity and nonparity
		bins B2_pp_7FFF = (binsof(a_parity_leg.parity)||binsof(b_parity_leg.parity))&&
		(binsof(a_leg.max) || binsof(b_leg.max));
		bins B2_nn_7FFF = (binsof(a_parity_leg.nonparity)||binsof(b_parity_leg.nonparity))&&
		(binsof(a_leg.max) || binsof(b_leg.max));
		bins B2_pn_7FFF = (binsof(a_parity_leg.parity)||binsof(b_parity_leg.nonparity))&&
		(binsof(a_leg.max) || binsof(b_leg.max));
		bins B2_np_7FFF = (binsof(a_parity_leg.nonparity)||binsof(b_parity_leg.parity))&&
		(binsof(a_leg.max) || binsof(b_leg.max));
		
		ignore_bins others_only = 
		binsof(a_leg.others) && binsof(b_leg.others) ;
	}
	
	
endgroup

mins_or_maxs	c_8000_7FFF;

initial begin : coverage
	c_8000_7FFF = new();
	forever begin : sample_cov
		@(posedge clk);
		if(result_rdy || !rst_n) begin
			c_8000_7FFF.sample();
			
			#1step;
			if($get_coverage() == 100) break;
			
			`ifdef DEBUG
				$strobe("%0t coverage: %.4g\%",$time, $get_coverage());
			`endif
			
		end
	end
end : coverage

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
// Tester
//------------------------------------------------------------------------------

//------------------------
// Tester main

initial begin : tester
	reset_alu();
	repeat (1000) begin : tester_main_blk
		@(negedge clk);
		arg_a = get_data();
		arg_a_parity = 1'($random);
		arg_b = get_data();
		arg_b_parity = 1'($random);
		req = 1'b1;
		while(!ack)@(negedge clk);
		req = 1'b0;
		while(!result_rdy)@(negedge clk);
		begin
			automatic bit signed [31:0] expected_result = get_expected_result(arg_a, arg_b, arg_a_parity, arg_b_parity);
			automatic bit expected_parity_res = get_expected_parity_32b(expected_result);
			automatic bit expected_arg_parity_error = get_expected_arg_parity_error(arg_a, arg_b, arg_a_parity, arg_b_parity);
			
			if((result === expected_result) && (result_parity === expected_parity_res) && (arg_parity_error === expected_arg_parity_error)) begin
					`ifdef DEBUG
					//$display("Test passed for arg_a=%0d arg_b=%0d", arg_a, arg_b);
					//display_in();
					//display_out();
					`endif
			end
			else begin
					$display("Test FAILED for arg_a=%0d arg_b=%0d", arg_a, arg_b);
					
					$display("Expected result: %d  received result: %d", expected_result, result);
					$display("Expected result parity: %d  received result parity: %d", expected_parity_res, result_parity);
					$display("Expected parity error = 0  received: %d", arg_parity_error);
					
                	test_result = TEST_FAILED;
            end
		end
	end : tester_main_blk
	$finish;
end : tester

//------------------------------------------------------------------------------
// reset task
//------------------------------------------------------------------------------

task reset_alu();
    rst_n = 1'b0;
    @(negedge clk);
    rst_n = 1'b1;
endtask : reset_alu

//------------------------------------------------------------------------------
// calculate expected result
//------------------------------------------------------------------------------

task display_in();
	$display("%0t arg_a: %0d, arg_a_parity: %0b, arg_b: %0d, arg_b_parity: %0b, req: %0b,",$time, arg_a, arg_a_parity, arg_b, arg_b_parity, req);
endtask : display_in
task display_out();
	$display("%0t result: %0d, result_parity : %0b, result_rdy: %0b, arg_parity_error: %0b", $time, result, result_parity, result_rdy, arg_parity_error);
endtask : display_out

function bit signed [31:0] get_expected_result(
		bit signed [15:0] arg_a,
		bit signed [15:0] arg_b,
		bit arg_a_parity,
		bit arg_b_parity
	);
	bit signed [31:0] ret;
	
	if((arg_a_parity == get_expected_parity_16b(arg_a))&&(arg_b_parity == get_expected_parity_16b(arg_b)))
		ret = arg_a * arg_b;
	else
		ret = 'sh0000;
		
	return ret;
	
endfunction


function bit get_expected_arg_parity_error(
		bit signed [15:0] arg_a,
		bit signed [15:0] arg_b,
		bit arg_a_parity,
		bit arg_b_parity
	);
	
	bit ret;
	
	if((arg_a_parity == get_expected_parity_16b(arg_a))&&(arg_b_parity == get_expected_parity_16b(arg_b)))
		ret = 0;
	else
		ret = 1;
		
	return ret;
	
endfunction
	
	
function bit get_expected_parity_16b(
		bit signed [15:0] arg_parity
	);
	return ^arg_parity;
endfunction

function bit get_expected_parity_32b(
		bit signed [31:0] arg_parity
	);
	return ^arg_parity;
endfunction

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

////------------------------------------------------------------------------------
//// Temporary. The scoreboard will be later used for checking the data
final begin : finish_of_the_test
   print_test_result(test_result);
end

//------------------------------------------------------------------------------
// Other functions
//------------------------------------------------------------------------------

// used to modify the color of the text printed on the terminal
function void set_print_color ( print_color_t c );
    string ctl;
    case(c)
        COLOR_BOLD_BLACK_ON_GREEN : ctl  = "\033\[1;30m\033\[102m";
        COLOR_BOLD_BLACK_ON_RED : ctl    = "\033\[1;30m\033\[101m";
        COLOR_BOLD_BLACK_ON_YELLOW : ctl = "\033\[1;30m\033\[103m";
        COLOR_BOLD_BLUE_ON_WHITE : ctl   = "\033\[1;34m\033\[107m";
        COLOR_BLUE_ON_WHITE : ctl        = "\033\[0;34m\033\[107m";
        COLOR_DEFAULT : ctl              = "\033\[0m\n";
        default : begin
            $error("set_print_color: bad argument");
            ctl                          = "";
        end
    endcase
    $write(ctl);
endfunction

function void print_test_result (test_result_t r);
    if(r == TEST_PASSED) begin
        set_print_color(COLOR_BOLD_BLACK_ON_GREEN);
        $write ("-----------------------------------\n");
        $write ("----------- Test PASSED -----------\n");
        $write ("-----------------------------------");
        set_print_color(COLOR_DEFAULT);
        $write ("\n");
    end
    else begin
        set_print_color(COLOR_BOLD_BLACK_ON_RED);
        $write ("-----------------------------------\n");
        $write ("----------- Test FAILED -----------\n");
        $write ("-----------------------------------");
        set_print_color(COLOR_DEFAULT);
        $write ("\n");
    end
endfunction

//------------------------------------------------------------------------------
// Scoreboard
//------------------------------------------------------------------------------
bit                         req_prev;
typedef struct packed {
	bit signed	  [15:0] arg_a;
	bit	signed	  [15:0] arg_b;
	bit			         arg_a_parity;
	bit			         arg_b_parity;
	bit signed	  [31:0] result;
	bit					 result_parity;
	bit					 arg_parity_error;
	
} data_packet_t;

data_packet_t			sb_data_q	[$];

always @(posedge clk) begin:scoreboard_fe_blk
	if(req == 1 && req_prev == 0)begin
		sb_data_q.push_front(
			data_packet_t'({arg_a,arg_b,arg_a_parity,arg_b_parity, get_expected_result(arg_a, arg_b, arg_a_parity, arg_b_parity), get_expected_parity_32b(get_expected_result(arg_a, arg_b, arg_a_parity, arg_b_parity)), get_expected_arg_parity_error(arg_a, arg_b, arg_a_parity, arg_b_parity)})	
		);
	end
	req_prev = req;
end
			

always @(negedge clk) begin: scoreboard_be_blk
	if(result_rdy)begin:verify_result
		data_packet_t dp;
		
		dp = sb_data_q.pop_back();
		
		CHK_RESULT: assert(result === dp.result) begin
			`ifdef DEBUG
			//$display("%0t result test passed for arg_a=%0d arg_b=%0d", $time, dp.arg_a, dp.arg_b);
//			display_in();
//			display_out();
			`endif
		end
		else begin
			test_result = TEST_FAILED;
			$error("%0t Test FAILED for arg_a=%0d arg_b=%0d\nExpected result: %d. Received result: %d", 
				$time, dp.arg_a, dp.arg_b, dp.result, result);
		end
		
		CHK_RESULT_PARITY: assert(result_parity === dp.result_parity) begin
			`ifdef DEBUG
			//$display("%0t result_parity test passed for arg_a=%0d arg_b=%0d", $time, dp.arg_a, dp.arg_b);
			`endif
		end
		else begin
			test_result = TEST_FAILED;
			$error("%0t Test FAILED for arg_a=%0d arg_b=%0d\nExpected result parity: %d. Received result parity: %d", 
				$time, dp.arg_a, dp.arg_b, dp.result_parity, result_parity);
		end;
		
		CHK_ARG_PARITY_ERROR: assert(arg_parity_error === dp.arg_parity_error) begin
			`ifdef DEBUG
			//$display("%0t arg_parity_error test passed for arg_a=%0d arg_b=%0d", $time, dp.arg_a, dp.arg_b);
//			display_out();
			`endif
		end
		else begin
			test_result = TEST_FAILED;
			$error("%0t Test FAILED for arg_a=%0d arg_b=%0d\nExpected arg_parity_error: %d. Received arg_parity_error: %d", 
				$time, dp.arg_a, dp.arg_b, dp.arg_parity_error, arg_parity_error);
		end
			
	end
end : scoreboard_be_blk

endmodule : top

