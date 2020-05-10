`timescale 1ns/1ps

module MEM_Block #(
  	parameter KEY_WIDTH = 5,
  	parameter DATA_WIDTH = 5,  
  	parameter ENTRY_ADDR_WIDTH = 10,
	parameter ENTRY_DATA_WIDTH = 10  
	)(
	input clk,
	input wen_a, 
	input rst,
	input [KEY_WIDTH-1:0] key_b_i,
	input [ENTRY_DATA_WIDTH-1:0] data_a_i,
	input [ENTRY_ADDR_WIDTH-1:0] addr_a, addr_b,
	output logic [ENTRY_DATA_WIDTH-1:0] data_b_o,
	output logic valid_o
);
	localparam ENTRY_NUM=2**ENTRY_ADDR_WIDTH;
	logic [ENTRY_DATA_WIDTH-1:0] RAM_1 [ENTRY_NUM-1:0];
	logic [ENTRY_DATA_WIDTH-1:0] RAM_2 [ENTRY_NUM-1:0];
	// logic [ENTRY_DATA_WIDTH-1:0] RAM_3 [ENTRY_NUM-1:0];
	// logic [ENTRY_DATA_WIDTH-1:0] RAM_4 [ENTRY_NUM-1:0];

	logic [ENTRY_NUM-1:0]VALID_RAM_1 ;
	logic [ENTRY_NUM-1:0]VALID_RAM_2 ;
	// logic [ENTRY_NUM-1:0]VALID_RAM_3 ;
	// logic [ENTRY_NUM-1:0]VALID_RAM_4 ;

	// logic valid_1,valid_2,valid_3,valid_4;
	// logic [ENTRY_DATA_WIDTH-1:0] data_1,data_2,data_3,data_4;
	logic valid_1,valid_2;
	logic [ENTRY_DATA_WIDTH-1:0] data_1,data_2;
	

	// Port A
	always@(posedge clk)
	begin
		if(rst)begin
			VALID_RAM_1 <= 0;
			VALID_RAM_2 <= 0;
			// VALID_RAM_3 <= 0;
			// VALID_RAM_4 <= 0;
		end
		else if (wen_a) begin
			if(VALID_RAM_1[addr_a]==0) begin 
				RAM_1[addr_a] <= data_a_i;
				VALID_RAM_1[addr_a] <= 1;
			end
			else if(VALID_RAM_2[addr_a]==0) begin
				RAM_2[addr_a] <= data_a_i;
				VALID_RAM_2[addr_a] <= 1;
			end
			// else if(VALID_RAM_3[addr_a]==0) begin 
			// 	RAM_3[addr_a] <= data_a_i;
			// 	VALID_RAM_3[addr_a] <= 1;
			// end
			// else if(VALID_RAM_4[addr_a]==0) begin
			// 	RAM_4[addr_a] <= data_a_i;
			// 	VALID_RAM_4[addr_a] <= 1;
			// end
		end
	end
	
	// Port B
	assign data_1=RAM_1[addr_b];
	assign data_2=RAM_2[addr_b];
	// assign data_3=RAM_3[addr_b];
	// assign data_4=RAM_4[addr_b];
	assign valid_1 = VALID_RAM_1[addr_b] == 1 && RAM_1[addr_b][ENTRY_DATA_WIDTH-1-:KEY_WIDTH] == key_b_i ? 1 : 0;
	assign valid_2 = VALID_RAM_2[addr_b] == 1 && RAM_2[addr_b][ENTRY_DATA_WIDTH-1-:KEY_WIDTH] == key_b_i ? 1 : 0;
	// assign valid_3 = VALID_RAM_3[addr_b] == 1 && RAM_3[addr_b][ENTRY_DATA_WIDTH-1-:KEY_WIDTH] == key_b_i ? 1 : 0;
	// assign valid_4 = VALID_RAM_4[addr_b] == 1 && RAM_4[addr_b][ENTRY_DATA_WIDTH-1-:KEY_WIDTH] == key_b_i ? 1 : 0;
	// assign data_b_o = valid_1==1 ? RAM_1[addr_b] : valid_2==1 ? RAM_2[addr_b] : valid_3==1 ? RAM_3[addr_b] : valid_4==1 ? RAM_4[addr_b]:0;
	assign data_b_o = valid_1==1 ? RAM_1[addr_b] : valid_2==1 ? RAM_2[addr_b] : 0;

	// assign valid_o = valid_1 || valid_2 || valid_3 || valid_4;

	assign valid_o = valid_1 || valid_2 ;
	
endmodule
