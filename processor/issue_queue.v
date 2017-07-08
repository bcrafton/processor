
module issue_queue(
  
  clk,
  flush,
  free,

  pop0,
  pop_instruction0,
  pop_pc0,
  pop_id0,
  pop_key0,

  pop1,
  pop_instruction1,
  pop_pc1,
  pop_id1,
  pop_key1,

  push0,
  push_instruction0,
  push_pc0,
  push_id0,

  push1,
  push_instruction1,
  push_pc1,
  push_id1,
  
  );

  input wire clk;
  input wire flush;
  output wire [2:0] free; // the # of non valid slots
  output wire [2:0] count;

  input wire pop0;
  output reg pop_instruction0;
  output reg pop_pc0;
  output reg pop_id0;
  output reg pop_key0;

  input wire pop1;
  output reg pop_instruction1;
  output reg pop_pc1;
  output reg pop_id1;
  output reg pop_key1;

  input wire push0;
  input wire push_instruction0;
  input wire push_pc0;
  input wire push_id0;

  input wire push1;
  input wire push_instruction1;
  input wire push_pc1;
  input wire push_id1;

  ///////////////

  reg [] instructions [0:7];
  reg [] pcs [0:7];
  reg [] ids [0:7];
  reg [] keys [0:7];
  reg [] vld [0:7];

  reg [] mru;
  reg [] lru;

  ///////////////

  assign free = !vld[0] +
                !vld[1] +
                !vld[2] +
                !vld[3] +
                !vld[4] +
                !vld[5] +
                !vld[6] +
                !vld[7];

  assign count = vld[0] +
                 vld[1] +
                 vld[2] +
                 vld[3] +
                 vld[4] +
                 vld[5] +
                 vld[6] +
                 vld[7];

  ///////////////

  // it shudnt matter where we put the pushed instruction ... earliest valid spot? -> no just lru

  /* 

  free = # of non valid slots in memory.
  oldest = start of list
  newest = end of list

  so if oldest.valid = 0, it is free
  if oldest.next.valid = 0, then 2 free slots.

  at what point is not incrementing all not-changed wires better.

  */

  // ALL THE DATA NEEDS TO BE BOUND TOGETHER SO U DONT HAVE TO UPDATE EACH ONES NEXT POINTERS AND SHIT.

  // THIS BE HARD SON.

  initial begin

    for(i=0; i<8; i=i+1) begin
      instructions[i] = 0;
      pcs[i] = 0;
      ids[i] = 0;
      keys[i] = 0; // we maintain this
      vld[i] = 0; // we maintain this
    end

    newest = 7;
    oldest = 0;
  end

  // dont have to increment free if it is a wire that will change - ah but we do because its posedge clk
  always @(posedge clk) begin

    if (flush) begin
    end else begin

      if (push0 && (free >= 1)) begin

        // do the evict.
        

        instructions[oldest] = push_instruction0;
        pcs[oldest] = push_pc0;
        ids[oldest] = push_id0;
        vld[oldest] = 1;
      end

      if (push1 && (free >= 2)) begin // not sure if correct
        instructions[oldest] = push_instruction0;
        pcs[oldest] = push_pc0;
        ids[oldest] = push_id0;
        vld[oldest] = 1;
      end

      if (pop0 && (count >= 1)) begin
      end

      if (pop1 && (count >= 2)) begin
      end

    end

  end

endmodule
