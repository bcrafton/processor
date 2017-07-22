`timescale 1ns / 1ps

`include "defines.vh"

module issue_queue(
  
  clk,

  flush,

  free,

  ///////////////

  pop0,
  pop_key0,

  pop1,
  pop_key1,

  ///////////////

  data0,
  data1,
  data2,
  data3,
  data4,
  data5,
  data6,
  data7,

  ///////////////

  vld0,
  vld1,
  vld2,
  vld3,
  vld4,
  vld5,
  vld6,
  vld7,

  ///////////////

  push0,
  push_data0,

  push1,
  push_data1
  
  );

  ///////////////

  input wire clk;
  input wire flush;

  input wire pop0;
  input wire [`NUM_IQ_ENTRIES_LOG2-1:0] pop_key0;

  input wire pop1;
  input wire [`NUM_IQ_ENTRIES_LOG2-1:0] pop_key1;

  input wire push0;
  input wire [`IQ_ENTRY_SIZE-1:0] push_data0;

  input wire push1;
  input wire [`IQ_ENTRY_SIZE-1:0] push_data1;

  ///////////////

  output wire full;
  output wire empty;
  output wire [3:0] free;

  ///////////////

  output wire [`IQ_ENTRY_SIZE-1:0] data0;
  output wire [`IQ_ENTRY_SIZE-1:0] data1;
  output wire [`IQ_ENTRY_SIZE-1:0] data2;
  output wire [`IQ_ENTRY_SIZE-1:0] data3;
  output wire [`IQ_ENTRY_SIZE-1:0] data4;
  output wire [`IQ_ENTRY_SIZE-1:0] data5;
  output wire [`IQ_ENTRY_SIZE-1:0] data6;
  output wire [`IQ_ENTRY_SIZE-1:0] data7; // passthrough

  ///////////////

  output wire vld0;
  output wire vld1;
  output wire vld2;
  output wire vld3;
  output wire vld4;
  output wire vld5;
  output wire vld6;
  output wire vld7; // passthrough

  ///////////////

  reg [2:0] wr_pointer;
  reg [2:0] rd_pointer;
  reg [3:0] count;

  assign full = (count == 8);
  assign free = (8 - count);
  assign empty = (count == 0);

  wire read0 =  pop0  && (count >= 1);
  wire read1 =  pop1  && (count >= 2);
  wire write0 = push0 && (free >= 1);
  wire write1 = push1 && (free >= 2);

  ///////////////

  reg [`IQ_ENTRY_SIZE-1:0] data [0:7];
  reg                      vld  [0:7];

  ///////////////

  integer i;

  ///////////////

  initial begin
    wr_pointer = 0;
    rd_pointer = 0;
    count = 0;
    for(i=0; i<8; i=i+1) begin
      data[i] = 0;
      vld[i] = 0;
    end
  end

  ///////////////

  assign data0 = data[rd_pointer];
  assign data1 = data[rd_pointer+1];
  assign data2 = data[rd_pointer+2];
  assign data3 = data[rd_pointer+3]; 
  assign data4 = data[rd_pointer+4];
  assign data5 = data[rd_pointer+5];
  assign data6 = data[rd_pointer+6];
  assign data7 = data[rd_pointer+7];

  assign vld0 = vld[rd_pointer];
  assign vld1 = vld[rd_pointer+1];
  assign vld2 = 0;
  assign vld3 = 0;
  assign vld4 = 0;
  assign vld5 = 0;
  assign vld6 = 0;
  assign vld7 = 0;

  ///////////////

  
  
  always @(posedge clk) begin

    if (flush) begin

      wr_pointer <= 0;
      rd_pointer <= 0;
      count <= 0;
      for(i=0; i<8; i=i+1) begin
        data[i] = 0;
      end

    end else begin

      if (write0 && write1) begin
        data[wr_pointer] <= push_data0;
        data[wr_pointer+1] <= push_data1;
        wr_pointer <= wr_pointer + 2;

        vld[wr_pointer] <= 1;
        vld[wr_pointer+1] <= 1;
      end else if (write0) begin
        data[wr_pointer] <= push_data0;
        wr_pointer <= wr_pointer + 1;

        vld[wr_pointer] <= 1;
      end

      if (read0 && read1) begin
        rd_pointer <= rd_pointer + 2;

        vld[rd_pointer] <= 0;
        vld[rd_pointer+1] <= 0;
      end else if (read0) begin
        rd_pointer <= rd_pointer + 1;

        vld[rd_pointer] <= 0;
      end

      count <= count + write0 + write1 - read0 - read1;

    end

  end

endmodule
