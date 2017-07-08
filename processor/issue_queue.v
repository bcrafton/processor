
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

  // we are gonna be outputing these things as separate things (instruction, pc, id) but storing them together.

  input wire clk;
  input wire flush;
  output wire [`NUM_IQ_ENTRIES_LOG2-1:0] free; // the # of non valid slots
  output wire [`NUM_IQ_ENTRIES_LOG2-1:0] count;

  input wire pop0;
  output wire pop_instruction0;
  output wire pop_pc0;
  output wire pop_id0;
  output wire pop_key0;

  input wire pop1;
  output wire pop_instruction1;
  output wire pop_pc1;
  output wire pop_id1;
  output wire pop_key1;

  input wire push0;
  input wire push_instruction0;
  input wire push_pc0;
  input wire push_id0;

  input wire push1;
  input wire push_instruction1;
  input wire push_pc1;
  input wire push_id1;

  ///////////////

  //reg [] instructions [0:7];
  //reg [] pcs [0:7];
  //reg [] ids [0:7];
  reg [] data [0:7];

  reg [] nexts [0:7];
  reg [] prevs [0:7];
  reg [] vld [0:7];

  reg [] head;
  reg [] tail;

  wire next;

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

  assign next = !vld[0] ? 0 :
                !vld[1] ? 1 :
                !vld[2] ? 2 :
                !vld[3] ? 3 :
                !vld[4] ? 4 :
                !vld[5] ? 5 :
                !vld[6] ? 6 :
                !vld[7] ? 7 :
                8;
                  

  ///////////////

  // it shudnt matter where we put the pushed instruction ... earliest valid spot? -> no just lru

  /* 

  free = # of non valid slots in memory.
  oldest = start of list
  newest = end of list

  so if oldest.valid = 0, it is free
  if oldest.next.valid = 0, then 2 free slots.

  at what point is not incrementing all not-changed wires better.

  we can use next to calculate order.

  so this implementation just needs to be a linked list.
  wondering how well it can be done in verilog and if it is even synthesizable.

  */

  initial begin

    for(i=0; i<8; i=i+1) begin
      //instructions[i] = 0;
      //pcs[i] = 0;
      //ids[i] = 0;
      data[i] = 0;

      nexts[i] = 0; // we maintain this
      prevs[i] = 0;
      vld[i] = 0; // we maintain this
    end

    head = 0; // do we even need this?
    tail = 0;
  end

  // dont have to increment free if it is a wire that will change - ah but we do because its posedge clk
  always @(posedge clk) begin

    if (flush) begin
    end else begin

      if (push0 && (free >= 1)) begin

        nexts[tail] <= next;
        nexts[prev] <= tail;
        data[tail] <= push_data0;
        vld[tail] <= 1;
        tail <= next;

      end

      if (push1 && (free >= 2)) begin // not sure if correct
      end

      if (pop0 && (count >= 1)) begin

        nexts[ prevs[pop0] ] <= nexts[pop0];
        prevs[ nexts[pop0] ] <= prevs[pop0];
        vld[pop0] = 0;

      end

      if (pop1 && (count >= 2)) begin
      end

    end

  end

endmodule
