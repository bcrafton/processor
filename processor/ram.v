`include "defines.vh"

module ram (
  reset,
  complete,

  address,
  write_data,
  read_data,
  mem_op,
  ); 

  input wire reset;
  input wire complete;

  input [`ADDR_WIDTH-1:0] address;
  input [`MEM_OP_BITS-1:0] mem_op;

  input [`DATA_WIDTH-1:0] write_data;
  output reg [`DATA_WIDTH-1:0] read_data;

  reg [`DATA_WIDTH-1:0] mem [0:`DMEMORY_SIZE-1];
  reg write_bit;

  integer i;
  integer f;

  // combinational logic
  always @(*) begin

    if (reset) begin

      for(i=0; i<`DMEMORY_SIZE; i=i+1) begin
        mem[i] = 0;
      end

    end else if (mem_op == `MEM_OP_WRITE) begin
      mem[address] = write_data;

    end else if (mem_op == `MEM_OP_READ) begin
      read_data = mem[address];

    end
  
  end

  always @(*) begin
    if (complete) begin
      // $display("Running complete code ram");
      f = $fopen("/home/brian/Desktop/processor/test_bench/out/sim/to_10.bc.s.hex/mem", "w");
      for(i=0; i<`DMEMORY_SIZE; i=i+1) begin
        $fwrite(f, "%h\n", mem[i]);
      end
      $fclose(f);
      // $display("Complete code ram");
    end
  end


endmodule
