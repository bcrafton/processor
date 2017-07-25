
`timescale 1ns / 1ps

// http://www.asic-world.com/examples/verilog/syn_fifo.html

module reorder_buffer (
  clk,
  reset,

  oldest0,
  oldest1,

  retire0,
  retire1,

  push0,
  iq_index0,
  data_in0,

  push1,
  iq_index1,
  data_in1,

  empty,
  full
  );    

  // 32x32 fifo by default.
  parameter DATA_WIDTH = 32;
  parameter ADDR_WIDTH = 5;
  parameter RAM_DEPTH = (1 << ADDR_WIDTH);

  input wire clk;
  input wire reset;

  input wire [`NUM_IQ_ENTRIES_LOG2-1:0] oldest0;
  input wire [`NUM_IQ_ENTRIES_LOG2-1:0] oldest1;

  output wire retire0;
  output wire retire1;

  input wire push0;
  input wire [`NUM_IQ_ENTRIES_LOG2-1:0] iq_index0;
  input wire [DATA_WIDTH-1:0] data_in0;

  input wire push1;
  input wire [`NUM_IQ_ENTRIES_LOG2-1:0] iq_index1;
  input wire [DATA_WIDTH-1:0] data_in1;

  reg [DATA_WIDTH-1:0] mem [0:RAM_DEPTH-1];
  reg                  vld [0:RAM_DEPTH-1];

  integer i;

  assign retire0 = vld[oldest0] == 1;
  assign retire1 = retire0 && vld[oldest1] == 1;

  initial begin
    for(i=0; i<RAM_DEPTH; i=i+1) begin
      mem[i] = 0;
      vld[i] = 0;
    end
  end

  always @(posedge clk) begin

    if (reset) begin

      for(i=0; i<RAM_DEPTH; i=i+1) begin
        mem[i] = 0;
        vld[i] = 0;
      end

    end else begin

      if (push0) begin
        mem[iq_index0] <= data_in0;
        vld[iq_index0] <= 1;
      end

      if (push1) begin
        mem[iq_index1] <= data_in1;
        vld[iq_index1] <= 1;
      end

      if (retire0) begin
        vld[oldest0] <= 0;
      end

      if (retire1) begin
        vld[oldest1] <= 0;
      end
  
    end
  
  end

endmodule
