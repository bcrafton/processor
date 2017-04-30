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
  // make this an output, make testing ez.
  //regfile
  );

  reg [`DATA_WIDTH-1:0] regfile [0:`NUM_REGISTERS-1];

  input clk;
  input complete;
  input write;

  input wire [`NUM_REGISTERS_LOG2-1:0] write_address;
  input wire [`DATA_WIDTH-1:0] write_data;

  input wire [`NUM_REGISTERS_LOG2-1:0] read_address_1;
  output wire [`DATA_WIDTH-1:0] read_data_1;

  input wire [`NUM_REGISTERS_LOG2-1:0] read_address_2;
  output wire [`DATA_WIDTH-1:0] read_data_2;

  initial begin
    regfile[0] <= 16'h0000;
    regfile[1] <= 16'h0000;
    regfile[2] <= 16'h0000;
    regfile[3] <= 16'h0000;

    regfile[4] <= 16'h0000;
    regfile[5] <= 16'h0000;
    regfile[6] <= 16'h0000;
    regfile[7] <= 16'h0000;
  end

  assign read_data_1 = regfile[read_address_1];
  assign read_data_2 = regfile[read_address_2];

  always @(*) begin
    if (write) begin
      regfile[write_address] <= write_data;
    end
  end

  integer f;
  always @(*) begin
    if(complete) begin
      f = $fopen("out/regfile", "w");
      $fwrite(f,"%h\n", regfile[0]);
      $fwrite(f,"%h\n", regfile[1]);
      $fwrite(f,"%h\n", regfile[2]);
      $fwrite(f,"%h\n", regfile[3]);
      $fwrite(f,"%h\n", regfile[4]);
      $fwrite(f,"%h\n", regfile[5]);
      $fwrite(f,"%h\n", regfile[6]);
      $fwrite(f,"%h\n", regfile[7]);
      $fclose(f);
    end
  end

endmodule






