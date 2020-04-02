module top
	#(parameter DATA_WIDTH=8, parameter SIZE_NUM=64, parameter SELECT_NUM=6)
	(
		input clk, 
		input rst_n, 
		input load, 
		input en, 
		input [DATA_WIDTH-1:0]datai, 
		input [SELECT_NUM-1:0]select, 
		output [DATA_WIDTH-1:0]datao );
	
	reg [0:SIZE_NUM*DATA_WIDTH-1] data_i;
	wire [0:SIZE_NUM*DATA_WIDTH-1] data_o;
	reg [SELECT_NUM-1:0]counter;
	integer i;

	Barrel_Shifter #( .DATA_WIDTH(DATA_WIDTH),.SIZE_NUM(SIZE_NUM),.SELECT_NUM(SELECT_NUM)) bs(
	 .clk(clk),.rst_n(rst_n),.select(select),.data_i(data_i),.data_o(data_o)
	);

	always @(posedge clk or negedge rst_n) begin 
		if(~rst_n) begin
			data_i<= 0;
			counter<=0;
		end 
		else if(en) begin
			counter<=counter+1;
		end
		else if(load) begin
			counter<=counter+1;
			data_i[counter*DATA_WIDTH+:DATA_WIDTH]<=datai;
		end
		else begin
			counter<=0;
		end
	end
	assign datao=data_o[counter*DATA_WIDTH+:DATA_WIDTH];
endmodule