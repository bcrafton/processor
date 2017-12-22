module register_file(
  reset, 
  complete,

  write1,
  write_address1,
  write_data1,

  write2,
  write_address2,
  write_data2,

  read_address_1_1,
  read_data_1_1,
  read_address_2_1,
  read_data_2_1,

  read_address_1_2,
  read_data_1_2,
  read_address_2_2,
  read_data_2_2
  );

 // reg [`DATA_WIDTH-1:0] regfile [0:`NUM_REGISTERS-1];

  input wire reset;
  input wire complete;

  // write

  input wire write1;
  input wire write2;

  input wire [`NUM_REGISTERS_LOG2-1:0] write_address1;
  input wire [`DATA_WIDTH-1:0] write_data1;

  input wire [`NUM_REGISTERS_LOG2-1:0] write_address2;
  input wire [`DATA_WIDTH-1:0] write_data2;

  // read

  input wire [`NUM_REGISTERS_LOG2-1:0] read_address_1_1;
  output reg [`DATA_WIDTH-1:0] read_data_1_1;
  input wire [`NUM_REGISTERS_LOG2-1:0] read_address_2_1;
  output reg [`DATA_WIDTH-1:0] read_data_2_1;

  input wire [`NUM_REGISTERS_LOG2-1:0] read_address_1_2;
  output reg [`DATA_WIDTH-1:0] read_data_1_2;
  input wire [`NUM_REGISTERS_LOG2-1:0] read_address_2_2;
  output reg [`DATA_WIDTH-1:0] read_data_2_2;

  reg write_bit;

  // regfile
  reg [`DATA_WIDTH-1:0] regfile [0:`NUM_REGISTERS-1];

  integer i;
  integer f;

  always @(*) begin

    if (reset) begin
      for(i=0; i<`NUM_REGISTERS; i=i+1) begin
        regfile[i] = 0;
      end
    end

    if (write1) begin
      regfile[write_address1] = write_data1;
    end

    if (write2) begin
      regfile[write_address2] = write_data2;
    end

    read_data_1_1 = regfile[read_address_1_1];
    read_data_2_1 = regfile[read_address_2_1];
    read_data_1_2 = regfile[read_address_1_2];
    read_data_2_2 = regfile[read_address_2_2];

  end

`ifdef SIMULATION

  always @(*) begin
    if (complete) begin
      // $display("Running complete code regfile");
      f = $fopen("/home/brian/Desktop/processor/test_bench/out/sim/to_10.bc.s.hex/reg", "w");
      for(i=0; i<`NUM_REGISTERS; i=i+1) begin
        $fwrite(f, "%h\n", regfile[i]);
      end
      $fclose(f);
      // $display("Complete code regfile");
    end
  end

`endif

endmodule






