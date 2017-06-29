
#include "emulator.h"

static program_state_t p;

static void execute_instruction(INSTRUCTION i, program_state_t* p)
{
  uint8_t opcode = opcode_of(i);
  uint8_t rs = rs_of(i);
  uint8_t rt = rt_of(i);
  uint8_t rd = rd_of(i);
  uint16_t imm = imm_of(i);

  uint32_t rs_data = mem_read(rs, REGFILE_ID);
  uint32_t rt_data = mem_read(rt, REGFILE_ID);

  uint16_t address = 0;
  uint32_t write_data = 0;

  uint32_t mem_read_data = 0;
  uint32_t mem_write_data = 0;

  uint32_t branch_taken = 0;

  uint32_t op1 = 0;
  uint32_t op2 = 0;

  instruction_log_t* log = (instruction_log_t*) malloc(sizeof(instruction_log_t));
  log->pc = p->pc;
  log->timestamp = p->instruction_count;
  log->id = p->instruction_count;
  log->instruction = i;
  log->reg_read_data0 = rs_data;
  log->reg_read_data1 = rt_data;
  // this happens after the switch.
  // log->reg_write_data = ;
  log->immediate = imm;

  switch (opcode) {
    // 6'b00xxxx
    case OP_CODE_ADD:
      op1 = rs_data;
      op2 = rt_data;
      write_data = op1 + op2;
      mem_write(rd, write_data, REGFILE_ID);
      p->pc++;
      break;
    case OP_CODE_SUB:
      op1 = rs_data;
      op2 = rt_data;
      write_data = op1 - op2;
      mem_write(rd, write_data, REGFILE_ID);
      p->pc++;
      break;
    case OP_CODE_NOT:
      printf("not implemented yet: not\n");
      break;
    case OP_CODE_AND:
      op1 = rs_data;
      op2 = rt_data;
      write_data = op1 & op2;
      mem_write(rd, write_data, REGFILE_ID);
      p->pc++;
      break;
    case OP_CODE_OR:
      op1 = rs_data;
      op2 = rt_data;
      write_data = op1 | op2;
      mem_write(rd, write_data, REGFILE_ID);
      p->pc++;
      break;
    case OP_CODE_NAND:
      op1 = rs_data;
      op2 = rt_data;
      write_data = ~(op1 & op2);
      mem_write(rd, write_data, REGFILE_ID);
      p->pc++;
      break;
    case OP_CODE_NOR:
      op1 = rs_data;
      op2 = rt_data;
      write_data = ~(op1 | op2);
      mem_write(rd, write_data, REGFILE_ID);
      p->pc++;
      break;
    case OP_CODE_MOV:
      op1 = rs_data;
      op2 = rt_data;
      write_data = op2;
      mem_write(rd, write_data, REGFILE_ID);
      p->pc++;
      break;
    case OP_CODE_SAR:
      // there is no sar in c ...
      op1 = rs_data;
      op2 = rt_data;
      write_data = op1 >> op2;
      mem_write(rd, write_data, REGFILE_ID);
      p->pc++;
      break;
    case OP_CODE_SHR:
      op1 = rs_data;
      op2 = rt_data;
      write_data = op1 >> op2;
      mem_write(rd, write_data, REGFILE_ID);
      p->pc++;
      break;
    case OP_CODE_SHL:
      op1 = rs_data;
      op2 = rt_data;
      write_data = op1 << op2;
      mem_write(rd, write_data, REGFILE_ID);
      p->pc++;
      break;
    case OP_CODE_XOR:
      op1 = rs_data;
      op2 = rt_data;
      write_data = op1 ^ op2;
      mem_write(rd, write_data, REGFILE_ID);
      p->pc++;
      break;
    case OP_CODE_TEST:
      op1 = rs_data;
      op2 = rt_data;
      p->pc++;
      p->zero = (op1 & op2) == 0;
      p->less = (op1 < op2);
      p->greater = (op1 > op2);
      break;
    case OP_CODE_CMP:
      op1 = rs_data;
      op2 = rt_data;
      p->pc++;
      p->zero = (op1 - op2) == 0;
      p->less = (op1 < op2);
      p->greater = (op1 > op2);
      break;

    // 6'b01xxxx
    case OP_CODE_ADDI:
      op1 = rs_data;
      op2 = imm;
      write_data = op1 + op2;
      mem_write(rt, write_data, REGFILE_ID);
      p->pc++;
      break;
    case OP_CODE_SUBI:
      op1 = rs_data;
      op2 = imm;
      write_data = op1 - op2;
      mem_write(rt, write_data, REGFILE_ID);
      p->pc++;
      break;
    case OP_CODE_NOTI:
      printf("not implemented yet: noti\n");
      break;
    case OP_CODE_ANDI:
      op1 = rs_data;
      op2 = imm;
      write_data = op1 & op2;
      mem_write(rt, write_data, REGFILE_ID);
      p->pc++;
      break;
    case OP_CODE_ORI:
      op1 = rs_data;
      op2 = imm;
      write_data = op1 | op2;
      mem_write(rt, write_data, REGFILE_ID);
      p->pc++;
      break;
    case OP_CODE_NANDI:
      op1 = rs_data;
      op2 = imm;
      write_data = ~(op1 & op2);
      mem_write(rt, write_data, REGFILE_ID);
      p->pc++;
      break;
    case OP_CODE_NORI:
      op1 = rs_data;
      op2 = imm;
      write_data = ~(op1 | op2);
      mem_write(rt, write_data, REGFILE_ID);
      p->pc++;
      break;
    case OP_CODE_MOVI:
      op1 = rs_data;
      op2 = imm;
      write_data = op2;
      mem_write(rt, write_data, REGFILE_ID);
      p->pc++;
      break;
    case OP_CODE_SARI:
      // there is no sar in c ...
      op1 = rs_data;
      op2 = imm;
      write_data = op1 >> op2;
      mem_write(rt, write_data, REGFILE_ID);
      p->pc++;
      break;
    case OP_CODE_SHRI:
      op1 = rs_data;
      op2 = imm;
      write_data = op1 >> op2;
      mem_write(rt, write_data, REGFILE_ID);
      p->pc++;
      break;
    case OP_CODE_SHLI:
      op1 = rs_data;
      op2 = imm;
      write_data = op1 << op2;
      mem_write(rt, write_data, REGFILE_ID);
      p->pc++;
      break;
    case OP_CODE_XORI:
      op1 = rs_data;
      op2 = imm;
      write_data = op1 ^ op2;
      mem_write(rt, write_data, REGFILE_ID);
      p->pc++;
      break;
    case OP_CODE_TESTI:
      op1 = rs_data;
      op2 = imm;
      p->pc++;
      p->zero = (op1 & op2) == 0;
      p->less = (op1 < op2);
      p->greater = (op1 > op2);
      break;
    case OP_CODE_CMPI:
      op1 = rs_data;
      op2 = imm;
      p->pc++;
      p->zero = (op1 - op2) == 0;
      p->less = (op1 < op2);
      p->greater = (op1 > op2);
      break;

    // 6'b10xxxx
    case OP_CODE_LW:
      op1 = rs_data;
      op2 = imm;

      address = op1 + op2;

      mem_read_data = mem_read(address, DMEM_ID);
      write_data = mem_read_data;

      mem_write(rt, write_data, REGFILE_ID);
      p->pc++;
      break;
    case OP_CODE_SW:
      op1 = rs_data;
      op2 = imm;

      address = op1 + op2;

      mem_write_data = rt_data;
      mem_write(address, mem_write_data, DMEM_ID);

      p->pc++;
      break;
    case OP_CODE_LA:
      break;
    case OP_CODE_SA:
      break;

    // 6'b11xxxx
    case OP_CODE_JMP:
      p->pc = imm;
      break;
    case OP_CODE_JO:
      printf("not implemented yet: jo\n");
      break;
    case OP_CODE_JE:
      if (p->zero) {
        p->pc = imm;
        branch_taken = 1;
      }
      else {
        p->pc++;
      }
      break;
    case OP_CODE_JNE:
      if (!p->zero) {
        p->pc = imm;
        branch_taken = 1;
      }
      else {
        p->pc++;
      }
      break;
    case OP_CODE_JL:
      if (p->less) {
        p->pc = imm;
        branch_taken = 1;
      }
      else {
        p->pc++;
      }
      break;
    case OP_CODE_JLE:
      if (p->less || p->zero) {
        p->pc = imm;
        branch_taken = 1;
      }
      else {
        p->pc++;
      }
      break;
    case OP_CODE_JG:
      if (p->greater) {
        p->pc = imm;
        branch_taken = 1;
      }
      else {
        p->pc++;
      }
      break;
    case OP_CODE_JGE:
      if (p->greater || p->zero) {
        p->pc = imm;
        branch_taken = 1;
      }
      else {
        p->pc++;
      }
      break;
    case OP_CODE_JZ:
      if (p->zero) {
        p->pc = imm;
        branch_taken = 1;
      }
      else {
        p->pc++;
      }
      break;
    case OP_CODE_JNZ:
      if (!p->zero) {
        p->pc = imm;
        branch_taken = 1;
      }
      else {
        p->pc++;
      }
      break;
    case OP_CODE_JR:
      p->pc = rs_data;
      break;

    case OP_CODE_NOP:
      break;

    default:
      printf("invalid instruction!\n");
  }

  log->reg_write_data = write_data;
  log->mem_read_data = mem_read_data;
  log->mem_write_data = mem_write_data;

  // not confident with these.
  log->zero = p->zero;
  log->greater = p->greater;
  log->less = p->less;

  log->branch_taken = branch_taken;

  log->alu_in0 = op1;
  log->alu_in1 = op2;

  instruction_log(log);

}

void execute_program(char* program_path, char* out_path, uint32_t run_time)
{
  memory_clear();

  p.pc = 0;
  p.zero = 0;
  p.less = 0;
  p.greater = 0; 
  p.instruction_count = 0;

  load_program(program_path);

  int i;
  for(i=0; i<run_time; i++) // dont know whether to do this or use while(<256)
  {
    INSTRUCTION i = mem_read(p.pc, IMEM_ID);
    execute_instruction(i, &p);
    p.instruction_count++;
  }

  dump_memory(out_path);
  dump_instruction_logs(out_path);
}

int main(int argc, char** argv)
{
  if(argc != 4)
  {
    fprintf(stderr, "want 4 arguments, got %d\n", argc);
    int i;
    for(i=1; i<argc; i++)
    {
      fprintf(stderr, "%s, ", argv[i]);
    }
  }
  char* program_path = argv[1];
  char* out_path = argv[2];
  int32_t run_time = atoi(argv[3]);

  execute_program(program_path, out_path, run_time);
}









