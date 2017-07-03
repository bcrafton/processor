
module issue(
  instruction0_in,
  vld0_in,
  instruction1_in,
  vld1_in,

  free,

  instruction0_out,
  vld0_out,
  instruction1_out,
  vld1_out,

  );

  //reg [31:0] instruction_q [0:7];

  reg [31:0] instruction0;
  reg [31:0] instruction1;

  input wire  [3 * 8 - 1 : 0] ins;
  input wire  [3 * 16 - 1 : 0] depends;
  output wire [8 * 8 - 1 : 0] outs;

  wire [2:0] _ins [0:7];
  wire [2:0] _depends0 [0:7];
  wire [2:0] _depends1 [0:7];

  genvar i, j;

  generate
    for (i=0; i<8; i=i+1) begin : generate_2d_arrays // this name cannot start with a #
      assign _ins[i] =          ins[ i*3   + 2 : i*3       ]; 
      assign _depends0[i] = depends[ i*2*3 + 2 : i*2*3     ]; 
      assign _depends1[i] = depends[ i*2*3 + 5 : i*2*3 + 3 ]; 
    end
  endgenerate

  generate
    for (i=0; i<8; i=i+1) begin : generate_out_x
      for (j=0; j<8; j=j+1) begin : generate_out_y
        assign outs[i] = _depends0[i] == _ins[j] || _depends1[i] == _ins[j];
      end
    end
  endgenerate

  




endmodule
