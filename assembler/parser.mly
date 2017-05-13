%{
open Types

%}

%token <int> NUM
%token <string> LABEL
%token LPARENSPACE LPARENNOSPACE RPAREN COMMA PLUS MINUS TIMES COLON EOF MOV ADD SUB MUL CMP JO JE JNE JL JLE JG JGE JMP JZ JNZ RET AND OR XOR SHL SHR SAR PUSH POP CALL TEST REAX REBX RECX REDX RESP REBP SECTION TEXT



%left MOV ADD SUB MUL CMP JO JE JNE JL JLE JG JMP JZ JNZ RET AND OR XOR SHL SHR SAR PUSH POP CALL TEST LABEL SECTION


%type <(Lexing.position * Lexing.position) Types.section> section

%start section

%%

reg :
  | REAX { Reg(EAX) }

inst :
  | MOV reg COMMA reg { IMov($2, $4) }

insts :
  | inst { [$1] }
  | inst insts { $1::$2 }

section : 
  | SECTION TEXT insts EOF { Section( $3 ) }


%%
