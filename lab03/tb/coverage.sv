module coverage(DUT_bfm bfm);

bit signed	  [15:0] arg_a;
bit			         arg_a_parity;
bit	signed	  [15:0] arg_b;
bit			         arg_b_parity;

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
		forever begin : sampling_block
			@(posedge bfm.clk);
			arg_a      		= bfm.arg_a;
        	arg_b      		= bfm.arg_b;
			arg_a_parity	= bfm.arg_a_parity;
        	arg_b_parity    = bfm.arg_b_parity;
			
			c_8000_7FFF.sample();
			
		end
	end
end : coverage
