`timescale 1ns / 1ps

`include "defines.vh"

module blt(
  clk,
  reset,

  write,
  write_key,
  write_val,
  hit,

  read_key,
  read_val,
  read_valid
  );

  // input = pc.
  // output = address

  // key = pc
  // val = address

  input wire clk;
  input wire reset;

  input wire write;
  input wire [`ADDR_WIDTH-1:0] write_key;
  input wire [`ADDR_WIDTH-1:0] write_val;
  input wire hit;

  input wire [`ADDR_WIDTH-1:0] read_key;
  output reg [`ADDR_WIDTH-1:0] read_val;
  output reg read_valid;

  reg [`ADDR_WIDTH-1:0] keys [0:`BLT_SIZE-1];
  reg [`ADDR_WIDTH-1:0] vals [0:`BLT_SIZE-1];
  reg [`NUM_BRANCH_MASKS-1:0] valid [0:`BLT_SIZE-1];

  reg [`BLT_SIZE_LOG2-1:0] current;
  wire [`BLT_SIZE_LOG2-1:0] next = (current == `BLT_SIZE-1) ? 0 : (current + 1);

  integer i;

  genvar j;
  wire [`BLT_SIZE-1:0] read_match;
  wire [`BLT_SIZE_LOG2-1:0] read_address;

  wire [`BLT_SIZE-1:0] write_match;
  wire [`BLT_SIZE_LOG2-1:0] write_address;

  generate
    for (j=0; j<`BLT_SIZE; j=j+1) begin : generate_read_match
      assign read_match[j] = (read_key == keys[j]) & ((valid[j] == `TAKE_BRANCH1) | (valid[j] == `TAKE_BRANCH2));
    end
  endgenerate

  generate
    for (j=0; j<`BLT_SIZE; j=j+1) begin : generate_write_match
      assign write_match[j] = (write_key == keys[j]);
    end
  endgenerate

  function [`NUM_BRANCH_MASKS-1:0] set_branch_predict;
    input [`NUM_BRANCH_MASKS-1:0] current_predict;
    input hit;
    begin
      case( {current_predict, hit} )

        {`TAKE_BRANCH2, 1'b1}: set_branch_predict = `TAKE_BRANCH2;
        {`TAKE_BRANCH2, 1'b0}: set_branch_predict = `TAKE_BRANCH1;

        {`TAKE_BRANCH1, 1'b1}: set_branch_predict = `TAKE_BRANCH2;
        {`TAKE_BRANCH1, 1'b0}: set_branch_predict = `DONT_TAKE_BRANCH1;

        {`DONT_TAKE_BRANCH1, 1'b1}: set_branch_predict = `TAKE_BRANCH1;
        {`DONT_TAKE_BRANCH1, 1'b0}: set_branch_predict = `DONT_TAKE_BRANCH2;

        {`DONT_TAKE_BRANCH2, 1'b1}: set_branch_predict = `DONT_TAKE_BRANCH1;
        {`DONT_TAKE_BRANCH2, 1'b0}: set_branch_predict = `DONT_TAKE_BRANCH2;

        default: $display("set_branch_predict error: %x %x\n", current_predict, hit);
      endcase
    end
  endfunction

  encoder5x32 read_encoder(
    .in(read_match),
    .out(read_address)
  );

  encoder5x32 write_encoder(
    .in(write_match),
    .out(write_address)
  );

  initial begin
    read_val = 0;
    read_valid = 0;
    for(i=0; i<`BLT_SIZE; i=i+1) begin
      keys[i] = 0;
      vals[i] = 0; 
      valid[i] = 0;
    end
    current = 0;
  end

  always @(*) begin
    if (read_match != 0) begin
      read_val = vals[read_address];
      read_valid = (valid[read_address] == `TAKE_BRANCH1) | (valid[read_address] == `TAKE_BRANCH2);
    end else begin
      read_valid = 0;
    end
  end

  always @(posedge clk) begin

    if(reset) begin

      for(i=0; i<`BLT_SIZE; i=i+1) begin
        keys[i] <= 0;
        vals[i] <= 0;  
        valid[i] <= 0;
      end
      current <= 0;
      read_val <= 0;
      read_valid <= 0;

	  end else if(write) begin
      if (write_match != 0) begin

        if (hit) begin
          vals[write_address] <= write_val;
        end
        valid[write_address] <= set_branch_predict(valid[write_address], hit);

      end else begin

        current <= next;
        vals[current] <= write_val;
        keys[current] <= write_key;
        if (hit) begin
          valid[current] <= `TAKE_BRANCH2;
        end else begin
          valid[current] <= `DONT_TAKE_BRANCH2;
        end
        
      end
    end
  end

endmodule



