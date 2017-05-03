open Printf
open Types
open Pretty

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


let const_true = HexConst (0xFFFFFFFF)
let const_false = HexConst(0x7FFFFFFF)
let bool_mask = HexConst(0x80000000)
let tag_as_bool = HexConst(0x00000001)

let err_COMP_NOT_NUM   = 0
let err_ARITH_NOT_NUM  = 1
let err_LOGIC_NOT_BOOL = 2
let err_IF_NOT_BOOL    = 3
let err_OVERFLOW       = 4

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

(* so not really sure how we can test this.
also not really sure if we have done this right
i think we are better off trying to make some of the other functions work
coming back and testing this*)
let well_formed (p : (Lexing.position * Lexing.position) program) : exn list =
  let rec wf_E (e : 'a expr) (dl : 'a decl list) (env : string list) : exn list =
    match e with
    | EApp(name, args, pos) ->
      let d = (find_decl dl name) in
      begin
      match d with
      | None -> [UnboundFun("", pos)]
      | Some(found_decl) -> 
        begin
        match found_decl with
        | DFun(fname, fargs, body, decl_pos) ->
            if ((List.length args) != (List.length fargs)) then [Arity((List.length args), (List.length fargs), decl_pos)] else []
        end
      end
    | ELet(binds, body, pos) ->
      let rec help (binds : 'a bind list) (body : 'a expr) (env : string list) (local_env : string list) : exn list =
        match binds with
        | (name, e, pos) :: rest ->
          if (contains env name) then [ShadowId(name, pos, pos)] @ (help rest body (name::env) (name::local_env))
          else if (contains local_env name) then [DuplicateId(name, pos, pos)] @ (help rest body (name::env) (name::local_env))
          else (wf_E e dl (name::env)) @ (help rest body (name::env) (name::local_env))
        | [] -> (wf_E body dl env)
      in
      (help binds body env [])
    | ENumber(n, pos) ->
        if n > 1073741823 || n < -1073741824 then [Overflow(n, pos)] else []
    | EId(name, pos) ->
      begin
      let id = (search env name) in
      match id with
      | None -> [UnboundId(name, pos)]
      | Some(v) -> []
      end
    | EPrim1(_, e, _) -> (wf_E e dl env)
    | EPrim2(_, e1, e2, _) -> (wf_E e1 dl env) @ (wf_E e2 dl env)
    | EIf(cond, tru, fals, _) -> (wf_E cond dl env) @ (wf_E tru dl env) @ (wf_E fals dl env)
    | EBool(_, _) -> []

  and wf_D (d : 'a decl) (dl : 'a decl list) (env : string list) : exn list =
    match d with
    | DFun(name, args, body, pos) ->
      let rec help (l : (string * (Lexing.position * Lexing.position)) list) (env : string list) : exn list = 
        match l with
        | (s, p) :: rest ->
          let dup = (find_dup l) in
          begin
          match dup with
          | None -> (help rest (s :: env))
          | Some(x) -> [DuplicateId("", p, p)] @ (help rest (s :: env))
          end
        | [] -> (wf_E body dl env)
      in
      let check = (help args []) in
      check
  in
  match p with
  | Program(decls, body, _) ->
    (* for each decl: 
    check names
    for each arg
    check args
    for each body
    check stuff *)
    let rec check_fn_names (d : (Lexing.position * Lexing.position) decl list) : exn list = 
      begin
      match d with
      | DFun(name, args, body, pos) :: rest ->
        let exn_list1 = (wf_D (DFun(name, args, body, pos)) d []) in
        let dup = (find_dup args) in
        begin
        match dup with
        | None -> exn_list1 @ (check_fn_names rest)
        | Some(x) -> exn_list1 @ [DuplicateFun("", pos, pos)] @ (check_fn_names rest)
        end
      | [] -> []
      end
    in
    let check_fn_name_exns = (check_fn_names decls) in
    let check_body = (wf_E body decls []) in
    check_fn_name_exns @ check_body
;;



type tag = int
let tag (p : 'a program) : tag program =
  let next = ref 0 in
  let tag () =
    next := !next + 1;
    !next in
  let rec helpE (e : 'a expr) : tag expr =
    match e with
    | EId(x, _) -> EId(x, tag())
    | ENumber(n, _) -> ENumber(n, tag())
    | EBool(b, _) -> EBool(b, tag())
    | EPrim1(op, e, _) ->
       let prim_tag = tag() in
       EPrim1(op, helpE e, prim_tag)
    | EPrim2(op, e1, e2, _) ->
       let prim_tag = tag() in
       EPrim2(op, helpE e1, helpE e2, prim_tag)
    | ELet(binds, body, _) ->
       let let_tag = tag() in
       ELet(List.map (fun (x, b, _) -> let t = tag() in (x, helpE b, t)) binds, helpE body, let_tag)
    | EIf(cond, thn, els, _) ->
       let if_tag = tag() in
       EIf(helpE cond, helpE thn, helpE els, if_tag)
    | EApp(name, args, _) ->
       let app_tag = tag() in
       EApp(name, List.map helpE args, app_tag)
  and helpD d =
    match d with
    | DFun(name, args, body, _) ->
       let fun_tag = tag() in
       DFun(name, List.map (fun (a, _) -> (a, tag())) args, helpE body, fun_tag)
  and helpP p =
    match p with
    | Program(decls, body, _) ->
       Program(List.map helpD decls, helpE body, 0)
  in helpP p

let rec untag (p : 'a program) : unit program =
  let rec helpE e =
    match e with
    | EId(x, _) -> EId(x, ())
    | ENumber(n, _) -> ENumber(n, ())
    | EBool(b, _) -> EBool(b, ())
    | EPrim1(op, e, _) ->
       EPrim1(op, helpE e, ())
    | EPrim2(op, e1, e2, _) ->
       EPrim2(op, helpE e1, helpE e2, ())
    | ELet(binds, body, _) ->
       ELet(List.map(fun (x, b, _) -> (x, helpE b, ())) binds, helpE body, ())
    | EIf(cond, thn, els, _) ->
       EIf(helpE cond, helpE thn, helpE els, ())
    | EApp(name, args, _) ->
       EApp(name, List.map helpE args, ())
  and helpD d =
    match d with
    | DFun(name, args, body, _) ->
       DFun(name, List.map (fun (a, _) -> (a, ())) args, helpE body, ())
  and helpP p =
    match p with
    | Program(decls, body, _) ->
       Program(List.map helpD decls, helpE body, ())
  in helpP p

let atag (p : 'a aprogram) : tag aprogram =
  let next = ref 0 in
  let tag () =
    next := !next + 1;
    !next in
  let rec helpA (e : 'a aexpr) : tag aexpr =
    match e with
    | ALet(x, c, b, _) ->
       let let_tag = tag() in
       ALet(x, helpC c, helpA b, let_tag)
    | ACExpr c -> ACExpr (helpC c)
  and helpC (c : 'a cexpr) : tag cexpr =
    match c with
    | CPrim1(op, e, _) ->
       let prim_tag = tag() in
       CPrim1(op, helpI e, prim_tag)
    | CPrim2(op, e1, e2, _) ->
       let prim_tag = tag() in
       CPrim2(op, helpI e1, helpI e2, prim_tag)
    | CIf(cond, thn, els, _) ->
       let if_tag = tag() in
       CIf(helpI cond, helpA thn, helpA els, if_tag)
    | CApp(name, args, _) ->
       let app_tag = tag() in
       CApp(name, List.map helpI args, app_tag)
    | CImmExpr i -> CImmExpr (helpI i)
  and helpI (i : 'a immexpr) : tag immexpr =
    match i with
    | ImmId(x, _) -> ImmId(x, tag())
    | ImmNum(n, _) -> ImmNum(n, tag())
    | ImmBool(b, _) -> ImmBool(b, tag())
  and helpD d =
    match d with
    | ADFun(name, args, body, _) ->
       let fun_tag = tag() in
       ADFun(name, args, helpA body, fun_tag)
  and helpP p =
    match p with
    | AProgram(decls, body, _) ->
       AProgram(List.map helpD decls, helpA body, 0)
  in helpP p


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
  | EDX -> "edx"
  | ESP -> "esp"
  | EBP -> "ebp"

let rec arg_to_asm (a : arg) : string =
  match a with
  | Const(n) -> sprintf "%d" n
  | HexConst(n) -> sprintf "0x%lx" (Int32.of_int n)
  | Reg(r) -> r_to_asm r
  | RegOffset(n, r) ->
     if n >= 0 then
       sprintf "[%s+%d]" (r_to_asm r) n
     else
       sprintf "[%s-%d]" (r_to_asm r) (-1 * n)
  | Sized(size, a) ->
     sprintf "%s %s"
             (match size with | DWORD_PTR -> "DWORD" | WORD_PTR -> "WORD" | BYTE_PTR -> "BYTE")
             (arg_to_asm a)
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

(*
let err_COMP_NOT_NUM   = 0
let err_ARITH_NOT_NUM  = 1
let err_LOGIC_NOT_BOOL = 2
let err_IF_NOT_BOOL    = 3
let err_OVERFLOW       = 4
*)

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
    IAnd(Reg(EAX), Sized(DWORD_PTR, Const(0x7FFFFFFF)));
    ICmp(Reg(EAX), Sized(DWORD_PTR, Const(0x7FFFFFFF)));
    IJne(err_label);
  ] @
  [
    IMov(Reg(EAX), a2);
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

let rec assemble (out : string) (il : instruction list) =
  let binary = (assemble_section il) in
  let outfile = open_out (out ^ ".b") in
  fprintf outfile "%s" binary

and assemble_section (il : instruction list) : string = 
  match il with
  | i :: rest ->
    sprintf "%s\n%s" (assemble_instruction i) (assemble_section rest)
  | [] -> ""

and assemble_instruction (i : instruction) : string = 
  sprintf "add 5, 4"

let rec compile_fun (fun_name : string) (args : string list) (body : tag aexpr) (env : arg envt) : instruction list =
  (* is env suppose to be a list of var names and RegOffset pairs *)
  (* think about what we need to do *)
  (* lets assume we have envt*)
  let offset = (count_vars body) in  
  let prelude = [
    ILabel(fun_name);
    IPush(Reg(EBP));
    IMov(Reg(EBP), Reg(ESP));
    IAdd(Reg(ESP), Const(-1*word_size*offset));
  ] in
  let postlude = [
    IMov(Reg(ESP), Reg(EBP));
    IPop(Reg(EBP));
    IRet;
  ] in 
  let compiled_body = (compile_aexpr body 1 env (List.length args) false) in
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
    let else_label = (sprintf "if_false_%d" t) in
    let done_label = (sprintf "done_%d" t) in
    (check_bool_if compile_cond) @
    [
      IMov(Reg(EAX), compile_cond);
      ICmp(Reg(EAX), Const(0xFFFFFFFF));
      IJne(else_label);
    ] @
    compile_then @
    [
      IJmp(done_label);
      ILabel(else_label);
    ] @
    compile_else @
    [ILabel(done_label);]

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
        ICmp(Reg(EAX), Const(0xFFFFFFFF));
        IJe(true_label);
      ] @
      [
        IMov(Reg(EAX), e_reg);
        ICmp(Reg(EAX), Const(0x7FFFFFFF));
        IJe(true_label);
      ] @
      [
        IMov(Reg(EAX), Const(0x7FFFFFFF));
        IJmp(done_label);

        ILabel(true_label);
        IMov(Reg(EAX), Const(0xFFFFFFFF));

        ILabel(done_label);
      ]

    | IsNum ->
      let else_label = (sprintf "else_%d" t) in
      let done_label = (sprintf "done_%d" t) in
      [
        IMov(Reg(EAX), e_reg);

        ITest(Reg(EAX), Const(0x00000001));
        IJnz(else_label);

        IMov(Reg(EAX), Const(0xFFFFFFFF));
        IJmp(done_label);

        ILabel(else_label);
        IMov(Reg(EAX), Const(0x7FFFFFFF));
        
        ILabel(done_label);
      ]
    | Not ->
      (check_bool_logic e_reg) @
      [
        IMov(Reg(EAX), e_reg);
        IXor(Reg(EAX), Sized(DWORD_PTR, Const(0x80000000)));
      ]

    | PrintStack -> failwith "print stack not implemented"
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

        IMov(Reg(EAX), Const(0x7FFFFFFF));
        IJmp(done_label);

        ILabel(true_label);
        IMov(Reg(EAX), Const(0xFFFFFFFF));

        ILabel(done_label);
      ]

    | GreaterEq ->
      (check_num_comp compile_left) @
      (check_num_comp compile_right) @
      [
        IMov(Reg(EAX), compile_left);
        ICmp(Reg(EAX), compile_right);
        IJge(true_label);

        IMov(Reg(EAX), Const(0x7FFFFFFF));
        IJmp(done_label);

        ILabel(true_label);
        IMov(Reg(EAX), Const(0xFFFFFFFF));

        ILabel(done_label);
      ]

    | Less ->
      (check_num_comp compile_left) @
      (check_num_comp compile_right) @
      [
        IMov(Reg(EAX), compile_left);
        ICmp(Reg(EAX), compile_right);
        IJl(true_label);

        IMov(Reg(EAX), Const(0x7FFFFFFF));
        IJmp(done_label);

        ILabel(true_label);
        IMov(Reg(EAX), Const(0xFFFFFFFF));

        ILabel(done_label);
      ]

    | LessEq ->
      (check_num_comp compile_left) @
      (check_num_comp compile_right) @
      [
        IMov(Reg(EAX), compile_left);
        ICmp(Reg(EAX), compile_right);
        IJle(true_label);

        IMov(Reg(EAX), Const(0x7FFFFFFF));
        IJmp(done_label);

        ILabel(true_label);
        IMov(Reg(EAX), Const(0xFFFFFFFF));

        ILabel(done_label);
      ]

    | Eq ->
      (check_num_comp compile_left) @
      (check_num_comp compile_right) @
      [
        IMov(Reg(EAX), compile_left);
        ICmp(Reg(EAX), compile_right);
        IJe(true_label);

        IMov(Reg(EAX), Const(0x7FFFFFFF));
        IJmp(done_label);

        ILabel(true_label);
        IMov(Reg(EAX), Const(0xFFFFFFFF));

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
      IPush(Sized(DWORD_PTR, compile_arg)) :: (push_parameters rest env)
    | [] -> []
    in
    let prelude = (push_parameters args env) in
    (* does push move the stack up *)
    let postlude = 
    [
      IAdd(Reg(ESP), Const(word_size * List.length(args)));
    ] in
    prelude @ [ICall(name);] @ postlude

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
      (first, RegOffset(8+index*4, EBP)) :: (aux rest (index+1))
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
    "section .text
extern error
extern print
global our_code_starts_here" in
let errors = [
      (* arith expected number *)
      ILabel("err_arith_not_num");
      IPush(Const(err_ARITH_NOT_NUM));
      ICall("error");
      (* comp expected number *)
      ILabel("err_comp_not_num");
      IPush(Const(err_COMP_NOT_NUM));
      ICall("error");
      (* overflow *)
      ILabel("err_overflow");
      IPush(Const(err_OVERFLOW));
      ICall("error");
      (* if expects boolean *)
      ILabel("err_if_not_bool");
      IPush(Const(err_IF_NOT_BOOL));
      ICall("error");
      (* logical operator expects boolean *)
      ILabel("err_logic_not_bool");
      IPush(Const(err_LOGIC_NOT_BOOL));
      ICall("error");
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
    let compiled_fns = (compile_fns fns) in
    let main = (compile_decl (ADFun("our_code_starts_here", [], body, t))) in
    let il = (compiled_fns @ main @ errors) in

    (assemble "prog" il); 

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

