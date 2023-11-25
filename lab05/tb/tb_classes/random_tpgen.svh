class random_tpgen extends base_tpgen;
	
	`uvm_component_utils (random_tpgen)	
	
	function new (string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

	protected function bit signed [15:0] get_data();
		bit [2:0] zero_ones;
		zero_ones = 3'($random);
		if (zero_ones == 3'b000)
			return 16'sh8000;
		else if (zero_ones == 3'b111)
			return 16'sh7FFF;
		else
			return 16'($random);
	endfunction : get_data

endclass : random_tpgen
