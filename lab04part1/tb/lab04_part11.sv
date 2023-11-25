virtual class shape_c;
   protected string name;
   protected real points[$][2];
   
   function new(real p[$][2], string n);
      points = p;
      name = n;
   endfunction : new

   
   function void print();  
           $display ("This is %s", name);
           foreach (points[i]) $display("(%0.2f, %0.2f)", points[i][0], points[i][1]);
   endfunction : print
   
   pure virtual function real get_area();
          
endclass : shape_c


class polygon_c extends shape_c;
    
   function new(real p[$][2], string n);
      super.new(p,n);
   endfunction : new   

   function real get_area();
      return -1;
   endfunction : get_area
   
endclass : polygon_c


class rectangle_c extends shape_c;
   function new(real p[$][2], string n);
      super.new(p,n);
   endfunction : new
   
   function real get_area();
       real dx1 = points[1][0] - points[0][0];
       real dy1 = points[1][1] - points[0][1];
       real side1 = $sqrt(dx1 * dx1 + dy1 * dy1);
      
       real dx2 = points[1][0] - points[2][0];
       real dy2 = points[1][1] - points[2][1];
       real side2 = $sqrt(dx2 * dx2 + dy2 * dy2);
      
       real area = side1 * side2;
      
       return area;
   endfunction : get_area

endclass : rectangle_c

class triangle_c extends shape_c;
   function new(real p[$][2], string n);
      super.new(p,n);
   endfunction : new   
   
   function real get_area();
       real dx1 = points[0][0] - points[1][0];
       real dy1 = points[0][1] - points[1][1];
       real side1 = $sqrt(dx1 * dx1 + dy1 * dy1);
      
       real dx2 = points[1][0] - points[2][0];
       real dy2 = points[1][1] - points[2][1];
       real side2 = $sqrt(dx2 * dx2 + dy2 * dy2);
      
       real dx3 = points[2][0] - points[0][0];
       real dy3 = points[2][1] - points[0][1];
       real side3 = $sqrt(dx2 * dx2 + dy2 * dy2);
      
       real area = (side1 + side2 + side3) / 2;
       return area;
   endfunction : get_area
endclass : triangle_c


class circle_c extends shape_c;
   function new(real p[$][2], string n);
      super.new(p,n);
   endfunction : new   
   
   function real get_area();
       real dx1 = points[0][0] - points[1][0];
       real dy1 = points[0][1] - points[1][1];
       real radius = $sqrt(dx1 * dx1 + dy1 * dy1);

      real area = radius * radius * 3.14 * 2;
	   
      return area;
	   
   endfunction : get_area
   
   function real get_radius();
       real dx1 = points[0][0] - points[1][0];
       real dy1 = points[0][1] - points[1][1];
       real radius = $sqrt(dx1 * dx1 + dy1 * dy1);
	   
	   return radius;
   endfunction : get_radius
   
   function void print();  
	   	real radius = get_radius();
	   	real area = get_area();
        $display ("This is %s", name);
        foreach (points[i]) $display("(%0.2f, %0.2f)", points[i][0], points[i][1]);
   		$display("Radius is: %0.2f", radius);
   endfunction : print

endclass : circle_c

class shape_factory;

   static function shape_c make_shape(string shape, real p[$][2]);
      shape_c shape_h;
      polygon_c       polygon_h;
      rectangle_c   rectangle_h;
      triangle_c       triangle_h;
      circle_c        circle_h;
      
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
           return circle_h;
        end

        default :
          $fatal (1, {"No such shape: ", shape});
        
      endcase // case (species)
      
   endfunction : make_shape
   
endclass : shape_factory



class shape_reporter #(type T=shape_c);

   protected static T storage[$];

   static function void cage_shape(T l);
      storage.push_back(l);
   endfunction : cage_shape

   static function void report_shapes();
      foreach (storage[i]) begin
	      real area_shape = storage[i].get_area();
          storage[i].print();
	      if(area_shape == -1)
          	$display("Area is: can not be calculated for generic polygon.");
	      else begin
		    $display("Area is: %0.2f", area_shape);
	      end
	      $display("//----------------");
      end
   endfunction : report_shapes

endclass : shape_reporter


module top;
    
   int fd;
   int code, counter;
   string s1;
   real x1,x2,x3,x4,x5,x6;
   real y1,y2,y3,y4,y5,y6;

   initial begin
      shape_c         shape_h;
      polygon_c       polygon_h;
      rectangle_c   rectangle_h;
      triangle_c       triangle_h;
      circle_c        circle_h;
     
      bit cast_ok;
      
      fd = $fopen("/home/student/smaciejewski/VDIC_2023/lab04part1/tb/lab04part1_shapes.txt", "r");

        while($fgets(s1, fd))
        begin
            code = $sscanf(s1, "%f %f %f %f %f %f %f %f %f %f",
                                x1, y1, x2, y2, x3, y3, x4, y4, x5, y5);
	        //$display(code);
	        	for (int i=0; i<s1.len(); i++) begin
		        	if(s1[i] == 32) begin
			        	counter = counter + 1;
		        	end
	        	end
	        	
              if(counter == 3) begin
                  real points [2][2];
                 
                  points[0] = '{x1, y1};
                  points[1] = '{x2, y2};
                 
                  cast_ok = $cast(circle_h, shape_h);
                  $cast(circle_h, shape_factory::make_shape("circle", points));
                  shape_reporter#(circle_c)::cage_shape(circle_h);
               
              end
              else if(counter == 5) begin
                  real points [3][2];
                 
                  points[0] = '{x1, y1};
                  points[1] = '{x2, y2};
                  points[2] = '{x3, y3};
               
                  cast_ok = $cast(triangle_h, shape_h);
                  $cast(triangle_h, shape_factory::make_shape("triangle", points));
                  shape_reporter#(triangle_c)::cage_shape(triangle_h);
              end
              else if(counter == 7) begin
                  real points [4][2];
                 
                  points[0] = '{x1, y1};
                  points[1] = '{x2, y2};
	              points[2] = '{x3, y3};
	              points[3] = '{x4, y4};
                 
                  cast_ok = $cast(rectangle_h, shape_h);
                  $cast(rectangle_h, shape_factory::make_shape("rectangle", points));
                  shape_reporter#(rectangle_c)::cage_shape(rectangle_h);
            end
              else if(counter == 9) begin
                  real points [5][2];
                 
                  points[0] = '{x1, y1};
	              points[1] = '{x2, y2};
	              points[2] = '{x3, y3};
	              points[3] = '{x4, y4};
	              points[4] = '{x5, y5};
                 
                  cast_ok = $cast(polygon_h, shape_h);
                  $cast(polygon_h, shape_factory::make_shape("polygon", points));
                  shape_reporter#(polygon_c)::cage_shape(polygon_h);
            end
              counter = 0;
              s1 = "";
        end
       
        shape_reporter #(circle_c)::report_shapes();
        shape_reporter #(triangle_c)::report_shapes();
        shape_reporter #(rectangle_c)::report_shapes();
        shape_reporter #(polygon_c)::report_shapes();
       
   end
   
endmodule: top  
