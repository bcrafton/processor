%{
open Types

%}

%token <int> NUM
%token <string> LABEL
%token LPARENSPACE LPARENNOSPACE RPAREN COMMA PLUS MINUS TIMES COLON EOF MOV ADD SUB MUL CMP JO JE JNE JL JLE JG JGE JMP JZ JNZ RET AND OR XOR SHL SHR SAR PUSH POP CALL TEST REAX REBX RECX REDX REEX REFX REGX REHX RESP REBP RESI SECTION TEXT LBRACKET RBRACKET



%left MOV ADD SUB MUL CMP JO JE JNE JL JLE JG JMP JZ JNZ RET AND OR XOR SHL SHR SAR PUSH POP CALL TEST LABEL SECTION


%type <(Lexing.position * Lexing.position) Types.section> section

%start section

%%

reg :
  | REAX { EAX }

  | REBX { EBX }
  | RECX { ECX }
  | REDX { EDX }

  | REEX { EEX }
  | REFX { EFX }
  | REGX { EGX }
  | REHX { EHX }

  | RESP { ESP }
  | REBP { EBP }
  | RESI { ESI }

rreg :
  | reg { Reg($1) }

const :
  | NUM { Const($1) }

reg_offset :
  | LBRACKET reg PLUS NUM RBRACKET { RegOffset($4, $2) }
  | LBRACKET reg MINUS NUM RBRACKET { RegOffset(-1*$4, $2) }

src :
  | const { $1 }
  | rreg { $1 }
  | reg_offset { $1 }

dst :
  | rreg { $1 }
  | reg_offset { $1 }

inst :
  | MOV dst COMMA src { IMov($2, $4) }
  | ADD dst COMMA src { IAdd($2, $4) }
  | SUB dst COMMA src { ISub($2, $4) }
  | MUL dst COMMA src { IMul($2, $4) }
  | CMP dst COMMA src { ICmp($2, $4) }

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

  | AND dst COMMA src { IAnd($2, $4) }
  | OR dst COMMA src { IOr($2, $4) }
  | XOR dst COMMA src { IXor($2, $4) }

  | SHL dst COMMA src { IShl($2, $4) }
  | SHR dst COMMA src { IShr($2, $4) }
  | SAR dst COMMA src { ISar($2, $4) }

  | PUSH src { IPush($2) }
  | POP rreg { IPop($2) }
  | CALL LABEL { ICall($2) }

  | TEST dst COMMA src { ITest($2, $4) }

  | LABEL COLON { ILabel($1) }


insts :
  | inst { [$1] }
  | inst insts { $1::$2 }

section : 
  | SECTION TEXT insts EOF { Section( $3 ) }


%%
