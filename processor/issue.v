`timescale 1ns / 1ps

`include "defines.vh"

module issue(
  clk,
  flush,

  if_id_instruction1,
  if_id_mem_op1,

  instruction0_in,
  instruction1_in,

  //////////////

  stall_out,

  //////////////

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

  first
  
  );

  input wire clk;
  input wire flush;

  input wire [`INST_WIDTH-1:0] if_id_instruction1;
  input wire [`MEM_OP_BITS-1:0] if_id_mem_op1;

  input wire [`INST_WIDTH-1:0] instruction0_in;
  input wire [`INST_WIDTH-1:0] instruction1_in;

  //////////////

  wire stall;
  output wire stall_out;

  //////////////

  input wire [`ADDR_WIDTH-1:0] pc0_in;
  input wire [`ADDR_WIDTH-1:0] pc1_in;

  input wire [`INSTRUCTION_ID_WIDTH-1:0] id0_in;
  input wire [`INSTRUCTION_ID_WIDTH-1:0] id1_in;

  //////////////

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

  reg [`INST_WIDTH-1:0] stall_instruction0;
  reg [`INST_WIDTH-1:0] stall_instruction1;
  reg [`ADDR_WIDTH-1:0] stall_pc0;
  reg [`ADDR_WIDTH-1:0] stall_pc1;
  reg [`INSTRUCTION_ID_WIDTH-1:0] stall_id0;
  reg [`INSTRUCTION_ID_WIDTH-1:0] stall_id1;

  //////////////

  wire [`INST_WIDTH-1:0] instruction0  = stall ? stall_instruction0 : instruction0_in;
  wire [`INST_WIDTH-1:0] instruction1  = stall ? stall_instruction1 : instruction1_in;
  wire [`ADDR_WIDTH-1:0] pc0           = stall ? stall_pc0 : pc0_in;
  wire [`ADDR_WIDTH-1:0] pc1           = stall ? stall_pc1 : pc1_in;
  wire [`INSTRUCTION_ID_WIDTH-1:0] id0 = stall ? stall_id0 : id0_in;
  wire [`INSTRUCTION_ID_WIDTH-1:0] id1 = stall ? stall_id1 : id1_in;
  
  //////////////
  
  // can this be assign stall = load_stall || split_stall || steer_stall; ?
  assign stall = (stall_instruction0 != 0) || (stall_instruction1 != 0);
  assign stall_out = !steer_vld_mask[0] ||  !steer_vld_mask[1];

  //////////////
  
  load_hazard lh(
  .if_id_instruction1(if_id_instruction1),
  .if_id_mem_op1(if_id_mem_op1),
  .instruction0_in(instruction0),
  .instruction1_in(instruction1),
  
  .vld_mask_out(load_vld_mask),
  .load_stall(load_stall)
  );
  
  split_hazard sh(
  .instruction0_in(instruction0),
  .instruction1_in(instruction1),
  .vld_mask_in(load_vld_mask),
  
  .vld_mask_out(split_vld_mask),
  .split_stall(split_stall)
  );
  
  steer s(
  .instruction0_in(instruction0),
  .instruction1_in(instruction1),
  .vld_mask_in(split_vld_mask),
  
  .vld_mask_out(steer_vld_mask),
  .steer_stall(steer_stall),
  .first(first)
  );
  
  initial begin
    instruction0_out <= 0;
    pc0_out          <= 0;
    id0_out          <= 0;
    
    instruction1_out <= 0;
    pc1_out          <= 0;
    id1_out          <= 0;

    stall_instruction0 <= 0;
    stall_pc0          <= 0;
    stall_id0          <= 0;
    
    stall_instruction1 <= 0;
    stall_pc1          <= 0;
    stall_id1          <= 0;
  end
  
  always @(*) begin
    
    if (flush) begin
      instruction0_out = 0;
      pc0_out          = 0;
      id0_out          = 0;
      
      instruction1_out = 0;
      pc1_out          = 0;
      id1_out          = 0;
    end else begin
      if(!first) begin
        instruction0_out = steer_vld_mask[0] ? instruction0 : 0;
        pc0_out          = steer_vld_mask[0] ? pc0 : 0;
        id0_out          = steer_vld_mask[0] ? id0 : 0;
        
        instruction1_out = steer_vld_mask[1] ? instruction1 : 0;
        pc1_out          = steer_vld_mask[1] ? pc1 : 0;
        id1_out          = steer_vld_mask[1] ? id1 : 0;
      end else begin
        instruction1_out = steer_vld_mask[0] ? instruction0 : 0;
        pc1_out          = steer_vld_mask[0] ? pc0 : 0;
        id1_out          = steer_vld_mask[0] ? id0 : 0;
        
        instruction0_out = steer_vld_mask[1] ? instruction1 : 0;
        pc0_out          = steer_vld_mask[1] ? pc1 : 0;
        id0_out          = steer_vld_mask[1] ? id1 : 0;
      end

    end
    
  end
  
  always @(posedge clk) begin
    if (flush) begin
      stall_instruction0 <= 0;
      stall_pc0          <= 0;
      stall_id0          <= 0;
      
      stall_instruction1 <= 0;
      stall_pc1          <= 0;
      stall_id1          <= 0;
    end else begin
      stall_instruction0 <= !steer_vld_mask[0] ? instruction0 : 0;
      stall_pc0          <= !steer_vld_mask[0] ? pc0 : 0;
      stall_id0          <= !steer_vld_mask[0] ? id0 : 0;
      
      stall_instruction1 <= !steer_vld_mask[1] ? instruction1 : 0;
      stall_pc1          <= !steer_vld_mask[1] ? pc1 : 0;
      stall_id1          <= !steer_vld_mask[1] ? id1 : 0;
    end
  end

endmodule

module load_hazard(
  if_id_instruction1,
  if_id_mem_op1,

  instruction0_in,
  instruction1_in,

  vld_mask_out,
  load_stall
  
  );
  
  input wire [`INST_WIDTH-1:0] if_id_instruction1;
  input wire [`MEM_OP_BITS-1:0] if_id_mem_op1;

  input wire [`INST_WIDTH-1:0] instruction0_in;
  input wire [`INST_WIDTH-1:0] instruction1_in;

  output reg [1:0] vld_mask_out;
  output reg load_stall;

  wire [`NUM_REGISTERS_LOG2-1:0] rs0 = instruction0_in[`REG_RS_MSB:`REG_RS_LSB];
  wire [`NUM_REGISTERS_LOG2-1:0] rt0 = instruction0_in[`REG_RT_MSB:`REG_RT_LSB];

  wire [`NUM_REGISTERS_LOG2-1:0] rs1 = instruction1_in[`REG_RS_MSB:`REG_RS_LSB];
  wire [`NUM_REGISTERS_LOG2-1:0] rt1 = instruction1_in[`REG_RT_MSB:`REG_RT_LSB];

  wire [`NUM_REGISTERS_LOG2-1:0] if_id_rt = if_id_instruction1[`REG_RT_MSB:`REG_RT_LSB];

  always @(*) begin
    if((rs0 == if_id_rt || rt0 == if_id_rt) && (if_id_mem_op1 == `MEM_OP_READ)) begin
      load_stall = 1;
      vld_mask_out = 2'b00;
    end else if((rs1 == if_id_rt || rt1 == if_id_rt) && (if_id_mem_op1 == `MEM_OP_READ)) begin
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

	instruction0_in,
	instruction1_in,
	
	vld_mask_in,
	
	vld_mask_out,
	split_stall

  );

	input wire [`INST_WIDTH-1:0] instruction0_in;
	input wire [`INST_WIDTH-1:0] instruction1_in;
	
	input wire [1:0] vld_mask_in;
	
  output wire [1:0] vld_mask_out;
	output wire split_stall;
  
  ///////////////////
  
  wire [`INST_WIDTH-1:0] instruction0 = vld_mask_in[0] ? instruction0_in : 0;
  wire [`INST_WIDTH-1:0] instruction1 = vld_mask_in[1] ? instruction1_in : 0;

  wire [`NUM_REG_MASKS-1:0] reg_vld_mask0;
  wire [`NUM_REG_MASKS-1:0] reg_vld_mask1;

  wire [`NUM_REGISTERS_LOG2-1:0] reg_src0_0;
  wire [`NUM_REGISTERS_LOG2-1:0] reg_src1_0;
  wire [`NUM_REGISTERS_LOG2-1:0] reg_dest_0;

  wire [`NUM_REGISTERS_LOG2-1:0] reg_src0_1;
  wire [`NUM_REGISTERS_LOG2-1:0] reg_src1_1;
  wire [`NUM_REGISTERS_LOG2-1:0] reg_dest_1;

  ///////////////////

  reg_depends reg_depends0(
  .instruction(instruction0),
  .reg_src0(reg_src0_0),
  .reg_src1(reg_src1_0),
  .reg_dest(reg_dest_0),
  .vld_mask(reg_vld_mask0)
  );

  reg_depends reg_depends1(
  .instruction(instruction1),
  .reg_src0(reg_src0_1),
  .reg_src1(reg_src1_1),
  .reg_dest(reg_dest_1),
  .vld_mask(reg_vld_mask1)
  );

  assign split_stall = ( ((reg_src0_1 == reg_dest_0) && ((reg_vld_mask1 & `REG_MASK_RS0) == `REG_MASK_RS0) && ((reg_vld_mask0 & `REG_MASK_RD) == `REG_MASK_RD)) ||
                         ((reg_src1_1 == reg_dest_0) && ((reg_vld_mask1 & `REG_MASK_RS1) == `REG_MASK_RS1) && ((reg_vld_mask0 & `REG_MASK_RD) == `REG_MASK_RD)) );

  assign vld_mask_out = split_stall ? vld_mask_in & 2'b01 : vld_mask_in;

endmodule

module steer(

	instruction0_in,
	instruction1_in,

	vld_mask_in,
	
	steer_stall,
	vld_mask_out,
	first
	
	);
  
  input wire [`INST_WIDTH-1:0] instruction0_in;
	input wire [`INST_WIDTH-1:0] instruction1_in;
	
	input wire [1:0] vld_mask_in;
	
	output reg steer_stall;
  output reg [1:0] vld_mask_out;
  output reg first;
  
  wire [`INST_WIDTH-1:0] instruction0 = vld_mask_in[0] ? instruction0_in : 0;
  wire [`INST_WIDTH-1:0] instruction1 = vld_mask_in[1] ? instruction1_in : 0;
  
  wire [`OP_CODE_BITS-1:0] opcode0 = instruction0[`OPCODE_MSB:`OPCODE_LSB];
  wire [`OP_CODE_BITS-1:0] opcode1 = instruction1[`OPCODE_MSB:`OPCODE_LSB];
	
  reg [`PIPE_BITS-1:0] instruction0_pipe;
  reg [`PIPE_BITS-1:0] instruction1_pipe;
	
	always @(*) begin

    casex(opcode0)
      6'b000000: begin
        instruction0_pipe = `PIPE_DONT_CARE;
      end
      6'b00????: begin // add, sub...
        if (opcode0 == `OP_CODE_CMP || opcode0 == `OP_CODE_TEST) begin
          instruction0_pipe = `PIPE_BRANCH;
        end else begin
          instruction0_pipe = `PIPE_DONT_CARE;
        end
      end
      6'b01????: begin // addi, subi...
        if (opcode0 == `OP_CODE_CMPI || opcode0 == `OP_CODE_TESTI) begin
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

    casex(opcode1)
      6'b000000: begin
        instruction1_pipe = `PIPE_DONT_CARE;
      end
      6'b00????: begin // add, sub...
        if (opcode1 == `OP_CODE_CMP || opcode1 == `OP_CODE_TEST) begin
          instruction1_pipe = `PIPE_BRANCH;
        end else begin
          instruction1_pipe = `PIPE_DONT_CARE;
        end
      end
      6'b01????: begin // addi, subi...
        if (opcode1 == `OP_CODE_CMPI || opcode1 == `OP_CODE_TESTI) begin
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




