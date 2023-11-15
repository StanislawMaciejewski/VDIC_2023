module top;

  int fd;
  int code;
  string s1;
  real x1,x2,x3,x4,x5,x6;
  real y1,y2,y3,y4,y5,y6;
	
  initial begin
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
								x1, y1,
								x2, y2,
								x3, y3,
								x4, y4,
								x5, y5,
								x6, y6);
		    $display(code);
		    
		end
    $fclose(fd);
  end
endmodule : top