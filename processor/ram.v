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

  input [`ADDR_WIDTH-1:0] address;
  input [`MEM_OP_BITS-1:0] mem_op;

  input [`DATA_WIDTH-1:0] write_data;
  output reg [`DATA_WIDTH-1:0] read_data;

  //reg [`DATA_WIDTH-1:0] mem [0:`DMEMORY_SIZE-1];
  reg write_bit, dump_bit;

  // combinational logic
  always @(*) begin

    if (mem_op == `MEM_OP_WRITE) begin
      write_bit = $mem_write(address, write_data, `DMEM_ID);
    end else if (mem_op == `MEM_OP_READ) begin
      read_data = $mem_read(address, `DMEM_ID);
    end
  
  end

  always @(complete) begin
    
    dump_bit <= $dump(`DMEM_ID);

  end

endmodule
