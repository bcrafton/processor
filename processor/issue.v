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

  stall,

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

  output wire stall;

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

  assign stall = load_stall || split_stall || steer_stall;

  //////////////
  
  load_hazard lh(
  .if_id_instruction1(if_id_instruction1),
  .if_id_mem_op1(if_id_mem_op1),
  .instruction0_in(instruction0_in),
  .instruction1_in(instruction1_in),
  
  .vld_mask_out(load_vld_mask),
  .load_stall(load_stall)
  );
  
  split_hazard sh(
  .instruction0_in(instruction0_in),
  .instruction1_in(instruction1_in),
  .vld_mask_in(load_vld_mask),
  
  .vld_mask_out(split_vld_mask),
  .split_stall(split_stall)
  );
  
  steer s(
  .instruction0_in(instruction0_in),
  .instruction1_in(instruction1_in),
  .vld_mask_in(split_vld_mask),
  
  .vld_mask_out(steer_vld_mask),
  .steer_stall(steer_stall),
  .first(first)
  );
  
  initial begin
    stall_instruction0 <= 0;
    stall_pc0          <= 0;
    stall_id0          <= 0;
    
    stall_instruction1 <= 0;
    stall_pc1          <= 0;
    stall_id1          <= 0;
  end
  
  always @(posedge clk) begin
    
    if (flush) begin
      instruction0_out <= 0;
      pc0_out          <= 0;
      id0_out          <= 0;
      
      instruction1_out <= 0;
      pc1_out          <= 0;
      id1_out          <= 0;
    end else begin
      if(!first) begin
        instruction0_out <= steer_vld_mask[0] ? instruction0 : 0;
        pc0_out          <= steer_vld_mask[0] ? pc0 : 0;
        id0_out          <= steer_vld_mask[0] ? id0 : 0;
        
        instruction1_out <= steer_vld_mask[1] ? instruction1 : 0;
        pc1_out          <= steer_vld_mask[1] ? pc1 : 0;
        id1_out          <= steer_vld_mask[1] ? id1 : 0;
      end else begin
        instruction1_out <= steer_vld_mask[0] ? instruction0 : 0;
        pc1_out          <= steer_vld_mask[0] ? pc0 : 0;
        id1_out          <= steer_vld_mask[0] ? id0 : 0;
        
        instruction0_out <= steer_vld_mask[1] ? instruction1 : 0;
        pc0_out          <= steer_vld_mask[1] ? pc1 : 0;
        id0_out          <= steer_vld_mask[1] ? id1 : 0;
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
    end else if((rs1 == if_id_rt || rt0 == if_id_rt) && (if_id_mem_op1 == `MEM_OP_READ)) begin
      load_stall = 1;
      vld_mask_out = 2'b00;
    end else begin
      load_stall = 0;
      vld_mask_out = 2'b11;
    end
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
	
  output reg [1:0] vld_mask_out;
	output reg split_stall;
  
  wire [`INST_WIDTH-1:0] instruction0 = vld_mask[0] ? instruction0_in : 0;
  wire [`INST_WIDTH-1:0] instruction1 = vld_mask[1] ? instruction1_in : 0;
  
  wire [`OP_CODE_BITS-1:0] opcode0   = instruction0[`OPCODE_MSB:`OPCODE_LSB];
  wire [`NUM_REGISTERS_LOG2-1:0] rs0 = instruction0[`REG_RS_MSB:`REG_RS_LSB];
  wire [`NUM_REGISTERS_LOG2-1:0] rt0 = instruction0[`REG_RT_MSB:`REG_RT_LSB];
  wire [`NUM_REGISTERS_LOG2-1:0] rd0 = instruction0[`REG_RD_MSB:`REG_RD_LSB];

  wire [`OP_CODE_BITS-1:0] opcode1   = instruction1[`OPCODE_MSB:`OPCODE_LSB];
  wire [`NUM_REGISTERS_LOG2-1:0] rs1 = instruction1[`REG_RS_MSB:`REG_RS_LSB];
  wire [`NUM_REGISTERS_LOG2-1:0] rt1 = instruction1[`REG_RT_MSB:`REG_RT_LSB];
  wire [`NUM_REGISTERS_LOG2-1:0] rd1 = instruction1[`REG_RD_MSB:`REG_RD_LSB];

  reg [`NUM_REG_MASKS-1:0] src_mask0;
  reg [`NUM_REG_MASKS-1:0] dst_mask0;

  reg [`NUM_REG_MASKS-1:0] src_mask1;
  reg [`NUM_REG_MASKS-1:0] dst_mask1;

  always @(*) begin
    if (split_stall) begin
      vld_mask_out = vld_mask_in & 2'b10;
    end else begin
      vld_mask_out = vld_mask_in & 2'b11;
    end
  end

	always @(*) begin

    casex(opcode0)
     `OP_CODE_NOP: begin
        src_mask0 <= 0;
        dst_mask0 <= 0;
      end
      `OP_CODE_JR: begin
        src_mask0 <= `REG_MASK_RS;
        dst_mask0 <= 0;
      end
      6'b00????: begin // add, sub...
        src_mask0 <= `REG_MASK_RS | `REG_MASK_RT;
        dst_mask0 <= `REG_MASK_RD;
      end
      6'b01????: begin // addi, subi...
        src_mask0 <= `REG_MASK_RS;
        dst_mask0 <= `REG_MASK_RT;
      end
      6'b10????: begin // lw, sw, la, sa
        if(opcode0 == `OP_CODE_LW) begin
          src_mask0 <= `REG_MASK_RS;
          dst_mask0 <= `REG_MASK_RT;
        end else if(opcode0 == `OP_CODE_SW) begin
          src_mask0 <= `REG_MASK_RS | `REG_MASK_RT;
          dst_mask0 <= 0;
        end else if(opcode0 == `OP_CODE_LA) begin
          src_mask0 <= 0;
          dst_mask0 <= `REG_MASK_RT;
        end else if(opcode0 == `OP_CODE_SA) begin
          src_mask0 <= `REG_MASK_RT;
          dst_mask0 <= 0;
        end
      end
      6'b11????: begin // jmp, jo, je ...
        src_mask0 <= 0;
        dst_mask0 <= 0;
      end
    endcase

    casex(opcode1)
     `OP_CODE_NOP: begin
        src_mask1 <= 0;
        dst_mask1 <= 0;
      end
      `OP_CODE_JR: begin
        src_mask1 <= `REG_MASK_RS;
        dst_mask1 <= 0;
      end
      6'b00????: begin // add, sub...
        src_mask1 <= `REG_MASK_RS | `REG_MASK_RT;
        dst_mask1 <= `REG_MASK_RD;
      end
      6'b01????: begin // addi, subi...
        src_mask1 <= `REG_MASK_RS;
        dst_mask1 <= `REG_MASK_RT;
      end
      6'b10????: begin // lw, sw, la, sa
        if(opcode1 == `OP_CODE_LW) begin
          src_mask1 <= `REG_MASK_RS;
          dst_mask1 <= `REG_MASK_RT;
        end else if(opcode1 == `OP_CODE_SW) begin
          src_mask1 <= `REG_MASK_RS | `REG_MASK_RT;
          dst_mask1 <= 0;
        end else if(opcode1 == `OP_CODE_LA) begin
          src_mask1 <= 0;
          dst_mask1 <= `REG_MASK_RT;
        end else if(opcode1 == `OP_CODE_SA) begin
          src_mask1 <= `REG_MASK_RT;
          dst_mask1 <= 0;
        end
      end
      6'b11????: begin // jmp, jo, je ...
        src_mask1 <= 0;
        dst_mask1 <= 0;
      end
    endcase

    casex( {src_mask1, dst_mask0} )

      {`REG_MASK_RS | `REG_MASK_RT, `REG_MASK_RT}: begin
        if (rs1 == rt0 || rt1 == rt0) begin
          split_stall = 1;
        end else begin
          split_stall = 0;
        end
      end
      {`REG_MASK_RS | `REG_MASK_RT, `REG_MASK_RD}: begin
        if (rs1 == rd0 || rt1 == rd0) begin
          split_stall = 1;
        end else begin
          split_stall = 0;
        end
      end

      {`REG_MASK_RS, `REG_MASK_RT}: begin
        if (rs1 == rt0) begin
          split_stall = 1;
        end else begin
          split_stall = 0;
        end
      end
      {`REG_MASK_RS, `REG_MASK_RD}: begin
        if (rs1 == rd0) begin
          split_stall = 1;
        end else begin
          split_stall = 0;
        end
      end
      {`REG_MASK_RT, `REG_MASK_RT}: begin
        if (rt1 == rt0) begin
          split_stall = 1;
        end else begin
          split_stall = 0;
        end
      end
      {`REG_MASK_RT, `REG_MASK_RD}: begin
        if (rt1 == rd0) begin
          split_stall = 1;
        end else begin
          split_stall = 0;
        end
      end
      default: begin
        split_stall = 0;
      end
    endcase
  end
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
  
  wire [`INST_WIDTH-1:0] instruction0 = vld_mask[0] ? instruction0_in : 0;
  wire [`INST_WIDTH-1:0] instruction1 = vld_mask[1] ? instruction1_in : 0;
  
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




