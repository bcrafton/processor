

module memory_controller(
    clk,
    
    wr_address,
    wr_en,
    wr_data,
    
    rd_address,
    rd_en,
    rd_data,
    );
    
    input clk;

    input      [15:0] wr_address;
    input             wr_en;
    input      [15:0] wr_data;

    input      [15:0] rd_address;
    input             rd_en;
    output reg [15:0] rd_data;

    reg bit;

    initial begin
        rd_data = 0;
    end

    always @(posedge clk) begin
        if(wr_en) begin
            bit <= $mem_write(wr_address, wr_data, $time);
            //$display("%d %d\n", wr_address, $time);
        end
        if (rd_en) begin
            rd_data <= $mem_read(rd_address, $time);
            $display("%d\n", rd_data);        
        end
    end

endmodule
