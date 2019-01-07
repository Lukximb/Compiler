all: flex.l bison.y
	bison -d bison.y
	flex -o flex.lex.c flex.l
	clang++ -Wno-everything -std=c++11 -o run_compiler bison.tab.c flex.lex.c
	cat program0.imp | ./run_compiler


clean:
	rm flex.lex.c
	rm bison.tab.c
	rm bison.tab.h
	rm run_compiler