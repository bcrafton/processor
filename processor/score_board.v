
`timescale 1ns / 1ps

`include "defines.vh"

module score_board (
  clk,
  flush,
  reset,

  flush_iq_index,
  oldest,

  issue0,
  issue_index0,
  pipe0,

  retire0,
  retire_index0,

  issue1,
  issue_index1,
  pipe1,

  retire1,
  retire_index1

  );    

  input wire clk;
  input wire flush;
  input wire reset;

  input wire [`NUM_IQ_ENTRIES_LOG2-1:0]  flush_iq_index;
  input wire [`NUM_IQ_ENTRIES_LOG2-1:0]  oldest;

  // push reg -> rob
  input wire                             issue0;
  input wire [`NUM_IQ_ENTRIES_LOG2-1:0]  issue_index0;
  input wire                             pipe0;

  input wire                             retire0;
  input wire [`NUM_IQ_ENTRIES_LOG2-1:0]  retire_index0;

  input wire                             issue1;
  input wire [`NUM_IQ_ENTRIES_LOG2-1:0]  issue_index1;
  input wire                             pipe1;

  input wire                             retire1;
  input wire [`NUM_IQ_ENTRIES_LOG2-1:0]  retire_index1;

  reg [2:0] location [`NUM_IQ_ENTRIES-1:0];
  reg       pipe [`NUM_IQ_ENTRIES-1:0];

  wire [`NUM_IQ_ENTRIES_LOG2-1:0] first_branch = oldest + flush_iq_index < 8 ? oldest + flush_iq_index : oldest + flush_iq_index - 8;
  wire [`NUM_IQ_ENTRIES_LOG2-1:0] order [0:7];

  integer i;
  genvar j;

  generate
    for (j=0; j<`NUM_IQ_ENTRIES; j=j+1) begin : generate_output
      assign order[j] = oldest + j < 8 ? oldest + j : oldest + j - 8;
    end
  endgenerate

  initial begin

    for(i=0; i<`NUM_IQ_ENTRIES; i=i+1) begin
      $dumpvars(0, location[i], pipe[i]);
    end

  end

  initial begin
    for(i=0; i<`NUM_IQ_ENTRIES; i=i+1) begin
      location[i] <= `IQ_NOT_ALLOCATED;
    end
  end

  always @(posedge clk) begin

    if(issue0) begin
      location[issue_index0] <= `IQ_ID_EX;
      pipe[issue_index0] <= pipe0;
    end

    if(issue1) begin
      location[issue_index1] <= `IQ_ID_EX;
      pipe[issue_index1] <= pipe1;
    end

    if(retire0) begin // needs to account for when we are probably gonna push in here instead of freeing it.
      location[retire_index0] <= `IQ_NOT_ALLOCATED;
    end

    if(retire1) begin
      location[retire_index1] <= `IQ_NOT_ALLOCATED;
    end

    for(i=0; i<`NUM_IQ_ENTRIES; i=i+1) begin
      if(location[i] >= `IQ_ID_EX && location[i] <= `IQ_MEM_WB) begin
        location[i] <= location[i] + 1;
      end
    end

  end

endmodule






