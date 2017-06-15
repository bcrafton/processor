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
    "fn_add.bc.s";
    "if_false.bc.s";
    "if_true.bc.s";

    "fib0.bc.s";
    "fib1.bc.s";
    "fib2.bc.s";
    "fib3.bc.s";
    "fib4.bc.s";
    "fib5.bc.s";
    "fib10.bc.s";

    "to_10.bc.s";

    "plus1.bc.s";

    "tuple1.bc.s";
    "tuple2.bc.s";
    "nested_tuple.bc.s";
    "tuple3.bc.s";

    "list.bc.s";
    "linked_list.bc.s";
 
  ] in

  let asm_tests = [
    "mov.s";
    "push.s";
    "pop.s";
    "push1.s";
    "plus1_asm.s";
    "branch_predict.s"
    
  ] in

  let asm_in = "../test_bench/programs/asm/asm/" in 
  let asm_out = "../test_bench/programs/asm/bin/" in
  let asm_mips = "../test_bench/programs/asm/mips/" in

  let compiled_in = "../test_bench/programs/code/asm/" in 
  let compiled_out = "../test_bench/programs/code/bin/" in
  let compiled_mips = "../test_bench/programs/code/mips/" in

  let assemble (names : string list) (in_dir : string) (out_dir : string) (mips_dir : string) =

    let help (name : string) = 
        let input_file = open_in (in_dir ^ name) in

        let (bin, mips) = assemble name input_file in
        
        let outfile = open_out (out_dir ^ name ^ ".hex") in
        fprintf outfile "%s" bin;
        close_out outfile;

        let mips_out = open_out (mips_dir ^ name ^ ".m") in
        fprintf mips_out "%s" mips;
        close_out mips_out;
        
    in

    List.iter help names;

  in

  (assemble asm_tests asm_in asm_out asm_mips); 
  (assemble code_tests compiled_in compiled_out compiled_mips);

