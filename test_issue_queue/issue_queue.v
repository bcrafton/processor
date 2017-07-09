`timescale 1ns / 1ps

`include "defines.vh"

module issue_queue(
  
  clk,

  flush,

  free,
  count,

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

  push0,
  push_data0,

  push1,
  push_data1
  
  );

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

  // these two are NUM_IQ_ENTRIES_LOG2 (not -1) because need to be able to store 8.
  
  output wire [`NUM_IQ_ENTRIES_LOG2:0] free; // the # of non valid slots
  output wire [`NUM_IQ_ENTRIES_LOG2:0] count; // # of valid slots

  output wire [`IQ_ENTRY_SIZE-1:0] data0;
  output wire [`IQ_ENTRY_SIZE-1:0] data1;
  output wire [`IQ_ENTRY_SIZE-1:0] data2;
  output wire [`IQ_ENTRY_SIZE-1:0] data3;
  output wire [`IQ_ENTRY_SIZE-1:0] data4;
  output wire [`IQ_ENTRY_SIZE-1:0] data5;
  output wire [`IQ_ENTRY_SIZE-1:0] data6;
  output wire [`IQ_ENTRY_SIZE-1:0] data7;

  ///////////////

  reg [`IQ_ENTRY_SIZE-1:0] data [0:`NUM_IQ_ENTRIES-1];
  reg                      vld  [0:`NUM_IQ_ENTRIES-1];

  wire [`NUM_IQ_ENTRIES_LOG2-1:0] next0;
  wire [`NUM_IQ_ENTRIES_LOG2-1:0] next1;

  ///////////////

  integer i;

  ///////////////

  assign free = !vld[0] +
                !vld[1] +
                !vld[2] +
                !vld[3] +
                !vld[4] +
                !vld[5] +
                !vld[6] +
                !vld[7];

  assign count = vld[0] +
                 vld[1] +
                 vld[2] +
                 vld[3] +
                 vld[4] +
                 vld[5] +
                 vld[6] +
                 vld[7];

  assign next0 = !vld[0] ? 0 :
                !vld[1] ? 1 :
                !vld[2] ? 2 :
                !vld[3] ? 3 :
                !vld[4] ? 4 :
                !vld[5] ? 5 :
                !vld[6] ? 6 :
                !vld[7] ? 7 :
                8;

  assign next1 = !vld[0] & ( next0 != 0 ) ? 0 :
                 !vld[1] & ( next0 != 1 ) ? 1 :
                 !vld[2] & ( next0 != 2 ) ? 2 :
                 !vld[3] & ( next0 != 3 ) ? 3 :
                 !vld[4] & ( next0 != 4 ) ? 4 :
                 !vld[5] & ( next0 != 5 ) ? 5 :
                 !vld[6] & ( next0 != 6 ) ? 6 :
                 !vld[7] & ( next0 != 7 ) ? 7 :
                 0;

  assign data0 = vld[0] ? data[0] : 0;
  assign data1 = vld[1] ? data[1] : 0;
  assign data2 = vld[2] ? data[2] : 0;
  assign data3 = vld[3] ? data[3] : 0;
  assign data4 = vld[4] ? data[4] : 0;
  assign data5 = vld[5] ? data[5] : 0;
  assign data6 = vld[6] ? data[6] : 0;
  assign data7 = vld[7] ? data[7] : 0;

  ///////////////

  initial begin

    for(i=0; i<8; i=i+1) begin
      data[i] = 0;
      vld[i] = 0; 
    end

  end

  always @(posedge clk) begin

    if (flush) begin

      for(i=0; i<8; i=i+1) begin
        data[i] = 0;
        vld[i] = 0; 
      end

    end else begin

      if (push0 && (free >= 1)) begin

        data[next0] <= push_data0;
        vld[next0] <= 1;

      end

      if (pop0) begin // no need for this : (pop0 && (count >= 1))

        vld[pop_key0] = 0;

      end

      if (push1 && (free >= 2)) begin

        data[next1] <= push_data1;
        vld[next1] <= 1;

      end

      if (pop1) begin

        vld[pop_key1] = 0;

      end

    end

  end

endmodule
