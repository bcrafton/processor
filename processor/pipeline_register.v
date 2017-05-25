`timescale 1ns / 1ps

module id_ex_register(
  clk,
  stall,
  flush,

  rs_in,
  rt_in,
  rd_in,
  reg_read_data_1_in,
  reg_read_data_2_in,
  immediate_in,
  address_in,
  shamt_in,
  reg_dst_in,
  mem_to_reg_in,
  alu_op_in,
  mem_op_in,
  alu_src_in,
  reg_write_in,
  jop_in,
  address_src_in,
  instruction_in,

  rs_out,
  rt_out,
  rd_out,
  reg_read_data_1_out,
  reg_read_data_2_out,
  immediate_out,
  address_out,
  shamt_out,
  reg_dst_out,
  mem_to_reg_out,
  alu_op_out,
  mem_op_out,
  alu_src_out,
  reg_write_out,
  jop_out,
  address_src_out,
  instruction_out,
  );

  input wire clk;
  input wire flush;
  input wire stall;

  input wire [`NUM_REGISTERS_LOG2-1:0] rs_in;
  input wire [`NUM_REGISTERS_LOG2-1:0] rt_in;
  input wire [`NUM_REGISTERS_LOG2-1:0] rd_in;
  input wire [`DATA_WIDTH-1:0] reg_read_data_1_in;
  input wire [`DATA_WIDTH-1:0] reg_read_data_2_in;
  input wire [`IMM_WIDTH-1:0] immediate_in;
  input wire [`ADDR_WIDTH-1:0] address_in;
  input wire [`SHAMT_BITS-1:0] shamt_in;
  input wire reg_dst_in;
  input wire mem_to_reg_in;
  input wire [`ALU_OP_BITS-1:0] alu_op_in;
  input wire [`MEM_OP_BITS-1:0] mem_op_in;
  input wire alu_src_in;
  input wire reg_write_in;
  input wire [`JUMP_BITS-1:0] jop_in;
  input wire address_src_in;
  input wire [`INST_WIDTH-1:0] instruction_in;

  reg stall_latch;
  reg flush_latch;

  reg [`NUM_REGISTERS_LOG2-1:0] rs;
  reg [`NUM_REGISTERS_LOG2-1:0] rt;
  reg [`NUM_REGISTERS_LOG2-1:0] rd;
  reg [`DATA_WIDTH-1:0] reg_read_data_1;
  reg [`DATA_WIDTH-1:0] reg_read_data_2;
  reg [`IMM_WIDTH-1:0] immediate;
  reg [`ADDR_WIDTH-1:0] address;
  reg [`SHAMT_BITS-1:0] shamt;
  reg reg_dst;
  reg mem_to_reg;
  reg [`ALU_OP_BITS-1:0] alu_op;
  reg [`MEM_OP_BITS-1:0] mem_op;
  reg alu_src;
  reg reg_write;
  reg [`JUMP_BITS-1:0] jop;
  reg address_src;
  reg [`INST_WIDTH-1:0] instruction;

  output wire [`NUM_REGISTERS_LOG2-1:0] rs_out;
  output wire [`NUM_REGISTERS_LOG2-1:0] rt_out;
  output wire [`NUM_REGISTERS_LOG2-1:0] rd_out;
  output wire [`DATA_WIDTH-1:0] reg_read_data_1_out;
  output wire [`DATA_WIDTH-1:0] reg_read_data_2_out;
  output wire [`IMM_WIDTH-1:0] immediate_out;
  output wire [`ADDR_WIDTH-1:0] address_out;
  output wire [`SHAMT_BITS-1:0] shamt_out;
  output wire reg_dst_out;
  output wire mem_to_reg_out;
  output wire [`ALU_OP_BITS-1:0] alu_op_out;
  output wire [`MEM_OP_BITS-1:0] mem_op_out;
  output wire alu_src_out;
  output wire reg_write_out;
  output wire [`JUMP_BITS-1:0] jop_out;
  output wire address_src_out;
  output wire [`INST_WIDTH-1:0] instruction_out;

  wire nop;
  assign nop = flush_latch || stall_latch;

  assign rs_out =              nop ? 0 : rs;
  assign rt_out =              nop ? 0 : rt;
  assign rd_out =              nop ? 0 : rd;
  assign reg_read_data_1_out = nop ? 0 : reg_read_data_1;
  assign reg_read_data_2_out = nop ? 0 : reg_read_data_2;
  assign immediate_out =       nop ? 0 : immediate;
  assign address_out =         nop ? 0 : address;
  assign shamt_out =           nop ? 0 : shamt;
  assign reg_dst_out =         nop ? 0 : reg_dst;
  assign mem_to_reg_out =      nop ? 0 : mem_to_reg;
  assign alu_op_out =          nop ? 0 : alu_op;
  assign mem_op_out =          nop ? 0 : mem_op;
  assign alu_src_out =         nop ? 0 : alu_src;
  assign reg_write_out =       nop ? 0 : reg_write;
  assign jop_out =             nop ? 0 : jop;
  assign address_src_out =     nop ? 0 : address_src;
  assign instruction_out =     nop ? 0 : instruction;

  initial begin
    stall_latch <= 0;
    flush_latch <= 0;

    rs <= 0;
    rt <= 0;
    rd <= 0;
    reg_read_data_1 <= 0;
    reg_read_data_2 <= 0;
    immediate <= 0;
    address <= 0;
    shamt <= 0;
    reg_dst <= 0;
    mem_to_reg <= 0;
    alu_op <= 0;
    mem_op <= 0;
    alu_src <= 0;
    reg_write <= 0;
    jop <= 0;
    address_src <= 0;
    instruction <= 0;
  end

  always @(posedge clk) begin

    stall_latch <= stall;
    flush_latch <= flush;

    if(!stall) begin
      if(flush) begin
        rs <= 0;
        rt <= 0;
        rd <= 0;
        reg_read_data_1 <= 0;
        reg_read_data_2 <= 0;
        immediate <= 0;
        address <= 0;
        shamt <= 0;
        reg_dst <= 0;
        mem_to_reg <= 0;
        alu_op <= 0;
        mem_op <= 0;
        alu_src <= 0;
        reg_write <= 0;
        jop <= 0;
        address_src <= 0;
        instruction <= 0;
      end else begin	
        rs <= rs_in;
        rt <= rt_in;
        rd <= rd_in;
        reg_read_data_1 <= reg_read_data_1_in;
        reg_read_data_2 <= reg_read_data_2_in;
        immediate <= immediate_in;
        address <= address_in;
        shamt <= shamt_in;
        reg_dst <= reg_dst_in;
        mem_to_reg <= mem_to_reg_in;
        alu_op <= alu_op_in;
        mem_op <= mem_op_in;
        alu_src <= alu_src_in;
        reg_write <= reg_write_in;
        jop <= jop_in;
        address_src <= address_src_in;
        instruction <=instruction_in;
      end
    end
  end

endmodule

module ex_mem_register(
  clk,
  stall,
  flush,

  alu_result_in,
  data_1_in,
  data_2_in,
  reg_dst_result_in,
  jop_in,
  mem_op_in,
  mem_to_reg_in,
  reg_write_in,
  address_in,
  address_src_result_in,
  instruction_in,

  alu_result_out,
  data_1_out,
  data_2_out,
  reg_dst_result_out,
  jop_out,
  mem_op_out,
  mem_to_reg_out,
  reg_write_out,
  address_out,
  address_src_result_out,
  instruction_out,
  );

  input wire clk;
  input wire stall;
  input wire flush;

  input wire [`DATA_WIDTH-1:0] alu_result_in;
  input wire [`DATA_WIDTH-1:0] data_1_in;
  input wire [`DATA_WIDTH-1:0] data_2_in;
  input wire [`NUM_REGISTERS_LOG2-1:0] reg_dst_result_in;
  input wire [`JUMP_BITS-1:0] jop_in;
  input wire [`MEM_OP_BITS-1:0] mem_op_in;
  input wire mem_to_reg_in;
  input wire reg_write_in;
  input wire [`ADDR_WIDTH-1:0] address_in;
  input wire [`ADDR_WIDTH-1:0] address_src_result_in;
  input wire [`INST_WIDTH-1:0] instruction_in;

  reg stall_latch;
  reg flush_latch;

  reg [`DATA_WIDTH-1:0] alu_result;
  reg [`DATA_WIDTH-1:0] data_1;
  reg [`DATA_WIDTH-1:0] data_2;
  reg [`NUM_REGISTERS_LOG2-1:0] reg_dst_result;
  reg [`JUMP_BITS-1:0] jop;
  reg [`MEM_OP_BITS-1:0] mem_op;
  reg mem_to_reg;
  reg reg_write;
  reg [`ADDR_WIDTH-1:0] address;
  reg [`ADDR_WIDTH-1:0] address_src_result;
  reg [`INST_WIDTH-1:0] instruction;

  output wire [`DATA_WIDTH-1:0] alu_result_out;
  output wire [`DATA_WIDTH-1:0] data_1_out;
  output wire [`DATA_WIDTH-1:0] data_2_out;
  output wire [`NUM_REGISTERS_LOG2-1:0] reg_dst_result_out;
  output wire [`JUMP_BITS-1:0] jop_out;
  output wire [`MEM_OP_BITS-1:0] mem_op_out;
  output wire mem_to_reg_out;
  output wire reg_write_out;
  output wire [`ADDR_WIDTH-1:0] address_out;
  output wire [`ADDR_WIDTH-1:0] address_src_result_out;
  output wire [`INST_WIDTH-1:0] instruction_out;

  wire nop;
  assign nop = flush_latch || stall_latch;

  assign alu_result_out =         nop ? 0 : alu_result;
  assign data_1_out =             nop ? 0 : data_1;
  assign data_2_out =             nop ? 0 : data_2;
  assign reg_dst_result_out =     nop ? 0 : reg_dst_result;
  assign jop_out =                nop ? 0 : jop;
  assign mem_op_out =             nop ? 0 : mem_op;
  assign mem_to_reg_out =         nop ? 0 : mem_to_reg;
  assign reg_write_out =          nop ? 0 : reg_write;
  assign address_out =            nop ? 0 : address;
  assign address_src_result_out = nop ? 0 : address_src_result;
  assign instruction_out =        nop ? 0 : instruction;

  initial begin
    alu_result <= 0;
    data_1 <= 0;
    data_2 <= 0;
    reg_dst_result <= 0;
    jop <= 0;
    mem_op <= 0;
    mem_to_reg <= 0;
    reg_write <= 0;
    address <= 0;
    address_src_result <= 0;
    instruction <= 0;
  end

  always @(posedge clk) begin
    
    stall_latch <= stall;
    flush_latch <= flush;

    if(!stall) begin
      if(flush) begin
        alu_result <= 0;
        data_1 <= 0;
        data_2 <= 0;
        reg_dst_result <= 0;
        jop <= 0;
        mem_op <= 0;
        mem_to_reg <= 0;
        reg_write <= 0;
        address <= 0;
        address_src_result <= 0;
        instruction <= 0;
      end else begin
        alu_result <= alu_result_in;
        data_1 <= data_1_in;
        data_2 <= data_2_in;
        reg_dst_result <= reg_dst_result_in;
        jop <= jop_in;
        mem_op <= mem_op_in;
        mem_to_reg <= mem_to_reg_in;
        reg_write <= reg_write_in;
        address <= address_in;
        address_src_result <= address_src_result_in;
        instruction <= instruction_in;
      end
    end
  end

endmodule

module mem_wb_register(
  clk,
  stall,
  flush,

  mem_to_reg_in,
  ram_read_data_in,
  alu_result_in,
  reg_dst_result_in,
  reg_write_in,
  instruction_in,

  mem_to_reg_out,
  ram_read_data_out,
  alu_result_out,
  reg_dst_result_out,
  reg_write_out,
  instruction_out,
  );

  input wire clk;
  input wire stall;
  input wire flush;

  input wire mem_to_reg_in;
  input wire [`DATA_WIDTH-1:0] ram_read_data_in;
  input wire [`DATA_WIDTH-1:0] alu_result_in;
  input wire [`NUM_REGISTERS_LOG2-1:0] reg_dst_result_in;
  input wire reg_write_in;
  input wire [`INST_WIDTH-1:0] instruction_in;

  reg stall_latch;
  reg flush_latch;

  reg mem_to_reg;
  reg [`DATA_WIDTH-1:0] ram_read_data;
  reg [`DATA_WIDTH-1:0] alu_result;
  reg [`NUM_REGISTERS_LOG2-1:0] reg_dst_result;
  reg reg_write;
  reg [`INST_WIDTH-1:0] instruction;

  output wire mem_to_reg_out;
  output wire [`DATA_WIDTH-1:0] ram_read_data_out;
  output wire [`DATA_WIDTH-1:0] alu_result_out;
  output wire [`NUM_REGISTERS_LOG2-1:0] reg_dst_result_out;
  output wire reg_write_out;
  output wire [`INST_WIDTH-1:0] instruction_out;

  wire nop;
  assign nop = flush_latch || stall_latch;

  assign mem_to_reg_out =     nop ? 0 : mem_to_reg;
  assign ram_read_data_out =  nop ? 0 : ram_read_data;
  assign alu_result_out =     nop ? 0 : alu_result;
  assign reg_dst_result_out = nop ? 0 : reg_dst_result;
  assign reg_write_out =      nop ? 0 : reg_write;
  assign instruction_out =    nop ? 0 : instruction;

  initial begin
    mem_to_reg <= 0;
    ram_read_data <= 0;
    alu_result <= 0;
    reg_dst_result <= 0;
    reg_write <= 0;
    instruction <= 0;
  end

  always @(posedge clk) begin

    stall_latch <= stall;
    flush_latch <= flush;

    if(!stall) begin
      if(flush) begin
        mem_to_reg <= 0;
        ram_read_data <= 0;
        alu_result <= 0;
        reg_dst_result <= 0;
        reg_write <= 0;
        instruction <= 0;
      end else begin
        mem_to_reg <= mem_to_reg_in;
        ram_read_data <= ram_read_data_in;
        alu_result <= alu_result_in;
        reg_dst_result <= reg_dst_result_in;
        reg_write <= reg_write_in;
        instruction <= instruction_in;
      end
    end
  end

endmodule
