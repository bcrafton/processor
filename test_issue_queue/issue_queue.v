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

  output wire [`IQ_ENTRY_SIZE-1:0] data0;
  output wire [`IQ_ENTRY_SIZE-1:0] data1;
  output wire [`IQ_ENTRY_SIZE-1:0] data2;
  output wire [`IQ_ENTRY_SIZE-1:0] data3;
  output wire [`IQ_ENTRY_SIZE-1:0] data4;
  output wire [`IQ_ENTRY_SIZE-1:0] data5;
  output wire [`IQ_ENTRY_SIZE-1:0] data6; // passthrough
  output wire [`IQ_ENTRY_SIZE-1:0] data7; // passthrough

  ///////////////

  reg [`IQ_ENTRY_SIZE-1:0] data [0:`NUM_IQ_ENTRIES-1];
  reg                      vld  [0:`NUM_IQ_ENTRIES-1];

  wire [`NUM_IQ_ENTRIES_LOG2-1:0] next [0:7];
  wire                            next_vld [0:7];
  wire [`NUM_IQ_ENTRIES_LOG2-1:0] sum_valid [0:7];

  ///////////////

  integer i;
  genvar j;

  ///////////////

  initial begin

    //$dumpvars(0, sum_valid[0], sum_valid[1], sum_valid[2]);

    for(i=0; i<8; i=i+1) begin
      $dumpvars(0, sum_valid[i], next[i], next_vld[i], vld[i]);
    end

  end

  generate
    for (j=0; j<8; j=j+1) begin : generate_sum_valid

      if (j == 0) begin
        assign sum_valid[j] = vld[j] & !(pop0 && (pop_key0 == j)) & !(pop1 && (pop_key1 == j));
      end
      
      else begin
        assign sum_valid[j] = sum_valid[j-1] + (vld[j] & !(pop0 && (pop_key0 == j)) & !(pop1 && (pop_key1 == j)));
      end

    end
  endgenerate

  generate
    for (j=0; j<6; j=j+1) begin : generate_reg_depends
      
      assign {next[j], next_vld[j]} = sum_valid[0] == j ? {3'h0, 1'h1} : 
                                      sum_valid[1] == j ? {3'h1, 1'h1} : 
                                      sum_valid[2] == j ? {3'h2, 1'h1} : 
                                      sum_valid[3] == j ? {3'h3, 1'h1} : 
                                      sum_valid[4] == j ? {3'h4, 1'h1} : 
                                      sum_valid[5] == j ? {3'h5, 1'h1} : 
                                      sum_valid[6] == j ? {3'h6, 1'h1} : 
                                      sum_valid[7] == j ? {3'h7, 1'h1} : 
                                      {1'h0, 1'h0};

    end
  endgenerate
  
  ///////////////

  assign free = !vld[0] +
                !vld[1] +
                !vld[2] +
                !vld[3] +
                !vld[4] +
                !vld[5]; // + pop0 + pop1

  assign data0 = vld[0] ? data[0] : 0;
  assign data1 = vld[1] ? data[1] : 0;
  assign data2 = vld[2] ? data[2] : 0;
  assign data3 = vld[3] ? data[3] : 0;
  assign data4 = vld[4] ? data[4] : 0;
  assign data5 = vld[5] ? data[5] : 0;
  assign data6 = vld[6] ? data[6] : 0;
  assign data7 = vld[7] ? data[7] : 0;
  
  always @(*) begin
    data[6] = push_data0;
    vld[6] = push0;
    
    data[7] = push_data1;
    vld[7] = push1;
  end

  ///////////////

  initial begin

    for(i=0; i<6; i=i+1) begin
      data[i] = 0;
      vld[i] = 0; 
    end

  end

  always @(posedge clk) begin

    if (flush) begin

      for(i=0; i<6; i=i+1) begin
        data[i] = 0;
        vld[i] = 0; 
      end

    end else begin

      data[0] <= data[next[0]];
      vld[0] <=  next_vld[0];
      
      data[1] <= data[next[0]];
      vld[1] <=  next_vld[0];
      
      data[2] <= data[next[0]];
      vld[2] <=  next_vld[0];
      
      data[3] <= data[next[0]];
      vld[3] <=  next_vld[0];
      
      data[4] <= data[next[0]];
      vld[4] <=  next_vld[0];
      
      data[5] <= data[next[0]];
      vld[5] <=  next_vld[0];
      
    end

  end

endmodule
