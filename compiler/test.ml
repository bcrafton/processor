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

let prog = Program([], EPrim2(Plus, ENumber((1), (0,0)), ENumber((2), (0,0)), (0,0)), (0,0));;
let aprog = AProgram([], ACExpr(CPrim2(Plus, ImmNum((1), ()), ImmNum((2), ()), ())), ());;

let func = DFun("f", [("x", (0,0)); ("y", (0,0))], EPrim2(Plus, ENumber((1), (0,0)), ENumber((2), (0,0)), (0,0)), (0,0));;
let afunc = ADFun("f", ["x"; "y"], ACExpr(CPrim2(Plus, ImmNum((1), ()), ImmNum((2), ()), ())), ());;

let prog1 = Program([], EPrim2(Plus, ENumber((1), (0,0)), ENumber((2), (0,0)), (0,0)), (0,0));;
let aprog1 = AProgram([], ACExpr(CPrim2(Plus, ImmNum((1), ()), ImmNum((2), ()), ())), ());;

let tests = [ 

t "given" 
"def f(x, y):
  x + y

f(1, 2)"
"3";

(* f1 *)
t "f1" 
"def f(x, y):
  x + y

let x=10, y=5 in f(x, y)"
"15";

(* f2 *)
t "f2" 
"def f(x, y):
  x + y

let x=10, y=5 in (x + f(x, y))"
"25";

(* f3 *)
t "f3" 
"def f(x, y):
  x + y

let x=10, y=f(x,10) in (f(y, x) + f(x, y))"
"60";

(* fib1 *)
t "fib1" 
"def f(n):
  if n == 0:
    0
  else:
    if n == 1:
      1
    else:
      f(n - 1) + f(n - 2)

f(10)"
"55";

(* fib2 *)
t "fib2" 
"def f(n):
  if n == 0:
    0
  else:
    if n == 1:
      1
    else:
      f(n - 1) + f(n - 2)

f(33)"
"3524578";


te "well_formed1"
"def f(x, x):
  x + 1

f(1)"
"Error";

te "well_formed2"
"def f(x, x):
  x + 1

def f(x, y):
  x + y

f(1)"
"Error";

te "well_formed3"
"def f(x, y):
  x + y

f(1)"
"Error";

te "well_formed4"
"def f(x, y):
  x + y

g(1, 2)"
"3";


tanf "anf1" prog aprog;
tanf "anf2" prog1 aprog1;

(* old tests *)
t "print" "print(10)" "10\n10";
t "print_problem" "let x = print(10) in x" "10\n10";

t "stack1" "if true: 
              let x = print(100), y = print(50), z = 25 in x+y+print(z)
            else: 
              100"
"100\n50\n25\n175";

t "stack2" "print(print(print(10)))" "10\n10\n10\n10";
t "stack3" "let x = 10, y=50, z=100 in
              if print(x) > z:
                print(x)
              else:
                let a = 10, b = 20 in
                print(a)"
"10\n10\n10";

t "test_true" "true" "true";
t "test_false" "false" "false";

te "nan1" "add1(false)" "arithmetic expected a number";
te "nan2" "add1(true)" "arithmetic expected a number";

t "add4" "let x = print(10), y = print(10) in (x+y)" "10\n10\n20";
te "add5" "let x = print(10), y = print(10) in (x+true)" "arithmetic expected a number";
te "add6" "(true+false)" "arithmetic expected a number";

te "or1" "10 || true" "logic expected a boolean";
te "or2" "true || 10" "logic expected a boolean";

t "or3" "false || false" "false";
t "or4" "false || true" "true";
t "or5" "true || false" "true";
t "or6" "true || true" "true";

te "and1" "10 && true" "logic expected a boolean";
te "and2" "true && 10" "logic expected a boolean";

t "and3" "false && false" "false";
t "and4" "false && true" "false";
t "and5" "true && false" "false";
t "and6" "true && true" "true";

t "greater1" "10 > 5" "true";
t "greater2" "5 > 10" "false";
te "greater3" "5 > true" "comparison expected a number";

t "greaterequal1" "10 >= 5" "true";
t "greaterequal2" "5 >= 10" "false";
te "greaterequal3" "5 >= true" "comparison expected a number";
t "greaterequal4" "5 >= 5" "true";

t "less1" "10 < 5" "false";
t "less2" "5 < 10" "true";
te "less3" "5 < true" "comparison expected a number";

t "lessequal1" "10 <= 5" "false";
t "lessequal2" "5 <= 10" "true";
te "lessequal3" "5 <= true" "comparison expected a number";
t "lessequal4" "5 <= 5" "true";

t "equal1" "10 == 5" "false";
t "equal2" "5 == 5" "true";
te "equal3" "5 == true" "comparison expected a number";

te "if4" "if 1: 1 else: 0" "if expected a boolean";

t "if5" "if 10>5: 4 else: 2" "4";
t "if6" "if 5>10: 4 else: 2" "2";
t "if7" "if 10>5: 1 else: 0" "1";

t "not1" "!(true)" "false";
t "not2" "!(false)" "true";

t "let_if1" "let x = 10, y = 50 in if x > y: 50 else: 20" "20";
t "let_if2" "if true: 
               let x = 100, y = 50, z = 25 in x+y+z 
             else: 
               100"
  "175";

t "let_if3" "if false: \
               let x = 100, y = 50, z = 25 in x+y+z \
             else: \
               100"
  "100";

(* old tests *)
t "plus1" "let x=10, y=10 in x+y" "20";
t "plus2" "let x=10, y=10 in 10+10" "20";
t "plus3" "let x=10, y=10 in x+y+10+10" "40";
t "plus4" "1 + 2" "3";

t "minus1" "let x=10, y=10 in x - y" "0";
t "minus2" "let x=10, y=10 in 10 - 10" "0";

t "times1" "let x=10, y=10 in x*y" "100";
t "times2" "let x=10, y=10 in 10*10" "100";

t "let1" "let x=10 in x" "10";
t "let2" "let x=10, y=10 in x" "10";
t "let3" "let x = let y=10 in y in x" "10";

t "add1" "add1(20)" "21";
t "add2" "let x = add1(20) in x" "21";
t "add3" "add1(-4)" "-3";

t "if1" "if true: 4 else: 2" "4";
t "if2" "if false: 4 else: 2" "2";
t "if3" "if true: 1 else: 0" "1";
]

let suite =
"suite">:::tests
 



let () =
  run_test_tt_main suite
;;

