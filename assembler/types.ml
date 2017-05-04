(* Abstract syntax of (a small subset of) x86 assembly instructions *)
let word_size = 4
;;

let op_code_add       = 0;;
let op_code_addi      = 1;;
let op_code_sub       = 2;;
let op_code_subi      = 3;;
let op_code_not       = 4;;
let op_code_and       = 5;;
let op_code_or        = 6;;
let op_code_nand      = 7;;
let op_code_nor       = 8;;
let op_code_mov       = 9;;
let op_code_li        = 10;;
let op_code_lw        = 11;;
let op_code_sw        = 12;;
let op_code_beq       = 13;;
let op_code_bne       = 14
let op_code_jump      = 15
let op_code_sa        = 16
let op_code_la        = 17
let op_code_sar       = 18
let op_code_shr       = 19
let op_code_shl       = 20
let op_code_xor       = 21

let opcode_msb = 31
let opcode_lsb = 26

let reg_rs_msb = 25
let reg_rs_lsb = 21

let reg_rt_msb = 20
let reg_rt_lsb = 16

(* R-TYPE *)
let reg_rd_msb = 15
let reg_rd_lsb = 11

(* I-TYPE *)
let imm_msb = 15
let imm_lsb = 0

type ('a, 'b) either =
  | Left of 'a
  | Right of 'b

               
type sourcespan = (Lexing.position * Lexing.position)
exception UnboundId of string * sourcespan (* name, where used *)
exception UnboundFun of string * sourcespan (* name of fun, where used *)
exception ShadowId of string * sourcespan * sourcespan (* name, where used, where defined *)
exception DuplicateId of string * sourcespan * sourcespan (* name, where used, where defined *)
exception DuplicateFun of string * sourcespan * sourcespan (* name, where used, where defined *)
exception Overflow of int * sourcespan (* value, where used *)
exception Arity of int * int * sourcespan (* intended arity, actual arity, where called *)

type reg =
  | EAX
  | EDX
  | ESP
  | EBP

type size =
  | DWORD_PTR
  | WORD_PTR
  | BYTE_PTR

type arg =
  | Const of int
  | HexConst of int
  | Reg of reg
  | RegOffset of int * reg (* int is # words of offset *)
  | Sized of size * arg

type asm_arg = 
  | AsmConst of int
  | AsmReg of reg

type reg_addr = int
type imm = int
type opcode = int

type asm_instruction
  | RType opcode * reg_addr * reg_addr * reg_addr
  | IType opcode * reg_addr * reg_addr * imm

type instruction =
  | IMov of arg * arg
  | IAdd of arg * arg
  | ISub of arg * arg
  | IMul of arg * arg
  | ILabel of string
  | ICmp of arg * arg
  | IJo of string
  | IJe of string
  | IJne of string
  | IJl of string
  | IJle of string
  | IJg of string
  | IJge of string
  | IJmp of string
  | IJz of string
  | IJnz of string
  | IRet
  | IAnd of arg * arg
  | IOr of arg * arg
  | IXor of arg * arg
  | IShl of arg * arg
  | IShr of arg * arg
  | ISar of arg * arg
  | IPush of arg
  | IPop of arg
  | ICall of string
  | ITest of arg * arg
  | ILineComment of string
  | IInstrComment of instruction * string

type mips_instruction =
  | MMov of arg * arg
  | MAdd of arg * arg
  | MSub of arg * arg
  | MMul of arg * arg
  | MLabel of string
  | MCmp of arg * arg
  | MJo of string
  | MJe of string
  | MJne of string
  | MJl of string
  | MJle of string
  | MJg of string
  | MJge of string
  | MJmp of string
  | MJz of string
  | MJnz of string
  | MRet
  | MAnd of arg * arg
  | MOr of arg * arg
  | MXor of arg * arg
  | MShl of arg * arg
  | MShr of arg * arg
  | MSar of arg * arg
  | MPush of arg
  | MPop of arg
  | MCall of string
  | MTest of arg * arg
  | MLineComment of string
  | MInstrComment of instruction * string

type prim1 =
  | Add1
  | Sub1
  | Print
  | IsBool
  | IsNum
  | Not
  | PrintStack

type prim2 =
  | Plus
  | Minus
  | Times
  | And
  | Or
  | Greater
  | GreaterEq
  | Less
  | LessEq
  | Eq

type 'a bind = (string * 'a expr * 'a)

and 'a expr =
  | ELet of 'a bind list * 'a expr * 'a
  | EPrim1 of prim1 * 'a expr * 'a
  | EPrim2 of prim2 * 'a expr * 'a expr * 'a
  | EIf of 'a expr * 'a expr * 'a expr * 'a
  | ENumber of int * 'a
  | EBool of bool * 'a
  | EId of string * 'a
  | EApp of string * 'a expr list * 'a

type 'a decl =
  | DFun of string * (string * 'a) list * 'a expr * 'a

type 'a program =
  | Program of 'a decl list * 'a expr * 'a

type 'a immexpr = (* immediate expressions *)
  | ImmNum of int * 'a
  | ImmBool of bool * 'a
  | ImmId of string * 'a
and 'a cexpr = (* compound expressions *)
  | CIf of 'a immexpr * 'a aexpr * 'a aexpr * 'a
  | CPrim1 of prim1 * 'a immexpr * 'a
  | CPrim2 of prim2 * 'a immexpr * 'a immexpr * 'a
  | CApp of string * 'a immexpr list * 'a
  | CImmExpr of 'a immexpr (* for when you just need an immediate value *)
and 'a aexpr = (* anf expressions *)
  | ALet of string * 'a cexpr * 'a aexpr * 'a
  | ACExpr of 'a cexpr
and 'a adecl =
  | ADFun of string * string list * 'a aexpr * 'a

and 'a aprogram =
  | AProgram of 'a adecl list * 'a aexpr * 'a


