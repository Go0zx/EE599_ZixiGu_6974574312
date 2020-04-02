`timescale 1ns/1ps

module tb_Barrel_Shifter;
	parameter DATA_WIDTH=8;
	parameter SIZE_NUM=64;
	parameter SELECT_NUM=6;
	reg clk;    // Clock
	reg rst_n;  // Asynchronous reset active low
	reg [SELECT_NUM-1:0]select ;
	reg [0:SIZE_NUM*DATA_WIDTH-1] data_i;
	wire [0:SIZE_NUM*DATA_WIDTH-1] data_o;
	reg [DATA_WIDTH-1:0] data_in [SIZE_NUM-1:0];
	reg [DATA_WIDTH-1:0] data_out [SIZE_NUM-1:0];
	integer i;

	Barrel_Shifter #( .DATA_WIDTH(DATA_WIDTH),.SIZE_NUM(SIZE_NUM),.SELECT_NUM(SELECT_NUM)) bs(
	 .clk(clk),.rst_n(rst_n),.select(select),.data_i(data_i),.data_o(data_o)
	);

	initial forever #5 clk=~clk;

	initial begin
		clk=0;
		rst_n=0;
		select=4'b0000;
		data_i=0;
		repeat(2)@(negedge clk);
		rst_n=1;
		select=4'b0001;
		for(i=0;i<SIZE_NUM;i=i+1) begin
			data_in[i]=i;
			data_i[i*DATA_WIDTH+:DATA_WIDTH]=i;
		end 
		repeat(5)@(negedge clk);
		for(i=0;i<SIZE_NUM;i=i+1) begin
			data_out[i]=data_o[i*DATA_WIDTH+:DATA_WIDTH];
		end 
		select=4'b0010;
		repeat(5)@(negedge clk);
		for(i=0;i<SIZE_NUM;i=i+1) begin
			data_out[i]=data_o[i*DATA_WIDTH+:DATA_WIDTH];
		end 
		select=4'b0011;
		repeat(5)@(negedge clk);
		for(i=0;i<SIZE_NUM;i=i+1) begin
			data_out[i]=data_o[i*DATA_WIDTH+:DATA_WIDTH];
		end 
		select=4'b0111;
		repeat(5)@(negedge clk);
		for(i=0;i<SIZE_NUM;i=i+1) begin
			data_out[i]=data_o[i*DATA_WIDTH+:DATA_WIDTH];
		end 
		select=4'b1111;
		repeat(5)@(negedge clk);
		for(i=0;i<SIZE_NUM;i=i+1) begin
			data_out[i]=data_o[i*DATA_WIDTH+:DATA_WIDTH];
		end 
		repeat(5)@(negedge clk);
		


		$stop;
	end 
endmodule