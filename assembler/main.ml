open Assemble
open Runner
open Printf
open Lexing
open Types
       
let () =
  let name = Sys.argv.(1) in
  let input_file = open_in name in
  let program = assemble_file_to_string name input_file in
  printf "%s\n" program;;

