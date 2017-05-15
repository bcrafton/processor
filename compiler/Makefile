UNAME := $(shell uname)
ifeq ($(UNAME), Linux)
  FORMAT=aout
else
ifeq ($(UNAME), Darwin)
  FORMAT=macho
endif
endif

PKGS=oUnit,extlib,unix,str
BUILD=ocamlbuild -r -use-ocamlfind

main: *.ml parser.mly lexer.mll
	$(BUILD) -package $(PKGS) main.native
	mv main.native main

clean:
	rm -rf output/*.o output/*.s output/*.dSYM output/*.run *.log
	rm -rf _build/
	rm -f main test
