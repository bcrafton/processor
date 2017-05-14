open Compile
open Runner
open Printf
open Lexing
open Types
open Str

let () =

  let code_in = "../test/programs/code/code/" in 
  let code_out = "../test/programs/code/asm/" in

  let rec last (l : string list) = 
    match l with
    | [x] -> Some(x)
    | _::rest -> last rest
    | [] -> None
  in

  let compile (in_dir : string) (out_dir : string) = 

    let help (name : string) = 
      let s = (Str.split (regexp "\\.") name) in
      let ext = (last s) in 
      match ext with
      | Some("bc") ->
        let input_file = open_in (in_dir ^ name) in
        let result = compile_file_to_string name input_file in
        begin
        match result with
        | Left errs ->
           printf "Errors:\n%s\n" (ExtString.String.join "\n" (print_errors errs))
        | Right program -> 
          let outfile = open_out (out_dir ^ name ^ ".s") in
          fprintf outfile "%s" program
        end
      | _ -> ()
    in

    let filenames = Sys.readdir(in_dir) in
    Array.iter help filenames

  in
  
  (compile code_in code_out);

  

