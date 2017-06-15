(* Abstract syntax of (a small subset of) x86 assembly instructions *)
let word_size = 1
;;

let	opcode_nop	=	0

let	opcode_add	=	1
let	opcode_sub	=	2
let	opcode_not	=	3
let	opcode_and	=	4
let	opcode_or	=	5
let	opcode_nand	=	6
let	opcode_nor	=	7
let	opcode_mov	=	8
let	opcode_sar	=	9
let	opcode_shr	=	10
let	opcode_shl	=	11
let	opcode_xor	=	12
let	opcode_test	=	13
let	opcode_cmp	=	14

let	opcode_addi	=	16
let	opcode_subi	=	17
let	opcode_noti	=	18
let	opcode_andi	=	19
let	opcode_ori = 20
let	opcode_nandi = 21
let	opcode_nori	=	22
let	opcode_movi	=	23
let	opcode_sari	=	24
let	opcode_shri	=	25
let	opcode_shli	=	26
let	opcode_xori	=	27
let	opcode_testi=	28
let	opcode_cmpi	=	29

let	opcode_lw	=	32
let	opcode_sw	=	33
let	opcode_la	=	33
let	opcode_sa	=	34

let	opcode_jmp = 48
let	opcode_jo = 49
let	opcode_je = 50
let	opcode_jne = 51
let	opcode_jl = 52
let	opcode_jle = 53
let	opcode_jg	=	54
let	opcode_jge = 55
let	opcode_jz	=	56
let	opcode_jnz = 57
let opcode_jr = 58

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

let max_imm_value = 65535
let max_reg_addr = 31
let max_opcode_value = 63

let stack_start = 128

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
(* these belong to assembler *)
  | EBX (* adding this *)
  | ECX (* adding this *)
  | EDX
(* can use these *)
  | EEX
  | EFX
  | EGX
  | EHX
(* program registers *)
  | ESP
  | EBP
  | ESI

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

type mips_arg =
  | MImm of int
  | MReg of reg

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
  |	MADD of reg * reg
  |	MSUB of reg * reg
  |	MNOT of reg
  |	MAND of reg * reg
  |	MOR of reg * reg
  |	MNAND of reg * reg
  |	MNOR of reg * reg
  |	MMOV of reg * reg
  |	MSAR of reg * reg
  |	MSHR of reg * reg
  |	MSHL of reg * reg
  |	MXOR of reg * reg
  |	MTEST of reg * reg
  |	MCMP of reg * reg

  |	MADDI of reg * int
  |	MSUBI of reg * int
  |	MNOTI of int
  |	MANDI of reg * int
  |	MORI of reg * int
  |	MNANDI of reg * int
  |	MNORI of reg * int
  |	MMOVI of reg * int
  |	MSARI of reg * int
  |	MSHRI of reg * int
  |	MSHLI of reg * int
  |	MXORI of reg * int
  |	MTESTI of reg * int
  |	MCMPI of reg * int

  |	MLW of reg * reg * int
  |	MLA of reg * int
  |	MSW of reg * reg * int
  |	MSA of reg * int

  |	MJUMP of string
  |	MJO of string
  |	MJE of string
  |	MJNE of string
  |	MJL of string
  |	MJLE of string
  |	MJG of string
  |	MJGE of string
  |	MJZ of string
  |	MJNZ of string
  | MJR of reg

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


type 'a section = 
  | Section of instruction list








