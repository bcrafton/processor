`timescale 1ns / 1ps

module mux2x1
  #(
  parameter DATA_WIDTH = 3
  )
  (
  in0,
  in1, 
  sel,
  out
  );
  
  input wire [DATA_WIDTH-1:0] in0;
  input wire [DATA_WIDTH-1:0] in1;
  input wire sel;

  output wire [DATA_WIDTH-1:0] out;

  assign out = (sel) ? in1 : in0;

endmodule

module mux4x2
  #(
  parameter DATA_WIDTH = 3
  )
  (
  in0,
  in1, 
  in2,
  in3, 
  sel,
  out
  );
  
  input wire [DATA_WIDTH-1:0] in0;
  input wire [DATA_WIDTH-1:0] in1;
  input wire [DATA_WIDTH-1:0] in2;
  input wire [DATA_WIDTH-1:0] in3;
  input wire [1:0] sel;

  output wire [DATA_WIDTH-1:0] out;

  assign out = (sel == 0) ? in0 : (sel == 1) ? in1 : (sel == 2) ? in2 : in3;

endmodule
