`timescale 1ns/1ps

module Odd_Even 
  #(parameter ADDRWIDTH =4,
  	parameter DATAWIDTH=8, 
	parameter SIZE=16)(
	input  clk,    
	input  rst_n,
	input  load,
	input  enable,
	input  [DATAWIDTH-1:0]in,
	output [DATAWIDTH-1:0]out 
);
	reg flag;
	reg [DATAWIDTH-1:0] in_reg [0:SIZE-1]; 
	reg [ADDRWIDTH-1:0] counter;
	integer i,j;
	always@(posedge clk or negedge rst_n) begin
		if(!rst_n) begin 
			flag<=0;
			counter<=0;
		end
		else if(enable)begin
			flag<=0;
			counter<=counter+1;
		end
		else if(load)begin
			flag<=0;
			in_reg[counter]<=in;
			counter<=counter+1;
		end
		else begin
			counter<=0;
			if(flag==0)begin
				for(j=0;j<SIZE/2;j=j+1)begin
						if(in_reg[2*j]>in_reg[2*j+1]) begin
							in_reg[2*j]<=in_reg[2*j+1];
							in_reg[2*j+1]<=in_reg[2*j];
						end
					end
				flag<=1;
			end
			else if(flag==1)begin
				for(j=0;j<SIZE/2-1;j=j+1)begin
						if(in_reg[2*j+1]>in_reg[2*j+2]) begin
							in_reg[2*j+1]<=in_reg[2*j+2];
							in_reg[2*j+2]<=in_reg[2*j+1];
						end
					end
				flag<=0;
			end
		end
	end
	assign out=in_reg[counter];
endmodule

module bram #(parameter ADDRWIDTH = 4, DATAWIDTH = 8, SIZE = 16) (
    input clk,
    input [ADDRWIDTH-1:0] addr, 
    input write,
    input [DATAWIDTH-1:0] data,
    output reg [DATAWIDTH-1:0] o_data 
);

    reg [DATAWIDTH-1:0] memory_array [0:SIZE-1]; 

    always @ (posedge clk)
    begin
        if(write) begin
            memory_array[addr] <= data;
        end
        else begin
            o_data <= memory_array[addr];
        end     
    end
endmodule





// if(flag==0)begin
// 				for(j=0;j<SIZE/2;j=j+1)begin
// 						if(out[2*j*DATAWIDTH+:DATAWIDTH]>out[(2*j+1)*DATAWIDTH+:DATAWIDTH]) begin
// 							out[2*j*DATAWIDTH+:DATAWIDTH]<=out[(2*j+1)*DATAWIDTH+:DATAWIDTH];
// 							out[(2*j+1)*DATAWIDTH+:DATAWIDTH]<=out[(2*j)*DATAWIDTH+:DATAWIDTH];
// 						end
// 					end
// 				flag<=1;
// 			end
// 			else if(flag==1)begin
// 				for(j=0;j<SIZE/2-1;j=j+1)begin
// 						if(out[(2*j+1)*DATAWIDTH+:DATAWIDTH]>out[(2*j+2)*DATAWIDTH+:DATAWIDTH]) begin
// 							out[(2*j+1)*DATAWIDTH+:DATAWIDTH]<=out[(2*j+2)*DATAWIDTH+:DATAWIDTH];
// 							out[(2*j+2)*DATAWIDTH+:DATAWIDTH]<=out[(2*j+1)*DATAWIDTH+:DATAWIDTH];
// 						end
// 					end
// 				flag<=0;
// 			end