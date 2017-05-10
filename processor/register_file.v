module register_file(
  clk,
  complete,
  write,
  write_address,
  write_data,
  read_address_1,
  read_data_1,
  read_address_2,
  read_data_2,
  program,
  // make this an output, make testing ez.
  //regfile
  );

  reg [`DATA_WIDTH-1:0] regfile [0:`NUM_REGISTERS-1];

  input clk;
  input complete;
  input write;
  input wire [`NUM_TESTS_LOG2-1:0] program;

  input wire [`NUM_REGISTERS_LOG2-1:0] write_address;
  input wire [`DATA_WIDTH-1:0] write_data;

  input wire [`NUM_REGISTERS_LOG2-1:0] read_address_1;
  output wire [`DATA_WIDTH-1:0] read_data_1;

  input wire [`NUM_REGISTERS_LOG2-1:0] read_address_2;
  output wire [`DATA_WIDTH-1:0] read_data_2;

  integer i;
  initial begin
    for (i=0; i<`NUM_REGISTERS; i=i+1) regfile[i] <= 32'h00000000;
  end

  assign read_data_1 = regfile[read_address_1];
  assign read_data_2 = regfile[read_address_2];

  always @(*) begin
    if (write) begin
      regfile[write_address] <= write_data;
    end
  end

  reg[`STRING_BITS-1:0] file_name;
  always @(*) begin
    case(program)
    `TEST_ADD_ENUM: $sformat(file_name,"%s%s%s", "../test/actual/", `TEST_ADD, ".regfile.actual");
    `TEST_IF_FALSE_ENUM: $sformat(file_name,"%s%s%s", "../test/actual/", `TEST_IF_FALSE, ".regfile.actual");
    `TEST_IF_TRUE_ENUM: $sformat(file_name,"%s%s%s", "../test/actual/", `TEST_IF_TRUE, ".regfile.actual");
    endcase
  end
  
  integer f;
  always @(*) begin
    if(complete) begin
      f = $fopen(file_name, "w");
      for (i=0; i<`NUM_REGISTERS; i=i+1) $fwrite(f,"%h\n", regfile[i]);
      $fclose(f);
    end
  end

endmodule






