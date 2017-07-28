
`timescale 1ns / 1ps

module rename_table (
  clk,
  flush,
  reset,

  // push reg -> rob
  push0,
  push_reg_addr0,
  push_rob_addr0,

  push1,
  push_reg_addr1,
  push_rob_addr1,

  // read reg -> rob
  read_reg_addr0_pipe0,
  read_reg_addr1_pipe0,

  read_rob_addr0_pipe0,
  read_rob_addr1_pipe0,

  read_rob_vld0_pipe0,
  read_rob_vld1_pipe0,

  read_reg_addr0_pipe1,
  read_reg_addr1_pipe1,

  read_rob_addr0_pipe1,
  read_rob_addr1_pipe1,

  read_rob_vld0_pipe1,
  read_rob_vld1_pipe1,

  // pop reg -> rob
  pop0,
  pop_reg_addr0,

  pop1,
  pop_reg_addr1
  

  );    

  input wire clk;
  input wire flush;
  input wire reset;

  // push reg -> rob
  input wire                           push0;
  input wire [`NUM_REGISTERS_LOG2-1:0] push_reg_addr0;
  input wire [4:0]                     push_rob_addr0;

  input wire                           push1;
  input wire [`NUM_REGISTERS_LOG2-1:0] push_reg_addr1;
  input wire [4:0]                     push_rob_addr1;

  // read reg -> rob
  input wire [`NUM_REGISTERS_LOG2-1:0] read_reg_addr0_pipe0;
  input wire [`NUM_REGISTERS_LOG2-1:0] read_reg_addr1_pipe0;

  output wire [4:0]                    read_rob_addr0_pipe0;
  output wire [4:0]                    read_rob_addr1_pipe0;

  output wire                          read_rob_vld0_pipe0;
  output wire                          read_rob_vld1_pipe0;

  input wire [`NUM_REGISTERS_LOG2-1:0] read_reg_addr0_pipe1;
  input wire [`NUM_REGISTERS_LOG2-1:0] read_reg_addr1_pipe1;

  output wire [4:0]                    read_rob_addr0_pipe1;
  output wire [4:0]                    read_rob_addr1_pipe1;

  output wire                          read_rob_vld0_pipe1;
  output wire                          read_rob_vld1_pipe1;

  // pop reg -> rob
  input wire                           pop0;
  input wire [`NUM_REGISTERS_LOG2-1:0] pop_reg_addr0;
  input wire [4:0]                     pop_rob_addr0;
  
  input wire                           pop1;
  input wire [`NUM_REGISTERS_LOG2-1:0] pop_reg_addr1;
  input wire [4:0]                     pop_rob_addr1;

  
  reg [4:0] maps [`NUM_REGISTERS-1:0]; 
  reg       vld  [`NUM_REGISTERS-1:0]; 


  assign read_rob_addr0_pipe0 = maps[read_reg_addr0_pipe0];
  assign read_rob_addr1_pipe0 = maps[read_reg_addr1_pipe0];

  assign read_rob_vld0_pipe0  = vld[read_reg_addr0_pipe0];
  assign read_rob_vld1_pipe0  = vld[read_reg_addr1_pipe0];

  assign read_rob_addr0_pipe1 = maps[read_reg_addr0_pipe1];
  assign read_rob_addr1_pipe1 = maps[read_reg_addr1_pipe1];

  assign read_rob_vld0_pipe1  = vld[read_reg_addr0_pipe1];
  assign read_rob_vld1_pipe1  = vld[read_reg_addr1_pipe1];

  integer i;

  initial begin
    for(i=0; i<32; i=i+1) begin
      maps[i] = 0;
      vld[i] = 0;
    end
  end

  always @(posedge clk) begin

    if (reset | flush) begin // this is wrong. cant flush everything. need to be speculative.

      for(i=0; i<32; i=i+1) begin
        maps[i] = 0;
        vld[i] = 0;
      end

    end else begin

      if (push0) begin
        maps[push_reg_addr0] <= push_rob_addr0;
        vld[push_reg_addr0]  <= 1;
      end

      if (push1) begin
        maps[push_reg_addr1] <= push_rob_addr1;
        vld[push_reg_addr1]  <= 1;
      end

      if (pop0 && (maps[pop_reg_addr0] == pop_rob_addr0)) begin
        vld[push_reg_addr0]  <= 0;
      end

      if (pop1 && (maps[pop_reg_addr1] == pop_rob_addr1)) begin
        vld[push_reg_addr1]  <= 0;
      end

    end
  end

endmodule