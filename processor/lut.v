`timescale 1ns / 1ps

`include "defines.vh"

module lut(
  clk,
  reset,

  write,
  write_key,
  write_val,
  hit,

  read_key,
  read_val,
  read_valid,
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

reg [`ADDR_WIDTH-1:0] keys [0:7];
reg [`ADDR_WIDTH-1:0] vals [0:7];
reg valid [0:7];

reg [2:0] current;
wire [2:0] next = (current == 7) ? 0 : (current + 1);

integer i;

genvar j;
wire [7:0] read_match;
wire [2:0] read_address;

wire [7:0] write_match;
wire [2:0] write_address;

generate
  for (j=0; j<8; j=j+1) begin
    assign read_match[j] = (read_key == keys[j]) & valid[j];
  end
endgenerate

generate
  for (j=0; j<8; j=j+1) begin
    assign write_match[j] = write_key == keys[j];
  end
endgenerate

encoder read_encoder(
  .in(read_match),
  .out(read_address)
);

encoder write_encoder(
  .in(write_match),
  .out(write_address)
);

initial begin

  read_val = 0;
  read_valid = 0;

  for(i=0; i<8; i=i+1) begin
    keys[i] = 0;
    vals[i] = 0;  
    valid[i] = 0;
  end

  current = 0;

end

always @(*) begin
  if (read_match != 0) begin
    read_val = vals[read_address];
    read_valid = valid[read_address];
  end else begin
    read_valid = 0;
  end
end

always @(posedge clk) begin
  if(reset) begin
    for(i=0; i<8; i=i+1) begin
      keys[i] <= 0;
      vals[i] <= 0;  
      valid[i] <= 0;
    end
    current <= 0;
    read_val <= 0;
    read_valid <= 0;
	end else if(write) begin
    if (write_match != 0) begin
      vals[write_address] <= write_val;
      valid[write_address] <= hit;
    end else begin
      current <= next;
      vals[current] <= write_val;
      keys[current] <= write_key;
      valid[current] <= hit;
    end
  end

end

endmodule



