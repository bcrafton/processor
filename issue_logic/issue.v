
module issue(
  ins,
  depends,
  outs
  );

  input wire  [3 * 8 - 1 : 0] ins;
  input wire  [3 * 16 - 1 : 0] depends;
  output wire [8 * 8 - 1 : 0] outs;

  // this is not valid 
  // remember we are doing each bit, not each set of 3 bits

  // out needs to do i, j
  // depends needs to get 3 bits.

  // yeah even this not smart enough
  // holy fuck this suck.

  // alright so this module kinda sucks

  wire [2:0] _ins [0:7];
  wire [2:0] _depends0 [0:7];
  wire [2:0] _depends1 [0:7];

  genvar i, j;

  /*
  123 456 789 abc
  2:0     8:6
      5:3     11:9
  */

  //assign _ins[2] = ins[3+2:3];

/*
  generate
    for (i=0; i<8; i=i+1) begin : 2d_array
      assign _ins[i] =          ins[ i*3   + 2 : i*3       ]; 
      assign _depends0[i] = depends[ i*2*3 + 2 : i*2*3     ]; 
      assign _depends1[i] = depends[ i*2*3 + 5 : i*2*3 + 3 ]; 
    end
  endgenerate
*/

  generate
    for (i=0; i<8; i=i+1) begin : generate_2d_arrays
      assign _ins[i] =          ins[ i*3   + 2 : i*3       ]; 
      assign _depends0[i] = depends[ i*2*3 + 2 : i*2*3     ]; 
      assign _depends1[i] = depends[ i*2*3 + 5 : i*2*3 + 3 ]; 
    end
  endgenerate

  generate
    for (i=0; i<8; i=i+1) begin : generate_out_x
      for (j=0; j<8; j=j+1) begin : generate_out_y
        assign outs[i] = _depends0[i] == ins[j] || _depends1[i] == ins[j];
      end
    end
  endgenerate

endmodule
