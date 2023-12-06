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
class random_command extends uvm_transaction;
    `uvm_object_utils(random_command)

//------------------------------------------------------------------------------
// transaction variables
//------------------------------------------------------------------------------


//------------------------------------------------------------------------------
	rand bit signed [15:0] arg_a;
	rand bit arg_a_parity;
	rand bit signed [15:0] arg_b;
	rand bit arg_b_parity;
	bit rst_n;

//------------------------------------------------------------------------------
// constraints
//------------------------------------------------------------------------------

    constraint data {
        arg_a dist {16'h8000:=1, [16'h7FFE : 16'h8001]:=1, 16'h7FFF:=1};
	    //arg_a_parity dist {1'b0:=1, 1'b1:=1};
        arg_b dist {16'h8000:=1, [16'h7FFE : 16'h8001]:=1, 16'h7FFF:=1};
	}
	    //arg_b_parity dist {1'b0:=1, 1'b1:=1};}
    
//------------------------------------------------------------------------------
// transaction functions: do_copy, clone_me, do_compare, convert2string
//------------------------------------------------------------------------------

    function void do_copy(uvm_object rhs);
        random_command copied_transaction_h;

        if(rhs == null)
            `uvm_fatal("COMMAND TRANSACTION", "Tried to copy from a null pointer")

        super.do_copy(rhs); // copy all parent class data

        if(!$cast(copied_transaction_h,rhs))
            `uvm_fatal("COMMAND TRANSACTION", "Tried to copy wrong type.")

        arg_a         = copied_transaction_h.arg_a;
        arg_b         = copied_transaction_h.arg_b;
        arg_a_parity  = copied_transaction_h.arg_a_parity;
        arg_b_parity  = copied_transaction_h.arg_b_parity;
        rst_n		  = copied_transaction_h.rst_n;

    endfunction : do_copy


    function random_command clone_me();
        
        random_command clone;
        uvm_object tmp;

        tmp = this.clone();
        $cast(clone, tmp);
        return clone;
        
    endfunction : clone_me


    function bit do_compare(uvm_object rhs, uvm_comparer comparer);
        
        random_command compared_transaction_h;
        bit same;

        if (rhs==null) `uvm_fatal("RANDOM TRANSACTION",
                "Tried to do comparison to a null pointer");

        if (!$cast(compared_transaction_h,rhs))
            same = 0;
        else
            same = super.do_compare(rhs, comparer) &&
            (compared_transaction_h.arg_a == arg_a) &&
            (compared_transaction_h.arg_b == arg_b) &&
            (compared_transaction_h.arg_a_parity == arg_a_parity) &&
            (compared_transaction_h.arg_b_parity == arg_b_parity) &&
            (compared_transaction_h.rst_n == rst_n);

        return same;
        
    endfunction : do_compare


    function string convert2string();
        string s;
        s = $sformatf("arg_a: %2h  arg_b: %2h arg_a_parity: %2h  arg_b_parity: %2h", arg_a, arg_b, arg_a_parity, arg_a_parity);
        return s;
    endfunction : convert2string

//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------

    function new (string name = "");
        super.new(name);
    endfunction : new

endclass : random_command
