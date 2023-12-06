class scoreboard extends uvm_subscriber #(result_transaction);
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
	uvm_tlm_analysis_fifo #(random_command) cmd_f;
	local test_result_t        tr = TEST_PASSED; // the result of the current test

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
// build phase
//------------------------------------------------------------------------------
    function void build_phase(uvm_phase phase);
		cmd_f = new ("cmd_f", this);
    endfunction : build_phase
    
//------------------------------------------------------------------------------
// function to calculate the expected ALU result
//------------------------------------------------------------------------------

    local function result_transaction predict_result(random_command cmd);
        result_transaction predicted;

        predicted = new("predicted");
	    
	    predicted.result = get_expected_result(cmd.arg_a, cmd.arg_b, cmd.arg_a_parity, cmd.arg_b_parity);
		predicted.result_parity = get_expected_parity_32b(get_expected_result(cmd.arg_a, cmd.arg_b, cmd.arg_a_parity, cmd.arg_b_parity));
		predicted.arg_parity_error = get_expected_arg_parity_error(cmd.arg_a, cmd.arg_b, cmd.arg_a_parity, cmd.arg_b_parity);

        return predicted;

    endfunction : predict_result

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
// subscriber write function
//------------------------------------------------------------------------------

	function void write(result_transaction t);
		string data_str;
		random_command cmd;
		result_transaction predicted;

		do
            if (!cmd_f.try_get(cmd))
                $fatal(1, "Missing command in self checker");
        while (cmd.rst_n == 0);

        predicted = predict_result(cmd);

        data_str  = { cmd.convert2string(),
            " ==>  Actual " , t.convert2string(),
            "/Predicted ",predicted.convert2string()};

        if (!predicted.compare(t)) begin
            `uvm_error("SELF CHECKER", {"FAIL: ",data_str})
            tr = TEST_FAILED;
        end
        else
            `uvm_info ("SELF CHECKER", {"PASS: ", data_str}, UVM_HIGH)
	endfunction : write
	
//------------------------------------------------------------------------------
// report phase
//------------------------------------------------------------------------------
    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        print_test_result(tr);
    endfunction : report_phase

endclass : scoreboard

