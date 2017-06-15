module register_file(
  write,
  write_address,
  write_data,
  read_address_1,
  read_data_1,
  read_address_2,
  read_data_2,

  other_write,
  other_write_address,
  other_write_data,
  );

 // reg [`DATA_WIDTH-1:0] regfile [0:`NUM_REGISTERS-1];

  input wire write;

  input wire [`NUM_REGISTERS_LOG2-1:0] write_address;
  input wire [`DATA_WIDTH-1:0] write_data;

  input wire [`NUM_REGISTERS_LOG2-1:0] read_address_1;
  output reg [`DATA_WIDTH-1:0] read_data_1;

  input wire [`NUM_REGISTERS_LOG2-1:0] read_address_2;
  output reg [`DATA_WIDTH-1:0] read_data_2;

  reg write_bit;

  input wire other_write;
  input wire [`NUM_REGISTERS_LOG2-1:0] other_write_address;
  input wire [`DATA_WIDTH-1:0] other_write_data;


  always @(*) begin

    if (write) begin
      //$display("writing %d %d %d\n", $time, write_address, write_data);
      write_bit = $mem_write(write_address, write_data, `REGFILE_ID);
    end

    if (other_write) begin
      if (other_write_address == read_address_1) begin
        read_data_1 = other_write_data;
      end else begin
        read_data_1 = $mem_read(read_address_1, `REGFILE_ID);
      end

      if (other_write_address == read_address_2) begin
        read_data_2 = other_write_data;
      end else begin
        read_data_2 = $mem_read(read_address_2, `REGFILE_ID);
      end
    end else begin
      read_data_1 = $mem_read(read_address_1, `REGFILE_ID);
      read_data_2 = $mem_read(read_address_2, `REGFILE_ID);
    end



  end

endmodule






