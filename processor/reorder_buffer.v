
`timescale 1ns / 1ps

`include "defines.vh"

module reorder_buffer (
  clk,
  reset,
  flush,

  oldest0,
  oldest1,

  retire0,
  retire1,

  push0,
  iq_index0,
  spec0,

  data0_in,
  reg_write0_in,
  address0_in,

  data0_out,
  reg_write0_out,
  address0_out,

  push1,
  iq_index1,
  spec1,

  data1_in,
  reg_write1_in,
  address1_in,

  data1_out,
  reg_write1_out,
  address1_out,

  read_addr0_pipe0,
  read_addr1_pipe0,
  read_addr0_pipe1,
  read_addr1_pipe1,

  read_data0_pipe0,
  read_data1_pipe0,
  read_data0_pipe1,
  read_data1_pipe1
  

  );    

  parameter ADDR_WIDTH = 5;
  parameter RAM_DEPTH = (1 << ADDR_WIDTH);

  input wire clk;
  input wire reset;
  input wire flush;

  input wire [`NUM_IQ_ENTRIES_LOG2-1:0] oldest0;
  input wire [`NUM_IQ_ENTRIES_LOG2-1:0] oldest1;

  output wire retire0;
  output wire retire1;

  input wire                            push0;
  input wire [`NUM_IQ_ENTRIES_LOG2-1:0] iq_index0;
  input wire                            spec0;

  input wire [`DATA_WIDTH-1:0]          data0_in;
  input wire                            reg_write0_in;
  input wire [`NUM_REGISTERS_LOG2-1:0]  address0_in;

  output wire [`DATA_WIDTH-1:0]         data0_out;
  output wire                           reg_write0_out;
  output wire [`NUM_REGISTERS_LOG2-1:0] address0_out;

  input wire                            push1;
  input wire [`NUM_IQ_ENTRIES_LOG2-1:0] iq_index1;
  input wire                            spec1;

  input wire [`DATA_WIDTH-1:0]          data1_in;
  input wire                            reg_write1_in;
  input wire [`NUM_REGISTERS_LOG2-1:0]  address1_in;

  output wire [`DATA_WIDTH-1:0]         data1_out;
  output wire                           reg_write1_out;
  output wire [`NUM_REGISTERS_LOG2-1:0] address1_out;

  input wire [`NUM_IQ_ENTRIES_LOG2-1:0] read_addr0_pipe0;
  input wire [`NUM_IQ_ENTRIES_LOG2-1:0] read_addr1_pipe0;
  input wire [`NUM_IQ_ENTRIES_LOG2-1:0] read_addr0_pipe1;
  input wire [`NUM_IQ_ENTRIES_LOG2-1:0] read_addr1_pipe1;

  output wire [`DATA_WIDTH-1:0] read_data0_pipe0;
  output wire [`DATA_WIDTH-1:0] read_data1_pipe0;
  output wire [`DATA_WIDTH-1:0] read_data0_pipe1;
  output wire [`DATA_WIDTH-1:0] read_data1_pipe1;

  reg [`DATA_WIDTH-1:0]         mem       [0:RAM_DEPTH-1];
  reg                           vld       [0:RAM_DEPTH-1];
  reg                           reg_write [0:RAM_DEPTH-1];
  reg [`NUM_REGISTERS_LOG2-1:0] address   [0:RAM_DEPTH-1];
  reg                           spec      [0:RAM_DEPTH-1];

  integer i;

  assign retire0 = vld[oldest0] == 1;
  assign retire1 = retire0 && vld[oldest1] == 1;

  assign data0_out = mem[oldest0];
  assign data1_out = mem[oldest1];

  assign reg_write0_out = retire0 && reg_write[oldest0];
  assign reg_write1_out = retire1 && reg_write[oldest1];

  assign address0_out = address[oldest0];
  assign address1_out = address[oldest1];

  ///////////////////////////

  assign read_data0_pipe0 = mem[read_addr0_pipe0];
  assign read_data1_pipe0 = mem[read_addr1_pipe0];
  assign read_data0_pipe1 = mem[read_addr0_pipe1];
  assign read_data1_pipe1 = mem[read_addr1_pipe1];

  ///////////////////////////

  initial begin

    for(i=0; i<8; i=i+1) begin
      $dumpvars(0, mem[i], vld[i], reg_write[i], address[i], spec[i]);
    end

  end

  initial begin
    for(i=0; i<RAM_DEPTH; i=i+1) begin
      mem[i] = 0;
      vld[i] = 0;
      reg_write[i] = 0;
      address[i] = 0;
      spec[i] = 0;
    end
  end

  always @(posedge clk) begin

      if (flush) begin

        for(i=0; i<RAM_DEPTH; i=i+1) begin
          if(spec[i]) begin // these are ordered so its all good.
            mem[i] <= 0;
            vld[i] <= 0;
            reg_write[i] <= 0;
            address[i] <= 0;
            spec[i] <= 0;
          end
        end
      end

      if (push0) begin
        mem[iq_index0]       <= data0_in;
        reg_write[iq_index0] <= reg_write0_in;
        address[iq_index0]   <= address0_in;
        vld[iq_index0]       <= 1;
        spec[iq_index0]      <= spec0;
      end

      if (push1) begin
        mem[iq_index1]       <= data1_in;
        reg_write[iq_index1] <= reg_write1_in;
        address[iq_index1]   <= address1_in;
        vld[iq_index1]       <= 1;
        spec[iq_index1]      <= spec1;
      end

      if (retire0) begin
        vld[oldest0] <= 0;
      end

      if (retire1) begin
        vld[oldest1] <= 0;
      end
  
  end

endmodule
