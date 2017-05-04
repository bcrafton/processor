(* Abstract syntax of (a small subset of) x86 assembly instructions *)
let word_size = 4
;;

let OP_CODE_ADD       = 0
let OP_CODE_ADDI      = 1
let OP_CODE_SUB       = 2
let OP_CODE_SUBI      = 3
let OP_CODE_NOT       = 4
let OP_CODE_AND       = 5
let OP_CODE_OR        = 6
let OP_CODE_NAND      = 7
let OP_CODE_NOR       = 8
let OP_CODE_MOV       = 9
let OP_CODE_LI        = 10
let OP_CODE_LW        = 11
let OP_CODE_SW        = 12
let OP_CODE_BEQ       = 13
let OP_CODE_BNE       = 14
let OP_CODE_JUMP      = 15
let OP_CODE_SA        = 16
let OP_CODE_LA        = 17
let OP_CODE_SAR       = 18
let OP_CODE_SHR       = 19
let OP_CODE_SHL       = 20
let OP_CODE_XOR       = 21

let OPCODE_MSB = 31
let OPCODE_LSB = 26

let REG_RS_MSB = 25
let REG_RS_LSB = 21

let REG_RT_MSB = 20
let REG_RT_LSB = 16

(* R-TYPE *)
let REG_RD_MSB = 15
let REG_RD_LSB = 11

(* I-TYPE *)
let IMM_MSB = 15
let IMM_LSB = 0

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
  | AsmArgConst(asm_const)
  | AsmArgReg(asm_reg)  

type asm_const
  | AsmConst of int
  | AsmHexConst of int
  | AsmConstSized of size * asm_const

type asm_reg
  | AsmReg of reg
  | AsmRegOffset of int * reg
  | AsmRegSized of size * asm_reg

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


