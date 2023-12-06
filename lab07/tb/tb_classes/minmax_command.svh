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
class minmax_command extends random_command;
    `uvm_object_utils(minmax_command)

//------------------------------------------------------------------------------
// constraints
//------------------------------------------------------------------------------

        constraint data {
        arg_a dist {16'h8000:=4, [16'h7FFE : 16'h8001]:=1, 16'h7FFF:=4};
        arg_b dist {16'h8000:=4, [16'h7FFE : 16'h8001]:=1, 16'h7FFF:=4};
		}

//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------

    function new(string name="");
        super.new(name);
    endfunction
    
    
endclass : minmax_command


