`timescale 1ns/1ps

module MulandAddTree 
    #(parameter ADDRWIDTH = 2,SIZE=4, DATAWIDTH=8)(
    input  clk,    
    input  rst_n,
    input  enable,
    input  load,
    input  [DATAWIDTH-1:0]in_a,
    input  [DATAWIDTH-1:0]in_b,
    output reg [2*DATAWIDTH+1:0]out  
);
    reg  [DATAWIDTH-1:0] in_a_reg   [0:SIZE-1]; 
    reg  [DATAWIDTH-1:0] in_b_reg   [0:SIZE-1]; 
    wire [2*DATAWIDTH-1:0] mul_reg  [0:SIZE-1]; 
    wire [2*DATAWIDTH-1:0] add_1_reg  [0:SIZE/2-1]; 
    wire [2*DATAWIDTH-1:0] add_2_reg  [0:SIZE/4-1]; 
    wire [2*DATAWIDTH-1:0] add_3_reg  [0:SIZE/8-1]; 
    wire [2*DATAWIDTH-1:0] add_4_reg  [0:SIZE/16-1]; 
    wire [2*DATAWIDTH-1:0] add_5_reg  [0:SIZE/32-1]; 
    reg [ADDRWIDTH-1:0] counter;

    genvar i;
    generate 
        for(i=0;i<SIZE;i=i+1)begin
            Multiply M(.clk(clk),.rst_n(rst_n),.in_a(in_a_reg[i]),.in_b(in_b_reg[i]),.out(mul_reg[i]));
        end
        for(i=0;i<SIZE/2;i=i+1)begin
            Adder A_1(.clk(clk),.rst_n(rst_n),.in_a(mul_reg[2*i]),.in_b(mul_reg[2*i+1]),.out(add_1_reg[i]));
        end  
        if(SIZE/4!=0)begin
            for(i=0;i<SIZE/4;i=i+1)begin
                Adder A_2(.clk(clk),.rst_n(rst_n),.in_a(add_1_reg[2*i]),.in_b(add_1_reg[2*i+1]),.out(add_2_reg[i]));
            end  
        end
        if(SIZE/8!=0)begin
            for(i=0;i<SIZE/8;i=i+1)begin
                Adder A_3(.clk(clk),.rst_n(rst_n),.in_a(add_2_reg[2*i]),.in_b(add_2_reg[2*i+1]),.out(add_3_reg[i]));
            end  
        end
        if(SIZE/16!=0)begin
            for(i=0;i<SIZE/16;i=i+1)begin
                Adder A_3(.clk(clk),.rst_n(rst_n),.in_a(add_3_reg[2*i]),.in_b(add_3_reg[2*i+1]),.out(add_4_reg[i]));
            end  
        end
        if(SIZE/32!=0)begin
            for(i=0;i<SIZE/32;i=i+1)begin
                Adder A_4(.clk(clk),.rst_n(rst_n),.in_a(add_4_reg[2*i]),.in_b(add_4_reg[2*i+1]),.out(add_5_reg[i]));
            end  
        end
    endgenerate

    always @(posedge clk or negedge rst_n) begin 
        if(~rst_n) begin
            out<=0;
            counter<=0;
        end
        else if(enable)begin
            if(SIZE==2) out<=add_1_reg[0];
            else if(SIZE==4) out<=add_2_reg[0];
            else if(SIZE==8) out<=add_3_reg[0];
            else if(SIZE==16) out<=add_4_reg[0];
            else if(SIZE==32) out<=add_5_reg[0];
            else out<=0;
        end
        else if(load)begin
            in_a_reg[counter]<=in_a;
            in_b_reg[counter]<=in_b;
            counter<=counter+1;
        end
    end
endmodule


module Multiply
    #(parameter DATAWIDTH=8)(
    input  clk,
    input  rst_n,
    input  [DATAWIDTH-1:0] in_a,
    input  [DATAWIDTH-1:0] in_b,
    output reg [2*DATAWIDTH-1:0] out
);
    always @(posedge clk or negedge rst_n) begin 
        if(~rst_n) begin
            out<=0;
        end else begin
            out<=in_a*in_b;
        end
    end

endmodule


module Adder
    #(parameter DATAWIDTH=8)(
    input  clk,
    input  rst_n,
    input  [2*DATAWIDTH-1:0] in_a,
    input  [2*DATAWIDTH-1:0] in_b,
    output reg [2*DATAWIDTH-1:0] out
);
    always @(posedge clk or negedge rst_n) begin 
        if(~rst_n) begin
            out<=0;
        end else begin
            out<={0,in_a+in_b};
        end
    end

endmodule