%{
    #include "structures/struct.h"
    #include "precodes/auxiliary_functions.h"
    #include "precodes/function_handlers.h"
    #include "asm/asm.h"
    #include "program/program_functions.h"

    using namespace std;

	int yylex(void);
	void yyerror(char *);

	// extern int yylineno;
%}

%union {
    struct ast* a;
	char* str;
	int number;
}

%token <str> DECLARE IN END
%token <str> IF THEN ELSE ENDIF
%token <str> WHILE DO ENDWHILE ENDDO
%token <str> FOR FROM TO DOWNTO ENDFOR
%token <str> READ WRITE
%token <str> ASSIGN
%token <str> '+' '-' '*' '/' '%'
%token <str> EQ NEQ LT GT LTE GTE
%token <str> '(' ')' ';'
%token <str> ID
%token <number> NUM

%type <a> program
%type <a> declarations
%type <a> commands
%type <a> command
%type <a> expression
%type <a> condition
%type <a> value
%type <a> identifier

%%

program: 
	DECLARE declarations IN commands END    {
        $$ = newast("PROGRAM", $2, $4, NULL, NULL, "EMPTY", 0);
        handle_program($$);
    }
;

declarations: 
	declarations ID';'  	{
        struct ast* id = newast(string("ID"), NULL, NULL, NULL, NULL, $2, 0);
        $$ = newast("DECLARATIONS", $1, id, NULL, NULL, "DECVAR", 0);
    }
|	declarations ID'('NUM':'NUM')'  {
        struct ast* id = newast("ID", NULL, NULL, NULL, NULL, $2, 0);
        struct ast* num1 = newast("NUM", NULL, NULL, NULL, NULL, "EMPTY", $4);
        struct ast* num2 = newast("NUM", NULL, NULL, NULL, NULL, "EMPTY", $6);
        $$ = newast("DECLARATIONS", $1, id, num1, num2, "DECARR", 0);
    }
|       {$$ = newast("NULL", NULL, NULL, NULL, NULL, "NULL", 0);}
;

commands:
	commands command    {
        $$ = newast("COMMANDS", $1, $2, NULL, NULL, "EMPTY", 0);
    }
|	command     {
        $$ = newast("COMMANDS1", $1, NULL, NULL, NULL, "EMPTY", 0);
    }
;

command:
	identifier ASSIGN expression';' {
        $$ = newast("COMMAND", $1, $3, NULL, NULL, "ASSIGN", 0);
    }
|	IF condition THEN commands ELSE commands ENDIF  {
        $$ = newast("COMMAND", $2, $4, $6, NULL, "IFELSE", 0);
    }
|	IF condition THEN commands ENDIF    {
        $$ = newast("COMMAND", $2, $4, NULL, NULL, "IF", 0);
    }
|	WHILE condition DO commands ENDWHILE    {
        $$ = newast("COMMAND", $2, $4, NULL, NULL, "WHILE", 0);
    }
|	DO commands WHILE condition ENDDO   {
        $$ = newast("COMMAND", $2, $4, NULL, NULL, "DOWHILE", 0);
    } 
|	FOR ID FROM value TO value DO commands ENDFOR   {
        struct ast* id = newast("ID", NULL, NULL, NULL, NULL, $2, 0);
        $$ = newast("COMMAND", id, $4, $6, $8, "FORTO", 0);
    }
|	FOR ID FROM value DOWNTO value DO commands ENDFOR   {
        struct ast* id = newast("ID", NULL, NULL, NULL, NULL, $2, 0);
        $$ = newast("COMMAND", id, $4, $6, $8, "FORDOWNTO", 0);
    }
|	READ identifier';'  {
        $$ = newast("COMMAND", $2, NULL, NULL, NULL, "READ", 0);
    }
|	WRITE value';'      {
        $$ = newast("COMMAND", $2, NULL, NULL, NULL, "WRITE", 0);
    }
;

expression:
	value   {
        $$ = newast("EXPRESSION", $1, NULL, NULL, NULL, "EMPTY", 0);
    }
|	value '+' value     {
        $$ = newast("EXPRESSION", $1, $3, NULL, NULL, "+", 0);
    }
|	value '-' value     {
        $$ = newast("EXPRESSION", $1, $3, NULL, NULL, "-", 0);
    }
|	value '*' value     {
        $$ = newast("EXPRESSION", $1, $3, NULL, NULL, "*", 0);
    }
|	value '/' value     {
        $$ = newast("EXPRESSION", $1, $3, NULL, NULL, "/", 0);
    }
|	value '%' value     {
        $$ = newast("EXPRESSION", $1, $3, NULL, NULL, "%", 0);
    }
;

condition:
	value EQ value     {
        $$ = newast("CONDITION", $1, $3, NULL, NULL, "=", 0);
    }
|	value NEQ value     {
        $$ = newast("CONDITION", $1, $3, NULL, NULL, "!=", 0);
    }
|	value LT value     {
        $$ = newast("CONDITION", $1, $3, NULL, NULL, "<", 0);
    }
|	value GT value     {
        $$ = newast("CONDITION", $1, $3, NULL, NULL, ">", 0);
    }
|	value LTE value     {
        $$ = newast("CONDITION", $1, $3, NULL, NULL, "<=", 0);
    }
|	value GTE value     {
        $$ = newast("CONDITION", $1, $3, NULL, NULL, ">=", 0);
    }
;

value:
	NUM     {
        struct ast* num = newast("NUM", NULL, NULL, NULL, NULL, "EMPTY", $1);
        $$ = newast("NUM", num, NULL, NULL, NULL, "EMPTY", 0);
    }
|	identifier  {
        $$ = newast("VALUE", $1, NULL, NULL, NULL, "EMPTY", 0);
    }
;

identifier:
	ID  {
        struct ast* id = newast(string("ID-"), NULL, NULL, NULL, NULL, string($1), 0);
        $$ = newast("IDENTIFIER1", id, NULL, NULL, NULL, "EMPTY", 0);
    }
|	ID'('ID')'  {
        struct ast* id1 = newast("ID", NULL, NULL, NULL, NULL, $1, 0);
        struct ast* id2 = newast("ID", NULL, NULL, NULL, NULL, $3, 0);
        $$ = newast("IDENTIFIER2", id1, id2, NULL, NULL, "EMPTY", 0);
    }
|	ID'('NUM')' {
        struct ast* id = newast("ID", NULL, NULL, NULL, NULL, $1, 0);
        struct ast* num = newast("NUM", NULL, NULL, NULL, NULL, "EMPTY", $3);
        $$ = newast("IDENTIFIER3", id, num, NULL, NULL, "EMPTY", 0);
    }
;

%%


int main(int argc, char **argv) {
	// initializeCompilation();
    yyparse();
    // finishCompilation();
    // printf("Compilation finished successfully\n");
}

void yyerror(char *s) {
	fprintf(stderr, "Error:%s.\n", s);
	exit(1);
}
