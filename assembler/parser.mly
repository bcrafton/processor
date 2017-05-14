%{
open Types

%}

%token <int> NUM
%token <string> LABEL
%token LPARENSPACE LPARENNOSPACE RPAREN COMMA PLUS MINUS TIMES COLON EOF MOV ADD SUB MUL CMP JO JE JNE JL JLE JG JGE JMP JZ JNZ RET AND OR XOR SHL SHR SAR PUSH POP CALL TEST REAX REBX RECX REDX RESP REBP SECTION TEXT LBRACKET RBRACKET



%left MOV ADD SUB MUL CMP JO JE JNE JL JLE JG JMP JZ JNZ RET AND OR XOR SHL SHR SAR PUSH POP CALL TEST LABEL SECTION


%type <(Lexing.position * Lexing.position) Types.section> section

%start section

%%

reg :
  | REAX { Reg(EAX) }
  | REBX { Reg(EBX) }
  | RECX { Reg(ECX) }
  | REDX { Reg(EDX) }
  | RESP { Reg(ESP) }
  | REBP { Reg(EBP) }

const :
  | NUM { Const($1) }

reg_offset :
  | LBRACKET reg PLUS 

imm :
  | const { $1 }
  | reg { $1 }
  | reg_offset { $1 }

inst :
  | MOV reg COMMA imm { IMov($2, $4) }
  | ADD reg COMMA imm { IAdd($2, $4) }
  | SUB reg COMMA imm { ISub($2, $4) }
  | MUL reg COMMA imm { IMul($2, $4) }
  | CMP reg COMMA imm { ICmp($2, $4) }

  | JO LABEL { IJo($2) }
  | JE LABEL { IJe($2) }
  | JNE LABEL { IJne($2) }
  | JL LABEL { IJl($2) }
  | JLE LABEL { IJle($2) }
  | JG LABEL { IJg($2) }
  | JGE LABEL { IJge($2) }
  | JMP LABEL { IJmp($2) }
  | JZ LABEL { IJz($2) }
  | JNZ LABEL { IJnz($2) }

  | RET { IRet }

  | AND reg COMMA imm { IAnd($2, $4) }
  | OR reg COMMA imm { IOr($2, $4) }
  | XOR reg COMMA imm { IXor($2, $4) }

  | SHL reg COMMA imm { IShl($2, $4) }
  | SHR reg COMMA imm { IShr($2, $4) }
  | SAR reg COMMA imm { ISar($2, $4) }

  | PUSH imm { IPush($2) }
  | POP reg { IPop($2) }
  | CALL LABEL { ICall($2) }

  | TEST reg COMMA imm { ITest($2, $4) }

  | LABEL COLON { ILabel($1) }


insts :
  | inst { [$1] }
  | inst insts { $1::$2 }

section : 
  | SECTION TEXT insts EOF { Section( $3 ) }


%%
