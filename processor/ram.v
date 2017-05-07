`include "defines.vh"

module ram (
  clk,
  complete,
  address,
  write_data,
  read_data,
  mem_op,
  // make this an output, make testing ez.
  //mem
  ); 

  input clk;
  input complete;
  //questionable
  input [`ADDR_WIDTH-1:0] address;
  input [`MEM_OP_BITS-1:0] mem_op;

  //questionable
  input [`DATA_WIDTH-1:0] write_data;
  output reg [`DATA_WIDTH-1:0] read_data;

  reg [`DATA_WIDTH-1:0] mem [0:`DMEMORY_SIZE-1];

  // combinational logic
  always @ (*) begin

    if (mem_op == `MEM_OP_WRITE) begin
      mem[address] = write_data;
    end else if (mem_op == `MEM_OP_READ) begin
      read_data = mem[address];
    end
  
  end

  integer i;
  integer f;
  always @(*) begin
    if(complete) begin
      f = $fopen("out/ram", "w");
      for (i=0; i<`DMEMORY_SIZE; i=i+1) $fwrite(f,"%h\n", mem[i]);
      $fclose(f);
    end
  end

endmodule
