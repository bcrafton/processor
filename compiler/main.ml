open Compile
open Runner
open Printf
open Lexing
open Types
       
let () =

  let in_dir = "../test/programs/code/src/" in 
  let out_dir = "../test/programs/assembly/compiled/" in

  let compile (name : string) = 
    let input_file = open_in (in_dir ^ name) in
    match compile_file_to_string name input_file with
    | Left errs ->
       printf "Errors:\n%s\n" (ExtString.String.join "\n" (print_errors errs))
    | Right program -> 
      let outfile = open_out (out_dir ^ name ^ ".hex") in
      fprintf outfile "%s" program

  in
  
  let filenames = Sys.readdir(in_dir) in
  Array.iter compile filenames
  

