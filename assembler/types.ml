(* Abstract syntax of (a small subset of) x86 assembly instructions *)
let word_size = 4
;;

let	opcode_add	=	0
let	opcode_sub	=	1
let	opcode_not	=	2
let	opcode_and	=	3
let	opcode_or	=	4
let	opcode_nand	=	5
let	opcode_nor	=	6
let	opcode_mov	=	7
let	opcode_sar	=	8
let	opcode_shr	=	9
let	opcode_shl	=	10
let	opcode_xor	=	11
let	opcode_test	=	12
let	opcode_cmp	=	13

let	opcode_addi	=	14
let	opcode_subi	=	15
let	opcode_noti	=	16
let	opcode_andi	=	17
let	opcode_ori = 18
let	opcode_nandi = 19
let	opcode_nori	=	20
let	opcode_movi	=	21
let	opcode_sari	=	22
let	opcode_shri	=	23
let	opcode_shli	=	24
let	opcode_xori	=	25
let	opcode_testi=	26
let	opcode_cmpi	=	27

let	opcode_lw	=	28
let	opcode_sw	=	29
let	opcode_la	=	30
let	opcode_sa	=	31

let	opcode_jmp	=	32
let	opcode_jo	=	33
let	opcode_je	=	34
let	opcode_jne	=	35
let	opcode_jl	=	36
let	opcode_jle	=	37
let	opcode_jg	=	38
let	opcode_jge	=	39
let	opcode_jz	=	40
let	opcode_jnz	=	41

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
  | EBX (* adding this *)
  | ECX (* adding this *)
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
  |	MSW of reg * reg * int
  |	MSA of reg * int
  |	MLA of reg * int

  |	MJUMP of int
  |	MJO of int
  |	MJE of int
  |	MJNE of int
  |	MJL of int
  |	MJLE of int
  |	MJG of int
  |	MJGE of int
  |	MJZ of int
  |	MJNZ of int

  | MLabel of string

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


