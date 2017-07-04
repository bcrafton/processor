`timescale 1ns / 1ps

`include "defines.vh"

module hazard_detection_unit(

  clk,

  load_instruction,
  mem_op,

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

  input wire [`INST_WIDTH-1:0] load_instruction;
  input wire [`MEM_OP_BITS-1:0] mem_op;

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

  output wire [`ADDR_WIDTH-1:0] pc0_out;
  output wire [`ADDR_WIDTH-1:0] pc1_out;

  output wire [`INSTRUCTION_ID_WIDTH-1:0] id0_out;
  output wire [`INSTRUCTION_ID_WIDTH-1:0] id1_out;

  output wire [`INST_WIDTH-1:0] instruction0_out;
  output wire [`INST_WIDTH-1:0] instruction1_out;

  output reg first;

  //////////////

  reg load_stall;
  reg split_stall;
  reg steer_stall;

  reg [`INST_WIDTH-1:0] stall_instruction0;
  reg [`INST_WIDTH-1:0] stall_instruction1;
  reg [`ADDR_WIDTH-1:0] stall_pc0;
  reg [`ADDR_WIDTH-1:0] stall_pc1;
  reg [`INSTRUCTION_ID_WIDTH-1:0] stall_id0;
  reg [`INSTRUCTION_ID_WIDTH-1:0] stall_id1;

  reg [`INST_WIDTH-1:0] last_instruction0;
  reg [`INST_WIDTH-1:0] last_instruction1;
  reg [`ADDR_WIDTH-1:0] last_pc0;
  reg [`ADDR_WIDTH-1:0] last_pc1;
  reg [`INSTRUCTION_ID_WIDTH-1:0] last_id0;
  reg [`INSTRUCTION_ID_WIDTH-1:0] last_id1;

  reg [`PIPE_BITS-1:0] instruction0_pipe;
  reg [`PIPE_BITS-1:0] instruction1_pipe;

  //////////////

  reg [`NUM_REG_MASKS-1:0] src_mask0;
  reg [`NUM_REG_MASKS-1:0] dst_mask0;

  reg [`NUM_REG_MASKS-1:0] src_mask1;
  reg [`NUM_REG_MASKS-1:0] dst_mask1;

  //////////////

  wire [`OP_CODE_BITS-1:0] opcode0;
  wire [`NUM_REGISTERS_LOG2-1:0] rs0;
  wire [`NUM_REGISTERS_LOG2-1:0] rt0;
  wire [`NUM_REGISTERS_LOG2-1:0] rd0;

  wire [`OP_CODE_BITS-1:0] opcode1;
  wire [`NUM_REGISTERS_LOG2-1:0] rs1;
  wire [`NUM_REGISTERS_LOG2-1:0] rt1;
  wire [`NUM_REGISTERS_LOG2-1:0] rd1;

  wire [`NUM_REGISTERS_LOG2-1:0] load_rt;

  //////////////

  wire [`OP_CODE_BITS-1:0] load_opcode0;
  wire [`OP_CODE_BITS-1:0] load_opcode1;

  wire [`ADDR_WIDTH-1:0] load_pc0;
  wire [`ADDR_WIDTH-1:0] load_pc1;

  wire [`INSTRUCTION_ID_WIDTH-1:0] load_id0;
  wire [`INSTRUCTION_ID_WIDTH-1:0] load_id1;

  wire [`INST_WIDTH-1:0] load_instruction0;
  wire [`INST_WIDTH-1:0] load_instruction1;

  //////////////

  wire [`OP_CODE_BITS-1:0] split_opcode0;
  wire [`OP_CODE_BITS-1:0] split_opcode1;

  wire [`ADDR_WIDTH-1:0] split_pc0;
  wire [`ADDR_WIDTH-1:0] split_pc1;

  wire [`INSTRUCTION_ID_WIDTH-1:0] split_id0;
  wire [`INSTRUCTION_ID_WIDTH-1:0] split_id1;

  wire [`INST_WIDTH-1:0] split_instruction0;
  wire [`INST_WIDTH-1:0] split_instruction1;

  //////////////

  reg [`ADDR_WIDTH-1:0] steer_pc0;
  reg [`ADDR_WIDTH-1:0] steer_pc1;

  reg [`INSTRUCTION_ID_WIDTH-1:0] steer_id0;
  reg [`INSTRUCTION_ID_WIDTH-1:0] steer_id1;

  reg [`INST_WIDTH-1:0] steer_instruction0;
  reg [`INST_WIDTH-1:0] steer_instruction1;

  //////////////

  wire [`INST_WIDTH-1:0] instruction0;
  wire [`INST_WIDTH-1:0] instruction1;

  wire [`ADDR_WIDTH-1:0] pc0;
  wire [`ADDR_WIDTH-1:0] pc1;

  wire [`INSTRUCTION_ID_WIDTH-1:0] id0;
  wire [`INSTRUCTION_ID_WIDTH-1:0] id1;

  //////////////

  assign opcode0 = instruction0[`OPCODE_MSB:`OPCODE_LSB];
  assign rs0 =     instruction0[`REG_RS_MSB:`REG_RS_LSB];
  assign rt0 =     instruction0[`REG_RT_MSB:`REG_RT_LSB];
  assign rd0 =     instruction0[`REG_RD_MSB:`REG_RD_LSB];

  assign opcode1 = instruction1[`OPCODE_MSB:`OPCODE_LSB];
  assign rs1 =     instruction1[`REG_RS_MSB:`REG_RS_LSB];
  assign rt1 =     instruction1[`REG_RT_MSB:`REG_RT_LSB];
  assign rd1 =     instruction1[`REG_RD_MSB:`REG_RD_LSB];

  assign load_rt = load_instruction[`REG_RT_MSB:`REG_RT_LSB];

  //////////////

  assign load_pc0 = load_stall ? 0 : pc0;
  assign load_pc1 = load_stall ? 0 : pc1;

  assign load_id0 = load_stall ? 0 : id0;
  assign load_id1 = load_stall ? 0 : id1;

  assign load_instruction0 = load_stall ? 0 : instruction0;
  assign load_instruction1 = load_stall ? 0 : instruction1;

  assign load_opcode0 = load_instruction0[`OPCODE_MSB:`OPCODE_LSB];
  assign load_opcode1 = load_instruction1[`OPCODE_MSB:`OPCODE_LSB];
  
  //////////////

  assign split_pc0 = split_stall ? 0 : load_pc0;
  assign split_pc1 = split_stall ? 0 : load_pc1;

  assign split_id0 = split_stall ? 0 : load_id0;
  assign split_id1 = split_stall ? 0 : load_id1;

  assign split_instruction0 = load_instruction0;
  assign split_instruction1 = split_stall ? 0 : load_instruction1;

  assign split_opcode0 = split_instruction0[`OPCODE_MSB:`OPCODE_LSB];
  assign split_opcode1 = split_instruction1[`OPCODE_MSB:`OPCODE_LSB];
  
  //////////////

  assign stall = (last_instruction0 != 0) || (last_instruction1 != 0);

  //////////////

  assign instruction0 = stall ? last_instruction0 : instruction0_in;
  assign instruction1 = stall ? last_instruction1 : instruction1_in;

  assign pc0 = stall ? last_pc0 : pc0_in;
  assign pc1 = stall ? last_pc1 : pc1_in;

  assign id0 = stall ? last_id0 : id0_in;
  assign id1 = stall ? last_id1 : id1_in;

  //////////////

  assign pc0_out = steer_pc0;
  assign pc1_out = steer_pc1;

  assign id0_out = steer_id0;
  assign id1_out = steer_id1;

  assign instruction0_out = steer_instruction0;
  assign instruction1_out = steer_instruction1;

  //////////////

  initial begin
    load_stall = 0;
    split_stall = 0;
    steer_stall = 0;

    stall_instruction0 = 0;
    stall_instruction1 = 0;
    stall_pc0 = 0;
    stall_pc1 = 0;
    stall_id0 = 0;
    stall_id1 = 0;

    last_instruction0 = 0;
    last_instruction1 = 0;
    last_pc0 = 0;
    last_pc1 = 0;
    last_id0 = 0;
    last_id1 = 0;
  end

  always @(posedge clk) begin
    last_instruction0 = stall_instruction0;
    last_instruction1 = stall_instruction1;
    last_pc0 = stall_pc0;
    last_pc1 = stall_pc1;
    last_id0 = stall_id0;
    last_id1 = stall_id1;
  end

  always @(*) begin
    if (load_stall) begin
      stall_instruction0 = instruction0;
      stall_instruction1 = instruction1;
      stall_pc0 = pc0;
      stall_pc1 = pc1;
      stall_id0 = id0;
      stall_id1 = id1;
    end else if (split_stall) begin
      stall_instruction0 = 0;
      stall_instruction1 = instruction1_in;
      stall_pc0 = 0;
      stall_pc1 = pc1_in;
      stall_id0 = 0;
      stall_id1 = id1_in;
    end else if (steer_stall) begin
    end else begin
      stall_instruction0 = 0;
      stall_instruction1 = 0;
      stall_pc0 = 0;
      stall_pc1 = 0;
      stall_id0 = 0;
      stall_id1 = 0;
    end
  end

  always @(*) begin
    if((rs0 == load_rt || rt0 == load_rt) && (mem_op == `MEM_OP_READ)) begin
      load_stall = 1;
    end else if((rs1 == load_rt || rt1 == load_rt) && (mem_op == `MEM_OP_READ)) begin
      load_stall = 1;
    end else begin
      load_stall = 0;
    end
  end

  always @(*) begin

    casex(load_opcode0)
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

    casex(load_opcode1)
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

    if(!load_stall) begin

      if (first) begin

        casex( {src_mask0, dst_mask1} )

          {`REG_MASK_RS | `REG_MASK_RT, `REG_MASK_RT}: begin
            if (rs0 == rt1 || rt0 == rt1) begin
              split_stall = 1;
            end else begin
              split_stall = 0;
            end
          end
          {`REG_MASK_RS | `REG_MASK_RT, `REG_MASK_RD}: begin
            if (rs0 == rd1 || rt0 == rd1) begin
              split_stall = 1;
            end else begin
              split_stall = 0;
            end
          end

          {`REG_MASK_RS, `REG_MASK_RT}: begin
            if (rs0 == rt1) begin
              split_stall = 1;
            end else begin
              split_stall = 0;
            end
          end
          {`REG_MASK_RS, `REG_MASK_RD}: begin
            if (rs0 == rd1) begin
              split_stall = 1;
            end else begin
              split_stall = 0;
            end
          end
          {`REG_MASK_RT, `REG_MASK_RT}: begin
            if (rt0 == rt1) begin
              split_stall = 1;
            end else begin
              split_stall = 0;
            end
          end
          {`REG_MASK_RT, `REG_MASK_RD}: begin
            if (rt0 == rd1) begin
               split_stall = 1;
            end else begin
              split_stall = 0;
            end
          end
          default: begin
            split_stall = 0;
          end
        endcase

      end else begin

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
    end
  end

  always @(*) begin

    casex(split_opcode0)
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

    casex(split_opcode1)
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
        steer_instruction0 = split_instruction0;
        steer_instruction1 = `NOP_INSTRUCTION;
        steer_pc0 = split_pc0;
        steer_pc1 = 0;
        steer_id0 = split_id0;
        steer_id1 = 0;

        //steer_stall = 1;
        first = 0;
        stall_instruction0 = split_instruction1;
        stall_instruction1 = `NOP_INSTRUCTION;
        stall_pc0 = split_pc1;
        stall_pc1 = 0;
        stall_id0 = split_id1;
        stall_id1 = 0;
      end
      {`PIPE_MEMORY, `PIPE_BRANCH}: begin
        steer_instruction0 = split_instruction1;
        steer_instruction1 = split_instruction0;
        steer_pc0 = split_pc1;
        steer_pc1 = split_pc0;
        steer_id0 = split_id1;
        steer_id1 = split_id0;

        //steer_stall = 0;
        first = 1;
      end
      {`PIPE_MEMORY, `PIPE_MEMORY}: begin // hazard. steer stall = 1.
        steer_instruction0 = `NOP_INSTRUCTION;
        steer_instruction1 = split_instruction0;
        steer_pc0 = 0;
        steer_pc1 = split_pc0;
        steer_pc0 = 0;
        steer_pc1 = split_id0;

        //steer_stall = 1;
        first = 1;
        stall_instruction0 = `NOP_INSTRUCTION;
        stall_instruction1 = split_instruction1;
        stall_pc0 = 0;
        stall_pc1 = split_pc1;
        stall_id0 = 0;
        stall_id1 = split_id1;
      end
      {`PIPE_MEMORY, `PIPE_DONT_CARE}: begin
        steer_instruction0 = split_instruction1;
        steer_instruction1 = split_instruction0;
        steer_pc0 = split_pc1;
        steer_pc1 = split_pc0;
        steer_id0 = split_id1;
        steer_id1 = split_id0;

        //steer_stall = 0;
        first = 1;
      end
      {`PIPE_DONT_CARE, `PIPE_BRANCH}: begin
        steer_instruction0 = split_instruction1;
        steer_instruction1 = split_instruction0;
        steer_pc0 = split_pc1;
        steer_pc1 = split_pc0;
        steer_id0 = split_id1;
        steer_id1 = split_id0;

        //steer_stall = 0;
        first = 1;
      end
      default: begin
        steer_instruction0 = split_instruction0;
        steer_instruction1 = split_instruction1;
        steer_pc0 = split_pc0;
        steer_pc1 = split_pc1;
        steer_id0 = split_id0;
        steer_id1 = split_id1;

        //steer_stall = 0;
        first = 0;
      end
    endcase
  end

endmodule
