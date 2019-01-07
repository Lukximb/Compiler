%{
	#include <stdio.h>
	// #include <stdlib.h>
    #include <string>
    #include <iostream>
    #include <vector>
    #include <map>
    using namespace std;

	int yylex(void);
	void yyerror(char *);

	// extern int yylineno;


// ========= STRUCT DECLARATION =============
	
    struct ast {
        string type;        // node type ex. program, declarations
        struct ast* s_1;    // first son
        struct ast* s_2;    // second son
        struct ast* s_3;
        struct ast* s_4;
        string value;       // string value or identifier ex for, wgile, ifelse
        int number;         // int value
    };

    struct array_object {
        string id;
        int start;
        int end;
    };

    enum variable_label {
        variable = 0,
        registry = 1,
        array = 2,
        constant = 3
    };

    struct variable {
        variable_label label;
        string id_1;
        string id_2;
        int value;
    };

    struct precode_object {
        string label;
        struct variable* var_1;
        struct variable* var_2;
    };

    struct precode_block {
        struct precode_block* previous;
        struct precode_block* next;
        vector<struct precode_object*> precode_list;
        int length;
    };



// ========= STRUCT CONSTRUCTOR DECLARATION =============

    struct ast* newast(
        string type, 
        struct ast* s_1, 
        struct ast* s_2, 
        struct ast* s_3, 
        struct ast* s_4,
        string value,
        int number
    );

    struct array_object* new_array_obj(
        string id,
        int start,
        int end
    );

    struct variable* new_variable(
        variable_label label,
        string id_1,
        string id_2,
        int value
    );

    struct precode_object* new_precode_obj(
        string label,
        struct variable* var_1,
        struct variable* var_2
    );

    struct precode_block* new_precode_block(
        struct precode_block* previous,
        struct precode_block* next,
        vector<struct precode_object*> precode_list,
        int length
    );



// ========= VARIABLE DECLARATION =============
    map<string, int> variables;                                             // all declared variables
    map<string, struct array_object*> arrays;                               // all declared arrays
    string registries[8] = {"A", "B", "C", "D", "E", "F", "G", "H"};        // all available registries


// ========= FUNCTION DECLARATION =============

    void handle_program(struct ast* root);
    int semantic_analyse(struct ast* root);
    // struct block* create_condition(struct ast* condition);
    // string create_value(struct ast* value);
%}

%union {
    struct ast* a;
	char* str;
	int number;
	// variable var;
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
    // 	HALT();
    // 	printToFile("wynik.txt");
    }
;

declarations: 
	declarations ID';'  	{
        cout << "declarations ID: " << $2 << endl;
        struct ast* id = newast(string("ID"), NULL, NULL, NULL, NULL, $2, 0);
        $$ = newast("DECLARATIONS", $1, id, NULL, NULL, "DECVAR", 0);
    }
|	declarations ID'('NUM':'NUM')'  {
        struct ast* id = newast("ID", NULL, NULL, NULL, NULL, $2, 0);
        struct ast* num1 = newast("NUM", NULL, NULL, NULL, NULL, "EMPTY", $4);
        struct ast* num2 = newast("NUM", NULL, NULL, NULL, NULL, "EMPTY", $6);
        $$ = newast("DECLARATIONS", $1, id, num1, num2, "DEACARR", 0);
    }
|       {$$ = newast("NULL", NULL, NULL, NULL, NULL, "NULL", 0);}
;

commands:
	commands command    {
        $$ = newast("COMMANDS", $1, $2, NULL, NULL, "EMPTY", 0);
    }
|	command     {
        $$ = newast("COMMANDS", $1, NULL, NULL, NULL, "EMPTY", 0);
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
        $$ = newast("VALUE", num, NULL, NULL, NULL, "EMPTY", 0);
    }
|	identifier  {
        $$ = newast("VALUE", $1, NULL, NULL, NULL, "EMPTY", 0);
    }
;

identifier:
	ID  {
        struct ast* id = newast(string("ID"), NULL, NULL, NULL, NULL, string($1), 0);
        // cout << "bison: identifier" << endl;
        $$ = newast("IDENTIFIER1", id, NULL, NULL, NULL, "EMPTY", 0);
    }
|	ID'('ID')'  {
        struct ast* id1 = newast("ID", NULL, NULL, NULL, NULL, $1, 0);
        struct ast* id2 = newast("ID", NULL, NULL, NULL, NULL, $2, 0);
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
    printf("Compilation finished successfully\n");
}

void yyerror(char *s) {
	// finishCompilation();
	fprintf(stderr, "Error:%s.\n", s);
	exit(1);
}

struct ast* newast(string type, 
        struct ast* s_1, 
        struct ast* s_2, 
        struct ast* s_3, 
        struct ast* s_4,
        string value,
        int number) {

    // cout << "type: " << type << " value: " << value << endl;
    struct ast* a = (struct ast*)malloc(sizeof(struct ast));
    
    if (!a) {
        cout << "ERR: out of space" << endl;
        yyerror("Err: out of space\n");
        exit(1);
    }
    a->type = type;
    a->s_1 = s_1;
    a->s_2 = s_2;
    a->s_3 = s_3;
    a->s_4 = s_4;
    a->value = value;
    a->number = number;
    return a;
}

struct array_object* new_array_obj(
        string id,
        int start,
        int end) {
    struct array_object* arr = (struct array_object*)malloc(sizeof(struct array_object));
    
    if (!arr) {
        cout << "ERR: arr out of space" << endl;
        yyerror("Err: out of space\n");
        exit(1);
    }
    arr->id = id;
    arr->start = start;
    arr->end = end;

    return arr;
}

struct variable* new_variable(variable_label label,
        string id_1,
        string id_2,
        int value) {
    struct variable* var = (struct variable*)malloc(sizeof(struct variable));
    
    if (!var) {
        cout << "ERR: var out of space" << endl;
        yyerror("Err: out of space\n");
        exit(1);
    }
    var->label = label;
    var->id_1 = id_1;
    var->id_2 = id_2;
    var->value = value;

    return var;
}

struct precode_object* new_precode_obj(
        string label,
        struct variable* var_1,
        struct variable* var_2) {
    struct precode_object* code = (struct precode_object*)malloc(sizeof(struct precode_object));
    
    if (!code) {
        cout << "ERR: code out of space" << endl;
        yyerror("Err: code out of space\n");
        exit(1);
    }
    code->label = label;
    code->var_1 = var_1;
    code->var_2 = var_2;

    return code;
}

struct precode_block* new_precode_block(
        struct precode_block* previous,
        struct precode_block* next,
        vector<struct precode_object*> precode_list,
        int length) {
    struct precode_block* block = (struct precode_block*)malloc(sizeof(struct precode_block));
    
    if (!block) {
        cout << "ERR: block out of space" << endl;
        yyerror("Err: block out of space\n");
        exit(1);
    }
    block->previous = previous;
    block->next = next;
    block->precode_list = precode_list;
    block->length = length;

    return block;
}

// struct block* new_block() {
//     struct block* block = (struct block*)malloc(sizeof(struct block));

//     if (!block) {
//         cout << "Err: block out of space" << endl;
//         yyerror("Err: block out of space\n");
//         exit(1);
//     }
//     block->prev_block = NULL;
//     block->next_block = NULL;
//     // block->vector = s_2;
//     block->length = 0;
//     return block;
// }

void handle_program(struct ast* root) {
    int result = semantic_analyse(root);
    if (result != 1) {
        cout << "Semantic Error" << endl;
        return;
    }
    // cout << "condition" << endl;
    // create_condition(root);
    cout << "handle program" << endl;
}

int semantic_analyse(struct ast* root) {
    cout << "do semantic analyse..." << endl;
    return 1;
}

// void create_if(struct ast* node) {
//     // warunek
//     // tworzenie jumpow
//     // wywolanie stwoerzenia instrukcji wew.
//     // tworzenie zakonczen


// }

// void create_ifelse(struct ast* node) {

// }

// struct block* create_condition(struct ast* condition) {
//     // condition (s_1 value s_2)
//     struct block* block = new_block();

//     if (string(condition->value).compare(">") == 0) {
//         block->codes.push_back(create_value(condition->s_2) + "<" + create_value(condition->s_1));
//     } else if (string(condition->value).compare(">") == 0) {
//         block->codes.push_back(create_value(condition->s_2) + "<" + create_value(condition->s_1));
//     }
//     cout << condition->value << "@" << endl;
//     // cout << block->codes[0] << endl;
//     return block;
// }

// string create_value(struct ast* value) {
//     if ((value->s_1->type).compare("NUM")) {
//         return string(to_string(value->s_1->number));
//     } else if ((value->s_1->type).compare("IDENTIFIER1")) {
//         return string(value->s_1->s_1->value);
//     } else if ((value->s_1->type).compare("IDENTIFIER2")) {
//         return string(value->s_1->s_1->value + "(" + value->s_1->s_2->value + ")");
//     } else {
//         return string(value->s_1->s_1->value + "(" + string(to_string(value->s_1->s_2->number)) + ")");
//     }
// }
