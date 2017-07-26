
`timescale 1ns / 1ps

`include "defines.vh"

module issue_queue(
  
  clk,

  flush,

  free,

  retire0,
  retire1,

  oldest0,
  oldest1,

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

  index0,
  index1,
  index2,
  index3,
  index4,
  index5,
  index6,
  index7,

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

  input wire retire0;
  input wire retire1;

  output wire [`NUM_IQ_ENTRIES_LOG2-1:0] oldest0;
  output wire [`NUM_IQ_ENTRIES_LOG2-1:0] oldest1;

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

  output wire [`NUM_IQ_ENTRIES_LOG2-1:0] index0;
  output wire [`NUM_IQ_ENTRIES_LOG2-1:0] index1;
  output wire [`NUM_IQ_ENTRIES_LOG2-1:0] index2;
  output wire [`NUM_IQ_ENTRIES_LOG2-1:0] index3;
  output wire [`NUM_IQ_ENTRIES_LOG2-1:0] index4;
  output wire [`NUM_IQ_ENTRIES_LOG2-1:0] index5;
  output wire [`NUM_IQ_ENTRIES_LOG2-1:0] index6;
  output wire [`NUM_IQ_ENTRIES_LOG2-1:0] index7; // passthrough

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

  assign oldest0 = order[0];
  assign oldest1 = order[1];

  ///////////////

  reg [2:0] wr_pointer;
  reg [2:0] rd_pointer;

  wire [2:0] wr_pointer0 = wr_pointer;
  wire [2:0] wr_pointer1 = wr_pointer + 1 < 8 ? wr_pointer + 1 : 0; 

  wire [2:0] rd_pointer0 = rd_pointer;
  wire [2:0] rd_pointer1 = rd_pointer + 1 < 8 ? rd_pointer + 1 : 0; 

  wire [2:0] order [0:7];

  reg [3:0] count;
  assign free = 8 - count;

  wire full = count == 8;

  wire write0 = push0 && (free >= 1);
  wire write1 = push1 && (free >= 2);

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

    for(i=0; i<8; i=i+1) begin
      $dumpvars(0, order[i], vld[i], data[i]);
    end

  end

  initial begin
    count = 0;
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

      assign vld_out[j] = vld[ order[j] ]                                 ? vld[ order[j] ] : 
                          ((free >= 1) && (push0 && (order[j] == wr_pointer0))) ? push0     :
                          ((free >= 2) && (push1 && (order[j] == wr_pointer1))) ? push1     :
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

  assign index0 = order[0];
  assign index1 = order[1];
  assign index2 = order[2];
  assign index3 = order[3];
  assign index4 = order[4];
  assign index5 = order[5];
  assign index6 = order[6];
  assign index7 = order[7];

  ///////////////
  
  always @(posedge clk) begin

    if (flush) begin

      count <= 0;
      wr_pointer <= 0;
      rd_pointer <= 0;
      for(i=0; i<8; i=i+1) begin
        data[i] = 0;
      end

    end else begin

      if (write0 && write1) begin

        data[ wr_pointer0 ] <= push_data0;
        data[ wr_pointer1 ] <= push_data1;

        if (!( (pop0 && (order[pop_key0] == wr_pointer0)) || (pop1 && (order[pop_key1] == wr_pointer0)) )) begin
          vld[ wr_pointer0 ] <= 1;
        end

        if (!( (pop0 && (order[pop_key0] == wr_pointer1)) || (pop1 && (order[pop_key1] == wr_pointer1)) )) begin
          vld[ wr_pointer1 ] <= 1;
        end

        wr_pointer <= wr_pointer + 2;

      end else if (write0) begin

        data[ wr_pointer0 ] <= push_data0;

        if (!( (pop0 && (order[pop_key0] == wr_pointer0)) || (pop1 && (order[pop_key1] == wr_pointer0)) )) begin
          vld[ wr_pointer0 ] <= 1;
        end

        wr_pointer <= wr_pointer + 1;

      end 

      if (retire0 && retire1) begin

        rd_pointer <= rd_pointer + 2;

      end else if (retire0) begin

        rd_pointer <= rd_pointer + 1;

      end

      if (pop0) begin
        vld[ order[pop_key0] ] <= 0;
      end 

      if (pop1) begin
        vld[ order[pop_key1] ] <= 0;
      end 

      count <= count + write0 + write1 - retire0 - retire1;

    end

  end

endmodule
