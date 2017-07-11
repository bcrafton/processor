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

  wire [`NUM_IQ_ENTRIES_LOG2:0] next [0:5];

  ///////////////

  integer i;
  genvar j;

  ///////////////
  
  assign next[0] = vld[0] & !(pop0 && (pop_key0 == 0)) & !(pop1 && (pop_key1 == 0)) ? 0 :
                   vld[1] & !(pop0 && (pop_key0 == 1)) & !(pop1 && (pop_key1 == 1)) ? 1 :
                   vld[2] & !(pop0 && (pop_key0 == 2)) & !(pop1 && (pop_key1 == 2)) ? 2 :
                   vld[3] & !(pop0 && (pop_key0 == 3)) & !(pop1 && (pop_key1 == 3)) ? 3 :
                   vld[4] & !(pop0 && (pop_key0 == 4)) & !(pop1 && (pop_key1 == 4)) ? 4 :
                   vld[5] & !(pop0 && (pop_key0 == 5)) & !(pop1 && (pop_key1 == 5)) ? 5 :
                   vld[6] & !(pop0 && (pop_key0 == 6)) & !(pop1 && (pop_key1 == 6)) ? 6 :
                   vld[7] & !(pop0 && (pop_key0 == 7)) & !(pop1 && (pop_key1 == 7)) ? 7 :
                   8;
  generate
    for (j=1; j<6; j=j+1) begin : generate_reg_depends

      //assign next[i] = i + (pop0 && (pop_key0 <= i)) + (pop1 && (pop_key1 <= i));
      
      assign next[j] = vld[0] & !(pop0 && (pop_key0 == 0)) & !(pop1 && (pop_key1 == 0)) & ( next[j-1] < 0 ) ? 0 :
                       vld[1] & !(pop0 && (pop_key0 == 1)) & !(pop1 && (pop_key1 == 1)) & ( next[j-1] < 1 ) ? 1 :
                       vld[2] & !(pop0 && (pop_key0 == 2)) & !(pop1 && (pop_key1 == 2)) & ( next[j-1] < 2 ) ? 2 :
                       vld[3] & !(pop0 && (pop_key0 == 3)) & !(pop1 && (pop_key1 == 3)) & ( next[j-1] < 3 ) ? 3 :
                       vld[4] & !(pop0 && (pop_key0 == 4)) & !(pop1 && (pop_key1 == 4)) & ( next[j-1] < 4 ) ? 4 :
                       vld[5] & !(pop0 && (pop_key0 == 5)) & !(pop1 && (pop_key1 == 5)) & ( next[j-1] < 5 ) ? 5 :
                       vld[6] & !(pop0 && (pop_key0 == 6)) & !(pop1 && (pop_key1 == 6)) & ( next[j-1] < 6 ) ? 6 :
                       vld[7] & !(pop0 && (pop_key0 == 7)) & !(pop1 && (pop_key1 == 7)) & ( next[j-1] < 7 ) ? 7 :
                       8;
      

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

      data[0] <= next[0] < 8 ? data[next[0]] : 0;
      vld[0] <=  next[0] < 8 ? vld[next[0]]  : 0;
      
      data[1] <= next[1] < 8 ? data[next[1]] : 0;
      vld[1] <=  next[1] < 8 ? vld[next[1]]  : 0;
      
      data[2] <= next[2] < 8 ? data[next[2]] : 0;
      vld[2] <=  next[2] < 8 ? vld[next[2]]  : 0;
      
      data[3] <= next[3] < 8 ? data[next[3]] : 0;
      vld[3] <=  next[3] < 8 ? vld[next[3]]  : 0;
      
      data[4] <= next[4] < 8 ? data[next[4]] : 0;
      vld[4] <=  next[4] < 8 ? vld[next[4]]  : 0;
      
      data[5] <= next[5] < 8 ? data[next[5]] : 0;
      vld[5] <=  next[5] < 8 ? vld[next[5]]  : 0;
      
    end

  end

endmodule
