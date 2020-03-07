
`timescale 1ns/1ps

module tb_Odd_Even (); 
	parameter ADDRWIDTH =4;
	parameter DATAWIDTH=8; 
	parameter SIZE=16;
	reg clk;
	reg rst_n;
	reg load;
	reg enable;
	reg [DATAWIDTH-1:0] in;
	wire [DATAWIDTH-1:0] out;
	reg mwrite;
	reg [ADDRWIDTH-1:0] maddr;
	reg [DATAWIDTH-1:0] min;
	wire [DATAWIDTH-1:0] mout;
	integer i=0;


	Odd_Even #(.ADDRWIDTH(ADDRWIDTH),.DATAWIDTH(DATAWIDTH), .SIZE(SIZE)) oe (.clk(clk),.rst_n(rst_n),.load(load),.enable(enable),.in(in),.out(out));
	bram  #(.ADDRWIDTH(ADDRWIDTH),.DATAWIDTH(DATAWIDTH), .SIZE(SIZE)) MEM(.clk(clk), .addr(maddr), .write(mwrite), .data(min), .o_data(mout));

	initial forever begin 
		#5 clk=~clk;
	end
	initial begin 
		clk=0;
		rst_n=0;
		load=0;
		enable=0;
		for(i=0;i<SIZE;i=i+1)begin
			mwrite=1;
			maddr=i;
			min=SIZE-i;
			@(negedge clk);
		end
		@(posedge clk);
		mwrite=0;
		rst_n=1;
		repeat(2)@(negedge clk);
		load=1;
		for(i=0;i<SIZE;i=i+1)begin
			maddr=i;
			in=mout;
			@(negedge clk);
		end
		load=0;
		repeat(SIZE+1)@(negedge clk);
		enable=1;
		for(i=0;i<SIZE;i=i+1)begin
			mwrite=1;
			maddr=i;
			min=out;
			@(negedge clk);
		end
		$stop;
	end
endmodule
