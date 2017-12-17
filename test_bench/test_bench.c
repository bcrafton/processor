
#include "test_bench.h"

static test_t tests[] = {

{"to_10", CODE_TEST, 20, 100000},
};

static int num_programs = sizeof(tests)/sizeof(test_t);

void get_program_filepath(test_t* test, char filepath[])
{
  switch(test->test_type)
  {
    case CODE_TEST:
      sprintf(filepath, "../test_bench/programs/code/bin/%s.bc.s.hex", test->name);
      break;
    case ASM_TEST:
      sprintf(filepath, "../test_bench/programs/asm/bin/%s.s.hex", test->name);
      break;
    case BINARY_TEST:
      sprintf(filepath, "../test_bench/programs/bin/%s.hex", test->name);
      break;
    default:
      fprintf(stderr, "invalid test type: %d", test->test_type);
      assert(0);
  }
}

void get_out_filepath(test_t* test, char* run_type, char filepath[])
{
  switch(test->test_type)
  {
    case CODE_TEST:
      sprintf(filepath, "../test_bench/out/%s/%s.bc.s.hex", run_type, test->name);
      break;
    case ASM_TEST:
      sprintf(filepath, "../test_bench/out/%s/%s.s.hex", run_type, test->name);
      break;
    case BINARY_TEST:
      sprintf(filepath, "../test_bench/out/%s/%s.hex", run_type, test->name);
      break;
    default:
      fprintf(stderr, "invalid test type: %d", test->test_type);
      assert(0);
  }
}

void execute_sim(char* in_path, char* out_path, uint32_t run_time)
{
  const char* sim_cmd = "vvp -M. -m ../processor/sim_vpi ../processor/sim_vpi.vvp +run_time=%d +in_path=%s +out_path=%s";
  char cmd[200];
  sprintf(cmd, sim_cmd, run_time, in_path, out_path);
  int ret = system(cmd);
}

void execute_emu(char* in_path, char* out_path, uint32_t run_time)
{
  const char* emu_cmd = "../emulator/emulator %s %s %d";
  char cmd[200];
  sprintf(cmd, emu_cmd, in_path, out_path, run_time);
  int ret = system(cmd);
}

int main()
{
  int i;
  char test_name[200];
  char program_dir[200];
  char command[200];
  for(i=0; i<num_programs; i++)
  {
    switch(tests[i].test_type)
    {
      case CODE_TEST:
        sprintf(test_name, "%s.bc.s.hex", tests[i].name);
        sprintf(program_dir, "%s", "../test_bench/programs/code/bin/");
        break;
      case ASM_TEST:
        sprintf(test_name, "%s.s.hex", tests[i].name);
        sprintf(program_dir, "%s", "../test_bench/programs/asm/bin/");
        break;
      case BINARY_TEST:
        sprintf(test_name, "%s.hex", tests[i].name);
        sprintf(program_dir, "%s", "../test_bench/programs/bin/");
        break;
      default:
        fprintf(stderr, "invalid test type: %d", tests[i].test_type);
        assert(0);
    }
    
    char emu_outpath[200];
    char sim_outpath[200];
    char inpath[200];
    get_out_filepath(&tests[i], "emu", emu_outpath);
    get_out_filepath(&tests[i], "sim", sim_outpath);
    get_program_filepath(&tests[i], inpath);
    struct stat st = {0};

    if (stat(emu_outpath, &st) == -1) {
        mkdir(emu_outpath, 0700);
    }

    if (stat(sim_outpath, &st) == -1) {
        mkdir(sim_outpath, 0700);
    }

    execute_emu(inpath, emu_outpath, tests[i].sim_time/10);
    execute_sim(inpath, sim_outpath, tests[i].sim_time);
  }

  bool result;
  for(i=0; i<num_programs; i++)
  {
    switch(tests[i].test_type)
    {
      case CODE_TEST:
        result = check_code(&tests[i]);
        if (result) printf("Test: %s Passed.\n", tests[i].name);
        else printf("Test: %s Failed.\n", tests[i].name);
        break;
      case ASM_TEST:
        result = check_asm(&tests[i]);
        if (result) printf("Test: %s Passed.\n", tests[i].name);
        else printf("Test: %s Failed.\n", tests[i].name);
        break;
      case BINARY_TEST:
        result = check_binary(&tests[i]);
        if (result) printf("Test: %s Passed.\n", tests[i].name);
        else printf("Test: %s Failed.\n", tests[i].name);
        break;
      default:
        fprintf(stderr, "invalid test type: %d", tests[i].test_type);
        assert(0);
    }
  }
}

void load_memory(char* dir, char* filename, char* ext, WORD memory[], uint32_t size)
{
  char filepath[100];
  sprintf(filepath, "%s%s%s", dir, filename, ext);

  FILE *file;
  file = fopen(filepath, "r");
  if(file == NULL)
  {
    fprintf(stderr, "could not find %s\n", filepath);
    assert(0);
  }

  int i;
  for(i=0; i<size; i++)
  {
    if(!fscanf(file, "%x", &memory[i]))
    {
      fprintf(stderr, "file does not contain enough words");
      assert(0);
    }
  }
  fclose(file);
}

GQueue* load_instruction_log(char* dir, char* filename)
{
  GQueue* q = g_queue_new();

  char filepath[100];
  sprintf(filepath, "%s%s", dir, filename);

  FILE *file;
  file = fopen(filepath, "r");
  if(file == NULL)
  {
    fprintf(stderr, "could not find %s\n", filepath);
    assert(0);
  }

  unsigned long timestamp;
  unsigned long id;
  uint32_t pc;
  uint32_t instruction;
  uint32_t alu_in0;
  uint32_t alu_in1;

  uint32_t branch_taken;
  uint32_t branch_taken_address;
  uint32_t branch_imm_address;
  uint32_t branch_reg_address;

  while( fscanf(file, "@%lu 0x%lx %d 0x%x 0x%x 0x%x %d %x %x %x\n", &timestamp, &id, &pc, &instruction, &alu_in0, &alu_in1, &branch_taken, &branch_taken_address, &branch_imm_address, &branch_reg_address) != EOF )
  {
    instruction_log_t* log = new_instruction_log();
  
    log->timestamp = timestamp;
    log->id = id;
    log->pc = pc;
    log->instruction = instruction;
    log->alu_in0 = alu_in0;
    log->alu_in1 = alu_in1;
    log->branch_taken = branch_taken;
    log->branch_taken_address = branch_taken_address;
    log->branch_imm_address = branch_imm_address;
    log->branch_reg_address = branch_reg_address;

    g_queue_push_tail(q, log);
  }
  
  return q;
}

bool diff_instruction_log(instruction_log_t* log1, instruction_log_t* log2)
{

  bool pass = (log1->instruction == log2->instruction);
  pass = pass && (log1->pc == log2->pc);

  uint8_t opcode = opcode_of(log1->instruction);

  switch (opcode) {
    // 6'b00xxxx
    case OP_CODE_ADD:
    case OP_CODE_SUB:
    case OP_CODE_NOT:
    case OP_CODE_AND:
    case OP_CODE_OR:
    case OP_CODE_NAND:
    case OP_CODE_NOR:
    case OP_CODE_MOV:
    case OP_CODE_SAR:
    case OP_CODE_SHR:
    case OP_CODE_SHL:
    case OP_CODE_XOR:
    case OP_CODE_TEST:
    case OP_CODE_CMP:
      pass = pass && (log1->alu_in0 == log2->alu_in0);
      pass = pass && (log1->alu_in1 == log2->alu_in1);
      break;

    // 6'b01xxxx
    case OP_CODE_ADDI:
    case OP_CODE_SUBI:
    case OP_CODE_NOTI:
    case OP_CODE_ANDI:
    case OP_CODE_ORI:
    case OP_CODE_NANDI:
    case OP_CODE_NORI:
    case OP_CODE_MOVI:
    case OP_CODE_SARI:
    case OP_CODE_SHRI:
    case OP_CODE_SHLI:
    case OP_CODE_XORI:
    case OP_CODE_TESTI:
    case OP_CODE_CMPI:
      pass = pass && (log1->alu_in0 == log2->alu_in0);
      pass = pass && (log1->alu_in1 == log2->alu_in1);
      break;

    // 6'b10xxxx
    case OP_CODE_LW:
      pass = pass && (log1->alu_in0 == log2->alu_in0);
      pass = pass && (log1->alu_in1 == log2->alu_in1);
      pass = pass && (log1->mem_read_data == log2->mem_read_data);
      break;
    case OP_CODE_SW:
      pass = pass && (log1->alu_in0 == log2->alu_in0);
      pass = pass && (log1->alu_in1 == log2->alu_in1);
      pass = pass && (log1->mem_write_data == log2->mem_write_data);
      break;
    case OP_CODE_LA:
      break;
    case OP_CODE_SA:
      break;

    // 6'b11xxxx
    case OP_CODE_JMP:
    case OP_CODE_JO:
    case OP_CODE_JE:
    case OP_CODE_JNE:
    case OP_CODE_JL:
    case OP_CODE_JLE:
    case OP_CODE_JG:
    case OP_CODE_JGE:
    case OP_CODE_JZ:
    case OP_CODE_JNZ:
    case OP_CODE_JR:
    case OP_CODE_NOP:
      break;

    default:
      printf("invalid instruction!\n");
  }
  return pass;
}

bool diff_instruction_logs(GQueue* q1, GQueue* q2)
{
  int length1 = g_queue_get_length(q1);
  int length2 = g_queue_get_length(q2);
  if (length1 != length2)
  {
    return false;
  }
  
  int i;
  for(i=0; i<length1; i++)
  {
    instruction_log_t* log1 = g_queue_pop_head(q1);
    instruction_log_t* log2 = g_queue_pop_head(q2);

    bool pass = diff_instruction_log(log1, log2);
    if(!pass)
    {
      return false;
    }
  }
  return true;
}

bool diff_memory(WORD* mem1, WORD* mem2, uint32_t mem_size)
{
  int i;
  for(i=0; i<mem_size; i++)
  {
    if(mem1[i] != mem2[i])
    {
      return false;
    }
  }
  return true;
}

bool check_code(test_t* test)
{
  REGISTER reg_sim[REGFILE_SIZE];
  WORD mem_sim[DMEMORY_SIZE];

  REGISTER reg_emu[REGFILE_SIZE];
  WORD mem_emu[DMEMORY_SIZE];

  char sim_out_path[200];
  char emu_out_path[200];

  get_out_filepath(test, "sim", sim_out_path);
  get_out_filepath(test, "emu", emu_out_path);
  
  load_memory(sim_out_path, "/reg", "", reg_sim, REGFILE_SIZE);
  load_memory(sim_out_path, "/mem", "", mem_sim, DMEMORY_SIZE);

  load_memory(emu_out_path, "/reg", "", reg_emu, REGFILE_SIZE);
  load_memory(emu_out_path, "/mem", "", mem_emu, DMEMORY_SIZE);

  bool diff = (reg_emu[0] == test->ans);
  diff = diff && diff_memory(reg_sim, reg_emu, REGFILE_SIZE);
  diff = diff && diff_memory(mem_sim, mem_emu, DMEMORY_SIZE);

  GQueue* q1 = load_instruction_log(sim_out_path, "/logs");
  GQueue* q2 = load_instruction_log(emu_out_path, "/logs");

  diff = diff && diff_instruction_logs(q1, q2);

  return diff;
}

bool check_asm(test_t* test)
{
  REGISTER reg_sim[REGFILE_SIZE];
  WORD mem_sim[DMEMORY_SIZE];

  REGISTER reg_emu[REGFILE_SIZE];
  WORD mem_emu[DMEMORY_SIZE];

  char sim_out_path[200];
  char emu_out_path[200];

  get_out_filepath(test, "sim", sim_out_path);
  get_out_filepath(test, "emu", emu_out_path);
  
  load_memory(sim_out_path, "/reg", "", reg_sim, REGFILE_SIZE);
  load_memory(sim_out_path, "/mem", "", mem_sim, DMEMORY_SIZE);

  load_memory(emu_out_path, "/reg", "", reg_emu, REGFILE_SIZE);
  load_memory(emu_out_path, "/mem", "", mem_emu, DMEMORY_SIZE);

  bool diff = (reg_emu[0] == test->ans);
  diff = diff && diff_memory(reg_sim, reg_emu, REGFILE_SIZE);
  diff = diff && diff_memory(mem_sim, mem_emu, DMEMORY_SIZE);

  return diff;
}

bool check_binary(test_t* test)
{
  REGISTER reg_exp[REGFILE_SIZE];
  WORD mem_exp[DMEMORY_SIZE];

  REGISTER reg_sim[REGFILE_SIZE];
  WORD mem_sim[DMEMORY_SIZE];

  REGISTER reg_emu[REGFILE_SIZE];
  WORD mem_emu[DMEMORY_SIZE];

  char sim_out_path[200];
  char emu_out_path[200];

  get_out_filepath(test, "sim", sim_out_path);
  get_out_filepath(test, "emu", emu_out_path);
  
  load_memory(sim_out_path, "/reg", "", reg_sim, REGFILE_SIZE);
  load_memory(sim_out_path, "/mem", "", mem_sim, DMEMORY_SIZE);

  load_memory(emu_out_path, "/reg", "", reg_emu, REGFILE_SIZE);
  load_memory(emu_out_path, "/mem", "", mem_emu, DMEMORY_SIZE);

  load_memory("../test_bench/expected/reg/", test->name, ".reg.expected", reg_exp, REGFILE_SIZE);
  load_memory("../test_bench/expected/mem/", test->name, ".mem.expected", mem_exp, DMEMORY_SIZE);

  bool diff = diff_memory(reg_exp, reg_emu, REGFILE_SIZE);
  diff = diff && diff_memory(mem_exp, mem_emu, DMEMORY_SIZE);

  diff = diff && diff_memory(reg_sim, reg_emu, REGFILE_SIZE);
  diff = diff && diff_memory(mem_sim, mem_emu, DMEMORY_SIZE);

  return diff;
}

/*
void load_memory(char* dir, char* filename, char* ext, WORD memory[], uint32_t size)
{

  char filepath[100];
  sprintf(filepath, "%s%s%s", dir, filename, ext);

  FILE *file;
  file = fopen(filepath, "r");
  if(file == NULL)
  {
    fprintf(stderr, "could not find %s\n", filepath);
    assert(0);
  }

  int i;
  for(i=0; i<size; i++)
  {
    if(!fscanf(file, "%x", &memory[i]))
    {
      fprintf(stderr, "file does not contain enough words");
      assert(0);
    }
  }
  fclose(file);
}


bool check_code(test_t* test)
{
  REGISTER result_regfile[REGFILE_SIZE];
  
  load_memory("../test_bench/out/", test->name, ".bc.s.hex.reg", result_regfile, REGFILE_SIZE);

  if(result_regfile[0] != test->ans)
  {
    return false;
  }

  return true;
}

bool check_asm(test_t* test)
{
  REGISTER result_regfile[REGFILE_SIZE];

  load_memory("../test_bench/out/", test->name, ".s.hex.reg", result_regfile, REGFILE_SIZE);

  if(result_regfile[0] != test->ans)
  {
    return false;
  }

  return true;
}

bool check_binary(test_t* test)
{
  REGISTER result_regfile[REGFILE_SIZE];
  WORD result_memory[DMEMORY_SIZE];

  REGISTER expected_regfile[REGFILE_SIZE];
  WORD expected_memory[DMEMORY_SIZE];

  load_memory("../test_bench/out/", test->name, ".hex.reg", result_regfile, REGFILE_SIZE);
  load_memory("../test_bench/out/", test->name, ".hex.mem", result_memory, DMEMORY_SIZE);

  load_memory("../test_bench/expected/reg/", test->name, ".reg.expected", expected_regfile, REGFILE_SIZE);
  load_memory("../test_bench/expected/mem/", test->name, ".mem.expected", expected_memory, DMEMORY_SIZE);

  int i;
  for(i=0; i<REGFILE_SIZE; i++)
  {
    if(result_regfile[i] != expected_regfile[i])
    {
      return false;
    }
  }

  for(i=0; i<DMEMORY_SIZE; i++)
  {
    if(result_memory[i] != expected_memory[i])
    {
      return false;
    }
  }

  return true;
}
*/




