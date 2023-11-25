class scoreboard;
	
//------------------------------------------------------------------------------
// local typdefs
//------------------------------------------------------------------------------

protected typedef enum bit {
    TEST_PASSED,
    TEST_FAILED
} test_result_t;
	
protected typedef enum {
    COLOR_BOLD_BLACK_ON_GREEN,
    COLOR_BOLD_BLACK_ON_RED,
    COLOR_BOLD_BLACK_ON_YELLOW,
    COLOR_BOLD_BLUE_ON_WHITE,
    COLOR_BLUE_ON_WHITE,
    COLOR_DEFAULT
} print_color_t;
	
protected typedef struct packed {
	bit signed	  [15:0] arg_a;
	bit	signed	  [15:0] arg_b;
	bit			         arg_a_parity;
	bit			         arg_b_parity;
	bit signed	  [31:0] result;
	bit					 result_parity;
	bit					 arg_parity_error;
} data_packet_t;
	
//------------------------------------------------------------------------------
// Local variables
//------------------------------------------------------------------------------

protected virtual mult_bfm bfm;
protected test_result_t        tr = TEST_PASSED; // the result of the current test

protected data_packet_t sb_data_q[$];
	
function new(virtual mult_bfm b);
	bfm = b;
endfunction : new

//------------------------------------------------------------------------------
// calculate expected result
//------------------------------------------------------------------------------

protected function bit signed [31:0] get_expected_result(
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


protected function bit get_expected_arg_parity_error(
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
	
	
protected function bit get_expected_parity_16b(
		bit signed [15:0] arg_parity
	);
	return ^arg_parity;
endfunction

protected function bit get_expected_parity_32b(
		bit signed [31:0] arg_parity
	);
	return ^arg_parity;
endfunction

//------------------------------------------------------------------------------
// data registering and checking
//------------------------------------------------------------------------------

protected task store_cmd();
	forever begin:scoreboard_fe_blk
	@(posedge bfm.clk)
	if(bfm.req == 1)begin
		sb_data_q.push_front(
			data_packet_t'({bfm.arg_a,bfm.arg_b,
							bfm.arg_a_parity, bfm.arg_b_parity, 
							get_expected_result(bfm.arg_a, bfm.arg_b, bfm.arg_a_parity, bfm.arg_b_parity),
							get_expected_parity_32b(get_expected_result(bfm.arg_a, bfm.arg_b, bfm.arg_a_parity, bfm.arg_b_parity)),
							get_expected_arg_parity_error(bfm.arg_a, bfm.arg_b, bfm.arg_a_parity, bfm.arg_b_parity)})
			);
			while(!bfm.ack) @(negedge bfm.clk);
		end
	end
endtask : store_cmd	

protected task process_data_from_dut();
	forever begin: scoreboard_be_blk
	@(negedge bfm.clk)
	if(bfm.result_rdy)begin:verify_result
		data_packet_t dp;
		
		dp = sb_data_q.pop_back();
		
		CHK_RESULT: assert(bfm.result === dp.result) begin
			`ifdef DEBUG
			$display("%0t result test passed for arg_a=%0d arg_b=%0d", $time, dp.arg_a, dp.arg_b);
//			display_in();
//			display_out();
			`endif
		end
		else begin
			tr = TEST_FAILED;
			$error("%0t Test FAILED for arg_a=%0d arg_b=%0d\nExpected result: %d. Received result: %d", 
				$time, dp.arg_a, dp.arg_b, dp.result, bfm.result);
		end
		
		CHK_RESULT_PARITY: assert(bfm.result_parity === dp.result_parity) begin
			`ifdef DEBUG
			$display("%0t result_parity test passed for arg_a=%0d arg_b=%0d", $time, dp.arg_a, dp.arg_b);
			`endif
		end
		else begin
			tr = TEST_FAILED;
			$error("%0t Test FAILED for arg_a=%0d arg_b=%0d\nExpected result parity: %d. Received result parity: %d", 
				$time, dp.arg_a, dp.arg_b, dp.result_parity, bfm.result_parity);
		end;
		
		CHK_ARG_PARITY_ERROR: assert(bfm.arg_parity_error === dp.arg_parity_error) begin
			`ifdef DEBUG
			$display("%0t arg_parity_error test passed for arg_a=%0d arg_b=%0d", $time, dp.arg_a, dp.arg_b);
//			display_out();
			`endif
		end
		else begin
			tr = TEST_FAILED;
			$error("%0t Test FAILED for arg_a=%0d arg_b=%0d\nExpected arg_parity_error: %d. Received arg_parity_error: %d", 
				$time, dp.arg_a, dp.arg_b, dp.arg_parity_error, bfm.arg_parity_error);
		end
			
		end
	end : scoreboard_be_blk
endtask : process_data_from_dut

task execute();
	fork
		store_cmd();
		process_data_from_dut();
	join_none
endtask

//------------------------------------------------------------------------------
// used to modify the color printed on the terminal
//------------------------------------------------------------------------------

protected function void set_print_color ( print_color_t c );
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

//------------------------------------------------------------------------------
// print the PASSED/FAILED in color
//------------------------------------------------------------------------------

protected function void print_test_result (test_result_t r);
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
// print the test result at the simulation end
//------------------------------------------------------------------------------
function void print_result();
    print_test_result(tr);
endfunction

endclass : scoreboard

