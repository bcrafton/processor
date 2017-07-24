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

  // changing these, keep in mind the goal here : just make a fifo work for 2 - we are changin after.

  wire [2:0] wr_pointer0 = wr_pointer;
  wire [2:0] wr_pointer1 = wr_pointer + 1 < 8 ? wr_pointer + 1 : 0; 

  wire [2:0] rd_pointer0 = rd_pointer;
  wire [2:0] rd_pointer1 = rd_pointer + 1 < 8 ? rd_pointer + 1 : 0; 

  wire [2:0] order [0:7];

  wire [3:0] count;

  // this is awful ... when we start holding a count this dosnt work...
  assign free = !vld[0] +
                !vld[1] +
                !vld[2] +
                !vld[3] +
                !vld[4] +
                !vld[5] +
                !vld[6] +
                !vld[7];

  assign count = 8 - free;

/*
(pop0 & (vld_out[pop_key0] == 1))
(pop1 & (vld_out[pop_key1] == 1))
*/

  // our problem is order rn
  // and having this dead lock issue because we are not doing this right.

  wire read0 =  pop0  && (count >= 1) && ((count == 8) || !((order[pop_key0] == wr_pointer0) || (order[pop_key0] == wr_pointer1)));
  wire read1 =  pop1  && (count >= 2) && ((count == 8) || !((order[pop_key1] == wr_pointer0) || (order[pop_key1] == wr_pointer1)));

  wire write0 = push0 && (free  >= 1) && !((pop0 && (order[pop_key0] == wr_pointer0)) || (pop1 && (order[pop_key1] == wr_pointer0)));
  wire write1 = push1 && (free  >= 2) && !((pop0 && (order[pop_key0] == wr_pointer1)) || (pop1 && (order[pop_key1] == wr_pointer1)));

  ///////////////

  wire [`IQ_ENTRY_SIZE-1:0] data_out [0:7];
  wire                      vld_out  [0:7];

  reg [`IQ_ENTRY_SIZE-1:0] data [0:7];
  reg                      vld  [0:7];

  ///////////////

  integer i;
  genvar j;

  ///////////////

  initial begin
    wr_pointer = 0;
    rd_pointer = 0;
    for(i=0; i<8; i=i+1) begin
      data[i] = 0;
      vld[i] = 0;
    end
  end

  generate
    for (j=0; j<8; j=j+1) begin : generate_output

      assign order[j] = rd_pointer + j < 8 ? rd_pointer + j : rd_pointer + j - 8;

      assign vld_out[j] = vld[ order[j] ]                      ? vld[ order[j] ] : 
                          (push0 && (order[j] == wr_pointer0)) ? push0           :
                          (push1 && (order[j] == wr_pointer1)) ? push1           :
                          0;

      assign data_out[j] = vld[ order[j] ]                      ? data[ order[j] ] : 
                           (push0 && (order[j] == wr_pointer0)) ? push_data0       :
                           (push1 && (order[j] == wr_pointer1)) ? push_data1       :
                           0;

    end
  endgenerate

  ///////////////

  assign data0 = data_out[0];
  assign data1 = data_out[1];
  assign data2 = data_out[2];
  assign data3 = data_out[3];
  assign data4 = data_out[4];
  assign data5 = data_out[5];
  assign data6 = data_out[6];
  assign data7 = data_out[7];

  assign vld0 = vld_out[0];
  assign vld1 = vld_out[1];
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
      for(i=0; i<8; i=i+1) begin
        data[i] = 0;
      end

    end else begin

      if (write0 && write1) begin

        data[ wr_pointer0 ] <= push_data0;
        data[ wr_pointer1 ] <= push_data1;

        vld[ wr_pointer0 ] <= 1;
        vld[ wr_pointer1 ] <= 1;

        wr_pointer <= wr_pointer + 2;

      end else if (write0) begin

        data[ wr_pointer0 ] <= push_data0;

        vld[ wr_pointer0 ] <= 1;

        wr_pointer <= wr_pointer + 1;

      end else if (write1) begin

        data[ wr_pointer0 ] <= push_data1;

        vld[ wr_pointer0 ] <= 1;

        wr_pointer <= wr_pointer + 1;

      end

      if (read0 && read1) begin

        vld[ rd_pointer0 ] <= 0;
        vld[ rd_pointer1 ] <= 0;

        rd_pointer <= rd_pointer + 2;

      end else if (read0) begin

        vld[ rd_pointer0 ] <= 0;

        rd_pointer <= rd_pointer + 1;

      end

    end

  end

endmodule
