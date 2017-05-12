%{
open Types

%}

%token <int> NUM
%token <string> LABEL
%token LPARENSPACE LPARENNOSPACE RPAREN COMMA PLUS MINUS TIMES COLON EOF MOV ADD SUB MUL CMP JO JE JNE JL JLE JG JMP JZ JNZ RET AND OR XOR SHL SHR SAR PUSH POP CALL TEST REAX REBX RECX REDX RESP REBP SECTION TEXT



%left MOV ADD SUB MUL CMP JO JE JNE JL JLE JG JMP JZ JNZ RET AND OR XOR SHL SHR SAR PUSH POP CALL TEST LABEL SECTION


%type <(Lexing.position * Lexing.position) Types.section> section

(* is this the base type ... section for us *)
%start section

%%

const :
  | NUM { ENumber($1, (Parsing.symbol_start_pos (), Parsing.symbol_end_pos ())) }

register :
 | REAX
 | REBX 
 | RECX 
  

inst :
 | IMov MOV 
 | ADD  
 | SUB  
 | MUL  
 | CMP  
 | JO  
 | JE  
 | JNE  
 | JL  
 | JLE  
 | JG  
 | JMP  
 | JZ  
 | JNZ  
 | RET  
 | AND  
 | OR  
 | XOR  
 | SHL  
 | SHR  
 | SAR

binds :
  | ID EQUAL expr { [($1, $3, (Parsing.rhs_start_pos 1, Parsing.rhs_end_pos 1))] }
  | ID EQUAL expr COMMA binds { ($1, $3, (Parsing.rhs_start_pos 1, Parsing.rhs_end_pos 1))::$5 }

instruction:
  | IAND const COMMA const { EPrim2(And, $2, $4, (Parsing.symbol_start_pos (), Parsing.symbol_end_pos ())) }

binop_expr :
  | prim1 LPARENNOSPACE expr RPAREN { EPrim1($1, $3, (Parsing.symbol_start_pos (), Parsing.symbol_end_pos ())) }
  | ID LPARENNOSPACE exprs RPAREN { EApp($1, $3, (Parsing.symbol_start_pos (), Parsing.symbol_end_pos ())) }
  | ID LPARENNOSPACE RPAREN { EApp($1, [], (Parsing.symbol_start_pos (), Parsing.symbol_end_pos ())) }
  | LPARENSPACE expr RPAREN { $2 }
  | LPARENNOSPACE expr RPAREN { $2 }
  | binop_expr PLUS binop_expr { EPrim2(Plus, $1, $3, (Parsing.symbol_start_pos (), Parsing.symbol_end_pos ())) }
  | binop_expr MINUS binop_expr { EPrim2(Minus, $1, $3, (Parsing.symbol_start_pos (), Parsing.symbol_end_pos ())) }
  | binop_expr TIMES binop_expr { EPrim2(Times, $1, $3, (Parsing.symbol_start_pos (), Parsing.symbol_end_pos ())) }
  | binop_expr AND binop_expr { EPrim2(And, $1, $3, (Parsing.symbol_start_pos (), Parsing.symbol_end_pos ())) }
  | binop_expr OR binop_expr { EPrim2(Or, $1, $3, (Parsing.symbol_start_pos (), Parsing.symbol_end_pos ())) }
  | binop_expr GREATER binop_expr { EPrim2(Greater, $1, $3, (Parsing.symbol_start_pos (), Parsing.symbol_end_pos ())) }
  | binop_expr GREATEREQ binop_expr { EPrim2(GreaterEq, $1, $3, (Parsing.symbol_start_pos (), Parsing.symbol_end_pos ())) }
  | binop_expr LESS binop_expr { EPrim2(Less, $1, $3, (Parsing.symbol_start_pos (), Parsing.symbol_end_pos ())) }
  | binop_expr LESSEQ binop_expr { EPrim2(LessEq, $1, $3, (Parsing.symbol_start_pos (), Parsing.symbol_end_pos ())) }
  | binop_expr EQEQ binop_expr { EPrim2(Eq, $1, $3, (Parsing.symbol_start_pos (), Parsing.symbol_end_pos ())) }
  | const { $1 }
  | ID { EId($1, (Parsing.symbol_start_pos (), Parsing.symbol_end_pos ())) }
  | instruction { $1 }

expr :
  | LET binds IN expr { ELet($2, $4, (Parsing.symbol_start_pos (), Parsing.symbol_end_pos ())) }
  | IF expr COLON expr ELSECOLON expr { EIf($2, $4, $6, (Parsing.symbol_start_pos (), Parsing.symbol_end_pos ())) }
  | binop_expr { $1 }

exprs :
  | expr { [$1] }
  | expr COMMA exprs { $1::$3 }

decl :
  | DEF ID LPARENNOSPACE RPAREN COLON expr { DFun($2, [], $6, (Parsing.symbol_start_pos (), Parsing.symbol_end_pos ())) }
  | DEF ID LPARENNOSPACE ids RPAREN COLON expr { DFun($2, $4, $7, (Parsing.symbol_start_pos (), Parsing.symbol_end_pos ())) }

ids :
  | ID { [$1, (Parsing.symbol_start_pos (), Parsing.symbol_end_pos ())] }
  | ID COMMA ids { ($1, (Parsing.rhs_start_pos 1, Parsing.rhs_end_pos 1))::$3 }

decls :
  | decl { [$1] }
  | decl decls { $1::$2 }

program :
  | decls expr EOF { Program($1, $2, (Parsing.symbol_start_pos (), Parsing.symbol_end_pos ())) }
  | expr EOF { Program([], $1, (Parsing.symbol_start_pos (), Parsing.symbol_end_pos ())) }

%%
