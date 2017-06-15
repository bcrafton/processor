open Compile
open Runner
open Printf
open Lexing
open Types
open Str

let () =

  let code_tests = [

    "a.bc";
    "b.bc";
    "fn_add.bc";
    "if_false.bc";
    "if_true.bc";

    "fib0.bc";
    "fib1.bc";
    "fib2.bc";
    "fib3.bc";
    "fib4.bc";
    "fib5.bc";
    "fib10.bc";

    "to_10.bc";

    "plus1.bc";

    "tuple1.bc";
    "tuple2.bc";
    "nested_tuple.bc";
    "tuple3.bc";

    "list.bc";
    "linked_list.bc";
    
  ] in

  let code_in = "../test_bench/programs/code/code/" in 
  let code_out = "../test_bench/programs/code/asm/" in

  let compile (in_dir : string) (out_dir : string) = 

    let help (name : string) = 
      let input_file = open_in (in_dir ^ name) in
      let result = compile_file_to_string name input_file in
      match result with
      | Left errs ->
         printf "Errors:\n%s\n" (ExtString.String.join "\n" (print_errors errs))
      | Right program -> 
        let outfile = open_out (out_dir ^ name ^ ".s") in
        fprintf outfile "%s" program;
        close_out outfile;
    in

    List.iter help code_tests

  in
  
  (compile code_in code_out);

  

