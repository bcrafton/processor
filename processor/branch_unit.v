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
  branch_taken_address,

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
  input wire [`ADDR_WIDTH-1:0] branch_taken_address;

  output reg [`NUM_PIPE_MASKS-1:0] flush;
  output reg [`ADDR_WIDTH-1:0] jump_address;

  input wire [`ADDR_WIDTH-1:0] pc;
  output wire [`ADDR_WIDTH-1:0] branch_predict;
  output wire take_branch;

  wire blt_write = is_branch;
  wire hit = branch_cond | (jop == `JMP_OP_JR);

  reg branch_cond;
  reg is_branch;

  blt l(
    .clk(clk),

    .write(blt_write),
    .write_key(id_ex_pc),
    .write_val(jump_address),
    .hit(hit),

    .read_key(pc),
    .read_val(branch_predict),
    .read_valid(take_branch),

    .reset(reset)
  );

  initial begin
    flush = 0;
    jump_address = 0;
    branch_cond = 0;
    is_branch = 0;
  end

  always@(*) begin
  
    case(jop)
      `JMP_OP_JEQ: branch_cond = zero == 1'b1;
      `JMP_OP_JNE: branch_cond = zero == 1'b0;

      `JMP_OP_JL:  branch_cond = less == 1'b1;
      `JMP_OP_JLE: branch_cond = (less == 1'b1) | (zero == 1'b1);

      `JMP_OP_JG:  branch_cond = greater == 1'b1;
      `JMP_OP_JGE: branch_cond = (greater == 1'b1) | (zero == 1'b1);

      `JMP_OP_JZ:  branch_cond = zero == 1'b1;
      `JMP_OP_JNZ: branch_cond = zero == 1'b0;

      default: branch_cond = 1'b0;
    endcase

    case(jop)
      `JMP_OP_JEQ: is_branch = 1;
      `JMP_OP_JNE: is_branch = 1;

      `JMP_OP_JL:  is_branch = 1;
      `JMP_OP_JLE: is_branch = 1;

      `JMP_OP_JG:  is_branch = 1;
      `JMP_OP_JGE: is_branch = 1;

      `JMP_OP_JZ:  is_branch = 1;
      `JMP_OP_JNZ: is_branch = 1;

      `JMP_OP_JR:  is_branch = 1;

      default: is_branch = 0;
    endcase

    case(jop)
      `JMP_OP_NOP: flush = 0;
      `JMP_OP_J:   flush = `PIPE_REG_EX_MEM;
      `JMP_OP_JR:  begin

        if (branch_taken) begin
          if(branch_taken_address == id_ex_reg_address) begin
            flush = `PIPE_REG_EX_MEM;
          end else begin
            flush = `PIPE_REG_EX_MEM | `PIPE_REG_ID_EX | `PIPE_REG_IF_ID | `PIPE_REG_PC;
          end
        end else begin
          flush = `PIPE_REG_EX_MEM | `PIPE_REG_ID_EX | `PIPE_REG_IF_ID | `PIPE_REG_PC;
        end

      end
      `JMP_OP_JEQ: begin
        if (branch_cond ^ branch_taken) begin
          flush = `PIPE_REG_EX_MEM | `PIPE_REG_ID_EX | `PIPE_REG_IF_ID | `PIPE_REG_PC;
        end else if (branch_cond & branch_taken) begin
          if (branch_taken_address != id_ex_imm_address) begin
            $display("Addresses are not same, FAIL");
          end
          flush = `PIPE_REG_EX_MEM;
        end else begin
          flush = 0;
        end
      end

      `JMP_OP_JNE: begin
        if (branch_cond ^ branch_taken) begin
          flush = `PIPE_REG_EX_MEM | `PIPE_REG_ID_EX | `PIPE_REG_IF_ID | `PIPE_REG_PC;
        end else if (branch_cond & branch_taken) begin
          if (branch_taken_address != id_ex_imm_address) begin
            $display("Addresses are not same, FAIL");
          end
          flush = `PIPE_REG_EX_MEM;
        end else begin
          flush = 0;
        end
      end

      `JMP_OP_JL: begin
        if (branch_cond ^ branch_taken) begin
          flush = `PIPE_REG_EX_MEM | `PIPE_REG_ID_EX | `PIPE_REG_IF_ID | `PIPE_REG_PC;
        end else if (branch_cond & branch_taken) begin
          if (branch_taken_address != id_ex_imm_address) begin
            $display("Addresses are not same, FAIL");
          end
          flush = `PIPE_REG_EX_MEM;
        end else begin
          flush = 0;
        end
      end

      `JMP_OP_JLE: begin
        if (branch_cond ^ branch_taken) begin
          flush = `PIPE_REG_EX_MEM | `PIPE_REG_ID_EX | `PIPE_REG_IF_ID | `PIPE_REG_PC;
        end else if (branch_cond & branch_taken) begin
          if (branch_taken_address != id_ex_imm_address) begin
            $display("Addresses are not same, FAIL");
          end
          flush = `PIPE_REG_EX_MEM;
        end else begin
          flush = 0;
        end
      end

      `JMP_OP_JG: begin
        if (branch_cond ^ branch_taken) begin
          flush = `PIPE_REG_EX_MEM | `PIPE_REG_ID_EX | `PIPE_REG_IF_ID | `PIPE_REG_PC;
        end else if (branch_cond & branch_taken) begin
          if (branch_taken_address != id_ex_imm_address) begin
            $display("Addresses are not same, FAIL");
          end
          flush = `PIPE_REG_EX_MEM;
        end else begin
          flush = 0;
        end
      end

      `JMP_OP_JGE: begin
        if (branch_cond ^ branch_taken) begin
          flush = `PIPE_REG_EX_MEM | `PIPE_REG_ID_EX | `PIPE_REG_IF_ID | `PIPE_REG_PC;
        end else if (branch_cond & branch_taken) begin
          if (branch_taken_address != id_ex_imm_address) begin
            $display("Addresses are not same, FAIL");
          end
          flush = `PIPE_REG_EX_MEM;
        end else begin
          flush = 0;
        end
      end

      `JMP_OP_JZ: begin
        if (branch_cond ^ branch_taken) begin
          flush = `PIPE_REG_EX_MEM | `PIPE_REG_ID_EX | `PIPE_REG_IF_ID | `PIPE_REG_PC;
        end else if (branch_cond & branch_taken) begin
          if (branch_taken_address != id_ex_imm_address) begin
            $display("Addresses are not same, FAIL");
          end
          flush = `PIPE_REG_EX_MEM;
        end else begin
          flush = 0;
        end
      end

      `JMP_OP_JNZ: begin
        if (branch_cond ^ branch_taken) begin
          flush = `PIPE_REG_EX_MEM | `PIPE_REG_ID_EX | `PIPE_REG_IF_ID | `PIPE_REG_PC;
        end else if (branch_cond & branch_taken) begin
          if (branch_taken_address != id_ex_imm_address) begin
            $display("Addresses are not same, FAIL");
          end
          flush = `PIPE_REG_EX_MEM;
        end else begin
          flush = 0;
        end
      end

      default: flush = 0;
    endcase

    if(jop == `JMP_OP_JR) begin
      jump_address = id_ex_reg_address;
    end else if (!branch_cond & branch_taken) begin
      jump_address = id_ex_pc+1;
    end else begin
      jump_address = id_ex_imm_address;
    end

  end

endmodule
