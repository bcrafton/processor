
`timescale 1ns / 1ps

// http://www.asic-world.com/examples/verilog/syn_fifo.html

module fifo (
  clk,
  reset,

  push0,
  data_in0,

  push1,
  data_in1,

  pop0,
  data_out0,

  pop1,
  data_out1,

  empty,
  full
  );    

  // 32x32 fifo by default.
  parameter DATA_WIDTH = 32;
  parameter ADDR_WIDTH = 5;
  parameter RAM_DEPTH = (1 << ADDR_WIDTH);

  input wire clk;
  input wire reset;

  input wire push0;
  input wire [DATA_WIDTH-1:0] data_in0;

  input wire push1;
  input wire [DATA_WIDTH-1:0] data_in1;

  input wire pop0;
  output wire [DATA_WIDTH-1:0] data_out0;

  input wire pop1;
  output wire [DATA_WIDTH-1:0] data_out1;

  output wire full;
  output wire empty;

  reg [ADDR_WIDTH-1:0] wr_pointer;
  reg [ADDR_WIDTH-1:0] rd_pointer;
  reg [ADDR_WIDTH:0] count;
  wire [ADDR_WIDTH:0] free;

  reg [DATA_WIDTH-1:0] mem [0:RAM_DEPTH-1];

  integer i;

  assign data_out0 = mem[rd_pointer];
  assign data_out1 = mem[rd_pointer+1];

  assign full = (count == (RAM_DEPTH-1));
  assign free = RAM_DEPTH - 1 - count;
  assign empty = (count == 0);

  wire read0 =  pop0  && (count >= 1);
  wire read1 =  pop1  && (count >= 2);
  wire write0 = push0 && (free >= 1);
  wire write1 = push1 && (free >= 2);

  initial begin
    wr_pointer = 0;
    rd_pointer = 0;
    count = 0;
    for(i=0; i<RAM_DEPTH; i=i+1) begin
      mem[i] = 0;
    end
  end

  always @(posedge clk) begin

    if (reset) begin

      wr_pointer <= 0;
      rd_pointer <= 0;
      count <= 0;
      for(i=0; i<RAM_DEPTH; i=i+1) begin
        mem[i] = 0;
      end

    end else begin

      if (write0 && write1) begin
        mem[wr_pointer] <= data_in0;
        mem[wr_pointer+1] <= data_in1;
        wr_pointer <= wr_pointer + 2;
      end else if (write0) begin
        mem[wr_pointer] <= data_in0;
        wr_pointer <= wr_pointer + 1;
      end

      if (read0 && read1) begin
        rd_pointer <= rd_pointer + 2;
      end else if (read0) begin
        rd_pointer <= rd_pointer + 1;
      end

      count <= count + write0 + write1 - read0 - read1;

    end
  end

endmodule
