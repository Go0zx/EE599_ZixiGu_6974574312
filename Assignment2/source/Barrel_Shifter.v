`timescale 1ns/1ps

module Barrel_Shifter 
	#(parameter DATA_WIDTH=8, parameter SIZE_NUM=64, parameter SELECT_NUM=6)(
	input 	clk,    // Clock
	input 	rst_n,  // Asynchronous reset active low
	input 	[SELECT_NUM-1:0]select,
	input 	[0:SIZE_NUM*DATA_WIDTH-1] data_i,
	output 	[0:SIZE_NUM*DATA_WIDTH-1] data_o
);
    reg [SELECT_NUM-1:0] select_reg [SELECT_NUM:0];
    reg [SIZE_NUM*DATA_WIDTH-1:0] data_reg [SELECT_NUM:0];
    integer j;
    genvar i;
    generate
    	for(i=0;i<SELECT_NUM;i=i+1) begin
    		always@(posedge clk or negedge rst_n) begin
				if(!rst_n) begin
					select_reg[i]<=0;
					// data_reg[i]<=0;
				end	
				else if(select_reg[i][i]==1'b1) begin

					for(j=0;j<SIZE_NUM-2**i;j=j+1) begin
						data_reg[i+1][j*DATA_WIDTH+:DATA_WIDTH]<=data_reg[i][(j+2**i)*DATA_WIDTH+:DATA_WIDTH];
					end
					for(j=SIZE_NUM-2**i;j<SIZE_NUM;j=j+1) begin
						data_reg[i+1][j*DATA_WIDTH+:DATA_WIDTH]<=data_reg[i][(j-SIZE_NUM+2**i)*DATA_WIDTH+:DATA_WIDTH];
					end
					for(j=0;j<SELECT_NUM;j=j+1) begin
						if(i==j)
							select_reg[i+1][j]<=0;
						else
							select_reg[i+1][j]<=select_reg[i][j];
					end
				end
				else begin
					if(i!=SELECT_NUM)begin
						data_reg[i+1]<=data_reg[i];
						select_reg[i+1]<=select_reg[i];
					end
				end
			end
    	end
    	
    endgenerate

    always @(posedge clk or negedge rst_n) begin
    	if(!rst_n) begin
    		
    	end 
    	else begin
    		select_reg[0]<=select;
    		data_reg[0]<=data_i;
    	end
    end
	assign data_o=data_reg[SELECT_NUM];

endmodule























