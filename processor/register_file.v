module register_file(
  clk,
  write,
  write_address,
  write_data,
  read_address_1,
  read_data_1,
  read_address_2,
  read_data_2,
  );

 // reg [`DATA_WIDTH-1:0] regfile [0:`NUM_REGISTERS-1];

  input clk;
  input write;

  input wire [`NUM_REGISTERS_LOG2-1:0] write_address;
  input wire [`DATA_WIDTH-1:0] write_data;

  input wire [`NUM_REGISTERS_LOG2-1:0] read_address_1;
  output reg [`DATA_WIDTH-1:0] read_data_1;

  input wire [`NUM_REGISTERS_LOG2-1:0] read_address_2;
  output reg [`DATA_WIDTH-1:0] read_data_2;

  reg write_bit;

  always @(*) begin

    if (write) begin
      //$display("writing %d %d %d\n", $time, write_address, write_data);
      write_bit = $mem_write(write_address, write_data, `REGFILE_ID);
    end

    read_data_1 = $mem_read(read_address_1, `REGFILE_ID);
    read_data_2 = $mem_read(read_address_2, `REGFILE_ID);

  end

endmodule






