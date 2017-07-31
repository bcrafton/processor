
`timescale 1ns / 1ps

`include "defines.vh"

module issue_queue(
  
  clk,

  flush,
  spec,

  free,

  retire0,
  retire1,

  oldest0,
  oldest1,
  flush_iq_index,

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
  output wire [`NUM_IQ_ENTRIES-1:0] spec;

  input wire retire0;
  input wire retire1;

  output wire [`NUM_IQ_ENTRIES_LOG2-1:0] oldest0;
  output wire [`NUM_IQ_ENTRIES_LOG2-1:0] oldest1;

  input wire [`NUM_IQ_ENTRIES_LOG2-1:0] flush_iq_index;

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

  wire                             is_branch [0:7];
  wire [`NUM_IQ_ENTRIES_LOG2-1:0]  first_branch;  
  wire                             has_branch;
  wire [`OP_CODE_BITS-1:0]         opcode [0:7];

  wire [`INST_WIDTH-1:0]           instruction          [0:7];
  wire [`ADDR_WIDTH-1:0]           pc                   [0:7];
  wire [`INSTRUCTION_ID_WIDTH-1:0] id                   [0:7];
  wire                             branch_taken         [0:7];
  wire [`ADDR_WIDTH-1:0]           branch_taken_address [0:7];
  wire [`NUM_IQ_ENTRIES_LOG2-1:0]  iq_index             [0:7];

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

  // this dosnt work because its not ordered.
  // thinking that order may be necessary.
  // need to sit down and think about what needs to be done to make this work from scratch.
  assign {first_branch, has_branch} = is_branch[0] ? {3'h0, 1'h1} :
                                      is_branch[1] ? {3'h1, 1'h1} :
                                      is_branch[2] ? {3'h2, 1'h1} :
                                      is_branch[3] ? {3'h3, 1'h1} :
                                      is_branch[4] ? {3'h4, 1'h1} :
                                      is_branch[5] ? {3'h5, 1'h1} :
                                      is_branch[6] ? {3'h6, 1'h1} :
                                      is_branch[7] ? {3'h7, 1'h1} :
                                      {3'h0, 1'h0};

  generate
    for (j=0; j<8; j=j+1) begin : generate_output

      // this is ordered.
      assign {branch_taken[j], branch_taken_address[j], id[j], instruction[j], pc[j]} = data[ order[j] ];
      assign opcode[j] = instruction[j][`OPCODE_MSB:`OPCODE_LSB];
      assign is_branch[j] = ((opcode[j] & 6'b110000) == 6'b110000) && (opcode[j] != `OP_CODE_JMP);

      if (j == 0) begin
        assign spec[j] = 0;
      end else begin
        assign spec[j] = spec[j-1] || is_branch[j-1];
      end

      assign order[j] = rd_pointer + j < 8 ? rd_pointer + j : rd_pointer + j - 8;

      assign vld_out[j] = vld[ order[j] ]                                 ? vld[ order[j] ] : 
                          ((free >= 1) && (push0 && (order[j] == wr_pointer0))) ? push0     :
                          ((free >= 2) && (push1 && (order[j] == wr_pointer1))) ? push1     :
                          0;

      // this makes it so issue does not stall if it sees invalid instruction
      assign data_out[j] = vld[ order[j] ]                      ? data[ order[j] ] : 
                           ((free >= 1) && (push0 && (order[j] == wr_pointer0))) ? push_data0       :
                           ((free >= 2) && (push1 && (order[j] == wr_pointer1))) ? push_data1       :
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
  assign vld2 = vld_out[2];
  assign vld3 = vld_out[3];
  assign vld4 = vld_out[4];
  assign vld5 = vld_out[5];
  assign vld6 = vld_out[6];
  assign vld7 = vld_out[7];

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
      // spec is ordered, so some funky shit needs to be done.
      count <= count - spec[0] - spec[1] - spec[2] - spec[3] - spec[4] - spec[5] - spec[6] - spec[7];
      wr_pointer <= flush_iq_index+1;

      // valid means issued here.
      for(i=0; i<8; i=i+1) begin
        if (vld[order[i]] && spec[i]) begin
          data[ order[i] ] <= 0;
          vld[ order[i] ] <= 0;
        end
      end

      // nothing changes for read pointer.
      if (retire0 && retire1) begin
        rd_pointer <= rd_pointer + 2;
      end else if (retire0) begin
        rd_pointer <= rd_pointer + 1;
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
