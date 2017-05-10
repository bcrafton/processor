
module top;
    reg  [15:0]  wr_address;
    reg          wr_en;
    reg  [15:0]  wr_data;

    reg  [15:0]  rd_address;
    reg          rd_en;
    wire [15:0]  rd_data;

    reg clk;

    memory_controller mc(
    .clk(clk),
    .wr_address(wr_address),
    .wr_en(wr_en),
    .wr_data(wr_data),

    .rd_address(rd_address),
    .rd_en(rd_en),
    .rd_data(rd_data)
    );

    initial begin
        wr_address = 0;
        wr_en = 0;
        wr_data = 0;
        
        rd_address = 0;
        rd_en = 0;
        
        wr_address = 10;
        wr_data = 0;
        rd_en = 1;
        wr_en = 1;

        clk = 0;
    end

    always #1 clk = ~clk;

    always @(posedge clk) begin

        if ($time > 260) begin
            rd_en <= 0;
            wr_en <= 0;
        end else begin
        end

        rd_address <= rd_address + 1;
        wr_address <= wr_address + 1;
        wr_data <= wr_data + 1;

    end

    always @(posedge clk) begin

        if($time > 1000) begin
            $finish;
        end
    end

endmodule
