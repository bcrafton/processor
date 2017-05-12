open Compile
open Runner
open Printf
open Lexing
open Types
       
let () =
  let name = Sys.argv.(1) in
  let input_file = open_in name in

(* the output of this program is written to a file in the make file *)

(*
  match compile_file_to_string name input_file with
  | Left errs ->
     printf "Errors:\n%s\n" (ExtString.String.join "\n" (print_errors errs))
  | Right program -> printf "%s\n" program;;
*)

  let program = assemble_file_to_string name input_file in
  printf "%s\n" program;;

