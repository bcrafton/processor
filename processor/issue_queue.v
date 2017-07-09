
module issue_queue(
  
  clk,

  flush,

  free,
  count,

  ///////////////

  pop0,
  pop_key0,

  pop1,
  pop_key1,

  ///////////////

  data0,
  key0,

  data1,
  key1,

  data2,
  key2,

  data3,
  key3,

  data4,
  key4,

  data5,
  key5,

  data6,
  key6,

  data7,
  key7,

  ///////////////

  push0,
  data0,

  push1,
  data1
  
  );

  // so i guess we are going general 
  // dont want to have that any ports
  // just doing 1 data.
  
  // do we want to have more than 1 key.
  // or have the order be the thing it has to shoot back
  
  // eh really only want to have 1 key
  // do a double lookup i think

  input wire clk;
  input wire flush;
  output wire [`NUM_IQ_ENTRIES_LOG2-1:0] free; // the # of non valid slots
  output wire [`NUM_IQ_ENTRIES_LOG2-1:0] count; // # of valid slots

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

  reg [`IQ_ENTRY_SIZE-1:0] data [0:`NUM_IQ_ENTRIES-1];
  reg vld [0:`NUM_IQ_ENTRIES-1];

  reg [`NUM_IQ_ENTRIES_LOG2-1:0] nexts [0:`NUM_IQ_ENTRIES-1];
  reg [`NUM_IQ_ENTRIES_LOG2-1:0] prevs [0:`NUM_IQ_ENTRIES-1];

  reg [`NUM_IQ_ENTRIES_LOG2-1:0] head;
  reg [`NUM_IQ_ENTRIES_LOG2-1:0] tail;

  wire next;

  wire [`IQ_ENTRY_SIZE-1:0] push_data0;
  wire [`IQ_ENTRY_SIZE-1:0] push_data1;

  ///////////////

  assign push_data0 = data

  // nah not doing that with data anymore..
  genvar i;
  generate
    for (i=0; i<`NUM_IQ_ENTRIES; i=i+1) begin : generate_out_vals
      // assign shit 
    end
  endgenerate

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

  /* cud do this? 
  assign keys[head] = 0;
  assign keys[ nexts[head] ] = 1; 

  but instead we can maintain order by just using prevs value ...
  fuck no u cant
  then u have to decrement.

  */

  


  /* 

  it shudnt matter where we put the pushed instruction ... earliest valid spot? -> no just lru

  free = # of non valid slots in memory.
  oldest = start of list
  newest = end of list

  so if oldest.valid = 0, it is free
  if oldest.next.valid = 0, then 2 free slots.

  so this implementation just needs to be a linked list.
  wondering how well it can be done in verilog and if it is even synthesizable.

  */

  initial begin

    for(i=0; i<8; i=i+1) begin
      data[i] = 0;

      nexts[i] = 0; 
      prevs[i] = 0;
      vld[i] = 0; 
    end

    head = 0; // do we even need this?
    tail = 0;
  end

  always @(posedge clk) begin

    if (flush) begin
    end else begin

      if (push0 && (free >= 1)) begin

        if (head == tail) begin
          nexts[tail] <= next;
          nexts[head] <= next;
          nexts[prev] <= tail;

          data[tail] <= push_data0;

          vld[tail] <= 1;

          head <= next;
          tail <= next;

          keys[next] <= keys[tail] + 1;

        end

      end

      if (pop0 && (count >= 1)) begin

        nexts[ prevs[pop0] ] <= nexts[pop0];
        prevs[ nexts[pop0] ] <= prevs[pop0];
        vld[pop0] = 0;

      end

      if (pop1 && (count >= 2)) begin // not sure if correct
      end

      if (push1 && (free >= 2)) begin // not sure if correct
      end

    end

  end

endmodule
