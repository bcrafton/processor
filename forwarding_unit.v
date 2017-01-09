`timescale 1ns / 1ps

module forwarding_unit(
    id_ex_rs,
    id_ex_rt,
    ex_mem_rd,
    mem_wb_rd,
    ex_mem_reg_write,
    mem_wb_reg_write,
    forward_a,
    forward_b
    );

    input wire [2:0] id_ex_rs;
    input wire [2:0] id_ex_rt;
    input wire [2:0] ex_mem_rd;
    input wire [2:0] mem_wb_rd;
    input wire ex_mem_reg_write;
    input wire mem_wb_reg_write;
    output reg [1:0] forward_a;
    output reg [1:0] forward_b;

    // this is combinational logic
    always @(*) begin

        if(ex_mem_reg_write && id_ex_rs == ex_mem_rd) begin
            forward_a <= 2;
        end else if(mem_wb_reg_write && id_ex_rs == mem_wb_rd) begin
            forward_a <= 1;
        end else begin
            forward_a <= 0;
        end

        if(ex_mem_reg_write && id_ex_rt == ex_mem_rd) begin
            forward_b <= 2;
        end else if(mem_wb_reg_write && id_ex_rt == mem_wb_rd) begin
            forward_b <= 1;
        end else begin
            forward_b <= 0;
        end

    end
endmodule
