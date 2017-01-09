`timescale 1ns / 1ps

module hazard_detection_unit(
    id_ex_mem_op,
    id_ex_rt, // the place we are loading to.
    if_id_rs,
    if_id_rt,

    stall
    );

    input wire [1:0] id_ex_mem_op;
    input wire [2:0] if_id_rs;
    input wire [2:0] if_id_rt;
    input wire [2:0] id_ex_rt;

    output reg stall;

    // this is combinational logic
    always@(*) begin

        if((if_id_rs == id_ex_rt || if_id_rt == id_ex_rt) && (id_ex_mem_op == 2'b01)) begin
            stall <= 1'b1;
        end else begin
            stall <= 1'b0;
        end

    end

endmodule
