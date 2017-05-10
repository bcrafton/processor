open Compile
open Runner
open Printf
open OUnit2
open Pretty
open Types
       
let is_osx = Conf.make_bool "osx" false "Set this flag to run on osx";;

let t name program expected = name>::test_run program name expected;;

let ta name program expected = name>::test_run_anf program name expected;;

let te name program expected_err = name>::test_err program name expected_err;;

let tvg name program expected = name>::test_run_valgrind program name expected;;
  
let tanf name program expected = name>::fun _ ->
  assert_equal expected (anf (tag program)) ~printer:string_of_aprogram;;

let teq name actual expected = name>::fun _ ->
  assert_equal expected actual ~printer:(fun s -> s);;

let tests = [ 

t "a" 
"if true: 10 else: 5"
"10";

]

let suite =
"suite">:::tests
 

let () =
  run_test_tt_main suite
;;

