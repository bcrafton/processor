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
    input [15:0] address;
    input [1:0] mem_op;

    input [15:0] write_data;
    output reg [15:0] read_data;

    reg [15:0] mem [0:1023];

    // combinational logic
    always @ (*) begin

        if (mem_op == 2'b10) begin
            mem[address] = write_data;
        end else if (mem_op == 2'b01) begin
            read_data = mem[address];
        end
    
    end

    integer f;
    always @(*) begin
        if(complete) begin
          f = $fopen("out/ram", "w");
          $fwrite(f,"%h\n", mem[0]);
          $fwrite(f,"%h\n", mem[1]);
          $fwrite(f,"%h\n", mem[2]);
          $fwrite(f,"%h\n", mem[3]);
          $fwrite(f,"%h\n", mem[4]);
          $fwrite(f,"%h\n", mem[5]);
          $fwrite(f,"%h\n", mem[6]);
          $fwrite(f,"%h\n", mem[7]);
          $fclose(f);
        end
    end

endmodule
