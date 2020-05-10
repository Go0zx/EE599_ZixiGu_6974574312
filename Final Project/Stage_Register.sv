`timescale 1ns/1ps
module Stage_Register 
  #(DATA_WIDTH = 32)
  (
  input  clk,
  input  rst,
  input  flash,
  input  logic[DATA_WIDTH-1:0]  data_i,
  output logic[DATA_WIDTH-1:0]  data_o
  );

  always@(posedge clk) begin
    if (rst) begin
      data_o <= 0;
    end 
    else if(flash) begin
        data_o <= 0;
    end
    else begin
      data_o<= data_i;
    end
  end

endmodule
