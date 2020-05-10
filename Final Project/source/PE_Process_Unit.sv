`timescale 1ns/1ps

module PE_Process_Unit #(
    // parameter PE_NUM = 4,
    parameter PE_ID = 0,
    parameter BLOCK_ID = 0,
    parameter KEY_WIDTH = 5,
    parameter DATA_WIDTH = 5,  
    parameter ENTRY_ADDR_WIDTH = 10,
    parameter ENTRY_DATA_WIDTH = 10,  
    parameter OPCODE_WIDTH = 4
)(
    input                                   clk,
    input                                   rst,
    // input                                   flash,

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
    output logic [DATA_WIDTH-1:0]           insert_data_o,
    output logic [ENTRY_ADDR_WIDTH-1:0]     wr_index_o,
    output logic [ENTRY_DATA_WIDTH-1:0]           r_data_o,
  
      // vertical
    input                                   w_en_i,
    input [ENTRY_ADDR_WIDTH-1:0]            w_index_i,
    input [ENTRY_DATA_WIDTH-1:0]            w_data_i,

    output logic                            w_en_o,
    output logic [ENTRY_ADDR_WIDTH-1:0]     w_index_o,
    output logic [ENTRY_DATA_WIDTH-1:0]     w_data_o
);

  /*
    op_valid:
  * opcode: 0000 - nop; 0001 - search; 0010 - insert; 
    res_valid:
  * rescode: 0000 - hash table block 0 owns the entry; 0001 - hash table block 1 owns the entry, et al
  */
  logic res_valid;
  logic [ENTRY_DATA_WIDTH-1:0] r_data;

MEM_Block #(
    .KEY_WIDTH(KEY_WIDTH),
    .DATA_WIDTH (DATA_WIDTH),  
    .ENTRY_ADDR_WIDTH(ENTRY_ADDR_WIDTH),
    .ENTRY_DATA_WIDTH(ENTRY_DATA_WIDTH) 
)
mem_block(
    .clk(clk),
    .wen_a(w_en_i), 
    .rst(rst),
    .key_b_i(key_i),
    .data_a_i(w_data_i),
    .addr_a(w_index_i), 
    .addr_b(wr_index_i),
    .data_b_o(r_data),
    .valid_o(res_valid)
);

// genvar i;
// generate
//     for(i=0;i<PE_NUM;i++) begin
//         if(PE_ID!=BLOCK_ID)begin

//         end
//     end
// endgenerate

//read horizontal
always@(posedge clk or posedge rst)begin
    if(rst) begin
        op_valid_o<=0;
        res_valid_o<=0;
        opcode_o<=0;
        key_o<=0;
        insert_data_o<=0;
        wr_index_o<=0;
        r_data_o<=0;
    end
    // else if(flash) begin
    //     op_valid_o<=0;
    //     res_valid_o<=0;
    //     opcode_o<=0;
    //     key_o<=key_i;
    //     insert_data_o<=insert_data_i;
    //     wr_index_o<=wr_index_i;
    //     r_data_o<=r_data_i;
    // end
    else if(op_valid_i==0 || opcode_i==4'b0000) begin   //nop
        op_valid_o<=0;
        res_valid_o<=0;
        opcode_o<=0;
        key_o<=key_i;
        insert_data_o<=insert_data_i;
        wr_index_o<=wr_index_i;
        r_data_o<=r_data_i;
    end
    else if(op_valid_i==1 && opcode_i==4'b0001) begin   //search
        op_valid_o<=op_valid_i;
        if(res_valid_i==1) begin
            res_valid_o<=res_valid_i;
            r_data_o<=r_data_i;
        end
        else begin
            res_valid_o<=res_valid;
            r_data_o<=r_data;
        end
        opcode_o<=opcode_i;
        key_o<=key_i;
        insert_data_o<=insert_data_i;
        wr_index_o<=wr_index_i;     
        
    end
    else if(op_valid_i==1 && opcode_i==4'b0010) begin   //insert
        op_valid_o<=op_valid_i;
        if(res_valid_i==1) begin
            res_valid_o<=res_valid_i;
            r_data_o<=r_data_i;
        end
        else begin
            res_valid_o<=res_valid;
            r_data_o<=r_data;
        end
        opcode_o<=opcode_i;
        key_o<=key_i;
        insert_data_o<=insert_data_i;
        wr_index_o<=wr_index_i;
        
    end
end

//write vertical
always@(posedge clk or posedge rst)begin
    if(rst) begin
        w_en_o<=0;
        w_index_o<=0;
        w_data_o<=0;
    end
    else begin
        w_en_o<=w_en_i;
        w_index_o<=w_index_i;
        w_data_o<=w_data_i;
    end
      
end

endmodule
