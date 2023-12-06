/*
 Copyright 2013 Ray Salemi

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */
class command_monitor extends uvm_component;
    `uvm_component_utils(command_monitor)

//------------------------------------------------------------------------------
// local variables
//------------------------------------------------------------------------------
    protected virtual mult_bfm bfm;
    uvm_analysis_port #(random_command) ap;

//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------
    function new (string name, uvm_component parent);
        super.new(name,parent);
    endfunction

//------------------------------------------------------------------------------
// build phase
//------------------------------------------------------------------------------
    function void build_phase(uvm_phase phase);

        if(!uvm_config_db #(virtual mult_bfm)::get(null, "*","bfm", bfm))
            $fatal(1, "Failed to get BFM");

        bfm.command_monitor_h = this;
        ap                    = new("ap",this);
    endfunction : build_phase

//------------------------------------------------------------------------------
// monitoring function called from BFM
//------------------------------------------------------------------------------
    function void write_to_monitor(bit signed [15:0] arg_a, bit signed [15:0] arg_b, bit arg_a_parity, bit arg_b_parity, bit rst_n);
	    random_command cmd;	    
	    `uvm_info("COMMAND MONITOR",$sformatf("MONITOR: arg_a: %2h  arg_b: %2h arg_a_parity: %2h  arg_b_parity: %2h ", arg_a, arg_b, arg_a_parity, arg_b_parity), UVM_HIGH);
        cmd    = new("cmd");
        cmd.arg_a  = arg_a;
        cmd.arg_b  = arg_b;
        cmd.arg_a_parity = arg_a_parity;
	    cmd.arg_b_parity = arg_b_parity;
	    cmd.rst_n = rst_n;
        ap.write(cmd);
    endfunction : write_to_monitor



endclass : command_monitor

