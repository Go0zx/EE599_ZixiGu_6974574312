`timescale 1ns/1ps
module tb_MulandAddTree();
	parameter ADDRWIDTH =2;
	parameter SIZE=4;
	parameter DATAWIDTH=8;
	reg clk;
	reg rst_n;
	reg enable;
	reg load;
	reg [DATAWIDTH-1:0] in_a_MEM    [0:SIZE-1][0:SIZE-1]; 
    reg [DATAWIDTH-1:0] in_b_MEM    [0:SIZE-1][0:SIZE-1]; 
    reg [2*DATAWIDTH-1:0] out_MEM   [0:SIZE-1][0:SIZE-1];  
    reg [DATAWIDTH-1:0] in_a;
    reg [DATAWIDTH-1:0] in_b;
    wire [2*DATAWIDTH-1:0] out;
    integer i,j,k;
    MulandAddTree 
    #( .ADDRWIDTH(ADDRWIDTH),.SIZE(SIZE), .DATAWIDTH(DATAWIDTH)) 
    muladdtree (
      .clk(clk), .rst_n(rst_n),.enable(enable),.load(load),.in_a(in_a),.in_b(in_b),.out(out)  
	);

	initial forever begin 
		#5 clk=~clk;
	end
    initial begin
    	for(i=0;i<SIZE;i=i+1)begin
    		for(j=0;j<SIZE;j=j+1)begin
	    		in_a_MEM[i][j]=i*j+1;
	    		in_b_MEM[i][j]=i*j+2;
    		end
    	end
    end
    initial begin 
		clk=0;
		rst_n=0;
		load=0;
		enable=0;
		@(posedge clk);
		rst_n=1;
		repeat(2)@(negedge clk);
		load=1;
		for(i=0;i<SIZE;i=i+1)begin
			for(j=0;j<SIZE;j=j+1)begin
				for(k=0;k<SIZE;k=k+1)begin
					in_a=in_a_MEM[i][k];
					in_b=in_b_MEM[k][j];
					@(negedge clk);
				end
				load=0;
				repeat(2*SIZE)@(negedge clk);
				enable=1;
				@(negedge clk);
				out_MEM[i][j]=out;
				enable=0;
				load=1;
			end
			
		end
		repeat(SIZE*SIZE*SIZE)@(negedge clk);
		$stop;
	end
endmodule