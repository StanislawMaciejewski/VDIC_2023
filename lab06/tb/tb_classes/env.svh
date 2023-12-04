class env extends uvm_env;
    `uvm_component_utils(env)

//------------------------------------------------------------------------------
// testbench elements
//------------------------------------------------------------------------------
    random_tpgen tpgen_h;
    uvm_tlm_fifo #(command_s) command_f;
    driver driver_h;

    coverage coverage_h;
    scoreboard scoreboard_h;
    command_monitor command_monitor_h;
    result_monitor result_monitor_h;
	
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
        tpgen_h      = random_tpgen::type_id::create("tpgen_h",this);
	    command_f    = new("command_f", this);
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
        command_monitor_h.ap.connect(scoreboard_h.cmd_f.analysis_export);
        result_monitor_h.ap.connect(scoreboard_h.analysis_export);
    endfunction : connect_phase

//------------------------------------------------------------------------------
// end-of-elaboration phase
//------------------------------------------------------------------------------
    function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);

        // display created tpgen type
        set_print_color(COLOR_BOLD_BLACK_ON_YELLOW);
        $write("*** Created tpgen type: %s ***", tpgen_h.get_type_name());
        set_print_color(COLOR_DEFAULT);
        $write("\n");

    endfunction : end_of_elaboration_phase

endclass

