virtual class base_tpgen extends uvm_component;
	
	protected virtual mult_bfm bfm;
	
	function new (string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

	pure virtual protected function bit signed [15:0] get_data();

	function void build_phase(uvm_phase phase);
		if(!uvm_config_db #(virtual mult_bfm)::get(null, "*","bfm", bfm))
			$fatal(1,"Failed to get BFM");
	endfunction : build_phase

task run_phase(uvm_phase phase);
	bit signed [15:0] iarg_a;
	bit signed [15:0] iarg_b;
	bit iarg_a_parity;
	bit iarg_b_parity;
	bit signed[31:0] iresult; 
	bit iresult_parity;
	bit iarg_parity_error;	
	
	phase.raise_objection(this);
	
	bfm.reset_alu();
	
	repeat (1000) begin : random_loop
		iarg_a = get_data();
		iarg_b = get_data();
		iarg_a_parity = 1'($random);
		iarg_b_parity = 1'($random);
		bfm.send_data(iarg_a, iarg_b, iarg_a_parity, iarg_b_parity, iresult, iresult_parity, iarg_parity_error);
	end : random_loop
	
	bfm.send_data(iarg_a, iarg_b, iarg_a_parity, iarg_b_parity, iresult, iresult_parity, iarg_parity_error);
	bfm.reset_alu();
	
	phase.drop_objection(this);
	
endtask : run_phase

endclass : base_tpgen
