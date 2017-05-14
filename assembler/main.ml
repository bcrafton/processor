open Assemble
open Runner
open Printf
open Lexing
open Types

let () =

  let src_dir = "../test/programs/assembly/src/" in 
  let compiled_dir = "../test/programs/assembly/compiled/" in

  let out_dir = "../test/programs/binary/assembled/" in

  let assemble_src (name : string) = 
    let input_file = open_in (src_dir ^ name) in
    let program = assemble_file_to_string name input_file in
    let outfile = open_out (out_dir ^ name ^ ".hex") in
    fprintf outfile "%s" program
  in

  let assemble_compiled (name : string) = 
    let input_file = open_in (compiled_dir ^ name) in
    let program = assemble_file_to_string name input_file in
    let outfile = open_out (out_dir ^ name ^ ".hex") in
    fprintf outfile "%s" program
  in
  
  let src_filenames = Sys.readdir(src_dir) in
  Array.iter assemble_src src_filenames;

  let compiled_filenames = Sys.readdir(compiled_dir) in
  Array.iter assemble_compiled compiled_filenames;
