
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

  uint16_t address;
  uint32_t data;

  switch (opcode) {
    // 6'b00xxxx
    case OP_CODE_ADD:
      data = rs_data + rt_data;
      mem_write(rd, data, REGFILE_ID);
      p->pc++;
      break;
    case OP_CODE_SUB:
      data = rs_data - rt_data;
      mem_write(rd, data, REGFILE_ID);
      p->pc++;
      break;
    case OP_CODE_NOT:
      printf("not implemented yet: not\n");
      break;
    case OP_CODE_AND:
      data = rs_data & rt_data;
      mem_write(rd, data, REGFILE_ID);
      p->pc++;
      break;
    case OP_CODE_OR:
      data = rs_data | rt_data;
      mem_write(rd, data, REGFILE_ID);
      p->pc++;
      break;
    case OP_CODE_NAND:
      data = ~(rs_data & rt_data);
      mem_write(rd, data, REGFILE_ID);
      p->pc++;
      break;
    case OP_CODE_NOR:
      data = ~(rs_data | rt_data);
      mem_write(rd, data, REGFILE_ID);
      p->pc++;
      break;
    case OP_CODE_MOV:
      data = rt_data;
      mem_write(rd, data, REGFILE_ID);
      p->pc++;
      break;
    case OP_CODE_SAR:
      // there is no sar in c ...
      data = rs_data >> rt_data;
      mem_write(rd, data, REGFILE_ID);
      p->pc++;
      break;
    case OP_CODE_SHR:
      data = rs_data >> rt_data;
      mem_write(rd, data, REGFILE_ID);
      p->pc++;
      break;
    case OP_CODE_SHL:
      data = rs_data << rt_data;
      mem_write(rd, data, REGFILE_ID);
      p->pc++;
      break;
    case OP_CODE_XOR:
      data = rs_data ^ rt_data;
      mem_write(rd, data, REGFILE_ID);
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
      data = rs_data + imm;
      mem_write(rt, data, REGFILE_ID);
      p->pc++;
      break;
    case OP_CODE_SUBI:
      data = rs_data - imm;
      mem_write(rd, data, REGFILE_ID);
      p->pc++;
      break;
    case OP_CODE_NOTI:
      printf("not implemented yet: noti\n");
      break;
    case OP_CODE_ANDI:
      data = rs_data & imm;
      mem_write(rt, data, REGFILE_ID);
      p->pc++;
      break;
    case OP_CODE_ORI:
      data = rs_data | imm;
      mem_write(rt, data, REGFILE_ID);
      p->pc++;
      break;
    case OP_CODE_NANDI:
      data = ~(rs_data & imm);
      mem_write(rt, data, REGFILE_ID);
      p->pc++;
      break;
    case OP_CODE_NORI:
      data = ~(rs_data | imm);
      mem_write(rt, data, REGFILE_ID);
      p->pc++;
      break;
    case OP_CODE_MOVI:
      data = imm;
      mem_write(rt, data, REGFILE_ID);
      p->pc++;
      break;
    case OP_CODE_SARI:
      // there is no sar in c ...
      data = rs_data >> imm;
      mem_write(rt, data, REGFILE_ID);
      p->pc++;
      break;
    case OP_CODE_SHRI:
      data = rs_data >> imm;
      mem_write(rt, data, REGFILE_ID);
      p->pc++;
      break;
    case OP_CODE_SHLI:
      rt_data = rs_data << imm;
      mem_write(rt, data, REGFILE_ID);
      p->pc++;
      break;
    case OP_CODE_XORI:
      data = rs_data ^ imm;
      mem_write(rt, data, REGFILE_ID);
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
      data = mem_read(address, DMEM_ID);
      mem_write(rt, data, REGFILE_ID);
      p->pc++;
      break;
    case OP_CODE_SW:
      address = rs_data + imm;
      data = rt_data;
      mem_write(address, data, DMEM_ID);
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
      if (p->zero) p->pc = imm;
      break;
    case OP_CODE_JNE:
      if (!p->zero) p->pc = imm;
      break;
    case OP_CODE_JL:
      if (p->less) p->pc = imm;
      break;
    case OP_CODE_JLE:
      if (p->less || p->zero) p->pc = imm;
      break;
    case OP_CODE_JG:
      if (p->greater) p->pc = imm;
      break;
    case OP_CODE_JGE:
      if (p->greater || p->zero) p->pc = imm;
      break;
    case OP_CODE_JZ:
      if (p->zero) p->pc = imm;
      break;
    case OP_CODE_JNZ:
      if (!p->zero) p->pc = imm;
      break;
    case OP_CODE_JR:
      p->pc = rs_data;
      break;

    case OP_CODE_NOP:
      break;

    default:
      printf("invalid instruction!\n");
  }
}

void execute_program(char* test_name, uint32_t run_time, char* program_dir, char* out_dir)
{
  memory_clear();
  load_program(program_dir, test_name);
  int i;

  for(i=0; i<run_time; i++) // dont know whether to do this or use while(<256)
  {
    INSTRUCTION i = mem_read(p.pc, IMEM_ID);
    execute_instruction(i, &p);
  }

  dump_memory(out_dir, test_name);
}


