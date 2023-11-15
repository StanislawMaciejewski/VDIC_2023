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

virtual class shape_c;
   protected string name;
   protected real points[$][2];
	
   
   function new(real p[$][2], string n);
      points = p;
      name = n;
   endfunction : new
  
   pure virtual function void get_area();
  
   function void print();  
	   	$display ("This is %s\n", name);
	   	foreach (points[i])
		  $display("(%0.2f, %0.2f)", points[i][0], points[i][1]);
   endfunction : print
	   	
endclass : shape_c


class polygon_c extends shape_c;
	
   function new(real p[$][2], string n);
      super.new(p,n);
   endfunction : new	

   function void get_area();
      $display ("Area is: can not be calculated for generic polygon.");
   endfunction : get_area
   
endclass : polygon_c


class rectangle_c extends shape_c;
   function new(real p[$][2], string n);
      super.new(p,n);
   endfunction : new
   
   function void get_area();
	   real side1 = $hypot(points[0], points[1]);
	   real side2 = $hypot(points[1], points[2]);
	   real area = side1 * side2;
      $display ("Area is: %0.2f", area);
   endfunction : get_area

endclass : rectangle_c

class triangle_c extends shape_c;
   function new(real p[$][2], string n);
      super.new(p,n);
   endfunction : new	
   
   function void get_area();
	   real side1 = $hypot(points[0], points[1]);
	   real side2 = $hypot(points[1], points[2]);
	   real side3 = $hypot(points[2], points[0]);
	   real area = (side1 + side2 + side3) / 2;
      $display ("Area is: %0.2f", area);
   endfunction : get_area
endclass : triangle_c


class circle_c extends shape_c;
   function new(real p[$][2], string n);
      super.new(p,n);
   endfunction : new	
   
   function void get_area();
	  real radius = $hypot(points[0], points[1]);
	  real area = radius * radius * 3.14 * 2; 
      $display("radius: %0.2f", radius);
	  $display("Area is: %0.2f", area); 
   endfunction : get_area

endclass : circle_c

class shape_factory;

   static function shape_c make_shape(string shape, real p[$][2]);
	  shape_c shape_h;
      polygon_c   	polygon_h;
	  rectangle_c   rectangle_h;
      triangle_c   	triangle_h;
	  circle_c		circle_h;
	   
      case (shape)
        "polygon" : begin
           polygon_h = new(p, shape);
           return polygon_h;
        end
        
        "rectangle" : begin
           rectangle_h = new(p, shape);
           return rectangle_h;
        end
                
        "triangle" : begin
           triangle_h = new(p, shape);
           return triangle_h;
        end

        "circle" : begin
           circle_h = new(p, shape);
           return triangle_h;
        end

        default : 
          $fatal (1, {"No such shape: ", shape});
        
      endcase // case (species)
      
   endfunction : make_shape
   
endclass : shape_factory



class shape_reporter #(type T=shape_c);

   protected static T storage[$];

//   static function void make_shape(T l);
//      storage.push_back(l);
//   endfunction : make_shape

   static function void report_shapes();
      foreach (storage[i])
      	$display(storage[i].print());
   endfunction : report_shapes

endclass : shape_reporter


module top;
	
   int fd;
   int code;
   string s1;
   real points[$][2];

   initial begin
      shape_c 		shape_h;
      polygon_c   	polygon_h;
	  rectangle_c   rectangle_h;
      triangle_c   	triangle_h;
	  circle_c		circle_h;
	  
      bit cast_ok;
      
      fd = $fopen("/home/student/smaciejewski/VDIC_2023/lab04part1/tb/lab04part1_shapes.txt", "r");

    	while($fgets(s1, fd))
	    begin
			$display(s1);
		    code = $sscanf(s1, "%0.2f %0.2f \
								%0.2f %0.2f \
								%0.2f %0.2f \
								%0.2f %0.2f \
								%0.2f %0.2f \
								%0.2f %0.2f ", 
								points[0][0], points[0][1],
								points[1][0], points[1][1],
								points[2][0], points[2][1],
								points[3][0], points[3][1],
								points[4][0], points[4][1],
								points[5][0], points[5][1]);
		    $display(code);
      		if(code == 2) begin
      			shape_h = shape_factory::make_shape("circle", points);
      			//shape_reporter::storage.push_back(shape_h);
	      	end
      		else if(code == 3) begin
	      		shape.h = shape_factory::make_shape("triangle", points);
	      		//shape_h.report_shapes();
	      	end
      		else if(code == 4) begin
	      		shape.h = shape_factory::make_shape("rectangle", points);
	      		//shape_h.report_shapes();
	        end
      		else if(code == 5) begin
	      		shape.h = shape_factory::make_shape("polygon", points);
	      		//shape_h.report_shapes();
	        end
	      	else if(code == 6) begin
	      		shape.h = shape_factory::make_shape("polygon", points);
		        //shape_h.report_shapes();
	        end
	    end 
   end

endmodule : top




