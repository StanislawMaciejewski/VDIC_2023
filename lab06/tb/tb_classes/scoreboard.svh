class scoreboard extends uvm_subscriber #(result_s);
	`uvm_component_utils(scoreboard)
	
//------------------------------------------------------------------------------
// local typdefs
//------------------------------------------------------------------------------

	typedef enum bit {
    	TEST_PASSED,
    	TEST_FAILED
	} test_result_t;
	
//------------------------------------------------------------------------------
// Local variables
//------------------------------------------------------------------------------
	uvm_tlm_analysis_fifo #(command_s) cmd_f;
	protected test_result_t        tr = TEST_PASSED; // the result of the current test

//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------
    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

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
// function to calculate the expected ALU result
//------------------------------------------------------------------------------

	function bit signed [31:0] get_expected_result(
			bit signed [15:0] arg_a,
			bit signed [15:0] arg_b,
			bit arg_a_parity,
			bit arg_b_parity
		);
		bit signed [31:0] ret;
	
		`ifdef DEBUG
			$display("%0t DEBUG: get_expected(%0d,%0d,%0d,%0d)",$time, arg_a, arg_b, arg_a_parity, arg_b_parity);
		`endif
    
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

//------------------------------------------------------------------------------
// build phase
//------------------------------------------------------------------------------
    function void build_phase(uvm_phase phase);
		cmd_f = new ("cmd_f", this);
    endfunction : build_phase

//------------------------------------------------------------------------------
// subscriber write function
//------------------------------------------------------------------------------

	function void write(result_s t);
		bit signed [31:0] predicted_result;
		bit predicted_parity;
		bit predicted_parity_error;
		
		command_s cmd;
		cmd.arg_a = 0;
		cmd.arg_b = 0;
		cmd.arg_a_parity = 0;
		cmd.arg_b_parity = 0;
		cmd.rst_n = 0;
		
		do
            if (!cmd_f.try_get(cmd))
                $fatal(1, "Missing command in self checker");
        while (cmd.rst_n == 0);
		
		predicted_result = get_expected_result(cmd.arg_a, cmd.arg_b, cmd.arg_a_parity, cmd.arg_b_parity);
		predicted_parity = get_expected_parity_32b(get_expected_result(cmd.arg_a, cmd.arg_b, cmd.arg_a_parity, cmd.arg_b_parity));
		predicted_parity_error = get_expected_arg_parity_error(cmd.arg_a, cmd.arg_b, cmd.arg_a_parity, cmd.arg_b_parity);
		
		CHK_RESULT: 
		assert(predicted_result === t.result) begin
			`ifdef DEBUG
			$display("%0t result test passed for arg_a=%0d arg_b=%0d", $time, cmd.arg_a, cmd.arg_b);
			`endif
		end
		else begin
			$error("FAILED: A: %0h  B: %0h result: %0h", cmd.arg_a, cmd.arg_b, t.result);
			tr = TEST_FAILED;
		end
		
		CHK_RESULT_PARITY: 
		assert(predicted_parity === t.result_parity) begin
			`ifdef DEBUG
			$display("%0t result_parity test passed for arg_a=%0d arg_b=%0d", $time, cmd.arg_a, cmd.arg_b);
			`endif
		end
		else begin
			$error("FAILED: A: %0h  B: %0h result: %0h", cmd.arg_a, cmd.arg_b, t.result_parity);
			tr = TEST_FAILED;
		end;
		
		CHK_ARG_PARITY_ERROR: 
		assert(predicted_parity_error === t.arg_parity_error) begin
			`ifdef DEBUG
			$display("%0t arg_parity_error test passed for arg_a=%0d arg_b=%0d", $time, cmd.arg_a, cmd.arg_b);
			`endif
		end
		else begin
			$error("FAILED: A: %0h  B: %0h result: %0h", cmd.arg_a, cmd.arg_b, t.arg_parity_error);
			tr = TEST_FAILED;
		end
		
//		end
//	end : scoreboard_be_blk
	endfunction : write
	
//------------------------------------------------------------------------------
// report phase
//------------------------------------------------------------------------------
    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        print_test_result(tr);
    endfunction : report_phase

endclass : scoreboard

