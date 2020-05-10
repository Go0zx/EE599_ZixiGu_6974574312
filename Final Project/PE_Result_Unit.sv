`timescale 1ns/1ps
module PE_Result_Unit #(
    parameter KEY_WIDTH = 5,
    parameter DATA_WIDTH = 5,  
    parameter ENTRY_ADDR_WIDTH = 10,
    parameter ENTRY_DATA_WIDTH = 10,  
    parameter OPCODE_WIDTH = 4,
    parameter RESCODE_WIDTH = 4
)(
    input                                   clk,
    input                                   rst,

     // horizontal
    input                                   op_valid_i,
    input                                   res_valid_i,
    input [OPCODE_WIDTH-1:0]                opcode_i,
    input [KEY_WIDTH-1:0]                   key_i,
    input [DATA_WIDTH-1:0]                  insert_data_i,
    input [ENTRY_ADDR_WIDTH-1:0]            wr_index_i,
    input [ENTRY_DATA_WIDTH-1:0]            r_data_i,

    output logic                            op_valid_o,
    output logic                            res_valid_o,
    output logic [OPCODE_WIDTH-1:0]         opcode_o,
    output logic [KEY_WIDTH-1:0]            key_o,
    output logic [DATA_WIDTH-1:0]     	r_data_o,
  
    // vertical
    output logic                            w_en_o,
    output logic [ENTRY_ADDR_WIDTH-1:0]     w_index_o,
    output logic [ENTRY_DATA_WIDTH-1:0]     w_data_o
);

	always@(posedge clk or posedge rst) begin
		if(rst)begin
			op_valid_o<=0;
			res_valid_o<=0;
			opcode_o<=0;
			key_o<=0;
			r_data_o<=0;
		end
		else begin
			op_valid_o<=op_valid_i;
			res_valid_o<=res_valid_i;
			opcode_o<=opcode_i;
			key_o<=key_i;
			r_data_o<=r_data_i[DATA_WIDTH-1:0];
			if(op_valid_i==1 && res_valid_i!=1 && opcode_i==4'b0010) begin 
				w_en_o<=1;
				w_index_o<=wr_index_i;
				w_data_o<={key_i,insert_data_i};
			end
			else begin 
				w_en_o<=0;
				w_index_o<=wr_index_i;
				w_data_o<={key_i,insert_data_i};
			end
		end
	end
endmodule 