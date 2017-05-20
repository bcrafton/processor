open Unix
open Filename
open Str
open Assemble
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

let assemble name input_file : (string * string) = 
  let sect = parse_file name input_file in
  match sect with 
  | Section(il) ->
    let bin = (to_bin il) in
    let asm = (to_asm il) in
    (bin, asm)

