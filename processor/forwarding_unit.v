`timescale 1ns / 1ps

`include "defines.vh"

// parameterize register value size?
// this feels like something that should be defined at processor level ...
module forwarding_unit(
  id_ex_rs,
  id_ex_rt,

  ex_mem_first,
  mem_wb_first,

  ex_mem_rd0,
  mem_wb_rd0,
  ex_mem_reg_write0,
  mem_wb_reg_write0,

  ex_mem_rd1,
  mem_wb_rd1,
  ex_mem_reg_write1,
  mem_wb_reg_write1,

  forward_a,
  forward_b,
  );

  //parameter NUM_REGISTERS_LOG2 = $clog2(`NUM_REGISTERS);

  input wire [`NUM_REGISTERS_LOG2-1:0] id_ex_rs;
  input wire [`NUM_REGISTERS_LOG2-1:0] id_ex_rt;

  input wire ex_mem_first;
  input wire mem_wb_first;

  // this isnt actually rd reg, its reg dst result.
  input wire [`NUM_REGISTERS_LOG2-1:0] ex_mem_rd0;
  input wire [`NUM_REGISTERS_LOG2-1:0] mem_wb_rd0;
  input wire ex_mem_reg_write0;
  input wire mem_wb_reg_write0;

  // this isnt actually rd reg, its reg dst result.
  input wire [`NUM_REGISTERS_LOG2-1:0] ex_mem_rd1;
  input wire [`NUM_REGISTERS_LOG2-1:0] mem_wb_rd1;
  input wire ex_mem_reg_write1;
  input wire mem_wb_reg_write1;

  output reg [`FORWARD_BITS-1:0] forward_a;
  output reg [`FORWARD_BITS-1:0] forward_b;

  always @(*) begin

    if(!ex_mem_first) begin
      
      if(!mem_wb_first) begin
        if(ex_mem_reg_write0 && (id_ex_rs == ex_mem_rd0)) begin
          forward_a <= `FORWARD_EX_MEM0;
        end else if(ex_mem_reg_write1 && (id_ex_rs == ex_mem_rd1)) begin
          forward_a <= `FORWARD_EX_MEM1;
        end else if(mem_wb_reg_write0 && (id_ex_rs == mem_wb_rd0)) begin
          forward_a <= `FORWARD_MEM_WB0;
        end else if(mem_wb_reg_write1 && (id_ex_rs == mem_wb_rd1)) begin
          forward_a <= `FORWARD_MEM_WB1;
        end else begin
          forward_a <= `NO_FORWARD;
        end

        if(ex_mem_reg_write0 && (id_ex_rt == ex_mem_rd0)) begin
          forward_b <= `FORWARD_EX_MEM0;
        end else if(ex_mem_reg_write1 && (id_ex_rt == ex_mem_rd1)) begin
          forward_b <= `FORWARD_EX_MEM1;
        end else if(mem_wb_reg_write0 && (id_ex_rt == mem_wb_rd0)) begin
          forward_b <= `FORWARD_MEM_WB0;
        end else if(mem_wb_reg_write1 && (id_ex_rt == mem_wb_rd1)) begin
          forward_b <= `FORWARD_MEM_WB1;
        end else begin
          forward_b <= `NO_FORWARD;
        end
      end else begin // if(!mem_wb_first) begin
        if(ex_mem_reg_write0 && (id_ex_rs == ex_mem_rd0)) begin
          forward_a <= `FORWARD_EX_MEM0;
        end else if(ex_mem_reg_write1 && (id_ex_rs == ex_mem_rd1)) begin
          forward_a <= `FORWARD_EX_MEM1;
        end else if(mem_wb_reg_write1 && (id_ex_rs == mem_wb_rd1)) begin
          forward_a <= `FORWARD_MEM_WB1;
        end else if(mem_wb_reg_write0 && (id_ex_rs == mem_wb_rd0)) begin
          forward_a <= `FORWARD_MEM_WB0;
        end else begin
          forward_a <= `NO_FORWARD;
        end

        if(ex_mem_reg_write0 && (id_ex_rt == ex_mem_rd0)) begin
          forward_b <= `FORWARD_EX_MEM0;
        end else if(ex_mem_reg_write1 && (id_ex_rt == ex_mem_rd1)) begin
          forward_b <= `FORWARD_EX_MEM1;
        end else if(mem_wb_reg_write1 && (id_ex_rt == mem_wb_rd1)) begin
          forward_b <= `FORWARD_MEM_WB1;
        end else if(mem_wb_reg_write0 && (id_ex_rt == mem_wb_rd0)) begin
          forward_b <= `FORWARD_MEM_WB0;
        end else begin
          forward_b <= `NO_FORWARD;
        end
      end

    end else begin // if(!ex_mem_first) begin

      if(!mem_wb_first) begin
        if(ex_mem_reg_write1 && (id_ex_rs == ex_mem_rd1)) begin
          forward_a <= `FORWARD_EX_MEM1;
        end else if(ex_mem_reg_write0 && (id_ex_rs == ex_mem_rd0)) begin
          forward_a <= `FORWARD_EX_MEM0;
        end else if(mem_wb_reg_write0 && (id_ex_rs == mem_wb_rd0)) begin
          forward_a <= `FORWARD_MEM_WB0;
        end else if(mem_wb_reg_write1 && (id_ex_rs == mem_wb_rd1)) begin
          forward_a <= `FORWARD_MEM_WB1;
        end else begin
          forward_a <= `NO_FORWARD;
        end

        if(ex_mem_reg_write1 && (id_ex_rt == ex_mem_rd1)) begin
          forward_b <= `FORWARD_EX_MEM1;
        end else if(ex_mem_reg_write0 && (id_ex_rt == ex_mem_rd0)) begin
          forward_b <= `FORWARD_EX_MEM0;
        end else if(mem_wb_reg_write0 && (id_ex_rt == mem_wb_rd0)) begin
          forward_b <= `FORWARD_MEM_WB0;
        end else if(mem_wb_reg_write1 && (id_ex_rt == mem_wb_rd1)) begin
          forward_b <= `FORWARD_MEM_WB1;
        end else begin
          forward_b <= `NO_FORWARD;
        end
      end else begin // if(!mem_wb_first) begin
        if(ex_mem_reg_write1 && (id_ex_rs == ex_mem_rd1)) begin
          forward_a <= `FORWARD_EX_MEM1;
        end else if(ex_mem_reg_write0 && (id_ex_rs == ex_mem_rd0)) begin
          forward_a <= `FORWARD_EX_MEM0;
        end else if(mem_wb_reg_write1 && (id_ex_rs == mem_wb_rd1)) begin
          forward_a <= `FORWARD_MEM_WB1;
        end else if(mem_wb_reg_write0 && (id_ex_rs == mem_wb_rd0)) begin
          forward_a <= `FORWARD_MEM_WB0;
        end else begin
          forward_a <= `NO_FORWARD;
        end

        if(ex_mem_reg_write1 && (id_ex_rt == ex_mem_rd1)) begin
          forward_b <= `FORWARD_EX_MEM1;
        end else if(ex_mem_reg_write0 && (id_ex_rt == ex_mem_rd0)) begin
          forward_b <= `FORWARD_EX_MEM0;
        end else if(mem_wb_reg_write1 && (id_ex_rt == mem_wb_rd1)) begin
          forward_b <= `FORWARD_MEM_WB1;
        end else if(mem_wb_reg_write0 && (id_ex_rt == mem_wb_rd0)) begin
          forward_b <= `FORWARD_MEM_WB0;
        end else begin
          forward_b <= `NO_FORWARD;
        end
      end

    end



  end
endmodule
