open Assemble
open Runner
open Printf
open Lexing
open Types
open Str

let () =

  let code_tests = [

    "a.bc.s";
    "b.bc.s";

    "fib0.bc.s";
    "fib1.bc.s";
    "fib2.bc.s";
    "fib3.bc.s";
    "fib4.bc.s";
    "fib5.bc.s";
 
  ] in

  let asm_tests = [

    "push.s";
    "pop.s";
    "push1.s";
    
  ] in

  let asm_in = "../test/programs/asm/asm/" in 
  let asm_out = "../test/programs/asm/bin/" in
  let asm_debug = "../test/programs/asm/mips/" in

  let compiled_in = "../test/programs/code/asm/" in 
  let compiled_out = "../test/programs/code/bin/" in
  let compiled_debug = "../test/programs/code/mips/" in

  let assemble (names : string list) (in_dir : string) (out_dir : string) (debug_dir : string) =

    let help (name : string) = 
        let input_file = open_in (in_dir ^ name) in

        let (bin, debug) = assemble name input_file in
        
        let outfile = open_out (out_dir ^ name ^ ".hex") in
        fprintf outfile "%s" bin;
        close_out outfile;

        let debug_out = open_out (debug_dir ^ name ^ ".d") in
        fprintf debug_out "%s" debug;
        close_out debug_out;
        
    in

    List.iter help names;

  in

  (assemble asm_tests asm_in asm_out asm_debug); 
  (assemble code_tests compiled_in compiled_out compiled_debug);

