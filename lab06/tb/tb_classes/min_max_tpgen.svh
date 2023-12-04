class min_max_tpgen extends random_tpgen;
	`uvm_component_utils (min_max_tpgen)	

//------------------------------------------------------------------------------
// function: get_data - generate random data for the tpgen
//------------------------------------------------------------------------------

	protected function bit signed [15:0] get_data();
		bit zero_ones;
		zero_ones = 1'($random);
		if (zero_ones == 1'b0)
			return 16'sh8000;
		else
			return 16'sh7FFF;
	endfunction : get_data

//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------
    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

endclass : min_max_tpgen
