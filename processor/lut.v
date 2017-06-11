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
reg [3:0] valid [0:7];

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
	// going to just do round robin for now.
 
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
    if(write_key == keys[0]) begin
      vals[0] <= write_val;
      valid[0] <= hit;
    end else if(write_key == keys[1]) begin
      vals[1] <= write_val;
      valid[1] <= hit;
    end else if(write_key == keys[2]) begin
      vals[2] <= write_val;
      valid[2] <= hit;
    end else if(write_key == keys[3]) begin
      vals[3] <= write_val;
      valid[3] <= hit;
    end else if(write_key == keys[4]) begin
      vals[4] <= write_val;
      valid[4] <= hit;
    end else if(write_key == keys[5]) begin
      vals[5] <= write_val;
      valid[5] <= hit;
    end else if(write_key == keys[6]) begin
      vals[6] <= write_val;
      valid[6] <= hit;
    end else if(write_key == keys[7]) begin
      vals[7] <= write_val;
      valid[7] <= hit;
    end else begin
      current <= next;
      vals[current] <= write_val;
      keys[current] <= write_key;
      valid[current] <= hit;
    end
  end

end

endmodule



