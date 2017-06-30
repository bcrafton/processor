
// http://www.asic-world.com/examples/verilog/syn_fifo.html

module fifo (
  clk,
  reset,

  push,
  data_in,

  pop,
  data_out,

  empty,
  full
  );    

  // 32x32 fifo by default.
  parameter DATA_WIDTH = 32;
  parameter ADDR_WIDTH = 5;
  parameter RAM_DEPTH = (1 << ADDR_WIDTH);

  input wire clk;
  input wire reset;

  input wire push;
  input wire [DATA_WIDTH-1:0] data_in;

  input wire pop;
  output reg [DATA_WIDTH-1:0] data_out;

  output wire full;
  output wire empty;

  reg [ADDR_WIDTH-1:0] wr_pointer;
  reg [ADDR_WIDTH-1:0] rd_pointer;
  reg [ADDR_WIDTH:0] count;

  reg [DATA_WIDTH-1:0] mem [0:RAM_DEPTH-1];

  integer i;

  assign full = (count == (RAM_DEPTH-1));
  assign empty = (count == 0);

  wire read = pop && !empty;
  wire write = push && !full;

  initial begin
    wr_pointer = 0;
    rd_pointer = 0;
    data_out = 0;
    count = 0;
    for(i=0; i<RAM_DEPTH; i=i+1) begin
      mem[i] = 0;
    end
  end

  always @(posedge clk) begin

    if (reset) begin

      wr_pointer <= 0;
      rd_pointer <= 0;
      data_out <= 0;
      count <= 0;
      for(i=0; i<RAM_DEPTH; i=i+1) begin
        mem[i] = 0;
      end

    end else begin

      if (write) begin
        mem[wr_pointer] <= data_in;
        wr_pointer <= wr_pointer + 1;
      end

      if (read) begin
        data_out <= mem[rd_pointer];
        rd_pointer <= rd_pointer + 1;
      end

      if (write && !read) begin
        count <= count + 1;
      end

      if (!write && read) begin
        count <= count - 1;
      end

    end
  end

endmodule
