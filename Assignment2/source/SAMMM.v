`timescale 1ns/1ps

module SAMMM 
  #(parameter DATA_WIDTH=2, 
	parameter SIZE_NUM=32,
	parameter COUNT_NUM=5)(
	input clk,    
	input rst_n,  
	input en,
	input load,
	input read,
	input  [DATA_WIDTH-1:0] A_i,
	input  [DATA_WIDTH-1:0] B_i,
	output [2*DATA_WIDTH-1:0]result
);	
	reg  [DATA_WIDTH-1:0] 	input_A   [SIZE_NUM-1:0][SIZE_NUM-1:0];
	reg  [DATA_WIDTH-1:0] 	input_B	  [SIZE_NUM-1:0][SIZE_NUM-1:0];
	wire [2*DATA_WIDTH-1:0] result_C  [SIZE_NUM-1:0][SIZE_NUM-1:0];
	reg  [DATA_WIDTH-1:0] 	A_input   [SIZE_NUM-1:0];
	reg  [DATA_WIDTH-1:0] 	B_input   [SIZE_NUM-1:0];
	wire [DATA_WIDTH-1:0] 	inter_A   [SIZE_NUM-1:0][SIZE_NUM-1:0];
	wire [DATA_WIDTH-1:0] 	inter_B   [SIZE_NUM-1:0][SIZE_NUM-1:0];
	reg  [COUNT_NUM-1:0] 	counter_i,counter_j;
	reg  [COUNT_NUM-1:0] 	counter_A[SIZE_NUM-1:0];
	reg  [COUNT_NUM-1:0] 	counter_B[SIZE_NUM-1:0];
	reg  A_enable[SIZE_NUM-1:0]; 
	reg  B_enable[SIZE_NUM-1:0];
	reg  en_pe;
	integer m,n;
	genvar i,j;
	generate
		for(i=0;i<SIZE_NUM;i=i+1) begin
			for(j=0;j<SIZE_NUM;j=j+1) begin
				if(i==SIZE_NUM-1 && j==SIZE_NUM-1) begin
					SAMMM_PE #(.DATA_WIDTH(DATA_WIDTH)) pe 
						(.clk(clk),.rst_n(rst_n),.en(en_pe),.A_i(inter_A[i][j-1]),.B_i(inter_B[i-1][j]),.A_o(),.B_o(),.C_o(result_C[i][j]));
				end
				else if(i==0 && j==0)begin
					SAMMM_PE #(.DATA_WIDTH(DATA_WIDTH)) pe 
						(.clk(clk),.rst_n(rst_n),.en(en_pe),.A_i(A_input[j]),.B_i(B_input[i]),.A_o(inter_A[i][j]),.B_o(inter_B[i][j]),.C_o(result_C[i][j]));
				end
				else if(i==SIZE_NUM-1 && j==0)begin
					SAMMM_PE #(.DATA_WIDTH(DATA_WIDTH)) pe 
						(.clk(clk),.rst_n(rst_n),.en(en_pe),.A_i(A_input[i]),.B_i(inter_B[i-1][j]),.A_o(inter_A[i][j]),.B_o(),.C_o(result_C[i][j]));
				end
				else if(i==0 && j==SIZE_NUM-1)begin
					SAMMM_PE #(.DATA_WIDTH(DATA_WIDTH)) pe 
						(.clk(clk),.rst_n(rst_n),.en(en_pe),.A_i(inter_A[i][j-1]),.B_i(B_input[j]),.A_o(),.B_o(inter_B[i][j]),.C_o(result_C[i][j]));
				end
				else if(j==0)begin
					SAMMM_PE #(.DATA_WIDTH(DATA_WIDTH)) pe 
						(.clk(clk),.rst_n(rst_n),.en(en_pe),.A_i(A_input[i]),.B_i(inter_B[i-1][j]),.A_o(inter_A[i][j]),.B_o(inter_B[i][j]),.C_o(result_C[i][j]));
				end
				else if(i==0)begin
					SAMMM_PE #(.DATA_WIDTH(DATA_WIDTH)) pe 
						(.clk(clk),.rst_n(rst_n),.en(en_pe),.A_i(inter_A[i][j-1]),.B_i(B_input[j]),.A_o(inter_A[i][j]),.B_o(inter_B[i][j]),.C_o(result_C[i][j]));
				end
				else if(i==SIZE_NUM-1) begin
					SAMMM_PE #(.DATA_WIDTH(DATA_WIDTH)) pe 
						(.clk(clk),.rst_n(rst_n),.en(en_pe),.A_i(inter_A[i][j-1]),.B_i(inter_B[i-1][j]),.A_o(inter_A[i][j]),.B_o(),.C_o(result_C[i][j]));
				end
				else if(j==SIZE_NUM-1) begin
					SAMMM_PE #(.DATA_WIDTH(DATA_WIDTH)) pe 
						(.clk(clk),.rst_n(rst_n),.en(en_pe),.A_i(inter_A[i][j-1]),.B_i(inter_B[i-1][j]),.A_o(),.B_o(inter_B[i][j]),.C_o(result_C[i][j]));
				end  
				else begin
					SAMMM_PE #(.DATA_WIDTH(DATA_WIDTH)) pe 
						(.clk(clk),.rst_n(rst_n),.en(en_pe),.A_i(inter_A[i][j-1]),.B_i(inter_B[i-1][j]),.A_o(inter_A[i][j]),.B_o(inter_B[i][j]),.C_o(result_C[i][j]));
				end
			end
		end
	endgenerate
	
	always@(posedge clk or negedge rst_n) begin
		if(!rst_n) begin
			for(m=0;m<SIZE_NUM;m=m+1) begin
				for(n=0;n<SIZE_NUM;n=n+1) begin
					input_A[m][n]<=0;
					input_B[m][n]<=0;
				end
			end
			for(m=0;m<SIZE_NUM;m=m+1) begin
				A_enable[m]<=0;
				B_enable[m]<=0;
				counter_A[m]<=0;
				counter_B[m]<=0;
			end
			counter_i<=0;
			counter_j<=0;
		end
		else if(en) begin
			en_pe<=en;
			counter_i<=counter_i+1;
			if(counter_i==15) counter_j<=counter_j+1;
			for(m=0;m<SIZE_NUM;m=m+1) begin
				if(A_enable[m]==0 && counter_i==m)begin
					if(counter_j==0) A_enable[m]<=1;
				end
				else if(A_enable[m]==1 && counter_i==m)begin
					A_enable[m]<=0;
				end
				if(B_enable[m]==0 && counter_i==m)begin
					if(counter_j==0) B_enable[m]<=1;
				end
				else if(B_enable[m]==1 && counter_i==m)begin
					B_enable[m]<=0;
				end
			end
			for(m=0;m<SIZE_NUM;m=m+1) begin
				if(A_enable[m]==1) begin
					A_input[m]<=input_A[m][counter_A[m]];
					counter_A[m]<=counter_A[m]+1;
				end
				else A_input[m]<=0;

				if(B_enable[m]==1) begin
					B_input[m]<=input_B[counter_B[m]][m];
					counter_B[m]<=counter_B[m]+1;
				end
				else B_input[m]<=0;
			end

		end
		else if(load) begin
			if(counter_j==SIZE_NUM-1)begin
				counter_i<=counter_i+1;
			end
			input_A[counter_i][counter_j]<=A_i;
			input_B[counter_i][counter_j]<=B_i;
			counter_j<=counter_j+1;
		end
		else if(read) begin
			if(counter_j==SIZE_NUM-1)begin
				counter_i<=counter_i+1;
			end
			counter_j<=counter_j+1;
		end
		else begin
			for(m=0;m<SIZE_NUM;m=m+1) begin
				A_enable[m]<=0;
				B_enable[m]<=0;
				counter_A[m]<=0;
				counter_B[m]<=0;
			end
			counter_i<=0;
			counter_j<=0;
		end
	end
	assign result=result_C[counter_i][counter_j];


endmodule


module SAMMM_PE 
  #(parameter DATA_WIDTH=8)(
	input clk,    
	input rst_n,  
	input en,
	input [DATA_WIDTH-1:0] A_i,
	input [DATA_WIDTH-1:0] B_i,
	output reg [DATA_WIDTH-1:0] A_o,
	output reg [DATA_WIDTH-1:0] B_o,
	output reg [2*DATA_WIDTH-1:0] C_o
	
);

	always@(posedge clk or negedge rst_n) begin
		if(!rst_n) begin
			A_o<=0;
			B_o<=0;
			C_o<=0;
		end
		else if(en) begin
			C_o<=C_o+(A_i*B_i);
			A_o<=A_i;
			B_o<=B_i;
		end
		else begin 
			C_o<=C_o;
			A_o<=A_o;
			B_o<=B_o;
		end
	end
endmodule