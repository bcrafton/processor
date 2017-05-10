`include "defines.vh"

module ram (
  clk,
  complete,
  address,
  write_data,
  read_data,
  mem_op,
  program,
  // make this an output, make testing ez.
  //mem
  ); 

  input clk;
  input complete;
  //questionable
  input [`ADDR_WIDTH-1:0] address;
  input [`MEM_OP_BITS-1:0] mem_op;
  input wire [`NUM_TESTS_LOG2-1:0] program;

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

  reg[`STRING_BITS-1:0] file_name;
  always @(*) begin
    case(program)
    `TEST_ADD_ENUM: $sformat(file_name,"%s%s%s", "../test/actual/", `TEST_ADD, ".ram.actual");
    `TEST_IF_FALSE_ENUM: $sformat(file_name,"%s%s%s", "../test/actual/", `TEST_IF_FALSE, ".ram.actual");
    `TEST_IF_TRUE_ENUM: $sformat(file_name,"%s%s%s", "../test/actual/", `TEST_IF_TRUE, ".ram.actual");
    endcase
  end

  integer i;
  integer f;
  always @(*) begin
    if(complete) begin
      f = $fopen(file_name, "w");
      for (i=0; i<`DMEMORY_SIZE; i=i+1) $fwrite(f,"%h\n", mem[i]);
      $fclose(f);
    end
  end

endmodule
