`timescale 1ns / 1ps

`include "defines.vh"

module issue(
  clk,
  flush,
  free,

  if_id_instruction1,
  if_id_mem_op1,

  instruction0_in,
  instruction1_in,

  push0,
  push1,

  //////////////

  stall_out,

  //////////////

  branch_taken0_in,
  branch_taken1_in,

  branch_taken_address0_in,
  branch_taken_address1_in,

  pc0_in,
  pc1_in,

  id0_in,
  id1_in,

  //////////////

  instruction0_out,
  instruction1_out,

  pc0_out,
  pc1_out,

  id0_out,
  id1_out,

  branch_taken0_out,
  branch_taken1_out,


  branch_taken_address0_out,
  branch_taken_address1_out,

  first
  
  );

  input wire clk;
  input wire flush;

  input wire [`INST_WIDTH-1:0] if_id_instruction1;
  input wire [`MEM_OP_BITS-1:0] if_id_mem_op1;

  input wire [`INST_WIDTH-1:0] instruction0_in;
  input wire [`INST_WIDTH-1:0] instruction1_in;

  input wire push0;
  input wire push1;

  //////////////

  wire stall;
  output wire stall_out;

  //////////////

  input wire branch_taken0_in;
  input wire branch_taken1_in;

  input wire [`ADDR_WIDTH-1:0] branch_taken_address0_in;
  input wire [`ADDR_WIDTH-1:0] branch_taken_address1_in;

  input wire [`ADDR_WIDTH-1:0] pc0_in;
  input wire [`ADDR_WIDTH-1:0] pc1_in;

  input wire [`INSTRUCTION_ID_WIDTH-1:0] id0_in;
  input wire [`INSTRUCTION_ID_WIDTH-1:0] id1_in;

  //////////////

  output reg branch_taken0_out;
  output reg branch_taken1_out;

  output reg [`ADDR_WIDTH-1:0] branch_taken_address0_out;
  output reg [`ADDR_WIDTH-1:0] branch_taken_address1_out;

  output reg [`ADDR_WIDTH-1:0] pc0_out;
  output reg [`ADDR_WIDTH-1:0] pc1_out;

  output reg [`INSTRUCTION_ID_WIDTH-1:0] id0_out;
  output reg [`INSTRUCTION_ID_WIDTH-1:0] id1_out;

  output reg [`INST_WIDTH-1:0] instruction0_out;
  output reg [`INST_WIDTH-1:0] instruction1_out;

  output wire first;

  //////////////

  wire load_stall;
  wire split_stall;
  wire steer_stall;
  
  wire [1:0] load_vld_mask;
  wire [1:0] split_vld_mask;
  wire [1:0] steer_vld_mask;

  //////////////

  wire [`INST_WIDTH-1:0] instruction0;
  wire [`INST_WIDTH-1:0] instruction1;
  wire [`ADDR_WIDTH-1:0] pc0;
  wire [`ADDR_WIDTH-1:0] pc1;
  wire [`INSTRUCTION_ID_WIDTH-1:0] id0;
  wire [`INSTRUCTION_ID_WIDTH-1:0] id1;

  wire branch_taken0;
  wire branch_taken1;

  wire [`ADDR_WIDTH-1:0] branch_taken_address0;
  wire [`ADDR_WIDTH-1:0] branch_taken_address1;
  
  //////////////

  output wire [3:0] free;

  //////////////
  
  // can this be assign stall = load_stall || split_stall || steer_stall; ?
  assign stall = free == 0;
  assign stall_out = free == 0;

  //////////////
  
  wire [`INST_WIDTH-1:0] instruction [0:7];
  wire [`OP_CODE_BITS-1:0] opcode [0:7];
  wire [`NUM_REG_MASKS-1:0] reg_vld_mask [0:7];
  wire [`NUM_REGISTERS_LOG2-1:0] reg_src0 [0:7];
  wire [`NUM_REGISTERS_LOG2-1:0] reg_src1 [0:7];
  wire [`NUM_REGISTERS_LOG2-1:0] reg_dest [0:7];
  
  assign instruction[0] = instruction0;
  assign instruction[1] = instruction1;
  assign instruction[2] = 0;
  assign instruction[3] = 0;
  assign instruction[4] = 0;
  assign instruction[5] = 0;
  assign instruction[6] = 0;
  assign instruction[7] = 0;

  //////////////

  issue_queue q(
  .clk(clk),
  .flush(flush),
  .free(free),

  ///////////////

  .pop0(steer_vld_mask[0]),
  .pop_key0(0),

  .pop1(steer_vld_mask[1]),
  .pop_key1(1),

  ///////////////

  .data0({pc0, instruction0, id0, branch_taken0, branch_taken_address0}),
  .data1({pc1, instruction1, id1, branch_taken1, branch_taken_address1}),
  .data2(),
  .data3(),
  .data4(),
  .data5(),
  .data6(),
  .data7(),

  ///////////////

  .push0(push0),
  .push_data0({pc0_in, instruction0_in, id0_in, branch_taken0_in, branch_taken_address0_in}),

  .push1(push1),
  .push_data1({pc1_in, instruction1_in, id1_in, branch_taken1_in, branch_taken_address1_in})
  );
  
  //////////////
  
  genvar i;

  generate
    for (i=0; i<8; i=i+1) begin : generate_reg_depends
      
	  assign opcode[i] = instruction[i][`OPCODE_MSB:`OPCODE_LSB];
	  
      reg_depends reg_depends(
      .instruction(instruction[i]),
      .reg_src0(reg_src0[i]),
      .reg_src1(reg_src1[i]),
      .reg_dest(reg_dest[i]),
      .vld_mask(reg_vld_mask[i])
      );

    end
  endgenerate
  
  ///////////////////
  
  load_hazard lh(
  .if_id_instruction1(if_id_instruction1),
  .if_id_mem_op1(if_id_mem_op1),

  .reg_src0_in( {reg_src0[7], reg_src0[6], reg_src0[5], reg_src0[4], reg_src0[3], reg_src0[2], reg_src0[1], reg_src0[0]} ),
  .reg_src1_in( {reg_src1[7], reg_src1[6], reg_src1[5], reg_src1[4], reg_src1[3], reg_src1[2], reg_src1[1], reg_src1[0]} ),
  .reg_vld_mask_in( {reg_vld_mask[7], reg_vld_mask[6], reg_vld_mask[5], reg_vld_mask[4], reg_vld_mask[3], reg_vld_mask[2], reg_vld_mask[1], reg_vld_mask[0]} ),
  
  .vld_mask_out(load_vld_mask),
  .load_stall(load_stall)
  );
  
  split_hazard sh(
  .reg_src0_in( {reg_src0[7], reg_src0[6], reg_src0[5], reg_src0[4], reg_src0[3], reg_src0[2], reg_src0[1], reg_src0[0]} ),
  .reg_src1_in( {reg_src1[7], reg_src1[6], reg_src1[5], reg_src1[4], reg_src1[3], reg_src1[2], reg_src1[1], reg_src1[0]} ),
  .reg_dest_in( {reg_dest[7], reg_dest[6], reg_dest[5], reg_dest[4], reg_dest[3], reg_dest[2], reg_dest[1], reg_dest[0]} ),
  .reg_vld_mask_in( {reg_vld_mask[7], reg_vld_mask[6], reg_vld_mask[5], reg_vld_mask[4], reg_vld_mask[3], reg_vld_mask[2], reg_vld_mask[1], reg_vld_mask[0]} ),

  .vld_mask_in(load_vld_mask),
  
  .vld_mask_out(split_vld_mask),
  .split_stall(split_stall)
  );
  
  steer s(
  .opcode_in( {opcode[7], opcode[6], opcode[5], opcode[4], opcode[3], opcode[2], opcode[1], opcode[0]} ),
  .vld_mask_in(split_vld_mask),
  
  .vld_mask_out(steer_vld_mask),
  .steer_stall(steer_stall),
  .first(first)
  );
  
  initial begin
    instruction0_out          <= 0;
    pc0_out                   <= 0;
    id0_out                   <= 0;
    branch_taken0_out         <= 0;
    branch_taken_address0_out <= 0;
    
    instruction1_out          <= 0;
    pc1_out                   <= 0;
    id1_out                   <= 0;
    branch_taken1_out         <= 0;
    branch_taken_address1_out <= 0;
  end
  
  always @(*) begin

    if (flush) begin
      instruction0_out          <= 0;
      pc0_out                   <= 0;
      id0_out                   <= 0;
      branch_taken0_out         <= 0;
      branch_taken_address0_out <= 0;
      
      instruction1_out          <= 0;
      pc1_out                   <= 0;
      id1_out                   <= 0;
      branch_taken1_out         <= 0;
      branch_taken_address1_out <= 0;
    end else begin
      if(!first) begin
        instruction0_out          = steer_vld_mask[0] ? instruction0          : 0;
        pc0_out                   = steer_vld_mask[0] ? pc0                   : 0;
        id0_out                   = steer_vld_mask[0] ? id0                   : 0;
        branch_taken0_out         = steer_vld_mask[0] ? branch_taken0         : 0;
        branch_taken_address0_out = steer_vld_mask[0] ? branch_taken_address0 : 0;
        
        instruction1_out          = steer_vld_mask[1] ? instruction1          : 0;
        pc1_out                   = steer_vld_mask[1] ? pc1                   : 0;
        id1_out                   = steer_vld_mask[1] ? id1                   : 0;
        branch_taken1_out         = steer_vld_mask[1] ? branch_taken1         : 0;
        branch_taken_address1_out = steer_vld_mask[1] ? branch_taken_address1 : 0;
      end else begin
        instruction1_out          = steer_vld_mask[0] ? instruction0          : 0;
        pc1_out                   = steer_vld_mask[0] ? pc0                   : 0;
        id1_out                   = steer_vld_mask[0] ? id0                   : 0;
        branch_taken1_out         = steer_vld_mask[0] ? branch_taken0         : 0;
        branch_taken_address1_out = steer_vld_mask[0] ? branch_taken_address0 : 0;
        
        instruction0_out          = steer_vld_mask[1] ? instruction1          : 0;
        pc0_out                   = steer_vld_mask[1] ? pc1                   : 0;
        id0_out                   = steer_vld_mask[1] ? id1                   : 0;
        branch_taken0_out         = steer_vld_mask[1] ? branch_taken1         : 0;
        branch_taken_address0_out = steer_vld_mask[1] ? branch_taken_address1 : 0;
      end

    end
    
  end

endmodule

module load_hazard(
  if_id_instruction1,
  if_id_mem_op1,

  reg_src0_in,
  reg_src1_in,
  reg_vld_mask_in,

  vld_mask_out,
  load_stall
  
  );
  
  input wire [`INST_WIDTH-1:0] if_id_instruction1;
  input wire [`MEM_OP_BITS-1:0] if_id_mem_op1;

  input wire [`NUM_REGISTERS_LOG2 * 8 -1:0] reg_src0_in;
  input wire [`NUM_REGISTERS_LOG2 * 8 -1:0] reg_src1_in;
  input wire [`NUM_REG_MASKS * 8 -1:0]      reg_vld_mask_in;
  
  output reg [1:0] vld_mask_out;
  output reg load_stall;
  
  wire [`NUM_REGISTERS_LOG2-1:0] if_id_rt = if_id_instruction1[`REG_RT_MSB:`REG_RT_LSB];
  wire [`NUM_REG_MASKS-1:0] reg_vld_mask [0:7];
  wire [`NUM_REGISTERS_LOG2-1:0] reg_src0 [0:7];
  wire [`NUM_REGISTERS_LOG2-1:0] reg_src1 [0:7];
  
  genvar i;
  generate
    for (i=0; i<8; i=i+1) begin : generate_reg_depends
	  
      assign reg_vld_mask[i] = reg_vld_mask_in[`NUM_REG_MASKS*i + `NUM_REG_MASKS-1 : `NUM_REG_MASKS*i];
      assign reg_src0[i] =     reg_src0_in[`NUM_REGISTERS_LOG2*i + `NUM_REGISTERS_LOG2-1 : `NUM_REGISTERS_LOG2*i];
      assign reg_src1[i] =     reg_src1_in[`NUM_REGISTERS_LOG2*i + `NUM_REGISTERS_LOG2-1 : `NUM_REGISTERS_LOG2*i];

    end
  endgenerate
  
  always @(*) begin
    if((reg_src0[0] == if_id_rt || reg_src1[0] == if_id_rt) && (if_id_mem_op1 == `MEM_OP_READ)) begin
      load_stall = 1;
      vld_mask_out = 2'b00;
    end else if((reg_src0[1] == if_id_rt || reg_src1[1] == if_id_rt) && (if_id_mem_op1 == `MEM_OP_READ)) begin
      load_stall = 1;
      vld_mask_out = 2'b00;
    end else begin
      load_stall = 0;
      vld_mask_out = 2'b11;
    end
  end
  
endmodule

module reg_depends(

  instruction,

  reg_src0,
  reg_src1,
  reg_dest,

  vld_mask

  );

  input wire [`INST_WIDTH-1:0] instruction;

  output reg [`NUM_REGISTERS_LOG2-1:0] reg_src0;
  output reg [`NUM_REGISTERS_LOG2-1:0] reg_src1;
  output reg [`NUM_REGISTERS_LOG2-1:0] reg_dest;

  output reg [`NUM_REG_MASKS-1:0] vld_mask;

  wire [`OP_CODE_BITS-1:0]       opcode =   instruction[`OPCODE_MSB:`OPCODE_LSB];
  wire [`NUM_REGISTERS_LOG2-1:0] rs =       instruction[`REG_RS_MSB:`REG_RS_LSB];
  wire [`NUM_REGISTERS_LOG2-1:0] rt =       instruction[`REG_RT_MSB:`REG_RT_LSB];
  wire [`NUM_REGISTERS_LOG2-1:0] rd =       instruction[`REG_RD_MSB:`REG_RD_LSB];

  always @(*) begin

    casex(opcode)
     `OP_CODE_NOP: begin
        vld_mask <= 0;
      end
      `OP_CODE_JR: begin
        reg_src0 <= rs;
        vld_mask <= `REG_MASK_RS0;
      end
      6'b00????: begin // add, sub...
        reg_src0 <= rs;
        reg_src1 <= rt;
        reg_dest <= rd;
        vld_mask <= `REG_MASK_RS0 | `REG_MASK_RS1 | `REG_MASK_RD;
      end
      6'b01????: begin // addi, subi...
        reg_src0 <= rs;
        reg_dest <= rt;
        vld_mask <= `REG_MASK_RS0 | `REG_MASK_RD;
      end
      6'b10????: begin // lw, sw, la, sa
        if(opcode == `OP_CODE_LW) begin
          reg_src0 <= rs;
          reg_dest <= rt;
          vld_mask <= `REG_MASK_RS0 | `REG_MASK_RD;
        end else if(opcode == `OP_CODE_SW) begin
          reg_src0 <= rs;
          reg_src1 <= rt;
          vld_mask <= `REG_MASK_RS0 | `REG_MASK_RS1;
        end else if(opcode == `OP_CODE_LA) begin
        end else if(opcode == `OP_CODE_SA) begin
        end
      end
      6'b11????: begin // jmp, jo, je ...
        vld_mask <= 0;
      end
    endcase

  end

endmodule


module split_hazard(

  reg_src0_in,
  reg_src1_in,
  reg_dest_in,
  reg_vld_mask_in,
	
	vld_mask_in,
	
	vld_mask_out,
	split_stall

  );

  input wire [`NUM_REGISTERS_LOG2 * 8 -1:0] reg_src0_in;
  input wire [`NUM_REGISTERS_LOG2 * 8 -1:0] reg_src1_in;
  input wire [`NUM_REGISTERS_LOG2 * 8 -1:0] reg_dest_in;
  input wire [`NUM_REG_MASKS * 8 -1:0]      reg_vld_mask_in;
  
	input wire [1:0] vld_mask_in;
  
  output wire [1:0] vld_mask_out;
	output wire split_stall;
  
  ///////////////////
 
  wire [`NUM_REG_MASKS-1:0] reg_vld_mask [0:7];
  wire [`NUM_REGISTERS_LOG2-1:0] reg_src0 [0:7];
  wire [`NUM_REGISTERS_LOG2-1:0] reg_src1 [0:7];
  wire [`NUM_REGISTERS_LOG2-1:0] reg_dest [0:7];
  
  // just unpacking the wires.
  genvar i;
  generate
    for (i=0; i<8; i=i+1) begin : generate_reg_depends
	  
      assign reg_vld_mask[i] = reg_vld_mask_in[`NUM_REG_MASKS*i + `NUM_REG_MASKS-1 : `NUM_REG_MASKS*i];
      assign reg_src0[i] =     reg_src0_in[`NUM_REGISTERS_LOG2*i + `NUM_REGISTERS_LOG2-1 : `NUM_REGISTERS_LOG2*i];
      assign reg_src1[i] =     reg_src1_in[`NUM_REGISTERS_LOG2*i + `NUM_REGISTERS_LOG2-1 : `NUM_REGISTERS_LOG2*i];
      assign reg_dest[i] =     reg_dest_in[`NUM_REGISTERS_LOG2*i + `NUM_REGISTERS_LOG2-1 : `NUM_REGISTERS_LOG2*i];

    end
  endgenerate

  assign split_stall = ( ((reg_src0[1] == reg_dest[0]) && ((reg_vld_mask[1] & `REG_MASK_RS0) == `REG_MASK_RS0) && ((reg_vld_mask[0] & `REG_MASK_RD) == `REG_MASK_RD)) ||
                         ((reg_src1[1] == reg_dest[0]) && ((reg_vld_mask[1] & `REG_MASK_RS1) == `REG_MASK_RS1) && ((reg_vld_mask[0] & `REG_MASK_RD) == `REG_MASK_RD)) );

  assign vld_mask_out = split_stall ? vld_mask_in & 2'b01 : vld_mask_in;

endmodule

module steer(

	opcode_in,

	vld_mask_in,
	
	steer_stall,
	vld_mask_out,
	first
	
	);
  
  input wire [`OP_CODE_BITS * 8 -1:0] opcode_in;
	
	input wire [1:0] vld_mask_in;
	
	output reg steer_stall;
  output reg [1:0] vld_mask_out;
  output reg first;
  
  ///////////////////
  
  wire [`OP_CODE_BITS-1:0] opcode [0:7];
  
  // just unpacking the wires.
  genvar i;
  generate
    for (i=0; i<8; i=i+1) begin : generate_reg_depends
	  
      assign opcode[i] = opcode_in[`OP_CODE_BITS*i + `OP_CODE_BITS-1 : `OP_CODE_BITS*i];

    end
  endgenerate
	
  reg [`PIPE_BITS-1:0] instruction0_pipe;
  reg [`PIPE_BITS-1:0] instruction1_pipe;
	
	always @(*) begin

    casex(opcode[0])
      6'b000000: begin
        instruction0_pipe = `PIPE_DONT_CARE;
      end
      6'b00????: begin // add, sub...
        if (opcode[0] == `OP_CODE_CMP || opcode[0] == `OP_CODE_TEST) begin
          instruction0_pipe = `PIPE_BRANCH;
        end else begin
          instruction0_pipe = `PIPE_DONT_CARE;
        end
      end
      6'b01????: begin // addi, subi...
        if (opcode[0] == `OP_CODE_CMPI || opcode[0] == `OP_CODE_TESTI) begin
          instruction0_pipe = `PIPE_BRANCH;
        end else begin
          instruction0_pipe = `PIPE_DONT_CARE;
        end        
      end
      6'b10????: begin // lw, sw, la, sa
        instruction0_pipe = `PIPE_MEMORY;
      end
      6'b11????: begin // jmp, jo, je ...
        instruction0_pipe = `PIPE_BRANCH;
      end
    endcase

    casex(opcode[1])
      6'b000000: begin
        instruction1_pipe = `PIPE_DONT_CARE;
      end
      6'b00????: begin // add, sub...
        if (opcode[1] == `OP_CODE_CMP || opcode[1] == `OP_CODE_TEST) begin
          instruction1_pipe = `PIPE_BRANCH;
        end else begin
          instruction1_pipe = `PIPE_DONT_CARE;
        end
      end
      6'b01????: begin // addi, subi...
        if (opcode[1] == `OP_CODE_CMPI || opcode[1] == `OP_CODE_TESTI) begin
          instruction1_pipe = `PIPE_BRANCH;
        end else begin
          instruction1_pipe = `PIPE_DONT_CARE;
        end        
      end
      6'b10????: begin // lw, sw, la, sa
        instruction1_pipe = `PIPE_MEMORY;
      end
      6'b11????: begin // jmp, jo, je ...
        instruction1_pipe = `PIPE_BRANCH;
      end
    endcase

    case( {instruction0_pipe, instruction1_pipe} )
      {`PIPE_BRANCH, `PIPE_BRANCH}: begin // hazard. steer stall = 1.
        steer_stall = 1;
        first = 0;
        vld_mask_out = vld_mask_in & 2'b01;
      end
      {`PIPE_MEMORY, `PIPE_BRANCH}: begin
        steer_stall = 0;
        first = 1;
        vld_mask_out = vld_mask_in & 2'b11;
      end
      {`PIPE_MEMORY, `PIPE_MEMORY}: begin // hazard. steer stall = 1.
        steer_stall = 1;
        first = 1;
        vld_mask_out = vld_mask_in & 2'b01;
      end
      {`PIPE_MEMORY, `PIPE_DONT_CARE}: begin
        steer_stall = 0;
        first = 1;
        vld_mask_out = vld_mask_in & 2'b11;
      end
      {`PIPE_DONT_CARE, `PIPE_BRANCH}: begin
        steer_stall = 0;
        first = 1;
        vld_mask_out = vld_mask_in & 2'b11;
      end
      default: begin
        steer_stall = 0;
        first = 0;
        vld_mask_out = vld_mask_in & 2'b11;
      end
    endcase
  end
  
endmodule




