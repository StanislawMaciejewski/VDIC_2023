class base_tpgen extends uvm_component;
	`uvm_component_utils (base_tpgen)
	
//------------------------------------------------------------------------------
// port for sending the transactions
//------------------------------------------------------------------------------
    uvm_put_port #(random_command) command_port;

//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------	
	function new (string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

	function void build_phase(uvm_phase phase);
		command_port = new("command_port", this);
	endfunction : build_phase

//------------------------------------------------------------------------------
// run phase
//------------------------------------------------------------------------------


	task run_phase(uvm_phase phase);

		random_command command;

		phase.raise_objection(this);
		
		command    = new("command");
		command.rst_n = 1;
		command_port.put(command);
		
		command    = random_command::type_id::create("command");
		repeat (50) begin
            assert(command.randomize());
            command_port.put(command);
		end
		
		command    = new("command");
		command.rst_n = 1;
		command_port.put(command);
		
		#500;
		phase.drop_objection(this);	
	endtask : run_phase

endclass : base_tpgen
