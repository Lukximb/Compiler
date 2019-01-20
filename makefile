all: compile run clean

run:
	# cat examples/program1.imp | ./run_compiler > examples/res.mr
	# ./machine/maszyna-rejestrowa examples/res.mr

	cat test/$(FILE).imp | ./run_compiler > test/results/$(FILE).mr
	./machine/maszyna-rejestrowa test/results/$(FILE).mr

compile: flex.l bison.y
	bison -d bison.y
	flex -o flex.lex.c flex.l
	clang++ -std=c++17 -c structures/struct.c
	clang++ -std=c++17 -c precodes/auxiliary_functions.c
	clang++ -std=c++17 -c precodes/function_handlers.c
	clang++ -std=c++17 -c program/program_functions.c
	clang++ -std=c++17 -c asm/asm.c
	clang++ -Wno-everything \
	-std=c++17 \
	-o run_compiler \
	struct.o \
	auxiliary_functions.o \
	function_handlers.o \
	asm.o \
	program_functions.o \
	bison.tab.c \
	flex.lex.c

clean:
	rm flex.lex.c
	rm bison.tab.c
	rm bison.tab.h
	# rm run_compiler
	rm struct.o
	rm auxiliary_functions.o
	rm function_handlers.o
	rm program_functions.o
	rm asm.o