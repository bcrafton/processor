open Printf
open Types
open Pretty

(* ASSEMBLER *)

let rec to_bin (il : instruction list) : string =
  let (mips, labels) = (to_mips il) in
  let binary = (assemble_bin_program mips labels) in
  binary

and to_asm (il : instruction list) : string =
  let (mips, labels) = (to_mips il) in
  let asm = (assemble_asm_program mips labels 0) in
  asm

and to_mips (il : instruction list) : (mips_instruction list * (string * int) list) = 
  
  let rec help (i : instruction) (n : int) : (mips_instruction list, (string * int)) either = 
    match i with
    | IMov(dst, src) ->
      let (dst_prelude, mips_arg_dst, dst_postlude) = (to_mips_dst dst) in
      let (src_prelude, mips_arg_src) = (to_mips_src src) in
      let mov = begin
      match (mips_arg_dst, mips_arg_src) with 
      | (MReg(dst'), MImm(src')) -> dst_prelude @ src_prelude @ [MMOVI(dst', src')] @ dst_postlude
      | (MReg(dst'), MReg(src')) -> dst_prelude @ src_prelude @ [MMOV(dst', src')] @ dst_postlude
      | _ -> failwith "impossible: cannot have a constant in the destination operand"
      end in 
      Left(mov)

    | IAdd(dst, src) ->
      let (dst_prelude, mips_arg_dst, dst_postlude) = (to_mips_dst dst) in
      let (src_prelude, mips_arg_src) = (to_mips_src src) in
      let add = begin
      match (mips_arg_dst, mips_arg_src) with 
      | (MReg(dst'), MImm(src')) -> dst_prelude @ src_prelude @ [MADDI(dst', src')] @ dst_postlude
      | (MReg(dst'), MReg(src')) -> dst_prelude @ src_prelude @ [MADD(dst', src')] @ dst_postlude
      | _ -> failwith "impossible: cannot have a constant in the destination operand"
      end in
      Left(add)

    | ISub(dst, src) ->
      let (dst_prelude, mips_arg_dst, dst_postlude) = (to_mips_dst dst) in
      let (src_prelude, mips_arg_src) = (to_mips_src src) in
      let sub = begin
      match (mips_arg_dst, mips_arg_src) with 
      | (MReg(dst'), MImm(src')) -> dst_prelude @ src_prelude @ [MSUBI(dst', src')] @ dst_postlude
      | (MReg(dst'), MReg(src')) -> dst_prelude @ src_prelude @ [MSUB(dst', src')] @ dst_postlude
      | _ -> failwith "impossible: cannot have a constant in the destination operand"
      end in
      Left(sub)

    | ICmp(dst, src) ->
      let (dst_prelude, mips_arg_dst, dst_postlude) = (to_mips_dst dst) in
      let (src_prelude, mips_arg_src) = (to_mips_src src) in
      let cmp = begin
      match (mips_arg_dst, mips_arg_src) with 
      | (MReg(dst'), MImm(src')) -> dst_prelude @ src_prelude @ [MCMPI(dst', src')] @ dst_postlude
      | (MReg(dst'), MReg(src')) -> dst_prelude @ src_prelude @ [MCMP(dst', src')] @ dst_postlude
      | _ -> failwith "impossible: cannot have a constant in the destination operand"
      end in 
      Left(cmp)

    | IAnd(dst, src) ->
      let (dst_prelude, mips_arg_dst, dst_postlude) = (to_mips_dst dst) in
      let (src_prelude, mips_arg_src) = (to_mips_src src) in
      let mand = begin
      match (mips_arg_dst, mips_arg_src) with 
      | (MReg(dst'), MImm(src')) -> dst_prelude @ src_prelude @ [MANDI(dst', src')] @ dst_postlude
      | (MReg(dst'), MReg(src')) -> dst_prelude @ src_prelude @ [MAND(dst', src')] @ dst_postlude
      | _ -> failwith "impossible: cannot have a constant in the destination operand"
      end in
      Left(mand)

    | IOr(dst, src) ->
      let (dst_prelude, mips_arg_dst, dst_postlude) = (to_mips_dst dst) in
      let (src_prelude, mips_arg_src) = (to_mips_src src) in
      let mor = begin
      match (mips_arg_dst, mips_arg_src) with 
      | (MReg(dst'), MImm(src')) -> dst_prelude @ src_prelude @ [MORI(dst', src')] @ dst_postlude
      | (MReg(dst'), MReg(src')) -> dst_prelude @ src_prelude @ [MOR(dst', src')] @ dst_postlude
      | _ -> failwith "impossible: cannot have a constant in the destination operand"
      end in 
      Left(mor)

    | IXor(dst, src) ->
      let (dst_prelude, mips_arg_dst, dst_postlude) = (to_mips_dst dst) in
      let (src_prelude, mips_arg_src) = (to_mips_src src) in
      let mxor = begin
      match (mips_arg_dst, mips_arg_src) with 
      | (MReg(dst'), MImm(src')) -> dst_prelude @ src_prelude @ [MXORI(dst', src')] @ dst_postlude
      | (MReg(dst'), MReg(src')) -> dst_prelude @ src_prelude @ [MXOR(dst', src')] @ dst_postlude
      | _ -> failwith "impossible: cannot have a constant in the destination operand"
      end in 
      Left(mxor)

    | IShl(dst, src) ->
      let (dst_prelude, mips_arg_dst, dst_postlude) = (to_mips_dst dst) in
      let (src_prelude, mips_arg_src) = (to_mips_src src) in
      let mshl = begin
      match (mips_arg_dst, mips_arg_src) with 
      | (MReg(dst'), MImm(src')) -> dst_prelude @ src_prelude @ [MSHLI(dst', src')] @ dst_postlude
      | (MReg(dst'), MReg(src')) -> dst_prelude @ src_prelude @ [MSHL(dst', src')] @ dst_postlude
      | _ -> failwith "impossible: cannot have a constant in the destination operand"
      end in
      Left(mshl)

    | IShr(dst, src) ->
      let (dst_prelude, mips_arg_dst, dst_postlude) = (to_mips_dst dst) in
      let (src_prelude, mips_arg_src) = (to_mips_src src) in
      let mshr = begin
      match (mips_arg_dst, mips_arg_src) with 
      | (MReg(dst'), MImm(src')) -> dst_prelude @ src_prelude @ [MSHRI(dst', src')] @ dst_postlude
      | (MReg(dst'), MReg(src')) -> dst_prelude @ src_prelude @ [MSHR(dst', src')] @ dst_postlude
      | _ -> failwith "impossible: cannot have a constant in the destination operand"
      end in
      Left(mshr)

    | ISar(dst, src) ->
      let (dst_prelude, mips_arg_dst, dst_postlude) = (to_mips_dst dst) in
      let (src_prelude, mips_arg_src) = (to_mips_src src) in
      let msar = begin
      match (mips_arg_dst, mips_arg_src) with 
      | (MReg(dst'), MImm(src')) -> dst_prelude @ src_prelude @ [MSARI(dst', src')] @ dst_postlude
      | (MReg(dst'), MReg(src')) -> dst_prelude @ src_prelude @ [MSAR(dst', src')] @ dst_postlude
      | _ -> failwith "impossible: cannot have a constant in the destination operand"
      end in
      Left(msar)

    | IPush(src) -> 
      let (src_prelude, mips_arg_src) = (to_mips_src src) in
      let mpush = begin
      match mips_arg_src with
      | MImm(src') -> 
        src_prelude @ 
        [
          (* this needs to be 1 not 4 for our processor *)
          MSUBI(ESP, 1);
          (* just put this in a register for now *)
          MMOVI(EBX, src');
          MSW(ESP, EBX, 0);
        ]
      | MReg(src') -> 
        src_prelude @ 
        [
          (* this needs to be 1 not 4 for our processor *)
          MSUBI(ESP, 1);
          MSW(ESP, src', 0);
        ]
      end in
      Left(mpush)
 
    | IPop(src) -> 
      let mpop = begin
      match src with
      (* pretty sure can only pop into a register *)
      | Reg(r) -> 
        [
          (* THIS NEEDS TO LOAD FIRST. *)
          MLW(ESP, r, 0);
          (* this needs to be 1 not 4 for our processor *)
          MADDI(ESP, 1);
        ]
      | _ -> failwith "impossible: can only pop a register"
      end in
      Left(mpop)

    | ITest(dst, src) ->
      let (dst_prelude, mips_arg_dst, dst_postlude) = (to_mips_dst dst) in
      let (src_prelude, mips_arg_src) = (to_mips_src src) in
      let mtest = begin
      match (mips_arg_dst, mips_arg_src) with 
      | (MReg(dst'), MImm(src')) -> dst_prelude @ src_prelude @ [MTESTI(dst', src')] @ dst_postlude
      | (MReg(dst'), MReg(src')) -> dst_prelude @ src_prelude @ [MTEST(dst', src')] @ dst_postlude
      | _ -> failwith "impossible: cannot have a constant in the destination operand"
      end in
      Left(mtest)

    | IJo(addr)  -> let j = [MJO(addr)]   in Left(j)
    | IJe(addr)  -> let j = [MJE(addr)]   in Left(j)
    | IJne(addr) -> let j = [MJNE(addr)]  in Left(j)
    | IJl(addr)  -> let j = [MJL(addr)]   in Left(j)
    | IJle(addr) -> let j = [MJLE(addr)]  in Left(j)
    | IJg(addr)  -> let j = [MJG(addr)]   in Left(j)
    | IJge(addr) -> let j = [MJGE(addr)]  in Left(j)
    | IJmp(addr) -> let j = [MJUMP(addr)] in Left(j)
    | IJz(addr)  -> let j = [MJZ(addr)]   in Left(j)
    | IJnz(addr) -> let j = [MJNZ(addr)]  in Left(j)

    | IMul(src, dst) -> failwith "multiply not implemented"
    | IInstrComment(i', _) -> (help i' n)
    | ILineComment(_) -> Left([])

    | ICall(label) -> 
      (* push current address on the stack *)
      (* jump to that address *)
      let call = [
        (* push *)
        MMOVI(EBX, (n+4)); 
        (* this is not n, this must be end of call *)
        (* which is n+4 *)
        MSUBI(ESP, 1);
        MSW(ESP, EBX, 0);
        (* jump *)
        MJUMP(label);
      ] in 
      Left(call)

    | IRet -> 
      (* pop off return value which shud now be on top *)
      let ret = [
        (* pop *)
        (* any time you change pop you need to change ret. same goes for push & call *)        
        MLW(ESP, EBX, 0);   
        MADDI(ESP, 1);     
        (* need to be able to do a jump to a register here. *)
        MJR(EBX);
      ] in
      Left(ret)

    | ILabel(label) -> 
      Right((label, n))
  in
  
  let rec itr (il : instruction list) (n : int) : (mips_instruction list * (string * int) list) = 
    match il with
    | i :: rest ->
      let e = (help i n) in
      begin
      match e with
      | Left(mi) ->
        let num_instr = (List.length mi) in
        let (mis, luts) = (itr rest (n+num_instr)) in
        (mi @ mis, luts)
      | Right(lut) ->
        let num_instr = 0 in
        let (mis, luts) = (itr rest (n+num_instr)) in
        (mis, lut :: luts)
      end
    | [] -> ([], [])
  in
  (itr il 0) 

and to_mips_dst (a : arg) : (mips_instruction list * mips_arg * mips_instruction list) = 
  match a with
  | Const(c) -> failwith "cannot have a constant in the destination operand"
  | HexConst(h) -> failwith "cannot have a constant in the destination operand"
  | Reg(r) -> 
    let prelude = [] in
    let postlude = [] in
    (prelude, MReg(r), postlude)
  | RegOffset(i, r) ->

    let prelude = 
      if i < 0 then
      [
        MMOV(EDX, r);
        MSUBI(EDX, (-1*i));
        MLW(EDX, EBX, 0);
      ]
      else 
      [
        MLW(r, EBX, i);
      ]
    in

    let postlude = 
      if i < 0 then
      [
        MMOV(EDX, r);
        MSUBI(EDX, (-1*i));
        MSW(EDX, EBX, 0);
      ]
      else 
      [
        MSW(r, EBX, i);
      ]
    in

    (prelude, MReg(EBX), postlude)
  | Sized(s, a') -> (to_mips_dst a') (* dont care about size in our processor *)

and to_mips_src (a : arg) : (mips_instruction list * mips_arg) =
  match a with
  | Const(c) -> 
    let prelude = [] in
    (prelude, MImm(c))
  | HexConst(h) ->
    let prelude = [] in
    (prelude, MImm(h))
  | Reg(r) -> 
    let prelude = [] in
    (prelude, MReg(r))
  | RegOffset(i, r) ->
(*
    (printf "reg offset: %d\n" (-1*i));
*)
    let prelude = 
      if i < 0 then
      [
        MMOV(EDX, r);
        MSUBI(EDX, (-1*i));
        MLW(EDX, ECX, 0);
      ]
      else 
      [
        MLW(r, ECX, i);
      ]
      in
      (prelude, MReg(ECX))

  | Sized(s, a') -> (to_mips_src a') (* dont care about size in our processor *)


and assemble_bin_program (il : mips_instruction list) (labels : (string * int) list) : string = 
  match il with
  | i :: rest ->
    sprintf "%s\n%s" (assemble_bin_instruction i labels) (assemble_bin_program rest labels)
  | [] -> ""

and assemble_bin_instruction (i : mips_instruction) (labels : (string * int) list) : string = 
  match i with
  |	MADD(dst, src) -> (assemble_r opcode_add dst src)
  |	MSUB(dst, src) -> (assemble_r opcode_sub dst src)
  |	MNOT(dst) -> "00000000"
  |	MAND(dst, src) -> (assemble_r opcode_and dst src)
  |	MOR(dst, src) -> (assemble_r opcode_or dst src)
  |	MNAND(dst, src) -> (assemble_r opcode_nand dst src)
  |	MNOR(dst, src) -> (assemble_r opcode_nor dst src)
    (* we cud flip flop src and dst here because we dont want to add an li instruction *)
  |	MMOV(dst, src) -> (assemble_r opcode_mov dst src)
  |	MSAR(dst, src) -> (assemble_r opcode_sar dst src)
  |	MSHR(dst, src) -> (assemble_r opcode_shr dst src)
  |	MSHL(dst, src) -> (assemble_r opcode_shl dst src)
  |	MXOR(dst, src) -> (assemble_r opcode_xor dst src)
  |	MTEST(dst, src) -> (assemble_r opcode_test dst src)
  |	MCMP(dst, src) -> (assemble_r opcode_cmp dst src)

  |	MADDI(dst, src) -> (assemble_i opcode_addi dst src)
  |	MSUBI(dst, src) -> (assemble_i opcode_subi dst src)
  |	MNOTI(dst) -> "00000000"
  |	MANDI(dst, src) -> (assemble_i opcode_andi dst src)
  |	MORI(dst, src) -> (assemble_i opcode_ori dst src)
  |	MNANDI(dst, src) -> (assemble_i opcode_nandi dst src)
  |	MNORI(dst, src) -> (assemble_i opcode_nori dst src)
  |	MMOVI(dst, src) -> (assemble_i opcode_movi dst src)
  |	MSARI(dst, src) -> (assemble_i opcode_sari dst src)
  |	MSHRI(dst, src) -> (assemble_i opcode_shri dst src)
  |	MSHLI(dst, src) -> (assemble_i opcode_shli dst src)
  |	MXORI(dst, src) -> (assemble_i opcode_xori dst src)
  |	MTESTI(dst, src) -> (assemble_i opcode_testi dst src)
  |	MCMPI(dst, src) -> (assemble_i opcode_cmpi dst src)

  (* data1 = address *)
  (* data2 = write data *)
  (* data2 = destination *)
  |	MLW(addr, dest, offset) -> (assemble_lw addr dest offset)
  |	MLA(addr, dest)         -> (assemble_i opcode_la addr dest)
  |	MSW(addr, data, offset) -> (assemble_sw addr data offset)
  |	MSA(addr, data)         -> (assemble_i opcode_sa addr data)

  | MJUMP(label) -> (assemble_jmp opcode_jmp labels label)
  | MJO(label) -> (assemble_jmp opcode_jo labels label)
  | MJE(label) -> (assemble_jmp opcode_je labels label)
  | MJNE(label) -> (assemble_jmp opcode_jne labels label)
  | MJL(label) -> (assemble_jmp opcode_jl labels label)
  | MJLE(label) -> (assemble_jmp opcode_jle labels label)
  | MJG(label) -> (assemble_jmp opcode_jg labels label)
  | MJGE(label) -> (assemble_jmp opcode_jge labels label)
  | MJZ(label) -> (assemble_jmp opcode_jz labels label)
  | MJNZ(label) -> (assemble_jmp opcode_jnz labels label)

  | MJR(addr) -> (assemble_jr addr)

(* rd is register we write to *)
and assemble_r (opcode : int) (rd : reg) (rs : reg) : string =
  let opcode' = assemble_opcode opcode in
  let rd_addr = (assemble_register rd) in
  let rs_addr = (assemble_register rs) in
  let b = 0 in
  let b = b lor (opcode' lsl opcode_lsb) in 
  let b = b lor (rd_addr lsl reg_rs_lsb) in
  let b = b lor (rs_addr lsl reg_rt_lsb) in
  let b = b lor (rd_addr lsl reg_rd_lsb) in
  sprintf "%08lx" (Int32.of_int b)

(* rt is register we write to *)
and assemble_i (opcode : int) (rd : reg) (imm : int) : string =
  let opcode' = assemble_opcode opcode in
  let rd_addr = (assemble_register rd) in
  let imm' = assemble_imm imm in
  let b = 0 in
  let b = b lor (opcode' lsl opcode_lsb) in 
  let b = b lor (rd_addr lsl reg_rs_lsb) in
  let b = b lor (rd_addr lsl reg_rt_lsb) in
  let b = b lor (imm'    lsl imm_lsb)    in
  sprintf "%08lx" (Int32.of_int b)

and assemble_lw (addr : reg) (dest : reg) (offset : int) : string = 
  let opcode' = assemble_opcode opcode_lw in
  let addr' = (assemble_register addr) in
  let dest' = (assemble_register dest) in
  let offset' = assemble_imm offset in
  let b = 0 in
  let b = b lor (opcode' lsl opcode_lsb) in 
  let b = b lor (addr'   lsl reg_rs_lsb) in
  let b = b lor (dest'   lsl reg_rt_lsb) in
  let b = b lor (offset' lsl imm_lsb)    in
  sprintf "%08lx" (Int32.of_int b)

and assemble_sw (addr : reg) (write_data : reg) (offset : int) : string = 
  let opcode' = assemble_opcode opcode_sw in
  let addr' = (assemble_register addr) in
  let write_data' = (assemble_register write_data) in
  let offset' = assemble_imm offset in
  let b = 0 in
  let b = b lor (opcode'     lsl opcode_lsb) in 
  let b = b lor (addr'       lsl reg_rs_lsb) in
  let b = b lor (write_data' lsl reg_rt_lsb) in
  let b = b lor (offset'     lsl imm_lsb)    in
  sprintf "%08lx" (Int32.of_int b)

and assemble_jmp (opcode : int) (labels : (string * int) list) (label : string) : string = 
  let opcode' = assemble_opcode opcode in
  let addr = (search_label labels label) in 
  let addr' = assemble_imm addr in
  let b = 0 in
  let b = b lor (opcode'  lsl opcode_lsb) in 
  let b = b lor (addr' lsl imm_lsb) in
  sprintf "%08lx" (Int32.of_int b)

and assemble_jr (addr : reg) : string = 
  let addr' = (assemble_register addr) in
  let b = 0 in
  let b = b lor (opcode_jr lsl opcode_lsb) in
  let b = b lor (addr'     lsl reg_rs_lsb) in
  sprintf "%08lx" (Int32.of_int b)

and assemble_opcode (opcode : int) : int = 
  if (opcode > max_opcode_value || opcode < 0) then failwith "opcode value out of bounds"
  else opcode

and assemble_imm (imm : int) : int =
  if (imm > max_imm_value || imm < 0) then (imm lsr 16)
  else imm

and assemble_register (r : reg) : int = 
  match r with
  | EAX -> 0
(* these belong to assembler *)
  | EBX -> 1
  | ECX -> 2
  | EDX -> 3
(* can use these *)
  | EEX -> 4
  | EFX -> 5
  | EGX -> 6
  | EHX -> 7
(* program registers *)
  | ESP -> 8
  | EBP -> 9
  | ESI -> 10

and search_label (labels : (string * int) list) (label : string) : int =
  match labels with
  | [] -> failwith (sprintf "Label %s not found" label)
  | (label',addr)::rest ->
     if label' = label then addr else (search_label rest label)

and assemble_asm_program (il : mips_instruction list) (labels : (string * int) list) (inst_num : int) : string = 

  match il with
  | i :: rest ->
    let labels' = (get_labels labels inst_num) in
    let bin = (assemble_bin_instruction i labels) in
    let asm = (assemble_instruction_asm i labels) in
    let ret = (sprintf "%s %s | %s\n%s" labels' bin asm (assemble_asm_program rest labels (inst_num+1))) in
    ret
  | [] -> ""

and get_labels (labels : (string * int) list) (inst_num : int) : string = 
  match labels with
  | [] -> ""
  | (label',addr)::rest ->
     if addr = inst_num then label' ^ "\n" ^ (get_labels rest inst_num) else (get_labels rest inst_num)

and assemble_instruction_asm (i : mips_instruction) (labels : (string * int) list) : string = 

  match i with
  |	MADD(dst, src) -> (sprintf "add %s, %s" (assemble_register_asm dst) (assemble_register_asm src))
  |	MSUB(dst, src) -> (sprintf "sub %s, %s" (assemble_register_asm dst) (assemble_register_asm src))
  |	MNOT(dst) -> failwith "not implemented"
  |	MAND(dst, src) -> (sprintf "and %s, %s" (assemble_register_asm dst) (assemble_register_asm src))
  |	MOR(dst, src) -> (sprintf "or %s, %s" (assemble_register_asm dst) (assemble_register_asm src))
  |	MNAND(dst, src) -> (sprintf "nand %s, %s" (assemble_register_asm dst) (assemble_register_asm src))
  |	MNOR(dst, src) -> (sprintf "nor %s, %s" (assemble_register_asm dst) (assemble_register_asm src))
  |	MMOV(dst, src) -> (sprintf "mov %s, %s" (assemble_register_asm dst) (assemble_register_asm src))
  |	MSAR(dst, src) -> (sprintf "sar %s, %s" (assemble_register_asm dst) (assemble_register_asm src))
  |	MSHR(dst, src) -> (sprintf "shr %s, %s" (assemble_register_asm dst) (assemble_register_asm src))
  |	MSHL(dst, src) -> (sprintf "shl %s, %s" (assemble_register_asm dst) (assemble_register_asm src))
  |	MXOR(dst, src) -> (sprintf "xor %s, %s" (assemble_register_asm dst) (assemble_register_asm src))
  |	MTEST(dst, src) -> (sprintf "test %s, %s" (assemble_register_asm dst) (assemble_register_asm src))
  |	MCMP(dst, src) -> (sprintf "cmp %s, %s" (assemble_register_asm dst) (assemble_register_asm src))

  |	MADDI(dst, src) -> (sprintf "addi %s, %x" (assemble_register_asm dst) src)
  |	MSUBI(dst, src) -> (sprintf "subi %s, %x" (assemble_register_asm dst) src)
  |	MNOTI(dst) -> failwith "not implemented"
  |	MANDI(dst, src) -> (sprintf "andi %s, %x" (assemble_register_asm dst) src)
  |	MORI(dst, src) -> (sprintf "ori %s, %x" (assemble_register_asm dst) src)
  |	MNANDI(dst, src) -> (sprintf "nandi %s, %x" (assemble_register_asm dst) src)
  |	MNORI(dst, src) -> (sprintf "nori %s, %x" (assemble_register_asm dst) src)
  |	MMOVI(dst, src) -> (sprintf "movi %s, %x" (assemble_register_asm dst) src)
  |	MSARI(dst, src) -> (sprintf "sari %s, %x" (assemble_register_asm dst) src)
  |	MSHRI(dst, src) -> (sprintf "shri %s, %x" (assemble_register_asm dst) src)
  |	MSHLI(dst, src) -> (sprintf "shli %s, %x" (assemble_register_asm dst) src)
  |	MXORI(dst, src) -> (sprintf "xori %s, %x" (assemble_register_asm dst) src)
  |	MTESTI(dst, src) -> (sprintf "testi %s, %x" (assemble_register_asm dst) src)
  |	MCMPI(dst, src) -> (sprintf "cmpi %s, %x" (assemble_register_asm dst) src)

  (* data1 = address *)
  (* data2 = write data *)
  (* data2 = destination *)
  |	MLW(addr, dest, offset) -> (sprintf "lw %s, %s, %x" (assemble_register_asm addr) (assemble_register_asm dest) offset)
  |	MLA(addr, dest)         -> (sprintf "la %s, %x" (assemble_register_asm addr) dest)
  |	MSW(addr, data, offset) -> (sprintf "sw %s, %s, %x" (assemble_register_asm addr) (assemble_register_asm data) offset)
  |	MSA(addr, data)         -> (sprintf "sa %s, %x" (assemble_register_asm addr) data)

  | MJUMP(label) -> (sprintf "jmp %s" label)
  | MJO(label) -> (sprintf "jo %s" label)
  | MJE(label) -> (sprintf "je %s" label)
  | MJNE(label) -> (sprintf "jne %s" label)
  | MJL(label) -> (sprintf "jl %s" label)
  | MJLE(label) -> (sprintf "jle %s" label)
  | MJG(label) -> (sprintf "jg %s" label)
  | MJGE(label) -> (sprintf "jge %s" label)
  | MJZ(label) -> (sprintf "jz %s" label)
  | MJNZ(label) -> (sprintf "jnz %s" label)

  | MJR(addr) -> (sprintf "jr %s" (assemble_register_asm addr))

and assemble_register_asm (r : reg) : string = 
  match r with
  | EAX -> "eax"
(* these belong to assembler *)
  | EBX -> "ebx"
  | ECX -> "ecx"
  | EDX -> "edx"
(* can use these *)
  | EEX -> "eex"
  | EFX -> "efx"
  | EGX -> "egx"
  | EHX -> "ehx"
(* program registers *)
  | ESP -> "esp"
  | EBP -> "ebp"
  | ESI -> "esi"










