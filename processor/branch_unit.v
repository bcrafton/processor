`timescale 1ns / 1ps

module branch_unit(
  clk,

  zero,
  less,
  greater,

  // these are only for writing to lut on branch miss.
  // still need for reading.
  id_ex_pc,
  id_ex_reg_address,
  id_ex_imm_address,

  pc,
  take_branch,
  branch_predict,
  
  jop,
  branch_taken,

  flush,
  jump_address,

  reset,
  );

  input wire clk;
  input wire reset;

  input wire zero;
  input wire less;
  input wire greater;

  input wire [`ADDR_WIDTH-1:0] id_ex_pc;
  input wire [`ADDR_WIDTH-1:0] id_ex_reg_address;
  input wire [`ADDR_WIDTH-1:0] id_ex_imm_address;

  input wire [`JUMP_BITS-1:0] jop;

  input wire branch_taken;

  output reg [`NUM_PIPE_MASKS-1:0] flush;
  output reg [`ADDR_WIDTH-1:0] jump_address;

  input wire [`ADDR_WIDTH-1:0] pc;
  output wire [`ADDR_WIDTH-1:0] branch_predict;
  output wire take_branch;

  // how was this not more obvious.
  // went and started adding them to each one of jumps down there.
  wire lut_write = (flush == (`PIPE_REG_EX_MEM | `PIPE_REG_ID_EX | `PIPE_REG_IF_ID | `PIPE_REG_PC)) && (jop != `JMP_OP_JR) ? 1 : 0;

  lut l(
    .clk(clk),
    .write(lut_write),
    
    .write_key(id_ex_pc),
    .write_val(jump_address),
    
    .read_key(pc),
    .read_val(branch_predict),
    .read_valid(take_branch),
    .reset(reset)
  );

  initial begin
    flush <= 0;
    jump_address <= 0;
  end

  always@(*) begin
  
    case(jop)
      `JMP_OP_NOP: flush = 0;
      `JMP_OP_J:   flush = `PIPE_REG_EX_MEM;
      `JMP_OP_JR:  flush = `PIPE_REG_EX_MEM | `PIPE_REG_ID_EX | `PIPE_REG_IF_ID | `PIPE_REG_PC;

      `JMP_OP_JEQ: flush = ((zero == 1'b1) ^ branch_taken) == 1'b1 ? `PIPE_REG_EX_MEM | `PIPE_REG_ID_EX | `PIPE_REG_IF_ID | `PIPE_REG_PC : 0;
      `JMP_OP_JNE: flush = ((zero == 1'b0) ^ branch_taken) == 1'b1 ? `PIPE_REG_EX_MEM | `PIPE_REG_ID_EX | `PIPE_REG_IF_ID | `PIPE_REG_PC : 0;

      `JMP_OP_JL:  flush = ((less == 1'b1) ^ branch_taken) == 1'b1 ? `PIPE_REG_EX_MEM | `PIPE_REG_ID_EX | `PIPE_REG_IF_ID | `PIPE_REG_PC : 0;
      `JMP_OP_JLE: flush = ((less == 1'b1) ^ branch_taken) == 1'b1 ? `PIPE_REG_EX_MEM | `PIPE_REG_ID_EX | `PIPE_REG_IF_ID | `PIPE_REG_PC : 0;

      `JMP_OP_JG:  flush = ((greater == 1'b1) ^ branch_taken) == 1'b1 ? `PIPE_REG_EX_MEM | `PIPE_REG_ID_EX | `PIPE_REG_IF_ID | `PIPE_REG_PC : 0;
      `JMP_OP_JGE: flush = ((greater == 1'b1) ^ branch_taken) == 1'b1 ? `PIPE_REG_EX_MEM | `PIPE_REG_ID_EX | `PIPE_REG_IF_ID | `PIPE_REG_PC : 0;

      `JMP_OP_JZ:  flush = ((zero == 1'b1) ^ branch_taken) == 1'b1 ? `PIPE_REG_EX_MEM | `PIPE_REG_ID_EX | `PIPE_REG_IF_ID | `PIPE_REG_PC : 0;
      `JMP_OP_JNZ: flush = ((zero == 1'b0) ^ branch_taken) == 1'b1 ? `PIPE_REG_EX_MEM | `PIPE_REG_ID_EX | `PIPE_REG_IF_ID | `PIPE_REG_PC : 0;

      //`JMP_OP_JO:  flush <= (zero == 1'b1);
    endcase

    if(jop == `JMP_OP_JR) begin
      jump_address = id_ex_reg_address;
    end else if (flush & branch_taken) begin
      jump_address = id_ex_pc+1;
    end else begin
      jump_address = id_ex_imm_address;
    end

  end

endmodule
