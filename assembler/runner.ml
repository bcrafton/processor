open Unix
open Filename
open Str
open Compile
open Printf
open OUnit2
open ExtLib
open Lexing
open Types
open Pretty
       
let either_printer e =
  match e with
  | Left(v) -> sprintf "Error: %s\n" v
  | Right(v) -> v

let string_of_position p =
  sprintf "%s:line %d, col %d" p.pos_fname p.pos_lnum (p.pos_cnum - p.pos_bol);;

let parse name lexbuf =
  try 
    lexbuf.lex_curr_p <- { lexbuf.lex_curr_p with pos_fname = name };
    Parser.section Lexer.token lexbuf
  with
  |  Failure "lexing: empty token" ->
      failwith (sprintf "lexical error at %s"
                        (string_of_position lexbuf.lex_curr_p))

let parse_file name input_file = 
  let lexbuf = Lexing.from_channel input_file in
  parse name lexbuf

(*
let compile_file_to_string name input_file =
  let input_program = parse_file name input_file in
  (compile_to_string input_program);;
*)

let assemble_file_to_string name input_file : string = 
  let sect = parse_file name input_file in
  match sect with 
  | Section(il) ->
    (assemble_to_string []);;

let print_errors exns =
  List.map (fun e ->
      match e with
      | UnboundId(x, loc) ->
         sprintf "The identifier %s, used at <%s>, is not in scope" x (string_of_pos loc)
      | UnboundFun(x, loc) ->
         sprintf "The function name %s, used at <%s>, is not in scope" x (string_of_pos loc)
      | ShadowId(x, loc, existing) ->
         sprintf "The identifier %s, defined at <%s>, shadows one defined at <%s>"
                 x (string_of_pos loc) (string_of_pos existing)
      | DuplicateId(x, loc, existing) ->
         sprintf "The identifier %s, redefined at <%s>, duplicates one at <%s>"
                 x (string_of_pos loc) (string_of_pos existing)
      | DuplicateFun(x, loc, existing) ->
         sprintf "The function name %s, redefined at <%s>, duplicates one at <%s>"
                 x (string_of_pos loc) (string_of_pos existing)
      | Overflow(num, loc) ->
         sprintf "The number literal %d, used at <%s>, is not supported in this language"
                 num (string_of_pos loc)
      | Arity(expected, actual, loc) ->
         sprintf "The function called at <%s> expected an arity of %d, but received %d arguments"
                 (string_of_pos loc) expected actual
      | _ ->
         sprintf "%s" (Printexc.to_string e)
    ) exns
;;
