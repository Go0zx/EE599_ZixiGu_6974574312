
`timescale 1ns/1ps

module tb_PHT (); /* this is automatically generated */

    parameter PE_NUM = 4;
    parameter KEY_WIDTH = 16;
    parameter DATA_WIDTH = 16;
    parameter ENTRY_ADDR_WIDTH = 10;
    parameter ENTRY_DATA_WIDTH = 32;
    parameter OPCODE_WIDTH = 4;

	logic 								clk;
	logic                               rst;
	logic                  [0:PE_NUM-1] op_valid_i;
	logic     [0:PE_NUM*OPCODE_WIDTH-1] opcode_i;
	logic        [0:PE_NUM*KEY_WIDTH-1] key_i;
	logic       [0:PE_NUM*DATA_WIDTH-1] insert_data_i;
	logic                  [0:PE_NUM-1] op_valid_o;
	logic                  [0:PE_NUM-1] res_valid_o;
	logic     [0:PE_NUM*OPCODE_WIDTH-1] opcode_o;
	logic        [0:PE_NUM*KEY_WIDTH-1] key_o;
	logic 	[0:PE_NUM*DATA_WIDTH-1] r_data_o;


	PHT #(
			.PE_NUM(PE_NUM),
			.KEY_WIDTH(KEY_WIDTH),
			.DATA_WIDTH(DATA_WIDTH),
			.ENTRY_ADDR_WIDTH(ENTRY_ADDR_WIDTH),
			.ENTRY_DATA_WIDTH(ENTRY_DATA_WIDTH),
			.OPCODE_WIDTH(OPCODE_WIDTH)
		) inst_PHT (
			.clk           (clk),
			.rst           (rst),
			.op_valid_i    (op_valid_i),
			.opcode_i      (opcode_i),
			.key_i         (key_i),
			.insert_data_i (insert_data_i),
			.op_valid_o    (op_valid_o),
			.res_valid_o   (res_valid_o),
			.opcode_o      (opcode_o),
			.key_o         (key_o),
			.r_data_o      (r_data_o)
		);

	initial begin
		clk = 0;
		forever #5 clk = ~clk;
	end

	
	initial begin
		rst = 1;
		#20
		rst = 0;
		op_valid_i=4'b0000;
	    opcode_i={		4'b0000,	4'b0000,	4'b0000,	4'b0000};
	    key_i={			16'd0,		16'd0,		16'd0,		16'd0};
	    insert_data_i={	16'd0,		16'd0,		16'd0,		16'd0};
		repeat(5)@(negedge clk);
		op_valid_i=4'b1111;
	    opcode_i={		4'b0010,	4'b0010,	4'b0010,	4'b0010};
	    key_i={			16'd10,		16'd10,		16'd10,		16'd10};
	    insert_data_i={	16'd10,		16'd10,		16'd10,		16'd10};
	    @(negedge clk);
		op_valid_i=4'b1111;
	    opcode_i={		4'b0010,	4'b0010,	4'b0010,	4'b0010};
	    key_i={			16'd10,		16'd20,		16'd30,		16'd40};
	    insert_data_i={	16'd10,		16'd20,		16'd30,		16'd40};
	    @(negedge clk);
	    op_valid_i=4'b1111;
	    opcode_i={		4'b0001,	4'b0001,	4'b0001,	4'b0001};
	    key_i={			16'd10,		16'd0,		16'd40,		16'd100};
	    insert_data_i={	16'd0,		16'd0,		16'd0,		16'd0};
	    @(negedge clk);
	    op_valid_i=4'b1111;
	    opcode_i={		4'b0010,	4'b0010,	4'b0010,	4'b0010};
	    key_i={			16'd40,		16'd30,		16'd20,		16'd10};
	    insert_data_i={	16'd40,		16'd30,		16'd20,		16'd10};
	    @(negedge clk);
	    op_valid_i=4'b1111;
	    opcode_i={		4'b0010,	4'b0010,	4'b0010,	4'b0010};
	    key_i={			16'd50,		16'd60,		16'd70,		16'd80};
	    insert_data_i={	16'd50,		16'd60,		16'd70,		16'd80};
	    @(negedge clk);
	    op_valid_i=4'b1111;
	    opcode_i={		4'b0010,	4'b0010,	4'b0010,	4'b0010};
	    key_i={			16'd100,	16'd200,	16'd300,	16'd400};
	    insert_data_i={	16'd100,	16'd200,	16'd300,	16'd400};
	    @(negedge clk);
	    op_valid_i=4'b1111;
	    opcode_i={		4'b0010,	4'b0010,	4'b0010,	4'b0010};
	    key_i={			16'd500,	16'd600,	16'd700,	16'd800};
	    insert_data_i={	16'd500,	16'd600,	16'd700,	16'd800};
	    @(negedge clk);
	    op_valid_i=4'b0000;
	    opcode_i={		4'b0000,	4'b0000,	4'b0000,	4'b0000};
	    key_i={			16'd0,		16'd0,		16'd0,		16'd0};
	    insert_data_i={	16'd0,		16'd0,		16'd0,		16'd0};
		repeat(10)@(negedge clk);
		op_valid_i=4'b1111;
	    opcode_i={		4'b0001,	4'b0001,	4'b0001,	4'b0001};
	    key_i={			16'd20,		16'd50,		16'd400,	16'd700};
	    insert_data_i={	16'd0,		16'd0,		16'd0,		16'd0};
	    @(negedge clk);
	    op_valid_i=4'b0000;
	    opcode_i={		4'b0000,	4'b0000,	4'b0000,	4'b0000};
	    key_i={			16'd0,		16'd0,		16'd0,		16'd0};
	    insert_data_i={	16'd0,		16'd0,		16'd0,		16'd0};
		repeat(10)@(negedge clk);
		$stop;
	end
	// initial begin
	// 	rst = 1;
	// 	#20
	// 	rst = 0;
	// 	op_valid_i=4'b0000;
	//     opcode_i={		4'b0000,	4'b0000,	4'b0000,	4'b0000};
	//     key_i={			32'd0,		32'd0,		32'd0,		32'd0};
	//     insert_data_i={	32'd0,		32'd0,		32'd0,		32'd0};
	// 	repeat(5)@(negedge clk);
	// 	op_valid_i=4'b1111;
	//     opcode_i={		4'b0010,	4'b0010,	4'b0010,	4'b0010};
	//     key_i={			32'd10,		32'd10,		32'd10,		32'd10};
	//     insert_data_i={	32'd10,		32'd10,		32'd10,		32'd10};
	//     @(negedge clk);
	// 	op_valid_i=4'b1111;
	//     opcode_i={		4'b0010,	4'b0010,	4'b0010,	4'b0010};
	//     key_i={			32'd10,		32'd20,		32'd30,		32'd40};
	//     insert_data_i={	32'd10,		32'd20,		32'd30,		32'd40};
	//     @(negedge clk);
	//     op_valid_i=4'b1111;
	//     opcode_i={		4'b0001,	4'b0001,	4'b0001,	4'b0001};
	//     key_i={			32'd10,		32'd0,		32'd40,		32'd100};
	//     insert_data_i={	32'd0,		32'd0,		32'd0,		32'd0};
	//     @(negedge clk);
	//     op_valid_i=4'b1111;
	//     opcode_i={		4'b0010,	4'b0010,	4'b0010,	4'b0010};
	//     key_i={			32'd40,		32'd30,		32'd20,		32'd10};
	//     insert_data_i={	32'd40,		32'd30,		32'd20,		32'd10};
	//     @(negedge clk);
	//     op_valid_i=4'b1111;
	//     opcode_i={		4'b0010,	4'b0010,	4'b0010,	4'b0010};
	//     key_i={			32'd50,		32'd60,		32'd70,		32'd80};
	//     insert_data_i={	32'd50,		32'd60,		32'd70,		32'd80};
	//     @(negedge clk);
	//     op_valid_i=4'b1111;
	//     opcode_i={		4'b0010,	4'b0010,	4'b0010,	4'b0010};
	//     key_i={			32'd100,	32'd200,	32'd300,	32'd400};
	//     insert_data_i={	32'd100,	32'd200,	32'd300,	32'd400};
	//     @(negedge clk);
	//     op_valid_i=4'b1111;
	//     opcode_i={		4'b0010,	4'b0010,	4'b0010,	4'b0010};
	//     key_i={			32'd500,	32'd600,	32'd700,	32'd800};
	//     insert_data_i={	32'd500,	32'd600,	32'd700,	32'd800};
	//     @(negedge clk);
	//     op_valid_i=4'b0000;
	//     opcode_i={		4'b0000,	4'b0000,	4'b0000,	4'b0000};
	//     key_i={			32'd0,		32'd0,		32'd0,		32'd0};
	//     insert_data_i={	32'd0,		32'd0,		32'd0,		32'd0};
	// 	repeat(10)@(negedge clk);
	// 	op_valid_i=4'b1111;
	//     opcode_i={		4'b0001,	4'b0001,	4'b0001,	4'b0001};
	//     key_i={			32'd20,		32'd50,		32'd400,	32'd700};
	//     insert_data_i={	32'd0,		32'd0,		32'd0,		32'd0};
	//     @(negedge clk);
	//     op_valid_i=4'b0000;
	//     opcode_i={		4'b0000,	4'b0000,	4'b0000,	4'b0000};
	//     key_i={			32'd0,		32'd0,		32'd0,		32'd0};
	//     insert_data_i={	32'd0,		32'd0,		32'd0,		32'd0};
	// 	repeat(10)@(negedge clk);
	// 	$stop;
	// end

	

endmodule
