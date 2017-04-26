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

    reg [15:0] regfile [0:7];

    input clk;
    input complete;
    input write;
    input wire [2:0] write_address;
    input wire [15:0] write_data;
    input wire [2:0] read_address_1;
    output wire [15:0] read_data_1;
    input wire [2:0] read_address_2;
    output wire [15:0] read_data_2;

    initial begin
        regfile[0] <= 4'h0000;
        regfile[1] <= 4'h0000;
        regfile[2] <= 4'h0000;
        regfile[3] <= 4'h0000;

        regfile[4] <= 4'h0000;
        regfile[5] <= 4'h0000;
        regfile[6] <= 4'h0000;
        regfile[7] <= 4'h0000;
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
          f = $fopen("out/ram", "w");
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






