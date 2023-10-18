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
		wait(ack);
		wait(result_rdy);
		@(negedge clk);
		req = 1'b0;
		begin
			automatic bit signed expected_parity_a = get_expected_parity_16b(arg_a);
			automatic bit signed expected_parity_b = get_expected_parity_16b(arg_b);
			automatic bit signed [31:0] expected_mul_res = get_expected_mul_res(arg_a, arg_b);
			automatic bit signed expected_parity_res = get_expected_parity_32b(expected_mul_res);
			
			if((expected_parity_a === arg_a_parity) && (expected_parity_b === arg_b_parity)) begin
				if((result === expected_mul_res) && (result_parity === expected_parity_res) && (arg_parity_error === 0)) begin
					$display("Test passed for arg_a=%0d arg_b=%0d", arg_a, arg_b);
				end
				else begin
					$display("Test FAILED for arg_a=%0d arg_b=%0d", arg_a, arg_b);
                	test_result = TEST_FAILED;
            	end
			end
			else if ((expected_parity_a !== arg_a_parity) || (expected_parity_b !== arg_b_parity)) begin
				if((result === 0) && (result_parity === 0) && (arg_parity_error === 1)) begin
					$display("Test passed for arg_a=%0d arg_b=%0d", arg_a, arg_b);
				end
				else begin
					$display("Test FAILED for arg_a=%0d arg_b=%0d", arg_a, arg_b);
                	test_result = TEST_FAILED;
				end
			end
			else begin
				$display("Test FAILED for arg_a=%0d arg_b=%0d", arg_a, arg_b);
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

function bit signed [31:0] get_expected_mul_res(
		bit signed [15:0] arg_a,
		bit signed [15:0] arg_b
	);
	bit signed [31:0] ret;
	
	ret = arg_a * arg_b;
	return ret;
endfunction

function bit get_expected_parity_16b(
		bit signed [15:0] arg_parity
	);
	return ($countones(arg_parity)%2);
endfunction

function bit get_expected_parity_32b(
		bit signed [31:0] arg_parity
	);
	return ($countones(arg_parity)%2);
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



endmodule : top