open Assemble
open Runner
open Printf
open Lexing
open Types
open Str

let () =

  let asm_in = "../test/programs/asm/asm/" in 
  let asm_out = "../test/programs/asm/bin/" in
  let asm_debug = "../test/programs/asm/mips/" in

  let compiled_in = "../test/programs/code/asm/" in 
  let compiled_out = "../test/programs/code/bin/" in
  let compiled_debug = "../test/programs/code/mips/" in

  let rec last (l : string list) = 
    match l with
    | [x] -> Some(x)
    | _::rest -> last rest
    | [] -> None
  in

  let assemble (in_dir : string) (out_dir : string) (debug_dir : string) =

    let help (name : string) = 
      let s = (Str.split (regexp "\\.") name) in
      let ext = (last s) in 
      match ext with
      | Some("s") ->
        let input_file = open_in (in_dir ^ name) in

        let (bin, debug) = assemble name input_file in
        

        let outfile = open_out (out_dir ^ name ^ ".hex") in
        fprintf outfile "%s" bin;
        let debug_out = open_out (debug_dir ^ name ^ ".d") in
        fprintf debug_out "%s" debug
        
      | _ -> ()
    in

    let filenames = Sys.readdir(in_dir) in
    Array.iter help filenames;

  in

  (assemble asm_in asm_out asm_debug); 
  (assemble compiled_in compiled_out compiled_debug);

