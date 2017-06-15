open Printf
open Types
open Pretty
open Expr

type 'a envt = (string * 'a) list

let rec is_anf (e : 'a expr) : bool =
  match e with
  | EPrim1(_, e, _) -> is_imm e
  | EPrim2(_, e1, e2, _) -> is_imm e1 && is_imm e2
  | ELet(binds, body, _) ->
     List.for_all (fun (_, e, _) -> is_anf e) binds
     && is_anf body
  | EIf(cond, thn, els, _) -> is_imm cond && is_anf thn && is_anf els
  | _ -> is_imm e
and is_imm e =
  match e with
  | ENumber _ -> true
  | EBool _ -> true
  | EId _ -> true
  | _ -> false
;;


let const_true = HexConst(0xFFFFFFFF)
let const_false = HexConst(0x7FFFFFFF)
let bool_mask = HexConst(0x80000000)
let tag_as_bool = HexConst(0x00000001)

let err_COMP_NOT_NUM   = 1
let err_ARITH_NOT_NUM  = 2
let err_LOGIC_NOT_BOOL = 3
let err_IF_NOT_BOOL    = 4
let err_OVERFLOW       = 5
let err_INDEX_NOT_NUM  = 6
let err_NOT_TUPLE      = 7
let err_INDEX_TOO_SMALL= 8
let err_INDEX_TOO_LARGE= 9

(*
so starting with just function definitions
2 same name arguments - handled in the definiton helper
multiple function defs - handled at program level

*)

let rec find_one (l : (string * 'b) list) (s : string) : bool =
  match l with
    | [] -> false
    | (str, _)::xs -> (s = str) || (find_one xs s)

let rec find_dup (l : (string * 'b) list) : 'a option =
  match l with
    | [] -> None
    | [x] -> None
    | (str, _)::xs ->
      if find_one xs str then Some(str) else find_dup xs

let rec find_decl (ds : 'a decl list) (name : string) : 'a decl option =
  match ds with
    | [] -> None
    | (DFun(fname, _, _, _) as d)::ds_rest ->
      if name = fname then Some(d) else find_decl ds_rest name

(*
let rec contains (l : (string * 'a) list) (s : string) : bool = 
  match l with
  | (first, _)::rest -> if(first=s) then true else (contains rest s)
  | [] -> false
;;

let rec double_args (l : (string * 'a) list) : bool = 
  match l with
  | (first, _)::rest -> if(contains rest first) then true else (double_args rest)
  | [] -> false
;;
*)

let rec search ls x : 'a option =
  match ls with
  | [] -> None
  | v::rest ->
     if v = x then Some(v) else search rest x

let rec contains (l : string list) (s : string) : bool = 
  match l with
  | first::rest -> if(first=s) then true else (contains rest s)
  | [] -> false

let well_formed (p : (Lexing.position * Lexing.position) program) : exn list =
  let rec wf_E e (env : sourcespan envt) (funenv : (sourcespan * int) envt) =
    match e with
    | EBool _ -> []
    | ENumber(n, loc) ->
       if n > 1073741823 || n < -1073741824 then [Overflow(n, loc)] else []
    | EId (x, loc) ->
       (try ignore (List.assoc x env); []
        with Not_found -> [UnboundId(x, loc)])
    | EPrim1(_, e, _) -> wf_E e env funenv
    | EPrim2(_, l, r, _) -> wf_E l env funenv @ wf_E r env funenv
    | EIf(c, t, f, _) -> wf_E c env funenv @ wf_E t env funenv @ wf_E f env funenv
    | ELet(binds, body, _) ->
       let rec dupe x binds =
         match binds with
         | [] -> None
         | (y, _, loc)::_ when x = y -> Some loc
         | _::rest -> dupe x rest in
       let rec process_binds rem_binds env =
         match rem_binds with
         | [] -> (env, [])
         | (x, e, loc)::rest ->
            let shadow =
              match dupe x rest with
              | Some where -> [DuplicateId(x, where, loc)]
              | None ->
                 try
                   let existing = List.assoc x env in [ShadowId(x, loc, existing)]
                 with Not_found -> [] in
            let errs_e = wf_E e env funenv in
            let new_env = (x, loc)::env in
            let (newer_env, errs) = process_binds rest new_env in
            (newer_env, (shadow @ errs_e @ errs)) in              
       let (env2, errs) = process_binds binds env in
       errs @ wf_E body env2 funenv
    | EApp(funname, args, loc) ->
       (try let (_, arity) = (List.assoc funname funenv) in
            let actual = List.length args in
            if actual != arity then [Arity(arity, actual, loc)] else []
        with Not_found ->
          [UnboundFun(funname, loc)]) @ List.concat (List.map (fun e -> wf_E e env funenv) args)
    | EGetItem(l, r, _) ->
      (wf_E l env funenv) @ (wf_E r env funenv)
    | ETuple(elts, _) ->
      let rec help (l : 'a expr list) : exn list =
        match l with
        | first::rest ->
          (wf_E first env funenv) @ (help rest)
        | [] -> []
      in (help elts)

  and wf_D d (env : sourcespan envt) (funenv : (sourcespan * int) envt) =
    match d with
    | DFun(_, args, body, _) ->
       let rec dupe x args =
         match args with
         | [] -> None
         | (y, loc)::_ when x = y -> Some loc
         | _::rest -> dupe x rest in
       let rec process_args rem_args =
         match rem_args with
         | [] -> []
         | (x, loc)::rest ->
            (match dupe x rest with
             | None -> []
             | Some where -> [DuplicateId(x, where, loc)]) @ process_args rest in
       (process_args args) @ wf_E body (args @ env) funenv
  in
  match p with
  | Program(decls, body, _) ->
     let rec find name decls =
       match decls with
       | [] -> None
       | DFun(n, args, _, loc)::rest when n = name -> Some(loc)
       | _::rest -> find name rest in
     let rec dupe_funbinds decls =
       match decls with
       | [] -> []
       | DFun(name, args, _, loc)::rest ->
          (match find name rest with
           | None -> []
           | Some where -> [DuplicateFun(name, where, loc)]) @ dupe_funbinds rest in
     let funbind d =
       match d with
       | DFun(name, args, _, loc) -> (name, (loc, List.length args)) in
     let funbinds : (string * (sourcespan * int)) list = List.map funbind decls in
     (dupe_funbinds decls)
     @ (List.concat (List.map (fun d -> wf_D d [] funbinds) decls))
     @ (wf_E body [] funbinds)
;;

let anf (p : tag program) : unit aprogram =
  let rec helpP (p : tag program) : unit aprogram =
    match p with
    | Program(decls, body, _) -> AProgram(List.map helpD decls, helpA body, ())
  and helpD (d : tag decl) : unit adecl =
    match d with
    | DFun(name, args, body, _) -> ADFun(name, List.map fst args, helpA body, ())
  and helpC (e : tag expr) : (unit cexpr * (string * unit cexpr) list) = 
    match e with
    | EPrim1(op, arg, _) ->
       let (arg_imm, arg_setup) = helpI arg in
       (CPrim1(op, arg_imm, ()), arg_setup)
    | EPrim2(op, left, right, _) ->
       let (left_imm, left_setup) = helpI left in
       let (right_imm, right_setup) = helpI right in
       (CPrim2(op, left_imm, right_imm, ()), left_setup @ right_setup)
    | EIf(cond, _then, _else, _) ->
       let (cond_imm, cond_setup) = helpI cond in
       (CIf(cond_imm, helpA _then, helpA _else, ()), cond_setup)
    | ELet([], body, _) -> helpC body
    | ELet((bind, exp, _)::rest, body, pos) ->
       let (exp_ans, exp_setup) = helpC exp in
       let (body_ans, body_setup) = helpC (ELet(rest, body, pos)) in
       (body_ans, exp_setup @ [(bind, exp_ans)] @ body_setup)
    | EApp(funname, args, _) ->
        let rec anf_args (args : tag expr list) : (unit immexpr list * (string * unit cexpr) list) =  
          match args with
          | first :: rest ->
            let (immexp, bindings) = (helpI first) in
            let (immexp_list, bindings_list) = (anf_args rest) in
            ([immexp] @ immexp_list, bindings @ bindings_list)
          | [] ->
            ([], [])
        in
        let (anfd_args, bindings) = (anf_args args) in
        (CApp(funname, anfd_args, ()), bindings)

    | ETuple(vals, _) ->
      let rec anf_vals (vals : tag expr list) : (unit immexpr list * (string * unit cexpr) list) =  
        match vals with
        | first :: rest ->
          let (immexp, bindings) = (helpI first) in
          let (immexp_list, bindings_list) = (anf_vals rest) in
          ([immexp] @ immexp_list, bindings @ bindings_list)
        | [] ->
          ([], [])
      in
      let (anfd_vals, bindings) = (anf_vals vals) in
      (CTuple(anfd_vals, ()), bindings)
    
    | EGetItem(tup, idx, _) ->
       let (tup_imm, tup_setup) = helpI tup in
       let (idx_imm, idx_setup) = helpI idx in
       (CGetItem(tup_imm, idx_imm, ()), tup_setup @ idx_setup)

    | _ -> let (imm, setup) = helpI e in (CImmExpr imm, setup)

  and helpI (e : tag expr) : (unit immexpr * (string * unit cexpr) list) =
    match e with
    | ENumber(n, _) -> (ImmNum(n, ()), [])
    | EBool(b, _) -> (ImmBool(b, ()), [])
    | EId(name, _) -> (ImmId(name, ()), [])

    | EPrim1(op, arg, tag) ->
       let tmp = sprintf "unary_%d" tag in
       let (arg_imm, arg_setup) = helpI arg in
       (ImmId(tmp, ()), arg_setup @ [(tmp, CPrim1(op, arg_imm, ()))])
    | EPrim2(op, left, right, tag) ->
       let tmp = sprintf "binop_%d" tag in
       let (left_imm, left_setup) = helpI left in
       let (right_imm, right_setup) = helpI right in
       (ImmId(tmp, ()), left_setup @ right_setup @ [(tmp, CPrim2(op, left_imm, right_imm, ()))])
    | EIf(cond, _then, _else, tag) ->
       let tmp = sprintf "if_%d" tag in
       let (cond_imm, cond_setup) = helpI cond in
       (ImmId(tmp, ()), cond_setup @ [(tmp, CIf(cond_imm, helpA _then, helpA _else, ()))])

    | EApp(funname, args, tag) ->
        let tmp = (sprintf "app_%d" tag) in
        let rec anf_args (args : tag expr list) : (unit immexpr list * (string * unit cexpr) list) =  
          match args with
          | first :: rest ->
            let (immexp, bindings) = (helpI first) in
            let (immexp_list, bindings_list) = (anf_args rest) in
            ([immexp] @ immexp_list, bindings @ bindings_list)
          | [] ->
            ([], [])
        in
        let (anfd_args, bindings) = (anf_args args) in
        (ImmId(tmp, ()), bindings @ [(tmp, CApp(funname, anfd_args, ()))])

    | ETuple(vals, tag) ->
      let tmp = (sprintf "tuple_%d" tag) in
      let rec anf_vals (vals : tag expr list) : (unit immexpr list * (string * unit cexpr) list) =  
        match vals with
        | first :: rest ->
          let (immexp, bindings) = (helpI first) in
          let (immexp_list, bindings_list) = (anf_vals rest) in
          ([immexp] @ immexp_list, bindings @ bindings_list)
        | [] ->
          ([], [])
      in
      let (anfd_vals, bindings) = (anf_vals vals) in
      (ImmId(tmp, ()), bindings @ [(tmp, CTuple(anfd_vals, ()))])

    | EGetItem(tup, idx, tag) ->
       let tmp = sprintf "get_item_%d" tag in
       let (tup_imm, tup_setup) = helpI tup in
       let (idx_imm, idx_setup) = helpI idx in
       (ImmId(tmp, ()), tup_setup @ idx_setup @ [(tmp, CGetItem(tup_imm, idx_imm, ()))])

    | ELet([], body, _) -> helpI body
    | ELet((bind, exp, _)::rest, body, pos) ->
       let (exp_ans, exp_setup) = helpC exp in
       let (body_ans, body_setup) = helpI (ELet(rest, body, pos)) in
       (body_ans, exp_setup @ [(bind, exp_ans)] @ body_setup)
  and helpA e : unit aexpr = 
    let (ans, ans_setup) = helpC e in
    List.fold_right (fun (bind, exp) body -> ALet(bind, exp, body, ())) ans_setup (ACExpr ans)
  in
  helpP p
;;

let r_to_asm (r : reg) : string =
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

let rec arg_to_asm (a : arg) : string =
  match a with
  | Const(n) -> sprintf "%d" n
  | HexConst(n) -> sprintf "0x%lx" (Int32.of_int n)
  | Reg(r) -> r_to_asm r
  | RegOffset(n, r) ->
     if n >= 0 then
       sprintf "[%s + %d]" (r_to_asm r) n
     else
       sprintf "[%s - %d]" (r_to_asm r) (-1 * n)
  | Sized(size, a) -> (arg_to_asm a)
;;

let rec i_to_asm (i : instruction) : string =
  match i with
  | IMov(dest, value) ->
     sprintf "  mov %s, %s" (arg_to_asm dest) (arg_to_asm value)
  | IAdd(dest, to_add) ->
     sprintf "  add %s, %s" (arg_to_asm dest) (arg_to_asm to_add)
  | ISub(dest, to_sub) ->
     sprintf "  sub %s, %s" (arg_to_asm dest) (arg_to_asm to_sub)
  | IMul(dest, to_mul) ->
     sprintf "  imul %s, %s" (arg_to_asm dest) (arg_to_asm to_mul)
  | ICmp(left, right) ->
     sprintf "  cmp %s, %s" (arg_to_asm left) (arg_to_asm right)
  | ILabel(name) ->
     name ^ ":"
  | IJo(label) ->
     sprintf "  jo %s" label
  | IJe(label) ->
     sprintf "  je %s" label
  | IJne(label) ->
     sprintf "  jne %s" label
  | IJl(label) ->
     sprintf "  jl %s" label
  | IJle(label) ->
     sprintf "  jle %s" label
  | IJg(label) ->
     sprintf "  jg %s" label
  | IJge(label) ->
     sprintf "  jge %s" label
  | IJmp(label) ->
     sprintf "  jmp %s" label
  | IJz(label) ->
     sprintf "  jz %s" label
  | IJnz(label) ->
     sprintf "  jnz %s" label
  | IAnd(dest, value) ->
     sprintf "  and %s, %s" (arg_to_asm dest) (arg_to_asm value)
  | IOr(dest, value) ->
     sprintf "  or %s, %s" (arg_to_asm dest) (arg_to_asm value)
  | IXor(dest, value) ->
     sprintf "  xor %s, %s" (arg_to_asm dest) (arg_to_asm value)
  | IShl(dest, value) ->
     sprintf "  shl %s, %s" (arg_to_asm dest) (arg_to_asm value)
  | IShr(dest, value) ->
     sprintf "  shr %s, %s" (arg_to_asm dest) (arg_to_asm value)
  | ISar(dest, value) ->
     sprintf "  sar %s, %s" (arg_to_asm dest) (arg_to_asm value)
  | IPush(value) ->
     sprintf "  push %s" (arg_to_asm value)
  | IPop(dest) ->
     sprintf "  pop %s" (arg_to_asm dest)
  | ICall(label) ->
     sprintf "  call %s" label
  | IRet ->
     "  ret"
  | ITest(arg, comp) ->
     sprintf "  test %s, %s" (arg_to_asm arg) (arg_to_asm comp)
  | ILineComment(str) ->
     sprintf "  ;; %s" str
  | IInstrComment(instr, str) ->
     sprintf "%s ; %s" (i_to_asm instr) str

let to_asm (is : instruction list) : string =
  List.fold_left (fun s i -> sprintf "%s\n%s" s (i_to_asm i)) "" is

let rec find ls x =
  match ls with
  | [] -> failwith (sprintf "Name %s not found" x)
  | (y,v)::rest ->
     if y = x then v else find rest x

let count_vars e =
  let rec helpA e =
    match e with
    | ALet(_, bind, body, _) -> 1 + (max (helpC bind) (helpA body))
    | ACExpr e -> helpC e
  and helpC e =
    match e with
    | CIf(_, t, f, _) -> max (helpA t) (helpA f)
    | _ -> 0
  in helpA e

let rec replicate x i =
  if i = 0 then []
  else x :: (replicate x (i - 1))

let check_index (a : arg) : instruction list =
  [
    IMov(Reg(EAX), a);
    ITest(Reg(EAX), Const(0x00000001));
    IJnz("err_index_not_num");
  ]

let check_tuple_size (tuple : arg) (index : arg) : instruction list = 
  [
    IMov(Reg(EAX), tuple);
    IAnd(Reg(EAX), Const(0xFFF8));
    IMov(Reg(EAX), RegOffset(0, EAX));
    
    IMov(Reg(EEX), index);
    ISar(Reg(EEX), Const(1));
    ICmp(Reg(EEX), Reg(EAX));

    IJge("err_index_too_large");

    ICmp(Reg(EEX), Const(0));
    IJl("err_index_too_small");
  ]

let check_tuple (a : arg) : instruction list = 
  [
    IMov(Reg(EAX), a);
    IAnd(Reg(EAX), Const(0x00000007));
    IXor(Reg(EAX), Const(0x00000006));
    ICmp(Reg(EAX), Const(0x00000007));
    IJne("err_not_tuple");
  ]

let check_num (err_label : string) (a : arg) : instruction list =
  [
    IMov(Reg(EAX), a);
    ITest(Reg(EAX), tag_as_bool);
    IJnz(err_label)
  ]

let check_num_arith  = check_num "err_arith_not_num"
let check_num_comp = check_num "err_comp_not_num"

let check_bool (err_label : string) (a : arg) : instruction list =
  [
    IMov(Reg(EAX), a);
    IAnd(Reg(EAX), const_false);
    ICmp(Reg(EAX), const_false);
    IJne(err_label)
  ]

let check_bool_if = check_bool "err_if_not_bool"
let check_bool_logic = check_bool "err_logic_not_bool"

let check_one_bool (a : arg) (t : tag) : instruction list =
  let err_label = (sprintf "err_label_%d" t) in
  let pass_label = (sprintf "pass_label_%d" t) in
  [
    IMov(Reg(EAX), a);
    IAnd(Reg(EAX), Sized(DWORD_PTR, Const(0x7FFFFFFF)));
    ICmp(Reg(EAX), Sized(DWORD_PTR, Const(0x7FFFFFFF)));
    IJne(err_label);
  ] @
  [IJmp(pass_label);] @
  [
    ILabel(err_label);
    IPush(Const(err_LOGIC_NOT_BOOL));
    ICall("error");
    IPop(Reg(EAX));

    ILabel(pass_label);
  ]

let check_two_bool (a1 : arg) (a2 : arg) (t : tag) : instruction list =
  let err_label = (sprintf "err_label_%d" t) in
  let pass_label = (sprintf "pass_label_%d" t) in
  [
    IMov(Reg(EAX), a1);
    IAnd(Reg(EAX), Sized(DWORD_PTR, HexConst(0x7FFFFFFF)));
    ICmp(Reg(EAX), Sized(DWORD_PTR, HexConst(0x7FFFFFFF)));
    IJne(err_label);
  ] @
  [
    IMov(Reg(EAX), a2);
    IAnd(Reg(EAX), Sized(DWORD_PTR, HexConst(0x7FFFFFFF)));
    ICmp(Reg(EAX), Sized(DWORD_PTR, HexConst(0x7FFFFFFF)));
    IJne(err_label);
  ] @
  [IJmp(pass_label);] @
  [
    ILabel(err_label);
    IPush(Const(err_LOGIC_NOT_BOOL));
    ICall("error");
    IPop(Reg(EAX));

    ILabel(pass_label);
  ]

let check_one_num (a1 : arg) (t : tag) : instruction list =
  let err_label = (sprintf "err_label_%d" t) in
  let pass_label = (sprintf "pass_label_%d" t) in
  [
    IMov(Reg(EAX), a1);
    ITest(Reg(EAX), Const(0x00000001));
    IJnz(err_label);
  ] @
  [IJmp(pass_label);] @
  [
    ILabel(err_label);
    IPush(Const(err_ARITH_NOT_NUM));
    ICall("error");
    IPop(Reg(EAX));

    ILabel(pass_label);
  ]

let check_two_num (a1 : arg) (a2 : arg) (t : tag) : instruction list =
  let err_label = (sprintf "err_label_%d" t) in
  let pass_label = (sprintf "pass_label_%d" t) in
  [
    IMov(Reg(EAX), a1);
    ITest(Reg(EAX), Const(0x00000001));
    IJnz(err_label);
  ] @
  [
    IMov(Reg(EAX), a2);
    ITest(Reg(EAX), Const(0x00000001));
    IJnz(err_label);
  ] @
  [IJmp(pass_label);] @
  [
    ILabel(err_label);
    IPush(Const(err_ARITH_NOT_NUM));
    ICall("error");
    IPop(Reg(EAX));

    ILabel(pass_label);
  ]

let rec compile_fun (fun_name : string) (args : string list) (body : tag aexpr) (env : arg envt) : instruction list =
  (* is env suppose to be a list of var names and RegOffset pairs *)
  (* think about what we need to do *)
  (* lets assume we have envt*)
  let offset = (count_vars body) in  
  let prelude = [
    ILabel(fun_name);
    IPush(Reg(EBP));
    IMov(Reg(EBP), Reg(ESP));
    ISub(Reg(ESP), Const(word_size*offset));
  ] in
  let postlude = [
    IMov(Reg(ESP), Reg(EBP));
    IPop(Reg(EBP));
    IRet;
  ] in 
  let compiled_body = (compile_aexpr body 1 env (List.length args) false) in
  prelude @ compiled_body @ postlude

and compile_main (body : tag aexpr) (stack_start : int) (heap_start : int) : instruction list = 
  let offset = (count_vars body) in 
  let prelude = [
    ILabel("our_code_starts_here");
    IMov(Reg(EAX), Const(0)); (* First inst = NOP *)
    IMov(Reg(ESP), Const(stack_start));
    IMov(Reg(EBP), Const(stack_start));
    IMov(Reg(ESI), Const(heap_start)); 
    (* dont think pushing these is necessary but we need the offset *)
    IPush(Reg(EBP));
    IMov(Reg(EBP), Reg(ESP));
    ISub(Reg(ESP), Const(word_size*offset));
  ] in
  (* dont think this is necessary, but these shud end up as same *)
  let postlude = [
    IMov(Reg(ESP), Reg(EBP));
    IPop(Reg(EBP));
  ] in  
  (* why is stack index = 1 *)
  let compiled_body = (compile_aexpr body 1 [] 0 false) in
  prelude @ compiled_body @ postlude
  
and compile_aexpr (e : tag aexpr) (si : int) (env : arg envt) (num_args : int) (is_tail : bool) : instruction list =
  match e with
  | ALet(var, bind, body, t) ->
      let compile_bind = (compile_cexpr bind (si + 1) env num_args is_tail) in
      let new_bind = (var, RegOffset(-1*si*word_size, EBP)) in
      let compile_body = (compile_aexpr body (si + 1) (new_bind::env) num_args is_tail) in
      
      compile_bind @ 
      [ IMov(RegOffset(-1*si*word_size, EBP), Reg(EAX)) ] @
      compile_body
  | ACExpr(ce) -> (compile_cexpr ce si env num_args is_tail)

and compile_cexpr (e : tag cexpr) (si : int) (env : arg envt) (num_args : int) (is_tail : bool) : instruction list =
  match e with
  | CIf(cond, thn, els, t) ->
    let compile_cond = (compile_imm cond env) in
    let compile_then = (compile_aexpr thn si env num_args is_tail) in
    let compile_else = (compile_aexpr els si env num_args is_tail) in
    let if_false_label = (sprintf "if_false_%d" t) in
    let done_label = (sprintf "done_%d" t) in
    (check_bool_if compile_cond) @
    [
      IMov(Reg(EAX), compile_cond);
      ICmp(Reg(EAX), HexConst(0xFFFFFFFF));
      IJne(if_false_label);
    ] @
    compile_then @
    [
      IJmp(done_label);
      ILabel(if_false_label);
    ] @
    compile_else @
    [
      ILabel(done_label);
    ]

  | CPrim1(op, e, t) -> 
    let e_reg = (compile_imm e env) in
    begin match op with
    | Add1 ->
      (check_num_arith e_reg) @
      [
        IMov(Reg(EAX), e_reg);
        IAdd(Reg(EAX), Const(2))
      ]
    | Sub1 -> 
      (check_num_arith e_reg) @
      [
        IMov(Reg(EAX), e_reg);
        IAdd(Reg(EAX), Const(2))
      ]
    | Print ->
      [
        IMov(Reg(EAX), e_reg);
        IPush(Reg(EAX));
        ICall("print");
        IPop(Reg(EAX));
      ]
    | IsBool ->
      let true_label = (sprintf "true_%d" t) in
      let done_label = (sprintf "done_%d" t) in
      [
        IMov(Reg(EAX), e_reg);
        ICmp(Reg(EAX), HexConst(0xFFFFFFFF));
        IJe(true_label);
      ] @
      [
        IMov(Reg(EAX), e_reg);
        ICmp(Reg(EAX), HexConst(0x7FFFFFFF));
        IJe(true_label);
      ] @
      [
        IMov(Reg(EAX), HexConst(0x7FFFFFFF));
        IJmp(done_label);

        ILabel(true_label);
        IMov(Reg(EAX), HexConst(0xFFFFFFFF));

        ILabel(done_label);
      ]

    | IsNum ->
      let else_label = (sprintf "else_%d" t) in
      let done_label = (sprintf "done_%d" t) in
      [
        IMov(Reg(EAX), e_reg);

        ITest(Reg(EAX), Const(0x00000001));
        IJnz(else_label);

        IMov(Reg(EAX), HexConst(0xFFFFFFFF));
        IJmp(done_label);

        ILabel(else_label);
        IMov(Reg(EAX), HexConst(0x7FFFFFFF));
        
        ILabel(done_label);
      ]
    | Not ->
      (check_bool_logic e_reg) @
      [
        IMov(Reg(EAX), e_reg);
        IXor(Reg(EAX), Sized(DWORD_PTR, HexConst(0x80000000)));
      ]

    | PrintStack -> failwith "Not yet implemented: PrintStack"
    | IsTuple -> failwith "Not yet implemented: IsTuple"
    | Input -> failwith "Not yet implemented: Input"
    end

  | CPrim2(op, left, right, t) -> 
    begin
    let compile_left = (compile_imm left env) in
    let compile_right = (compile_imm right env) in
    let true_label = (sprintf "true_%d" t) in
    let done_label = (sprintf "done_%d" t) in
    match op with
    | Plus ->
      (check_num_arith compile_left) @
      (check_num_arith compile_right) @
      [
        IMov(Reg(EAX), compile_left);
        IAdd(Reg(EAX), compile_right);
      ]
    | Minus ->
      (check_num_arith compile_left) @
      (check_num_arith compile_right) @
      [
        IMov(Reg(EAX), compile_left);
        ISub(Reg(EAX), compile_right);
      ]

    | Times ->
      (check_num_arith compile_left) @
      (check_num_arith compile_right) @
      [
        IMov(Reg(EAX), compile_left);
        IMul(Reg(EAX), compile_right);
        IShr(Reg(EAX), Const(1));
      ]

    | And ->
      (check_bool_logic compile_left) @
      (check_bool_logic compile_right) @
      [
        IMov(Reg(EAX), compile_left);
        IAnd(Reg(EAX), compile_right);
      ]

    | Or ->
      (check_bool_logic compile_left) @
      (check_bool_logic compile_right) @
      [
        IMov(Reg(EAX), compile_left);
        IOr(Reg(EAX), compile_right);
      ]

    | Greater ->
      (check_num_comp compile_left) @
      (check_num_comp compile_right) @
      [
        IMov(Reg(EAX), compile_left);
        ICmp(Reg(EAX), compile_right);
        IJg(true_label);

        IMov(Reg(EAX), HexConst(0x7FFFFFFF));
        IJmp(done_label);

        ILabel(true_label);
        IMov(Reg(EAX), HexConst(0xFFFFFFFF));

        ILabel(done_label);
      ]

    | GreaterEq ->
      (check_num_comp compile_left) @
      (check_num_comp compile_right) @
      [
        IMov(Reg(EAX), compile_left);
        ICmp(Reg(EAX), compile_right);
        IJge(true_label);

        IMov(Reg(EAX), HexConst(0x7FFFFFFF));
        IJmp(done_label);

        ILabel(true_label);
        IMov(Reg(EAX), HexConst(0xFFFFFFFF));

        ILabel(done_label);
      ]

    | Less ->
      (check_num_comp compile_left) @
      (check_num_comp compile_right) @
      [
        IMov(Reg(EAX), compile_left);
        ICmp(Reg(EAX), compile_right);
        IJl(true_label);

        IMov(Reg(EAX), HexConst(0x7FFFFFFF));
        IJmp(done_label);

        ILabel(true_label);
        IMov(Reg(EAX), HexConst(0xFFFFFFFF));

        ILabel(done_label);
      ]

    | LessEq ->
      (check_num_comp compile_left) @
      (check_num_comp compile_right) @
      [
        IMov(Reg(EAX), compile_left);
        ICmp(Reg(EAX), compile_right);
        IJle(true_label);

        IMov(Reg(EAX), HexConst(0x7FFFFFFF));
        IJmp(done_label);

        ILabel(true_label);
        IMov(Reg(EAX), HexConst(0xFFFFFFFF));

        ILabel(done_label);
      ]

    | Eq ->
(*
      (check_num_comp compile_left) @
      (check_num_comp compile_right) @
*)
      [
        IMov(Reg(EAX), compile_left);
        ICmp(Reg(EAX), compile_right);
        IJe(true_label);

        IMov(Reg(EAX), HexConst(0x7FFFFFFF));
        IJmp(done_label);

        ILabel(true_label);
        IMov(Reg(EAX), HexConst(0xFFFFFFFF));

        ILabel(done_label);
      ]

    end
  | CApp(name, args, t) -> 
    (* alright need to implement caller callee *)
    
    (* we dont need to push eax *)
    (* we do need to push the parameters *)
    (* the call instruction puts the return address on top of the stack *)
    (* (printf "%d\n" (List.length args)); *)
    let rec push_parameters (args : tag immexpr list) (env : arg envt) : instruction list =
    match args with
    | first :: rest ->
      let compile_arg = (compile_imm first env) in
      (push_parameters rest env) @ [IPush(Sized(DWORD_PTR, compile_arg))]
    | [] -> []
    in
    let prelude = (push_parameters args env) in
    (* does push move the stack up *)
    let postlude = 
    [
      IAdd(Reg(ESP), Const(word_size * List.length(args)));
    ] in
    prelude @ [ICall(name);] @ postlude

  | CTuple(elts, _) ->
    (* cannot just move esi up and then reference it by subtracting ... it may change
    then how can we ensure we are looking at right pointer value
    wait no they are all immediates, meaning they shudnt put anything on esi
    how do u return esi in eax
    well can increment esi each time then put current esi - list length
    or can just use offsets each time, and put esi in eax and then add to it

    we need to do something about the tag on the tuple pointer*)
    let rec help (vals : 'a immexpr list) (env : arg envt) (offset : int) : instruction list =
      match vals with
      | first :: rest ->
        let compile_val = (compile_imm first env) in 
        [
          (* 2 instructions in case it is a tuple ... cannot move memory to memory *)
          IMov(Reg(EEX), Sized(DWORD_PTR, compile_val));
          IMov(RegOffset(word_size * offset, ESI), Reg(EEX));
        ] @
        (help rest env (offset + 1))
        (* we incremented ESI along the way so we need to set it back to the orignal pointer to put in EAX*)
      | [] -> 
        let extra = (offset mod 2) in
        [
          IMov(Reg(EAX), Reg(ESI));
(*
          IOr(Reg(EAX), Const(1));
*)
          IAdd(Reg(ESI), Const(word_size * (offset + extra)));
        ]
    in 
    [
      IMov(RegOffset(0, ESI), Sized(DWORD_PTR, Const(List.length elts)));
    ] @
    (* first index to write is 1 *)
    (help elts env 1)
  | CGetItem(coll, index, _) ->
    (* what are we suppose to lookup here
       put whatever is in the tuple lookup index into eax
       *)
    let compile_coll = (compile_imm coll env) in
    let compile_index = (compile_imm index env) in
    
(*
    (check_tuple compile_coll) @
    (check_index compile_index) @
    (check_tuple_size compile_coll compile_index) @ 
*)   
    [
      IMov(Reg(EEX), compile_index);
      ISar(Reg(EEX), Const(1));
      IAdd(Reg(EEX), Const(1));

      IMov(Reg(EAX), compile_coll);
(*
      IAnd(Reg(EAX), Const(0xFFF8));
*)
      IAdd(Reg(EAX), Reg(EEX));
      IMov(Reg(EAX), RegOffset(0, EAX));
    ]

  | CImmExpr(ie) -> 
    [
      IMov(Reg(EAX), (compile_imm ie env));
    ]

and compile_imm (e : tag immexpr) (env : arg envt) : arg = 
  match e with
  | ImmNum(n, _) -> Const((n lsl 1))
  | ImmBool(true, _) -> const_true
  | ImmBool(false, _) -> const_false
  | ImmId(x, _) -> (find env x)

let get_env (args : string list) : arg envt =
  let rec aux (args : string list) (index : int) : arg envt =
    match args with
    | first :: rest ->
      (* changing from 8 -> 2, 4 -> word_size (1) *)
      (first, RegOffset(2+index*word_size, EBP)) :: (aux rest (index+1))
    | [] -> []
  in
  (aux args 0)

let compile_decl (d : tag adecl) : instruction list =
  match d with
  (* assuming the env is a empty list here *)
  | ADFun(name, args, body, pos) -> 
    let env = (get_env args) in
    (compile_fun name args body env)

let compile_prog (prog : tag aprogram) : string =
  let prelude =
    "section .text" in
  let errors = [
    (* jump to the end of the program *)
    IJmp("end_of_program");

    (* arith expected number *)
    ILabel("err_arith_not_num");
    IPush(Const(err_ARITH_NOT_NUM));
    IMov(Reg(EAX), Const(0xa5a5));
    IJmp("end_of_program");

    ILabel("err_comp_not_num");
    IPush(Const(err_COMP_NOT_NUM));
    IMov(Reg(EAX), Const(0xa5a5));
    IJmp("end_of_program");

    ILabel("err_overflow");
    IPush(Const(err_OVERFLOW));
    IMov(Reg(EAX), Const(0xa5a5));
    IJmp("end_of_program");

    ILabel("err_if_not_bool");
    IPush(Const(err_IF_NOT_BOOL));
    IMov(Reg(EAX), Const(0xa5a5));
    IJmp("end_of_program");

    ILabel("err_logic_not_bool");
    IPush(Const(err_LOGIC_NOT_BOOL));
    IMov(Reg(EAX), Const(0xa5a5));
    IJmp("end_of_program");

    ILabel("err_index_not_num");
    IPush(Const(err_INDEX_NOT_NUM));
    IMov(Reg(EAX), Const(0xa5a5));
    IJmp("end_of_program");

    ILabel("err_not_tuple");
    IPush(Const(err_NOT_TUPLE));
    IMov(Reg(EAX), Const(0xa5a5));
    IJmp("end_of_program");

    ILabel("err_index_too_small");
    IPush(Const(err_INDEX_TOO_SMALL));
    IMov(Reg(EAX), Const(0xa5a5));
    IJmp("end_of_program");

    ILabel("err_index_too_large");
    IPush(Const(err_INDEX_TOO_LARGE));
    IMov(Reg(EAX), Const(0xa5a5));
    IJmp("end_of_program");

    (* jump to the end of the program *)
    ILabel("end_of_program");
  ] in
  match prog with
  | AProgram(fns, body, t) ->
    (* iterate through each decl and get the instruction list *)
    (* compile body *)
    let rec compile_fns (fns : tag adecl list) : instruction list = 
      match fns with
      | first :: rest ->
        (compile_decl first) @ (compile_fns rest)
      | [] -> []
    in
    let start = 
    [
      IJmp("our_code_starts_here");
    ] in
    let compiled_fns = (compile_fns fns) in
    let main = (compile_main body stack_start heap_start) in
    let il = (start @ compiled_fns @ main @ errors) in
    let as_assembly_string = (to_asm il) in
    sprintf "%s%s\n" prelude as_assembly_string
    
  
let compile_to_string prog : (exn list, string) either =
  let errors = well_formed prog in
  match errors with
  | [] ->
     let tagged : tag program = tag prog in
     let anfed : tag aprogram = atag (anf tagged) in
     (* printf "Prog:\n%s\n" (ast_of_expr prog); *)
     (* printf "Tagged:\n%s\n" (format_expr tagged string_of_int); *)
     (* printf "ANFed/tagged:\n%s\n" (format_expr anfed string_of_int); *)
     (* printf "made it here"; *)
     Right(compile_prog anfed)
  | _ -> Left(errors)

