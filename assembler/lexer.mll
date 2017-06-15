{
  open Lexing
  open Parser
  open Printf
}

let dec_digit = ['0'-'9']
let signed_int = dec_digit+ | ('-' dec_digit+)

let hex_number = ['0']['x' 'X']['0'-'9' 'a'-'f' 'A'-'F']+

let ident = ['a'-'z' 'A'-'Z' '_']['a'-'z' 'A'-'Z' '0'-'9' '_']*

let blank = [' ' '\t']+

let space = [' ' '\t' '\n']+

rule token = parse
  | '#' [^ '\n']+ { token lexbuf }
  | blank "(" { LPARENSPACE }
  | '\n' "(" { LPARENSPACE }
  | blank { token lexbuf }
  | '\n' { new_line lexbuf; token lexbuf }
  | signed_int as x { NUM (int_of_string x) }
  | hex_number as x { NUM (int_of_string x) }

  | "mov" { MOV }
  | "add" { ADD }
  | "sub" { SUB }
  | "mul" { MUL }
  | "cmp" { CMP }
  | "jo" { JO }
  | "je" { JE }
  | "jne" { JNE }
  | "jl" { JL }
  | "jle" { JLE }
  | "jg" { JG }
  | "jge" { JGE }
  | "jmp" { JMP }
  | "jz" { JZ }
  | "jnz" { JNZ }
  | "ret" { RET }
  | "and" { AND }
  | "or" { OR }
  | "xor" { XOR }
  | "shl" { SHL }
  | "shr" { SHR }
  | "sar" { SAR }
  | "push" { PUSH }
  | "pop" { POP }
  | "call" { CALL }
  | "test" { TEST }

  | "eax" { REAX }

  | "ebx" { REBX }
  | "ecx" { RECX }
  | "edx" { REDX }

  | "eex" { REEX }
  | "efx" { REFX }
  | "egx" { REGX }
  | "ehx" { REHX }

  | "esp" { RESP }
  | "ebp" { REBP }
  | "esi" { RESI }

  | ":" { COLON }
  | "," { COMMA }
  | "(" { LPARENNOSPACE }
  | ")" { RPAREN }
  | "[" { LBRACKET }
  | "]" { RBRACKET }
  | "+" { PLUS }
  | "-" { MINUS }
  | "*" { TIMES }

  | "section" { SECTION }
  | ".text"    { TEXT }

  | ident as x { LABEL x }
  | eof { EOF }
  | _ as c { failwith (sprintf "Unrecognized character: %c" c) }










