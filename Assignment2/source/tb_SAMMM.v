
`timescale 1ns/1ps

module tb_SAMMM ();

	parameter DATA_WIDTH = 8;
	parameter SIZE_NUM   = 16;
	parameter COUNT_NUM  = 4;

	reg rst_n;
	reg clk;
	reg en;
	reg load;
	reg read;
	reg [DATA_WIDTH-1:0] A_i;
	reg [DATA_WIDTH-1:0] B_i;
	wire [2*DATA_WIDTH-1:0] result;

	integer i,j;

	SAMMM #(
			.DATA_WIDTH(DATA_WIDTH),
			.SIZE_NUM(SIZE_NUM),
			.COUNT_NUM(COUNT_NUM)
		) inst_SAMMM (
			.clk   (clk),
			.rst_n (rst_n),
			.en    (en),
			.load  (load),
			.read  (read),
			.A_i   (A_i),
			.B_i   (B_i),
			.result(result)
		);
	initial begin
		clk = 0;
		forever #5 clk = ~clk;
	end

	initial begin
		rst_n = 0;
		en=0;
		read=0;
		load=0;
		repeat(3)@(negedge clk);
		rst_n = 1;
		load=1;
		for(i=0;i<SIZE_NUM;i=i+1) begin
			for(j=0;j<SIZE_NUM;j=j+1) begin
				A_i=j%10;
				B_i=j%10;
				@(negedge clk);
			end
		end
		load=0;
		repeat(3)@(negedge clk);
		en=1;

		repeat(60)@(negedge clk);
		$stop;
	end

	
endmodule
