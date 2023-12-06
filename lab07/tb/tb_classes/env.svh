class env extends uvm_env;
    `uvm_component_utils(env)

//------------------------------------------------------------------------------
// testbench elements
//------------------------------------------------------------------------------
    base_tpgen tpgen_h;
	coverage coverage_h;
	scoreboard scoreboard_h;
	driver driver_h;
	command_monitor command_monitor_h;
    result_monitor result_monitor_h;
    uvm_tlm_fifo #(random_command) command_f;
	
//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------
    function new (string name, uvm_component parent);
        super.new(name,parent);
    endfunction : new

//------------------------------------------------------------------------------
// build phase
//------------------------------------------------------------------------------
    function void build_phase(uvm_phase phase);
	    command_f    = new("command_f", this);
        tpgen_h      = base_tpgen::type_id::create("tpgen_h",this);
	    driver_h     = driver::type_id::create("drive_h",this);
        coverage_h   = coverage::type_id::create ("coverage_h",this);
        scoreboard_h = scoreboard::type_id::create("scoreboard_h",this);
        command_monitor_h = command_monitor::type_id::create("command_monitor_h",this);
        result_monitor_h  = result_monitor::type_id::create("result_monitor_h",this);
    endfunction : build_phase

//------------------------------------------------------------------------------
// connect phase
//------------------------------------------------------------------------------
    function void connect_phase(uvm_phase phase);
        driver_h.command_port.connect(command_f.get_export);
        tpgen_h.command_port.connect(command_f.put_export);
        command_monitor_h.ap.connect(coverage_h.analysis_export);
	    //      We could also connect the coverage directly to the command fifo instead,
		//      skipping the command monitor
		//        command_f.put_ap.connect(coverage_h.analysis_export);
        command_monitor_h.ap.connect(scoreboard_h.cmd_f.analysis_export);
        result_monitor_h.ap.connect(scoreboard_h.analysis_export);
    endfunction : connect_phase

//------------------------------------------------------------------------------
// end-of-elaboration phase
//------------------------------------------------------------------------------

//    function void end_of_elaboration_phase(uvm_phase phase);
//        scoreboard_h.set_report_verbosity_level_hier(UVM_HIGH);
//    endfunction : end_of_elaboration_phase

endclass

