`timescale 1ns / 1ps

`include "defines.vh"

module lut(
  clk,
  write,

  write_key,
  write_val,

  read_key,
  read_val,
  read_valid
);

// input = pc.
// output = address

// key = pc
// val = address

input wire clk;
input wire write;

input wire [`ADDR_WIDTH-1:0] write_key;
input wire [`ADDR_WIDTH-1:0] write_val;

input wire [`ADDR_WIDTH-1:0] read_key;
output reg [`ADDR_WIDTH-1:0] read_val;
output reg read_valid;

reg [`ADDR_WIDTH-1:0] keys [0:7];
reg [`ADDR_WIDTH-1:0] vals [0:7];

reg [2:0] current;
wire [2:0] next = (current == 7) ? 0 : (current + 1);

integer i;

initial begin

  read_val = 0;
  read_valid = 0;

  for(i=0; i<8; i=i+1) begin
    keys[i] = 0;
    vals[i] = 0;  
  end

  current = 0;

end

always @(*) begin

	if(read_key == keys[0]) begin
		read_val = vals[0];
		read_valid = 1;
	end else if(read_key == keys[1]) begin
		read_val = vals[1];
		read_valid = 1;
	end else if(read_key == keys[2]) begin
		read_val = vals[2];
		read_valid = 1;
	end else if(read_key == keys[3]) begin
		read_val = vals[3];
		read_valid = 1;
	end else if(read_key == keys[4]) begin
		read_val = vals[4];
		read_valid = 1;
	end else if(read_key == keys[5]) begin
		read_val = vals[5];
		read_valid = 1;
	end else if(read_key == keys[6]) begin
		read_val = vals[6];
		read_valid = 1;
	end else if(read_key == keys[7]) begin
		read_val = vals[7];
		read_valid = 1;
	end else begin
		read_valid = 0;
	end
end

always @(posedge clk) begin
	// going to just do round robin for now.
	if(write) begin
		if(write_key == keys[0]) begin
			vals[0] = write_val;
		end else if(write_key == keys[1]) begin
			vals[1] = write_val;
		end else if(write_key == keys[2]) begin
			vals[2] = write_val;
		end else if(write_key == keys[3]) begin
			vals[3] = write_val;
		end else if(write_key == keys[4]) begin
			vals[4] = write_val;
		end else if(write_key == keys[5]) begin
			vals[5] = write_val;
		end else if(write_key == keys[6]) begin
			vals[6] = write_val;
		end else if(write_key == keys[7]) begin
			vals[7] = write_val;
		end else begin
			current <= next;
			vals[current] = write_val;
      keys[current] = write_key;
		end
	end

end

endmodule



