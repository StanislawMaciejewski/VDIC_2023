virtual class base_tpgen extends uvm_component;
	
//------------------------------------------------------------------------------
// port for sending the transactions
//------------------------------------------------------------------------------
    uvm_put_port #(command_s) command_port;
	
//------------------------------------------------------------------------------
//  function prototypes
//------------------------------------------------------------------------------
	pure virtual protected function bit signed [15:0] get_data();
	
//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------	
	function new (string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

//------------------------------------------------------------------------------
// build phase
//------------------------------------------------------------------------------
	function void build_phase(uvm_phase phase);
		command_port = new("command_port", this);
	endfunction : build_phase

	task run_phase(uvm_phase phase);

		command_s command;

		phase.raise_objection(this);
		command.rst_n = 1;
		command_port.put(command);
		command.rst_n = 0;
		repeat (1000) begin : random_loop
			command.arg_a = get_data();
			command.arg_b = get_data();
			command.arg_a_parity = 1'($random);
			command.arg_b_parity = 1'($random);
			command_port.put(command);
		end : random_loop
		
		command_port.put(command);
		command.rst_n = 1;
		command_port.put(command);
		#500;
		phase.drop_objection(this);	
	endtask : run_phase

endclass : base_tpgen
