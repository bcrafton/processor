`timescale 1ns / 1ps

`include "defines.vh"

module issue(
  clk,
  flush,
  free,

  if_id_instruction1,
  if_id_mem_op1,

  instruction0_in,
  instruction1_in,

  push0,
  push1,

  //////////////

  stall,

  //////////////

  branch_taken0_in,
  branch_taken1_in,

  branch_taken_address0_in,
  branch_taken_address1_in,

  pc0_in,
  pc1_in,

  id0_in,
  id1_in,

  //////////////

  instruction0_out,
  instruction1_out,

  pc0_out,
  pc1_out,

  id0_out,
  id1_out,

  branch_taken0_out,
  branch_taken1_out,

  branch_taken_address0_out,
  branch_taken_address1_out,

  iq_index0_out,
  iq_index1_out,

  first
  
  );

  input wire clk;
  input wire flush;

  input wire [`INST_WIDTH-1:0] if_id_instruction1;
  input wire [`MEM_OP_BITS-1:0] if_id_mem_op1;

  input wire [`INST_WIDTH-1:0] instruction0_in;
  input wire [`INST_WIDTH-1:0] instruction1_in;

  input wire push0;
  input wire push1;

  //////////////

  output wire stall;

  //////////////

  input wire branch_taken0_in;
  input wire branch_taken1_in;

  input wire [`ADDR_WIDTH-1:0] branch_taken_address0_in;
  input wire [`ADDR_WIDTH-1:0] branch_taken_address1_in;

  input wire [`ADDR_WIDTH-1:0] pc0_in;
  input wire [`ADDR_WIDTH-1:0] pc1_in;

  input wire [`INSTRUCTION_ID_WIDTH-1:0] id0_in;
  input wire [`INSTRUCTION_ID_WIDTH-1:0] id1_in;

  //////////////

  output reg branch_taken0_out;
  output reg branch_taken1_out;

  output reg [`ADDR_WIDTH-1:0] branch_taken_address0_out;
  output reg [`ADDR_WIDTH-1:0] branch_taken_address1_out;

  output reg [`ADDR_WIDTH-1:0] pc0_out;
  output reg [`ADDR_WIDTH-1:0] pc1_out;

  output reg [`INSTRUCTION_ID_WIDTH-1:0] id0_out;
  output reg [`INSTRUCTION_ID_WIDTH-1:0] id1_out;

  output reg [`INST_WIDTH-1:0] instruction0_out;
  output reg [`INST_WIDTH-1:0] instruction1_out;

  output reg [`NUM_IQ_ENTRIES_LOG2-1:0] iq_index0_out;
  output reg [`NUM_IQ_ENTRIES_LOG2-1:0] iq_index1_out;

  output wire first;

  //////////////
  
  wire [7:0] vld_mask;
  wire [7:0] load_vld_mask;
  wire [7:0] split_vld_mask;
  //wire [1:0] steer_vld_mask;
  wire [2:0] pop_key0;
  wire [2:0] pop_key1;  
  wire pop0;
  wire pop1;

  //////////////

  output wire [3:0] free;

  //////////////
  
  assign stall = free == 0;

  //////////////
  
  wire [`INST_WIDTH-1:0]           instruction          [0:7];
  wire [`ADDR_WIDTH-1:0]           pc                   [0:7];
  wire [`INSTRUCTION_ID_WIDTH-1:0] id                   [0:7];
  wire                             branch_taken         [0:7];
  wire [`ADDR_WIDTH-1:0]           branch_taken_address [0:7];
  wire [`NUM_IQ_ENTRIES_LOG2-1:0]  iq_index             [0:7];

  wire [`OP_CODE_BITS-1:0] opcode [0:7];
  wire [`NUM_REG_MASKS-1:0] reg_vld_mask [0:7];
  wire [`NUM_REGISTERS_LOG2-1:0] reg_src0 [0:7];
  wire [`NUM_REGISTERS_LOG2-1:0] reg_src1 [0:7];
  wire [`NUM_REGISTERS_LOG2-1:0] reg_dest [0:7];

  //////////////

  issue_queue q(
  .clk(clk),
  .flush(flush),
  .free(free),

  ///////////////

  .pop0(pop0),
  .pop_key0(pop_key0),

  .pop1(pop1),
  .pop_key1(pop_key1),

  ///////////////

  .data0({branch_taken[0], branch_taken_address[0], id[0], instruction[0], pc[0]}),
  .data1({branch_taken[1], branch_taken_address[1], id[1], instruction[1], pc[1]}),
  .data2({branch_taken[2], branch_taken_address[2], id[2], instruction[2], pc[2]}),
  .data3({branch_taken[3], branch_taken_address[3], id[3], instruction[3], pc[3]}),
  .data4({branch_taken[4], branch_taken_address[4], id[4], instruction[4], pc[4]}),
  .data5({branch_taken[5], branch_taken_address[5], id[5], instruction[5], pc[5]}),
  .data6({branch_taken[6], branch_taken_address[6], id[6], instruction[6], pc[6]}),
  .data7({branch_taken[7], branch_taken_address[7], id[7], instruction[7], pc[7]}),


  ///////////////

  .vld0(vld_mask[0]),
  .vld1(vld_mask[1]),
  .vld2(vld_mask[2]),
  .vld3(vld_mask[3]),
  .vld4(vld_mask[4]),
  .vld5(vld_mask[5]),
  .vld6(vld_mask[6]),
  .vld7(vld_mask[7]),

  ///////////////

  .index0(iq_index[0]),
  .index1(iq_index[1]),
  .index2(iq_index[2]),
  .index3(iq_index[3]),
  .index4(iq_index[4]),
  .index5(iq_index[5]),
  .index6(iq_index[6]),
  .index7(iq_index[7]),

  ///////////////

  .push0(push0),
  .push_data0({branch_taken0_in, branch_taken_address0_in, id0_in, instruction0_in, pc0_in}),

  .push1(push1),
  .push_data1({branch_taken1_in, branch_taken_address1_in, id1_in, instruction1_in, pc1_in})
  );
  
  //////////////
  
  genvar i;

  generate
    for (i=0; i<8; i=i+1) begin : generate_reg_depends
      
	  assign opcode[i] = instruction[i][`OPCODE_MSB:`OPCODE_LSB];
	  
      reg_depends reg_depends(
      .instruction(instruction[i]),
      .reg_src0(reg_src0[i]),
      .reg_src1(reg_src1[i]),
      .reg_dest(reg_dest[i]),
      .vld_mask(reg_vld_mask[i])
      );

    end
  endgenerate
  
  ///////////////////
  
  load_hazard lh(
  .if_id_instruction1(if_id_instruction1),
  .if_id_mem_op1(if_id_mem_op1),

  .reg_src0_in( {reg_src0[7], reg_src0[6], reg_src0[5], reg_src0[4], reg_src0[3], reg_src0[2], reg_src0[1], reg_src0[0]} ),
  .reg_src1_in( {reg_src1[7], reg_src1[6], reg_src1[5], reg_src1[4], reg_src1[3], reg_src1[2], reg_src1[1], reg_src1[0]} ),
  .reg_vld_mask_in( {reg_vld_mask[7], reg_vld_mask[6], reg_vld_mask[5], reg_vld_mask[4], reg_vld_mask[3], reg_vld_mask[2], reg_vld_mask[1], reg_vld_mask[0]} ),
  
  .vld_mask_in(vld_mask),

  .vld_mask_out(load_vld_mask)
  );
  
  split_hazard sh(
  .opcode_in(   {opcode[7], opcode[6], opcode[5], opcode[4], opcode[3], opcode[2], opcode[1], opcode[0]}                 ),
  .reg_src0_in( {reg_src0[7], reg_src0[6], reg_src0[5], reg_src0[4], reg_src0[3], reg_src0[2], reg_src0[1], reg_src0[0]} ),
  .reg_src1_in( {reg_src1[7], reg_src1[6], reg_src1[5], reg_src1[4], reg_src1[3], reg_src1[2], reg_src1[1], reg_src1[0]} ),
  .reg_dest_in( {reg_dest[7], reg_dest[6], reg_dest[5], reg_dest[4], reg_dest[3], reg_dest[2], reg_dest[1], reg_dest[0]} ),
  .reg_vld_mask_in( {reg_vld_mask[7], reg_vld_mask[6], reg_vld_mask[5], reg_vld_mask[4], reg_vld_mask[3], reg_vld_mask[2], reg_vld_mask[1], reg_vld_mask[0]} ),

  .vld_mask_in(load_vld_mask),
  .pop0(pop0),
  .pop_key0(pop_key0),
  
  .vld_mask_out(split_vld_mask)
  );
  
  steer s(
  .opcode_in( {opcode[7], opcode[6], opcode[5], opcode[4], opcode[3], opcode[2], opcode[1], opcode[0]} ),
  .vld_mask_in(split_vld_mask),
  
  .first(first),
  .pop_key0(pop_key0),
  .pop_key1(pop_key1),
  .pop0(pop0),
  .pop1(pop1)
  );
  
  initial begin
    instruction0_out          <= 0;
    pc0_out                   <= 0;
    id0_out                   <= 0;
    branch_taken0_out         <= 0;
    branch_taken_address0_out <= 0;
    iq_index0_out             <= 0;
    
    instruction1_out          <= 0;
    pc1_out                   <= 0;
    id1_out                   <= 0;
    branch_taken1_out         <= 0;
    branch_taken_address1_out <= 0;
    iq_index1_out             <= 0;
  end
  
  always @(*) begin

    if (flush) begin
      instruction0_out          = 0;
      pc0_out                   = 0;
      id0_out                   = 0;
      branch_taken0_out         = 0;
      branch_taken_address0_out = 0;
      iq_index0_out             = 0;
      
      instruction1_out          = 0;
      pc1_out                   = 0;
      id1_out                   = 0;
      branch_taken1_out         = 0;
      branch_taken_address1_out = 0;
      iq_index1_out             = 0;
    end else begin
      if(!first) begin
        instruction0_out          = pop0 ? instruction[pop_key0]          : 0;
        pc0_out                   = pop0 ? pc[pop_key0]                   : 0;
        id0_out                   = pop0 ? id[pop_key0]                   : 0;
        branch_taken0_out         = pop0 ? branch_taken[pop_key0]         : 0;
        branch_taken_address0_out = pop0 ? branch_taken_address[pop_key0] : 0;
        iq_index0_out             = pop0 ? iq_index[pop_key0]             : 0;
        
        instruction1_out          = pop1 ? instruction[pop_key1]          : 0;
        pc1_out                   = pop1 ? pc[pop_key1]                   : 0;
        id1_out                   = pop1 ? id[pop_key1]                   : 0;
        branch_taken1_out         = pop1 ? branch_taken[pop_key1]         : 0;
        branch_taken_address1_out = pop1 ? branch_taken_address[pop_key1] : 0;
        iq_index1_out             = pop1 ? iq_index[pop_key1]             : 0;
      end else begin
        instruction1_out          = pop0 ? instruction[pop_key0]          : 0;
        pc1_out                   = pop0 ? pc[pop_key0]                   : 0;
        id1_out                   = pop0 ? id[pop_key0]                   : 0;
        branch_taken1_out         = pop0 ? branch_taken[pop_key0]         : 0;
        branch_taken_address1_out = pop0 ? branch_taken_address[pop_key0] : 0;
        iq_index1_out             = pop0 ? iq_index[pop_key0]             : 0;
        
        instruction0_out          = pop1 ? instruction[pop_key1]          : 0;
        pc0_out                   = pop1 ? pc[pop_key1]                   : 0;
        id0_out                   = pop1 ? id[pop_key1]                   : 0;
        branch_taken0_out         = pop1 ? branch_taken[pop_key1]         : 0;
        branch_taken_address0_out = pop1 ? branch_taken_address[pop_key1] : 0;
        iq_index0_out             = pop1 ? iq_index[pop_key1]             : 0;
      end

    end
    
  end

endmodule

module load_hazard(
  if_id_instruction1,
  if_id_mem_op1,

  reg_src0_in,
  reg_src1_in,
  reg_vld_mask_in,

  vld_mask_in,
  vld_mask_out,
  
  );
  
  input wire [`INST_WIDTH-1:0] if_id_instruction1;
  input wire [`MEM_OP_BITS-1:0] if_id_mem_op1;

  input wire [`NUM_REGISTERS_LOG2 * 8 -1:0] reg_src0_in;
  input wire [`NUM_REGISTERS_LOG2 * 8 -1:0] reg_src1_in;
  input wire [`NUM_REG_MASKS * 8 -1:0]      reg_vld_mask_in;
  
  input wire [7:0] vld_mask_in;

  output wire [7:0] vld_mask_out;
  
  wire [`NUM_REGISTERS_LOG2-1:0] if_id_rt = if_id_instruction1[`REG_RT_MSB:`REG_RT_LSB];
  wire [`NUM_REG_MASKS-1:0]      reg_vld_mask [0:7];
  wire [`NUM_REGISTERS_LOG2-1:0] reg_src0     [0:7];
  wire [`NUM_REGISTERS_LOG2-1:0] reg_src1     [0:7];
  wire [7:0]                     load_stall;
  
  genvar i;
  generate
    for (i=0; i<8; i=i+1) begin : generate_reg_depends
	  
      assign reg_vld_mask[i] = reg_vld_mask_in[`NUM_REG_MASKS*i + `NUM_REG_MASKS-1 : `NUM_REG_MASKS*i];
      assign reg_src0[i] =     reg_src0_in[`NUM_REGISTERS_LOG2*i + `NUM_REGISTERS_LOG2-1 : `NUM_REGISTERS_LOG2*i];
      assign reg_src1[i] =     reg_src1_in[`NUM_REGISTERS_LOG2*i + `NUM_REGISTERS_LOG2-1 : `NUM_REGISTERS_LOG2*i];

      assign load_stall[i] = ( ((reg_src0[i] == if_id_rt) && ((reg_vld_mask[i] & `REG_MASK_RS0) == `REG_MASK_RS0))   || 
                               ((reg_src1[i] == if_id_rt) && ((reg_vld_mask[i] & `REG_MASK_RS1) == `REG_MASK_RS1)) ) && 
                               (if_id_mem_op1 == `MEM_OP_READ);

      assign vld_mask_out[i] = !load_stall[i] & vld_mask_in[i];
    end
  endgenerate
  
  
endmodule

module reg_depends(

  instruction,

  reg_src0,
  reg_src1,
  reg_dest,

  vld_mask

  );

  input wire [`INST_WIDTH-1:0] instruction;

  output reg [`NUM_REGISTERS_LOG2-1:0] reg_src0;
  output reg [`NUM_REGISTERS_LOG2-1:0] reg_src1;
  output reg [`NUM_REGISTERS_LOG2-1:0] reg_dest;

  output reg [`NUM_REG_MASKS-1:0] vld_mask;

  wire [`OP_CODE_BITS-1:0]       opcode =   instruction[`OPCODE_MSB:`OPCODE_LSB];
  wire [`NUM_REGISTERS_LOG2-1:0] rs =       instruction[`REG_RS_MSB:`REG_RS_LSB];
  wire [`NUM_REGISTERS_LOG2-1:0] rt =       instruction[`REG_RT_MSB:`REG_RT_LSB];
  wire [`NUM_REGISTERS_LOG2-1:0] rd =       instruction[`REG_RD_MSB:`REG_RD_LSB];

  always @(*) begin

    casex(opcode)
     `OP_CODE_NOP: begin
        vld_mask <= 0;
      end
      `OP_CODE_JR: begin
        reg_src0 <= rs;
        vld_mask <= `REG_MASK_RS0;
      end
      6'b00????: begin // add, sub...
        reg_src0 <= rs;
        reg_src1 <= rt;
        reg_dest <= rd;
        vld_mask <= `REG_MASK_RS0 | `REG_MASK_RS1 | `REG_MASK_RD;
      end
      6'b01????: begin // addi, subi...
        reg_src0 <= rs;
        reg_dest <= rt;
        vld_mask <= `REG_MASK_RS0 | `REG_MASK_RD;
      end
      6'b10????: begin // lw, sw, la, sa
        if(opcode == `OP_CODE_LW) begin
          reg_src0 <= rs;
          reg_dest <= rt;
          vld_mask <= `REG_MASK_RS0 | `REG_MASK_RD;
        end else if(opcode == `OP_CODE_SW) begin
          reg_src0 <= rs;
          reg_src1 <= rt;
          vld_mask <= `REG_MASK_RS0 | `REG_MASK_RS1;
        end else if(opcode == `OP_CODE_LA) begin
        end else if(opcode == `OP_CODE_SA) begin
        end
      end
      6'b11????: begin // jmp, jo, je ...
        vld_mask <= 0;
      end
    endcase

  end

endmodule


module split_hazard(

  opcode_in,
  reg_src0_in,
  reg_src1_in,
  reg_dest_in,
  reg_vld_mask_in,
	
	vld_mask_in,
  pop_key0,
  pop0,
	
	vld_mask_out

  );

  input wire [`OP_CODE_BITS * 8 -1:0]       opcode_in;
  input wire [`NUM_REGISTERS_LOG2 * 8 -1:0] reg_src0_in;
  input wire [`NUM_REGISTERS_LOG2 * 8 -1:0] reg_src1_in;
  input wire [`NUM_REGISTERS_LOG2 * 8 -1:0] reg_dest_in;
  input wire [`NUM_REG_MASKS * 8 -1:0]      reg_vld_mask_in;

  output wire [2:0] pop_key0;
  output wire pop0;
  
	input wire [7:0] vld_mask_in;
  
  output wire [7:0] vld_mask_out;
	
  
  ///////////////////
 
  wire [`OP_CODE_BITS-1:0]       opcode       [0:7];
  wire                           is_branch    [0:7];
  wire                           is_cmp       [0:7];
  wire                           is_mem       [0:7];
  wire [`NUM_REG_MASKS-1:0]      reg_vld_mask [0:7];
  wire [`NUM_REGISTERS_LOG2-1:0] reg_src0     [0:7];
  wire [`NUM_REGISTERS_LOG2-1:0] reg_src1     [0:7];
  wire [`NUM_REGISTERS_LOG2-1:0] reg_dest     [0:7];
  wire [7:0]                     split_stall  [0:7];
  
  // just unpacking the wires.
  genvar i, j;
  generate
    for (i=0; i<8; i=i+1) begin : generate_reg_depends_i
	  
      assign opcode[i] = opcode_in[`OP_CODE_BITS*i + `OP_CODE_BITS-1 : `OP_CODE_BITS*i];

      assign is_branch[i] = ((opcode[i] & 6'b110000) == 6'b110000) && (opcode[i] != `OP_CODE_JMP);
      assign is_cmp[i] = (opcode[i] ==`OP_CODE_CMPI) | (opcode[i] ==`OP_CODE_CMP) | (opcode[i] ==`OP_CODE_TEST) | (opcode[i] ==`OP_CODE_TESTI);
      assign is_mem[i] = (opcode[i] ==`OP_CODE_LW) | (opcode[i] ==`OP_CODE_SW);

      assign reg_vld_mask[i] = reg_vld_mask_in[`NUM_REG_MASKS*i + `NUM_REG_MASKS-1 : `NUM_REG_MASKS*i];
      assign reg_src0[i] =     reg_src0_in[`NUM_REGISTERS_LOG2*i + `NUM_REGISTERS_LOG2-1 : `NUM_REGISTERS_LOG2*i];
      assign reg_src1[i] =     reg_src1_in[`NUM_REGISTERS_LOG2*i + `NUM_REGISTERS_LOG2-1 : `NUM_REGISTERS_LOG2*i];
      assign reg_dest[i] =     reg_dest_in[`NUM_REGISTERS_LOG2*i + `NUM_REGISTERS_LOG2-1 : `NUM_REGISTERS_LOG2*i];

      // SPLIT STALL MORE COMPLICATED THEN THIS ... REMEMBER 2D!!!!
      // does not support this: for (j=0; j<i; j=j+1) begin : generate_reg_depends_j
      generate
        for (j=0; j<8; j=j+1) begin : generate_reg_depends_j

          if (i <= j) begin
            assign split_stall[i][j] = 0;
          end else begin
            assign split_stall[i][j] = ( ((reg_src0[i] == reg_dest[j]) 
                                           && ((reg_vld_mask[i] & `REG_MASK_RS0) == `REG_MASK_RS0) 
                                           && ((reg_vld_mask[j] & `REG_MASK_RD) == `REG_MASK_RD)) ||
                                         ((reg_src1[i] == reg_dest[j]) 
                                           && ((reg_vld_mask[i] & `REG_MASK_RS1) == `REG_MASK_RS1) 
                                           && ((reg_vld_mask[j] & `REG_MASK_RD) == `REG_MASK_RD)) || 

                                         ((reg_src0[j] == reg_dest[i]) 
                                           && ((reg_vld_mask[j] & `REG_MASK_RS0) == `REG_MASK_RS0) 
                                           && ((reg_vld_mask[i] & `REG_MASK_RD) == `REG_MASK_RD)
                                           && !(pop0 && (pop_key0 == j))) || 
                                         ((reg_src1[j] == reg_dest[i]) 
                                           && ((reg_vld_mask[j] & `REG_MASK_RS1) == `REG_MASK_RS1) 
                                           && ((reg_vld_mask[i] & `REG_MASK_RD) == `REG_MASK_RD)
                                           && !(pop0 && (pop_key0 == j))) || 

                                         ((reg_dest[i] == reg_dest[j]) 
                                           && ((reg_vld_mask[i] & `REG_MASK_RD)  == `REG_MASK_RD) 
                                           && ((reg_vld_mask[j] & `REG_MASK_RD) == `REG_MASK_RD)
                                           && !(pop0 && (pop_key0 == j))) || 
                                         
                                         (is_branch[j] && !(pop0 && (pop_key0 == j))) ||

                                         (is_branch[i] && !(i == 0 || i == 1)) ||
                                         (is_branch[i] && is_cmp[j]) ||
                                         (is_cmp[i] && is_branch[j]) ||

                                         (is_mem[i] && is_mem[j])
                                         );
          end

        end
      endgenerate

      assign vld_mask_out[i] = !(|split_stall[i]) & vld_mask_in[i];

    end

  endgenerate

  

endmodule

module steer_depends(
  opcode,
  instruction_pipe
  );

  input wire [`OP_CODE_BITS-1:0] opcode;

  output reg [`PIPE_BITS-1:0]    instruction_pipe;

  always @(*) begin

    casex(opcode)
      6'b000000: begin
        instruction_pipe = `PIPE_DONT_CARE;
      end
      6'b00????: begin // add, sub...
        if (opcode == `OP_CODE_CMP || opcode == `OP_CODE_TEST) begin
          instruction_pipe = `PIPE_BRANCH;
        end else begin
          instruction_pipe = `PIPE_DONT_CARE;
        end
      end
      6'b01????: begin // addi, subi...
        if (opcode == `OP_CODE_CMPI || opcode == `OP_CODE_TESTI) begin
          instruction_pipe = `PIPE_BRANCH;
        end else begin
          instruction_pipe = `PIPE_DONT_CARE;
        end        
      end
      6'b10????: begin // lw, sw, la, sa
        instruction_pipe = `PIPE_MEMORY;
      end
      6'b11????: begin // jmp, jo, je ...
        instruction_pipe = `PIPE_BRANCH;
      end
    endcase

  end 

endmodule

module pipe_depends(
  instruction_pipe0,
  instruction_pipe1,
  
  steer_stall,
  first
  );

  input wire [`PIPE_BITS-1:0] instruction_pipe0;
  input wire [`PIPE_BITS-1:0] instruction_pipe1;

  output reg steer_stall;
  output reg first;

  always @(*) begin

    case( {instruction_pipe0, instruction_pipe1} )
      {`PIPE_BRANCH, `PIPE_BRANCH}: begin // hazard. steer stall = 1.
        steer_stall = 1;
        first = 0;
      end
      {`PIPE_MEMORY, `PIPE_BRANCH}: begin
        steer_stall = 0;
        first = 1;
      end
      {`PIPE_MEMORY, `PIPE_MEMORY}: begin // hazard. steer stall = 1.
        steer_stall = 1;
        first = 1;
      end
      {`PIPE_MEMORY, `PIPE_DONT_CARE}: begin
        steer_stall = 0;
        first = 1;
      end
      {`PIPE_DONT_CARE, `PIPE_BRANCH}: begin
        steer_stall = 0;
        first = 1;
      end
      default: begin
        steer_stall = 0;
        first = 0;
      end
    endcase
  end

endmodule


module steer(

	opcode_in,
	vld_mask_in,
	
	first,
  pop_key0,
  pop_key1,
  pop0,
  pop1
	
	);
  
  input wire [`OP_CODE_BITS * 8 -1:0] opcode_in;
	input wire [7:0] vld_mask_in;
	
  output wire first;
  output wire [2:0] pop_key0;
  output wire [2:0] pop_key1;  
  output wire pop0;
  output wire pop1;
  
  ///////////////////
  
  wire [`OP_CODE_BITS-1:0] opcode           [0:7];
  wire [`PIPE_BITS-1:0]    instruction_pipe [0:7];

  wire [7:0] steer_stall;
  wire [7:0] first_array;

  wire [7:0] steer_vld_mask;

  ///////////////////

  assign first = first_array[pop_key1];

  ///////////////////

  // just unpacking the wires.
  genvar i;
  generate
    for (i=0; i<8; i=i+1) begin : generate_reg_depends
	  
      assign opcode[i] = opcode_in[`OP_CODE_BITS*i + `OP_CODE_BITS-1 : `OP_CODE_BITS*i];

      steer_depends steer_depend(
        .opcode(opcode[i]),
        .instruction_pipe(instruction_pipe[i])
      );

      pipe_depends pipe_depends(
      .instruction_pipe0(instruction_pipe[pop_key0]),
      .instruction_pipe1(instruction_pipe[i]),
      .first(first_array[i]),
      .steer_stall(steer_stall[i])
      );

      assign steer_vld_mask[i] = !steer_stall[i] & vld_mask_in[i];

    end
  endgenerate

  // THIS IS LITERALLY A PRIORITY ENCODER ...
  assign {pop_key0, pop0} = vld_mask_in[0] == 1 ? {3'h0, 1'h1} : 
                            vld_mask_in[1] == 1 ? {3'h1, 1'h1} : 
                            vld_mask_in[2] == 1 ? {3'h2, 1'h1} : 
                            vld_mask_in[3] == 1 ? {3'h3, 1'h1} : 
                            vld_mask_in[4] == 1 ? {3'h4, 1'h1} : 
                            vld_mask_in[5] == 1 ? {3'h5, 1'h1} : 
                            vld_mask_in[6] == 1 ? {3'h6, 1'h1} : 
                            vld_mask_in[7] == 1 ? {3'h7, 1'h1} : 
                                                  {3'h0, 1'h0};

  assign {pop_key1, pop1} = (steer_vld_mask[0] == 1) & !(pop_key0 == 0) ? {3'h0, 1'h1} : 
                            (steer_vld_mask[1] == 1) & !(pop_key0 == 1) ? {3'h1, 1'h1} : 
                            (steer_vld_mask[2] == 1) & !(pop_key0 == 2) ? {3'h2, 1'h1} : 
                            (steer_vld_mask[3] == 1) & !(pop_key0 == 3) ? {3'h3, 1'h1} : 
                            (steer_vld_mask[4] == 1) & !(pop_key0 == 4) ? {3'h4, 1'h1} : 
                            (steer_vld_mask[5] == 1) & !(pop_key0 == 5) ? {3'h5, 1'h1} : 
                            (steer_vld_mask[6] == 1) & !(pop_key0 == 6) ? {3'h6, 1'h1} : 
                            (steer_vld_mask[7] == 1) & !(pop_key0 == 7) ? {3'h7, 1'h1} : 
                                                                          {3'h0, 1'h0};
  
endmodule




