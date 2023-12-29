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
class mult_agent_config;

//------------------------------------------------------------------------------
// configuration variables
//------------------------------------------------------------------------------

   virtual mult_bfm bfm;
   protected  uvm_active_passive_enum     is_active;

//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------

   function new (virtual mult_bfm bfm, uvm_active_passive_enum is_active);
      this.bfm = bfm;
      this.is_active = is_active;
   endfunction : new

//------------------------------------------------------------------------------
// is_active access function
//------------------------------------------------------------------------------

   function uvm_active_passive_enum get_is_active();
      return is_active;
   endfunction : get_is_active
   
endclass : mult_agent_config
