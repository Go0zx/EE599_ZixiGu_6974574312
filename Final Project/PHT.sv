
`timescale 1ns/1ps

module PHT #(
    parameter PE_NUM = 4,
    parameter KEY_WIDTH = 32,
    parameter DATA_WIDTH = 16,  
    parameter ENTRY_ADDR_WIDTH = 10,
    parameter ENTRY_DATA_WIDTH = 48,  
    parameter OPCODE_WIDTH = 4  
    )(
    input                                           clk,   
    input                                           rst,
    input [0:PE_NUM-1]                              op_valid_i,
    input [0:PE_NUM*OPCODE_WIDTH-1]                 opcode_i,
    input [0:PE_NUM*KEY_WIDTH-1]                    key_i,
    input [0:PE_NUM*DATA_WIDTH-1]                   insert_data_i,

    output [0:PE_NUM-1]                             op_valid_o,
    output [0:PE_NUM-1]                             res_valid_o,
    output [0:PE_NUM*OPCODE_WIDTH-1]                opcode_o,
    output [0:PE_NUM*KEY_WIDTH-1]                   key_o,
    output [0:PE_NUM*DATA_WIDTH-1]                  r_data_o
);

    logic [0:PE_NUM*ENTRY_ADDR_WIDTH-1]             hash_value;
    //hash unit horizontal interconnect
    logic [0:PE_NUM-1]                              hu_op_valid_1, hu_op_valid_2;
    logic [0:PE_NUM*OPCODE_WIDTH-1]                 hu_opcode_1, hu_opcode_2;
    logic [0:PE_NUM*KEY_WIDTH-1]                    hu_key_1, hu_key_2;
    logic [0:PE_NUM*DATA_WIDTH-1]                   hu_insert_data_1, hu_insert_data_2;
    logic [0:PE_NUM-1]                              hu_stage2_flash_en;
    logic [0:PE_NUM-1]                              hu_res_valid_o;
    logic [0:PE_NUM-1][0:ENTRY_DATA_WIDTH-1]        hu_r_data_o;

    //process unit horizontal interconnect
    logic [0:PE_NUM-1][0:PE_NUM-1]                  pu_op_valid;
    logic [0:PE_NUM-1][0:PE_NUM-1]                  pu_res_valid;
    logic [0:PE_NUM-1][0:PE_NUM*OPCODE_WIDTH-1]     pu_opcode;
    logic [0:PE_NUM-1][0:PE_NUM*KEY_WIDTH-1]        pu_key_i;
    logic [0:PE_NUM-1][0:PE_NUM*DATA_WIDTH-1]       pu_insert_data;
    logic [0:PE_NUM-1][0:PE_NUM*ENTRY_ADDR_WIDTH-1] pu_wr_index;
    logic [0:PE_NUM-1][0:PE_NUM*ENTRY_DATA_WIDTH-1] pu_r_data;
    //process unit vertical interconnect

    logic [0:PE_NUM-1][0:PE_NUM-1]                  pu_w_en;
    logic [0:PE_NUM-1][0:PE_NUM*ENTRY_ADDR_WIDTH-1] pu_w_index;
    logic [0:PE_NUM-1][0:PE_NUM*ENTRY_DATA_WIDTH-1] pu_w_data;    
    //result unit horizontal interconnect
    logic [0:PE_NUM-1]                              ru_op_valid;
    logic [0:PE_NUM-1]                              ru_res_valid;
    logic [0:PE_NUM*OPCODE_WIDTH-1]                 ru_opcode;
    logic [0:PE_NUM*KEY_WIDTH-1]                    ru_key;
    logic [0:PE_NUM*DATA_WIDTH-1]                   ru_r_data;

    //result unit vertical interconnect
    logic [0:PE_NUM-1]                              ru_w_en;
    logic [0:PE_NUM*ENTRY_ADDR_WIDTH-1]             ru_w_index;
    logic [0:PE_NUM*ENTRY_DATA_WIDTH-1]             ru_w_data;


    //operation check
    logic [0:PE_NUM-1][0:PE_NUM+3]                  insert_op_check;
    logic [0:PE_NUM-1][0:PE_NUM*(PE_NUM+2)-1]       WAW_key_check;
    logic [0:PE_NUM-1][0:PE_NUM-1]                  WAW_ini_key_check;
    logic [0:PE_NUM-1]                              WAW_ini_flash_check;

    logic [0:PE_NUM-1][0:PE_NUM+3]                  search_op_check;
    logic [0:PE_NUM-1][0:PE_NUM*(PE_NUM+2)-1]       RAW_key_check;
    logic [0:PE_NUM-1][0:PE_NUM+1]                  RAW_Forward_en;
    logic [0:PE_NUM-1][0:(PE_NUM+2)*ENTRY_DATA_WIDTH-1] RAW_Forward_data;


    //forwarding data select
    logic [0:PE_NUM-1][0:PE_NUM+1]           res_valid_i;
    logic [0:PE_NUM-1][0:(PE_NUM+2)*ENTRY_DATA_WIDTH-1] r_data_i;

    integer m;
    genvar i,j,k;
    generate
        for(i=0;i<PE_NUM;i++)begin

            PE_Hashing_Unit #(
                .KEY_WIDTH(KEY_WIDTH),
                .ENTRY_ADDR_WIDTH(ENTRY_ADDR_WIDTH)) 
            PE_hu(
                .clk(clk),
                .rst(rst),
                .key(key_i[i*KEY_WIDTH+:KEY_WIDTH]),
                .hash_value(hash_value[i*ENTRY_ADDR_WIDTH+:ENTRY_ADDR_WIDTH]));
            Stage_Register #(.DATA_WIDTH(1))            
            PE_hu_stage1_1(
                .clk(clk),
                .rst(rst),
                .flash(),
                .data_i(op_valid_i[i]), 
                .data_o(hu_op_valid_1[i]));
            Stage_Register #(.DATA_WIDTH(OPCODE_WIDTH)) 
            PE_hu_stage1_2(
                .clk(clk),
                .rst(rst),
                .flash(),
                .data_i(opcode_i[i*OPCODE_WIDTH+:OPCODE_WIDTH]), 
                .data_o(hu_opcode_1[i*OPCODE_WIDTH+:OPCODE_WIDTH]));
            Stage_Register #(.DATA_WIDTH(KEY_WIDTH))    
            PE_hu_stage1_3(
                .clk(clk),
                .rst(rst),
                .flash(),
                .data_i(key_i[i*KEY_WIDTH+:KEY_WIDTH]), 
                .data_o(hu_key_1[i*KEY_WIDTH+:KEY_WIDTH]));
            Stage_Register #(.DATA_WIDTH(DATA_WIDTH))   
            PE_hu_stage1_4(
                .clk(clk),
                .rst(rst),
                .flash(),
                .data_i(insert_data_i[i*DATA_WIDTH+:DATA_WIDTH]), 
                .data_o(hu_insert_data_1[i*DATA_WIDTH+:DATA_WIDTH]));


            Stage_Register #(.DATA_WIDTH(1))   
            PE_hu_stage2_1(
                .clk(clk),
                .rst(rst),
                .flash(hu_stage2_flash_en[i]),
                .data_i(hu_op_valid_1[i]), 
                .data_o(hu_op_valid_2[i]));
            Stage_Register #(.DATA_WIDTH(OPCODE_WIDTH)) 
            PE_hu_stage2_2(
                .clk(clk),
                .rst(rst),
                .flash(hu_stage2_flash_en[i]),
                .data_i(hu_opcode_1[i*OPCODE_WIDTH+:OPCODE_WIDTH]), 
                .data_o(hu_opcode_2[i*OPCODE_WIDTH+:OPCODE_WIDTH]));
            Stage_Register #(.DATA_WIDTH(KEY_WIDTH))    
            PE_hu_stage2_3(
                .clk(clk),
                .rst(rst),
                .flash(),
                .data_i(hu_key_1[i*KEY_WIDTH+:KEY_WIDTH]), 
                .data_o(hu_key_2[i*KEY_WIDTH+:KEY_WIDTH]));
            Stage_Register #(.DATA_WIDTH(DATA_WIDTH))   
            PE_hu_stage2_4(
                .clk(clk),
                .rst(rst),
                .flash(),
                .data_i(hu_insert_data_1[i*DATA_WIDTH+:DATA_WIDTH]), 
                .data_o(hu_insert_data_2[i*DATA_WIDTH+:DATA_WIDTH]));


            Stage_Register #(.DATA_WIDTH(1))            
            PE_hu_stage2_5(
                .clk(clk),
                .rst(rst),
                .flash(hu_stage2_flash_en[i]),
                .data_i(res_valid_i[i][0]), 
                .data_o(hu_res_valid_o[i]));


            Stage_Register #(.DATA_WIDTH(ENTRY_DATA_WIDTH))   
            PE_hu_stage2_6(
                .clk(clk),
                .rst(rst),
                .flash(),
                .data_i(r_data_i[i][0*ENTRY_DATA_WIDTH+:ENTRY_DATA_WIDTH]), 
                .data_o(hu_r_data_o[i]));
           
            for(j=0;j<PE_NUM;j++)begin
                if(j==0 && i==0)begin    //master
                    PE_Process_Unit #(
                        // .PE_NUM(PE_NUM),
                        .PE_ID(i),
                        .BLOCK_ID (j),
                        .KEY_WIDTH(KEY_WIDTH),
                        .DATA_WIDTH(DATA_WIDTH),  
                        .ENTRY_ADDR_WIDTH(ENTRY_ADDR_WIDTH),
                        .ENTRY_DATA_WIDTH(ENTRY_DATA_WIDTH),  
                        .OPCODE_WIDTH(OPCODE_WIDTH))
                    PE_pu(
                        //control signal
                        .clk(clk),
                        .rst(rst),
                        // .flash(),

                        // horizontal singal
                        .op_valid_i(hu_op_valid_2[i]),
                        .res_valid_i(res_valid_i[i][j+1]),
                        .opcode_i(hu_opcode_2[i*OPCODE_WIDTH+:OPCODE_WIDTH]),
                        .key_i(hu_key_2[i*KEY_WIDTH+:KEY_WIDTH]),
                        .insert_data_i(hu_insert_data_2[i*DATA_WIDTH+:DATA_WIDTH]),
                        .wr_index_i(hash_value[i*ENTRY_ADDR_WIDTH+:ENTRY_ADDR_WIDTH]),
                        .r_data_i(r_data_i[i][(j+1)*ENTRY_DATA_WIDTH+:ENTRY_DATA_WIDTH]),

                        .op_valid_o(pu_op_valid[i][0]),
                        .res_valid_o(pu_res_valid[i][0]),
                        .opcode_o(pu_opcode[i][j*OPCODE_WIDTH+:OPCODE_WIDTH]),
                        .key_o(pu_key_i[i][j*KEY_WIDTH+:KEY_WIDTH]),
                        .insert_data_o(pu_insert_data[i][j*DATA_WIDTH+:DATA_WIDTH]),
                        .wr_index_o(pu_wr_index[i][j*ENTRY_ADDR_WIDTH+:ENTRY_ADDR_WIDTH]),
                        .r_data_o(pu_r_data[i][j*ENTRY_DATA_WIDTH+:ENTRY_DATA_WIDTH]),
                        
                        // vertical singal
                        .w_en_i(ru_w_en[i]),
                        .w_index_i(ru_w_index[i*ENTRY_ADDR_WIDTH+:ENTRY_ADDR_WIDTH]),
                        .w_data_i(ru_w_data[i*ENTRY_DATA_WIDTH+:ENTRY_DATA_WIDTH]),

                        .w_en_o(pu_w_en[i][j]),
                        .w_index_o(pu_w_index[i][j*ENTRY_ADDR_WIDTH+:ENTRY_ADDR_WIDTH]),
                        .w_data_o(pu_w_data[i][j*ENTRY_DATA_WIDTH+:ENTRY_DATA_WIDTH]));    
                end
                else if (j==0 && i!=0)begin
                    PE_Process_Unit #(
                        // .PE_NUM(PE_NUM),
                        .PE_ID(i),
                        .BLOCK_ID (j),
                        .KEY_WIDTH(KEY_WIDTH),
                        .DATA_WIDTH(DATA_WIDTH),  
                        .ENTRY_ADDR_WIDTH(ENTRY_ADDR_WIDTH),
                        .ENTRY_DATA_WIDTH(ENTRY_DATA_WIDTH),  
                        .OPCODE_WIDTH(OPCODE_WIDTH))
                    PE_pu(
                        //control signal
                        .clk(clk),
                        .rst(rst),
                        // .flash(),

                        // horizontal singal
                        .op_valid_i(hu_op_valid_2[i]),
                        .res_valid_i(res_valid_i[i][j+1]),
                        .opcode_i(hu_opcode_2[i*OPCODE_WIDTH+:OPCODE_WIDTH]),
                        .key_i(hu_key_2[i*KEY_WIDTH+:KEY_WIDTH]),
                        .insert_data_i(hu_insert_data_2[i*DATA_WIDTH+:DATA_WIDTH]),
                        .wr_index_i(hash_value[i*ENTRY_ADDR_WIDTH+:ENTRY_ADDR_WIDTH]),
                        .r_data_i(r_data_i[i][(j+1)*ENTRY_DATA_WIDTH+:ENTRY_DATA_WIDTH]),

                        .op_valid_o(pu_op_valid[i][j]),
                        .res_valid_o(pu_res_valid[i][j]),
                        .opcode_o(pu_opcode[i][j*OPCODE_WIDTH+:OPCODE_WIDTH]),
                        .key_o(pu_key_i[i][j*KEY_WIDTH+:KEY_WIDTH]),
                        .insert_data_o(pu_insert_data[i][j*DATA_WIDTH+:DATA_WIDTH]),
                        .wr_index_o(pu_wr_index[i][j*ENTRY_ADDR_WIDTH+:ENTRY_ADDR_WIDTH]),
                        .r_data_o(pu_r_data[i][j*ENTRY_DATA_WIDTH+:ENTRY_DATA_WIDTH]),
                        
                        // vertical singal
                        .w_en_i(pu_w_en[i-1][j]),
                        .w_index_i(pu_w_index[i-1][j*ENTRY_ADDR_WIDTH+:ENTRY_ADDR_WIDTH]),
                        .w_data_i(pu_w_data[i-1][j*ENTRY_DATA_WIDTH+:ENTRY_DATA_WIDTH]),

                        .w_en_o(pu_w_en[i][j]),
                        .w_index_o(pu_w_index[i][j*ENTRY_ADDR_WIDTH+:ENTRY_ADDR_WIDTH]),
                        .w_data_o(pu_w_data[i][j*ENTRY_DATA_WIDTH+:ENTRY_DATA_WIDTH]));    
                end
                else if (j!=0 && i==0)begin
                    PE_Process_Unit #(
                        // .PE_NUM(PE_NUM),
                        .PE_ID(i),
                        .BLOCK_ID (j),
                        .KEY_WIDTH(KEY_WIDTH),
                        .DATA_WIDTH(DATA_WIDTH),  
                        .ENTRY_ADDR_WIDTH(ENTRY_ADDR_WIDTH),
                        .ENTRY_DATA_WIDTH(ENTRY_DATA_WIDTH),  
                        .OPCODE_WIDTH(OPCODE_WIDTH))
                    PE_pu(
                        //control signal
                        .clk(clk),
                        .rst(rst),
                        // .flash(),

                        // horizontal singal
                        .op_valid_i(pu_op_valid[i][j-1]),
                        .res_valid_i(res_valid_i[i][j+1]),
                        .opcode_i(pu_opcode[i][(j-1)*OPCODE_WIDTH+:OPCODE_WIDTH]),
                        .key_i(pu_key_i[i][(j-1)*KEY_WIDTH+:KEY_WIDTH]),
                        .insert_data_i(pu_insert_data[i][(j-1)*DATA_WIDTH+:DATA_WIDTH]),
                        .wr_index_i(pu_wr_index[i][(j-1)*ENTRY_ADDR_WIDTH+:ENTRY_ADDR_WIDTH]),
                        .r_data_i(r_data_i[i][(j+1)*ENTRY_DATA_WIDTH+:ENTRY_DATA_WIDTH]),


                        .op_valid_o(pu_op_valid[i][j]),
                        .res_valid_o(pu_res_valid[i][j]),
                        .opcode_o(pu_opcode[i][j*OPCODE_WIDTH+:OPCODE_WIDTH]),
                        .key_o(pu_key_i[i][j*KEY_WIDTH+:KEY_WIDTH]),
                        .insert_data_o(pu_insert_data[i][j*DATA_WIDTH+:DATA_WIDTH]),
                        .wr_index_o(pu_wr_index[i][j*ENTRY_ADDR_WIDTH+:ENTRY_ADDR_WIDTH]),
                        .r_data_o(pu_r_data[i][j*ENTRY_DATA_WIDTH+:ENTRY_DATA_WIDTH]),
                        
                        // vertical singal
                        .w_en_i(pu_w_en[PE_NUM-1][j]),
                        .w_index_i(pu_w_index[PE_NUM-1][j*ENTRY_ADDR_WIDTH+:ENTRY_ADDR_WIDTH]),
                        .w_data_i(pu_w_data[PE_NUM-1][j*ENTRY_DATA_WIDTH+:ENTRY_DATA_WIDTH]),

                        .w_en_o(pu_w_en[i][j]),
                        .w_index_o(pu_w_index[i][j*ENTRY_ADDR_WIDTH+:ENTRY_ADDR_WIDTH]),
                        .w_data_o(pu_w_data[i][j*ENTRY_DATA_WIDTH+:ENTRY_DATA_WIDTH]));    
                end
                else if(i==j) begin         //master
                        PE_Process_Unit #(
                        // .PE_NUM(PE_NUM),
                        .PE_ID(i),
                        .BLOCK_ID (j),
                        .KEY_WIDTH(KEY_WIDTH),
                        .DATA_WIDTH(DATA_WIDTH),  
                        .ENTRY_ADDR_WIDTH(ENTRY_ADDR_WIDTH),
                        .ENTRY_DATA_WIDTH(ENTRY_DATA_WIDTH),  
                        .OPCODE_WIDTH(OPCODE_WIDTH))
                    PE_pu(
                        //control signal
                        .clk(clk),
                        .rst(rst),
                        // .flash(),

                        // horizontal singal
                        .op_valid_i(pu_op_valid[i][j-1]),
                        .res_valid_i(res_valid_i[i][j+1]),
                        .opcode_i(pu_opcode[i][(j-1)*OPCODE_WIDTH+:OPCODE_WIDTH]),
                        .key_i(pu_key_i[i][(j-1)*KEY_WIDTH+:KEY_WIDTH]),
                        .insert_data_i(pu_insert_data[i][(j-1)*DATA_WIDTH+:DATA_WIDTH]),
                        .wr_index_i(pu_wr_index[i][(j-1)*ENTRY_ADDR_WIDTH+:ENTRY_ADDR_WIDTH]),
                        .r_data_i(r_data_i[i][(j+1)*ENTRY_DATA_WIDTH+:ENTRY_DATA_WIDTH]),

                        .op_valid_o(pu_op_valid[i][j]),
                        .res_valid_o(pu_res_valid[i][j]),
                        .opcode_o(pu_opcode[i][j*OPCODE_WIDTH+:OPCODE_WIDTH]),
                        .key_o(pu_key_i[i][j*KEY_WIDTH+:KEY_WIDTH]),
                        .insert_data_o(pu_insert_data[i][j*DATA_WIDTH+:DATA_WIDTH]),
                        .wr_index_o(pu_wr_index[i][j*ENTRY_ADDR_WIDTH+:ENTRY_ADDR_WIDTH]),
                        .r_data_o(pu_r_data[i][j*ENTRY_DATA_WIDTH+:ENTRY_DATA_WIDTH]),
                        
                        // vertical singal
                        .w_en_i(ru_w_en[i]),
                        .w_index_i(ru_w_index[i*ENTRY_ADDR_WIDTH+:ENTRY_ADDR_WIDTH]),
                        .w_data_i(ru_w_data[i*ENTRY_DATA_WIDTH+:ENTRY_DATA_WIDTH]),

                        .w_en_o(pu_w_en[i][j]),
                        .w_index_o(pu_w_index[i][j*ENTRY_ADDR_WIDTH+:ENTRY_ADDR_WIDTH]),
                        .w_data_o(pu_w_data[i][j*ENTRY_DATA_WIDTH+:ENTRY_DATA_WIDTH]));   
                end
                else if(i!=j) begin
                        PE_Process_Unit #(
                        // .PE_NUM(PE_NUM),
                        .PE_ID(i),
                        .BLOCK_ID (j),
                        .KEY_WIDTH(KEY_WIDTH),
                        .DATA_WIDTH(DATA_WIDTH),  
                        .ENTRY_ADDR_WIDTH(ENTRY_ADDR_WIDTH),
                        .ENTRY_DATA_WIDTH(ENTRY_DATA_WIDTH),  
                        .OPCODE_WIDTH(OPCODE_WIDTH))
                    PE_pu(
                        //control signal
                        .clk(clk),
                        .rst(rst),
                        // .flash(),

                        // horizontal singal
                        .op_valid_i(pu_op_valid[i][j-1]),
                        .res_valid_i(res_valid_i[i][j+1]),
                        .opcode_i(pu_opcode[i][(j-1)*OPCODE_WIDTH+:OPCODE_WIDTH]),
                        .key_i(pu_key_i[i][(j-1)*KEY_WIDTH+:KEY_WIDTH]),
                        .insert_data_i(pu_insert_data[i][(j-1)*DATA_WIDTH+:DATA_WIDTH]),
                        .wr_index_i(pu_wr_index[i][(j-1)*ENTRY_ADDR_WIDTH+:ENTRY_ADDR_WIDTH]),
                        .r_data_i(r_data_i[i][(j+1)*ENTRY_DATA_WIDTH+:ENTRY_DATA_WIDTH]),

                        .op_valid_o(pu_op_valid[i][j]),
                        .res_valid_o(pu_res_valid[i][j]),
                        .opcode_o(pu_opcode[i][j*OPCODE_WIDTH+:OPCODE_WIDTH]),
                        .key_o(pu_key_i[i][j*KEY_WIDTH+:KEY_WIDTH]),
                        .insert_data_o(pu_insert_data[i][j*DATA_WIDTH+:DATA_WIDTH]),
                        .wr_index_o(pu_wr_index[i][j*ENTRY_ADDR_WIDTH+:ENTRY_ADDR_WIDTH]),
                        .r_data_o(pu_r_data[i][j*ENTRY_DATA_WIDTH+:ENTRY_DATA_WIDTH]),
                        
                        // vertical singal
                        .w_en_i(pu_w_en[i-1][j]),
                        .w_index_i(pu_w_index[i-1][j*ENTRY_ADDR_WIDTH+:ENTRY_ADDR_WIDTH]),
                        .w_data_i(pu_w_data[i-1][j*ENTRY_DATA_WIDTH+:ENTRY_DATA_WIDTH]),

                        .w_en_o(pu_w_en[i][j]),
                        .w_index_o(pu_w_index[i][j*ENTRY_ADDR_WIDTH+:ENTRY_ADDR_WIDTH]),
                        .w_data_o(pu_w_data[i][j*ENTRY_DATA_WIDTH+:ENTRY_DATA_WIDTH]));    

                end
                
            end
             

            PE_Result_Unit #(
                .KEY_WIDTH(KEY_WIDTH),
                .DATA_WIDTH(DATA_WIDTH),  
                .ENTRY_ADDR_WIDTH(ENTRY_ADDR_WIDTH),
                .ENTRY_DATA_WIDTH(ENTRY_DATA_WIDTH),  
                .OPCODE_WIDTH(OPCODE_WIDTH))
            PE_ru(
                .clk(clk),
                .rst(rst),

                 // horizontal
                .op_valid_i(pu_op_valid[i][PE_NUM-1]),
                .res_valid_i(res_valid_i[i][PE_NUM+1]),
                .opcode_i(pu_opcode[i][(PE_NUM-1)*OPCODE_WIDTH+:OPCODE_WIDTH]),
                .key_i(pu_key_i[i][(PE_NUM-1)*KEY_WIDTH+:KEY_WIDTH]),
                .insert_data_i(pu_insert_data[i][(PE_NUM-1)*DATA_WIDTH+:DATA_WIDTH]),
                .wr_index_i(pu_wr_index[i][(PE_NUM-1)*ENTRY_ADDR_WIDTH+:ENTRY_ADDR_WIDTH]),
                .r_data_i(r_data_i[i][(PE_NUM+1)*ENTRY_DATA_WIDTH+:ENTRY_DATA_WIDTH]),

                .op_valid_o(ru_op_valid[i]),
                .res_valid_o(ru_res_valid[i]),
                .opcode_o(ru_opcode[i*OPCODE_WIDTH+:OPCODE_WIDTH]),
                .key_o(ru_key[i*KEY_WIDTH+:KEY_WIDTH]),
                .r_data_o(ru_r_data[i*DATA_WIDTH+:DATA_WIDTH]),
              
                // vertical
                .w_en_o(ru_w_en[i]),
                .w_index_o(ru_w_index[i*ENTRY_ADDR_WIDTH+:ENTRY_ADDR_WIDTH]),
                .w_data_o(ru_w_data[i*ENTRY_DATA_WIDTH+:ENTRY_DATA_WIDTH]));

        end
    endgenerate



    // op_valid_i[i]
    // opcode_i[i*OPCODE_WIDTH+:OPCODE_WIDTH]
    // key_i[i*KEY_WIDTH+:KEY_WIDTH]

    // hu_op_valid_1[i]
    // hu_opcode_1[i*OPCODE_WIDTH+:OPCODE_WIDTH]
    // hu_key_1[i*KEY_WIDTH+:KEY_WIDTH]

    // hu_op_valid_2[i]
    // hu_opcode_2[i*OPCODE_WIDTH+:OPCODE_WIDTH]
    // hu_key_2[i*KEY_WIDTH+:KEY_WIDTH]

    // pu_op_valid[i][j]
    // pu_opcode[i][j*OPCODE_WIDTH+:OPCODE_WIDTH]
    // pu_key_i[i][j*KEY_WIDTH+:KEY_WIDTH]


    
    generate
        for(i=0;i<PE_NUM;i++) begin
            assign insert_op_check[i][0] = op_valid_i[i]==1'b1 && opcode_i[i*OPCODE_WIDTH+:OPCODE_WIDTH]==4'b0010 ? 1:0;
            assign insert_op_check[i][1] = hu_op_valid_1[i]==1'b1 && hu_opcode_1[i*OPCODE_WIDTH+:OPCODE_WIDTH]==4'b0010 ? 1:0;
            assign insert_op_check[i][2] = hu_op_valid_2[i]==1'b1 &&hu_opcode_2[i*OPCODE_WIDTH+:OPCODE_WIDTH]==4'b0010 ? 1:0;
            for(j=3;j<PE_NUM+3;j++) begin
                assign insert_op_check[i][j] = pu_op_valid[i][j-3] && pu_opcode[i][(j-3)*OPCODE_WIDTH+:OPCODE_WIDTH]==4'b0010 ? 1:0;
            end
            assign insert_op_check[i][PE_NUM+3] = ru_op_valid[i] && ru_opcode[i*OPCODE_WIDTH+:OPCODE_WIDTH]==4'b0010 ? 1:0;
        end
    endgenerate


    generate
        for(i=0;i<PE_NUM;i++) begin
            assign search_op_check[i][0] = op_valid_i[i]==1'b1 && opcode_i[i*OPCODE_WIDTH+:OPCODE_WIDTH]==4'b0001 ? 1:0;
            assign search_op_check[i][1] = hu_op_valid_1[i]==1'b1 && hu_opcode_1[i*OPCODE_WIDTH+:OPCODE_WIDTH]==4'b0001 ? 1:0;
            assign search_op_check[i][2] = hu_op_valid_2[i]==1'b1 &&hu_opcode_2[i*OPCODE_WIDTH+:OPCODE_WIDTH]==4'b0001 ? 1:0;
            for(j=3;j<PE_NUM+3;j++) begin
                assign search_op_check[i][j] = pu_op_valid[i][j-3] && pu_opcode[i][(j-3)*OPCODE_WIDTH+:OPCODE_WIDTH]==4'b0001 ? 1:0;
            end
            assign search_op_check[i][PE_NUM+3] = ru_op_valid[i] && ru_opcode[i*OPCODE_WIDTH+:OPCODE_WIDTH]==4'b0001 ? 1:0;
        end
    endgenerate

    //RAW Control 
     generate
        for(i=0;i<PE_NUM;i++) begin
            for(k=0;k<PE_NUM;k++) begin
                assign RAW_key_check[i][k*(PE_NUM+2)+0]=insert_op_check[i][PE_NUM+3]==1'b1&&search_op_check[k][1]==1'b1&&ru_key[i*KEY_WIDTH+:KEY_WIDTH]==hu_key_1[k*KEY_WIDTH+:KEY_WIDTH] ? 1:0;
            end
            for(k=0;k<PE_NUM;k++) begin
                assign RAW_key_check[i][k*(PE_NUM+2)+1]=insert_op_check[i][PE_NUM+3]==1'b1&&search_op_check[k][2]==1'b1&&ru_key[i*KEY_WIDTH+:KEY_WIDTH]==hu_key_2[k*KEY_WIDTH+:KEY_WIDTH] ? 1:0;
            end
            
            for(j=3;j<PE_NUM+3;j++) begin
                 for(k=0;k<PE_NUM;k++) begin
                    assign RAW_key_check[i][k*(PE_NUM+2)+j-1]=insert_op_check[i][PE_NUM+3]==1'b1&&search_op_check[k][j]==1'b1&&ru_key[i*KEY_WIDTH+:KEY_WIDTH]==pu_key_i[i][(j-3)*KEY_WIDTH+:KEY_WIDTH] ? 1:0;
                end
            end
        end
    endgenerate

     generate
        for(i=0;i<PE_NUM;i++) begin
            for(j=0;j<PE_NUM+2;j++) begin
                assign RAW_Forward_en[i][j]= RAW_key_check[i][i*(PE_NUM+2)+j]==1'b1 ? 1:0;
                assign RAW_Forward_data[i][j*ENTRY_DATA_WIDTH+:ENTRY_DATA_WIDTH]={ru_w_data[i*ENTRY_DATA_WIDTH+:ENTRY_DATA_WIDTH]};
            end
        end
    endgenerate


    generate
        for(i=0;i<PE_NUM;i++)begin
            for(j=0;j<PE_NUM+2;j++) begin
                if(j==0) begin
                    assign res_valid_i[i][j]= RAW_Forward_en[i][j]==1'b1 ? 1 :0;
                    assign r_data_i[i][j*ENTRY_DATA_WIDTH+:ENTRY_DATA_WIDTH]= RAW_Forward_en[i][j]==1'b1 ? RAW_Forward_data[i][j*ENTRY_DATA_WIDTH+:ENTRY_DATA_WIDTH]:0;
                end
                else if(j==1)begin
                    assign res_valid_i[i][j]= RAW_Forward_en[i][j]==1'b1 ? 1 : hu_res_valid_o[i];
                    assign r_data_i[i][j*ENTRY_DATA_WIDTH+:ENTRY_DATA_WIDTH]= RAW_Forward_en[i][j]==1'b1 ? RAW_Forward_data[i][j*ENTRY_DATA_WIDTH+:ENTRY_DATA_WIDTH]:hu_r_data_o[i];
                end
                else begin
                    assign res_valid_i[i][j]= RAW_Forward_en[i][j]==1'b1 ? 1 : pu_res_valid[i][j-2];
                    assign r_data_i[i][j*ENTRY_DATA_WIDTH+:ENTRY_DATA_WIDTH]= RAW_Forward_en[i][j]==1'b1 ? RAW_Forward_data[i][j*ENTRY_DATA_WIDTH+:ENTRY_DATA_WIDTH]:pu_r_data[i][(j-2)*ENTRY_DATA_WIDTH+:ENTRY_DATA_WIDTH];
                end
            end
        end
    endgenerate

 

    //WAW Control
    generate
        for(i=0;i<PE_NUM;i++) begin
           
            // assign WAW_key_check[i][0]=0;
            // for(k=0;k<PE_NUM;k++) begin
            //     if(k!=i)begin
            //           assign WAW_key_check[i][k*(PEM_NUM+3)]=insert_op_check[i][0]==1'b1&&insert_op_check[k][0]==1'b1&&key_i[i*KEY_WIDTH+:KEY_WIDTH]==key_i[k*KEY_WIDTH+:KEY_WIDTH] ? 1:0;
            //     end
            // end
            for(k=0;k<PE_NUM;k++) begin
                assign WAW_key_check[i][k*(PE_NUM+2)+0]=insert_op_check[i][0]==1'b1&&insert_op_check[k][1]==1'b1&&key_i[i*KEY_WIDTH+:KEY_WIDTH]==hu_key_1[k*KEY_WIDTH+:KEY_WIDTH] ? 1:0;
            end
            for(k=0;k<PE_NUM;k++) begin
                assign WAW_key_check[i][k*(PE_NUM+2)+1]=insert_op_check[i][0]==1'b1&&insert_op_check[k][2]==1'b1&&key_i[i*KEY_WIDTH+:KEY_WIDTH]==hu_key_2[k*KEY_WIDTH+:KEY_WIDTH] ? 1:0;
            end
            
            for(j=3;j<PE_NUM+3;j++) begin
                 for(k=0;k<PE_NUM;k++) begin
                    assign WAW_key_check[i][k*(PE_NUM+2)+j-1]=insert_op_check[i][0]==1'b1&&insert_op_check[k][j]==1'b1&&key_i[i*KEY_WIDTH+:KEY_WIDTH]==pu_key_i[i][(j-3)*KEY_WIDTH+:KEY_WIDTH] ? 1:0;
                end
            end
        end
    endgenerate


    generate
        for(i=0;i<PE_NUM;i++) begin
            for(j=0;j<PE_NUM;j++) begin
                if(i!=j)begin
                    assign WAW_ini_key_check[i][j] = insert_op_check[i][0]==1'b1&&insert_op_check[j][0]==1'b1&&key_i[i*KEY_WIDTH+:KEY_WIDTH]==key_i[j*KEY_WIDTH+:KEY_WIDTH] ? 1:0;
                end
                else begin
                    assign WAW_ini_key_check[i][j] = 0;
                end
            end
        end
    endgenerate
    

    generate
        for(i=0;i<PE_NUM;i++) begin
            always@(posedge clk) begin
                if(rst)begin
                    hu_stage2_flash_en[i]<= 0;
                end
                else begin
                    hu_stage2_flash_en[i]<= (|WAW_key_check[i]) |WAW_ini_flash_check[i];
                end
            end
        end
    endgenerate


    generate
        for(i=PE_NUM-1;i>=0;i--) begin
            if(i==PE_NUM-1) begin
                assign WAW_ini_flash_check[i] = |WAW_ini_key_check[i];
            end
            else if(i==0) begin
                assign WAW_ini_flash_check[i] = 0;
            end
            else begin
                assign WAW_ini_flash_check[i] = |((~WAW_ini_flash_check) & WAW_ini_key_check[i]);
            end
        end
    endgenerate
   

    assign  op_valid_o=ru_op_valid;
    assign  res_valid_o=ru_res_valid;
    assign  opcode_o=ru_opcode;
    assign  key_o=ru_key;
    assign  r_data_o=ru_r_data;




endmodule