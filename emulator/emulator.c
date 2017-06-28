
#include "emulator.h"

static program_state_t p;

// https://stackoverflow.com/questions/10090326/how-to-extract-specific-bits-from-a-number-in-c
static inline unsigned int bit_select(INSTRUCTION i, unsigned int msb, unsigned int lsb)
{
  unsigned int mask = ~(~0 << (msb - lsb + 1));
  unsigned int value = (i >> lsb) & mask;
  return value;
}

static inline unsigned int opcode_of(INSTRUCTION i)
{
  return bit_select(i, OPCODE_MSB, OPCODE_LSB);
}

static inline unsigned int rs_of(INSTRUCTION i)
{
  return bit_select(i, REG_RS_MSB, REG_RS_LSB);
}

static inline unsigned int rt_of(INSTRUCTION i)
{
  return bit_select(i, REG_RT_MSB, REG_RT_LSB);
}

static inline unsigned int rd_of(INSTRUCTION i)
{
  return bit_select(i, REG_RD_MSB, REG_RD_LSB);
}

static inline unsigned int imm_of(INSTRUCTION i)
{
  return bit_select(i, IMM_MSB, IMM_LSB);
}

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
      write_data = rs_data + rt_data;
      mem_write(rd, write_data, REGFILE_ID);
      p->pc++;
      break;
    case OP_CODE_SUB:
      write_data = rs_data - rt_data;
      mem_write(rd, write_data, REGFILE_ID);
      p->pc++;
      break;
    case OP_CODE_NOT:
      printf("not implemented yet: not\n");
      break;
    case OP_CODE_AND:
      write_data = rs_data & rt_data;
      mem_write(rd, write_data, REGFILE_ID);
      p->pc++;
      break;
    case OP_CODE_OR:
      write_data = rs_data | rt_data;
      mem_write(rd, write_data, REGFILE_ID);
      p->pc++;
      break;
    case OP_CODE_NAND:
      write_data = ~(rs_data & rt_data);
      mem_write(rd, write_data, REGFILE_ID);
      p->pc++;
      break;
    case OP_CODE_NOR:
      write_data = ~(rs_data | rt_data);
      mem_write(rd, write_data, REGFILE_ID);
      p->pc++;
      break;
    case OP_CODE_MOV:
      write_data = rt_data;
      mem_write(rd, write_data, REGFILE_ID);
      p->pc++;
      break;
    case OP_CODE_SAR:
      // there is no sar in c ...
      write_data = rs_data >> rt_data;
      mem_write(rd, write_data, REGFILE_ID);
      p->pc++;
      break;
    case OP_CODE_SHR:
      write_data = rs_data >> rt_data;
      mem_write(rd, write_data, REGFILE_ID);
      p->pc++;
      break;
    case OP_CODE_SHL:
      write_data = rs_data << rt_data;
      mem_write(rd, write_data, REGFILE_ID);
      p->pc++;
      break;
    case OP_CODE_XOR:
      write_data = rs_data ^ rt_data;
      mem_write(rd, write_data, REGFILE_ID);
      p->pc++;
      break;
    case OP_CODE_TEST:
      p->pc++;
      p->zero = (rs_data & rt_data) == 0;
      p->less = (rs_data < rt_data);
      p->greater = (rs_data > rt_data);
      break;
    case OP_CODE_CMP:
      p->pc++;
      p->zero = (rs_data - rt_data) == 0;
      p->less = (rs_data < rt_data);
      p->greater = (rs_data > rt_data);
      break;

    // 6'b01xxxx
    case OP_CODE_ADDI:
      write_data = rs_data + imm;
      mem_write(rt, write_data, REGFILE_ID);
      p->pc++;
      break;
    case OP_CODE_SUBI:
      write_data = rs_data - imm;
      mem_write(rt, write_data, REGFILE_ID);
      p->pc++;
      break;
    case OP_CODE_NOTI:
      printf("not implemented yet: noti\n");
      break;
    case OP_CODE_ANDI:
      write_data = rs_data & imm;
      mem_write(rt, write_data, REGFILE_ID);
      p->pc++;
      break;
    case OP_CODE_ORI:
      write_data = rs_data | imm;
      mem_write(rt, write_data, REGFILE_ID);
      p->pc++;
      break;
    case OP_CODE_NANDI:
      write_data = ~(rs_data & imm);
      mem_write(rt, write_data, REGFILE_ID);
      p->pc++;
      break;
    case OP_CODE_NORI:
      write_data = ~(rs_data | imm);
      mem_write(rt, write_data, REGFILE_ID);
      p->pc++;
      break;
    case OP_CODE_MOVI:
      write_data = imm;
      mem_write(rt, write_data, REGFILE_ID);
      p->pc++;
      break;
    case OP_CODE_SARI:
      // there is no sar in c ...
      write_data = rs_data >> imm;
      mem_write(rt, write_data, REGFILE_ID);
      p->pc++;
      break;
    case OP_CODE_SHRI:
      write_data = rs_data >> imm;
      mem_write(rt, write_data, REGFILE_ID);
      p->pc++;
      break;
    case OP_CODE_SHLI:
      write_data = rs_data << imm;
      mem_write(rt, write_data, REGFILE_ID);
      p->pc++;
      break;
    case OP_CODE_XORI:
      write_data = rs_data ^ imm;
      mem_write(rt, write_data, REGFILE_ID);
      p->pc++;
      break;
    case OP_CODE_TESTI:
      p->pc++;
      p->zero = (rs_data & imm) == 0;
      p->less = (rs_data < imm);
      p->greater = (rs_data > imm);
      break;
    case OP_CODE_CMPI:
      p->pc++;
      p->zero = (rs_data - imm) == 0;
      p->less = (rs_data < imm);
      p->greater = (rs_data > imm);
      break;

    // 6'b10xxxx
    case OP_CODE_LW:
      address = rs_data + imm;

      mem_read_data = mem_read(address, DMEM_ID);
      write_data = mem_read_data;

      mem_write(rt, write_data, REGFILE_ID);
      p->pc++;
      break;
    case OP_CODE_SW:
      address = rs_data + imm;

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









