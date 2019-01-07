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
        arr = 2,
        constant = 3,
        label = 4
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

    struct precode_block* new_precode_block(
        struct precode_block* previous,
        struct precode_block* next,
        int length
    );



// ========= VARIABLE DECLARATION =============
    map<string, int> variables;                                             // all declared variables
    map<string, struct array_object*> arrays;                               // all declared arrays
    string registries[8] = {"A", "B", "C", "D", "E", "F", "G", "H"};        // all available registries

    int label_iterator = 0;      
    struct precode_block* root_block = new_precode_block(NULL, NULL, 0);
    struct precode_block* current_block = root_block;                                             // global id for labels

// ========= FUNCTION DECLARATION =============

    void handle_program(struct ast* root);
    int semantic_analyse(struct ast* root);

    struct precode_block* create_commands(struct ast* node);
    struct precode_block* create_command(struct ast* node);
    vector<struct precode_object*> create_expression(struct ast* node, string reg);
    vector<struct precode_object*> create_condition(struct ast* node, struct variable* label);

    struct precode_block* create_assign(struct ast* node);
    struct precode_block* create_ifelse(struct ast* node);
    struct precode_block* create_if(struct ast* node);
    struct precode_block* create_while(struct ast* node);
    struct precode_block* create_dowhile(struct ast* node);
    struct precode_block* create_forto(struct ast* node);
    struct precode_block* create_fordownto(struct ast* node);
    struct precode_block* create_read(struct ast* node);
    struct precode_block* create_write(struct ast* node);

    struct precode_object* create_load(struct ast* node, string reg);
    struct precode_object* create_store(struct ast* node, string reg);
    struct variable* create_variable(struct ast* node);
    struct variable* get_new_label();

    void print_precode_obj(struct precode_object* obj);
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
    if (!id_1.empty()) {
        var->id_1 = id_1;
    }
    if (!id_2.empty()) {
        var->id_2 = id_2;
    }
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

struct precode_block* new_precode_block(
        struct precode_block* previous,
        struct precode_block* next,
        int length) {
    struct precode_block* block = (struct precode_block*)malloc(sizeof(struct precode_block));
    
    if (!block) {
        cout << "ERR: block out of space" << endl;
        yyerror("Err: block out of space\n");
        exit(1);
    }
    block->previous = previous;
    block->next = next;
    block->length = length;

    return block;
}

void handle_program(struct ast* root) {
    int result = semantic_analyse(root);
    if (result != 1) {
        cout << "Semantic Error" << endl;
        return;
    }
    struct precode_block* block = create_commands(root->s_2);
    cout << "handle program" << endl;

    while (NULL != block) {
        cout << "=== block ===" << endl;
        for (int i = 0; i < block->precode_list.size(); i++) {
            print_precode_obj(block->precode_list[i]);
        }
        block = block->next;
    }

}

int semantic_analyse(struct ast* root) {
    cout << "do semantic analyse..." << endl;
    return 1;
}


// ============ PRECODE CONSTRUCTORS ==================

struct precode_block* create_assign(struct ast* node) {
    string reg = "B";
    vector<struct precode_object*> precode_list = create_expression(node->s_2, reg);
    precode_list.push_back(create_store(node, reg));

    return new_precode_block(NULL, NULL, precode_list, precode_list.size());
}

struct precode_block* create_ifelse(struct ast* node) {
    return NULL;
}

struct precode_block* create_if(struct ast* node) {
    struct variable* label = get_new_label();
    vector<struct precode_object*> cond = create_condition(node->s_1, label);
    struct precode_block* commands = create_commands(node->s_2);

    struct precode_block* cond_block = new_precode_block(NULL, NULL, cond, cond.size());

    cond_block->next = commands;
    commands->previous = cond_block;
    
    struct precode_block* current_command = cond_block;
    while (current_command->next != NULL) {
        current_command = current_command->next;
    }

    (current_command->precode_list).push_back(new_precode_obj("LABEL", label, NULL));
    current_command->length++;

    return cond_block;
}

struct precode_block* create_while(struct ast* node) {
    return NULL;
}

struct precode_block* create_dowhile(struct ast* node) {
    return NULL;
}

struct precode_block* create_forto(struct ast* node) {
    return NULL;
}

struct precode_block* create_fordownto(struct ast* node) {
    return NULL;
}

struct precode_block* create_read(struct ast* node) {
    vector<struct precode_object*> precode_list;

    struct variable* reg_b = new_variable(variable_label(registry), "B", "", 0);
    precode_list.push_back(new_precode_obj("GET", reg_b, NULL));
    precode_list.push_back(create_store(node, "B"));

    return new_precode_block(NULL, NULL, precode_list, precode_list.size());
}

struct precode_block* create_write(struct ast* node) {
    vector<struct precode_object*> precode_list;

    struct variable* reg_b = new_variable(variable_label(registry), "B", "", 0);
    precode_list.push_back(create_load(node->s_1, "B"));
    precode_list.push_back(new_precode_obj("PUT", reg_b, NULL));

    return new_precode_block(NULL, NULL, precode_list, precode_list.size());
}





// ===== PRIVATE FUNCTIONS ================


struct precode_block* create_commands(struct ast* node) {
    struct precode_block* root = NULL;
    struct precode_block* block = NULL;

    if (node->s_2 != NULL) {
        root = create_command(node->s_2);
        block = create_commands(node->s_1);
    }else {
        root = create_command(node->s_1);
    }

    if (block != NULL) {
        struct precode_block* last_from_block = block;
        while (last_from_block->next != NULL) {
            last_from_block = last_from_block->next;
        }
        last_from_block->next = root;
        root->previous = block;
        return block;
    } else {
        return root;
    }
}

struct precode_block* create_command(struct ast* node) {
    if ((node->value).compare("ASSIGN") == 0) {
        return create_assign(node);
    } else if ((node->value).compare("IFELSE") == 0) {
        return create_ifelse(node);
    } else if ((node->value).compare("IF") == 0) {
        return create_if(node);
    } else if ((node->value).compare("WHILE") == 0) {
        return create_while(node);
    } else if ((node->value).compare("DOWHILE") == 0) {
        return create_dowhile(node);
    } else if ((node->value).compare("FORTO") == 0) {
        return create_forto(node);
    } else if ((node->value).compare("FORDOWNTO") == 0) {
        return create_fordownto(node);
    } else if ((node->value).compare("READ") == 0) {
        return create_read(node);
    } else if ((node->value).compare("WRITE") == 0) {
        return create_write(node);
    } else {
        return NULL;
        // return create_write(node);
    }
}

vector<struct precode_object*> create_condition(struct ast* node, struct variable* label) {
    vector<struct precode_object*> precode_list;

    struct variable* reg_b = new_variable(variable_label(registry), "B", "", 0);
    struct variable* reg_c = new_variable(variable_label(registry), "C", "", 0);
    struct variable* reg_d = new_variable(variable_label(registry), "D", "", 0);

    if ((node->value).compare("<") == 0) { // a < b; b - a; a -> C; b -> B
        precode_list.push_back(create_load(node->s_1, "C"));
        precode_list.push_back(create_load(node->s_2, "B"));
        precode_list.push_back(new_precode_obj("SUB", reg_b, reg_c));
        precode_list.push_back(new_precode_obj("JZERO", reg_b, label));
    } else if ((node->value).compare(">") == 0) { // a > b; b < a; a - b; a -> C; b -> B
        precode_list.push_back(create_load(node->s_1, "C"));
        precode_list.push_back(create_load(node->s_2, "B"));
        precode_list.push_back(new_precode_obj("SUB", reg_c, reg_b));
        precode_list.push_back(new_precode_obj("JZERO", reg_c, label));
    } else if ((node->value).compare("<=") == 0) { // a <= b; a - b; a -> B; b -> C
        struct variable* var = new_variable(variable_label(constant), "", "", 2);
        precode_list.push_back(create_load(node->s_1, "B"));
        precode_list.push_back(create_load(node->s_2, "C"));
        precode_list.push_back(new_precode_obj("SUB", reg_b, reg_c));
        precode_list.push_back(new_precode_obj("JZERO_2", reg_b, var));
        precode_list.push_back(new_precode_obj("JUMP", label, NULL));
    } else if ((node->value).compare(">=") == 0) { // a >= b; b <= a; b - a; b -> B; a -> C
        struct variable* var = new_variable(variable_label(constant), "", "", 2);
        precode_list.push_back(create_load(node->s_1, "C"));
        precode_list.push_back(create_load(node->s_2, "B"));
        precode_list.push_back(new_precode_obj("SUB", reg_b, reg_c));
        precode_list.push_back(new_precode_obj("JZERO_2", reg_b, var));
        precode_list.push_back(new_precode_obj("JUMP", label, NULL));
    } else if ((node->value).compare("=") == 0) { 
        // a == b; b == a; a - b; b - a; b -> B; a -> C,D
        struct variable* var = new_variable(variable_label(constant), "", "", 2);
        precode_list.push_back(create_load(node->s_1, "C"));
        precode_list.push_back(create_load(node->s_2, "B"));
        precode_list.push_back(new_precode_obj("COPY", reg_d, reg_c));
        precode_list.push_back(new_precode_obj("SUB", reg_c, reg_b));
        precode_list.push_back(new_precode_obj("JZERO_2", reg_c, var));
        precode_list.push_back(new_precode_obj("JUMP", label, NULL));
        precode_list.push_back(new_precode_obj("SUB", reg_b, reg_d));
        precode_list.push_back(new_precode_obj("JZERO_2", reg_b, var));
        precode_list.push_back(new_precode_obj("JUMP", label, NULL));
    } else if ((node->value).compare("=") == 0) { 
        // a == b; b == a; a - b; b - a; b -> B; a -> C,D
        struct variable* var = new_variable(variable_label(constant), "", "", 2);
        struct variable* comm = new_variable(variable_label(constant), "", "", 3); // jump to commands
        precode_list.push_back(create_load(node->s_1, "C"));
        precode_list.push_back(create_load(node->s_2, "B"));
        precode_list.push_back(new_precode_obj("COPY", reg_d, reg_c));
        precode_list.push_back(new_precode_obj("SUB", reg_c, reg_b));
        precode_list.push_back(new_precode_obj("JZERO_2", reg_c, var));
        precode_list.push_back(new_precode_obj("JUMP", comm, NULL));
        precode_list.push_back(new_precode_obj("SUB", reg_b, reg_d));
        precode_list.push_back(new_precode_obj("JZERO_2", reg_b, label));
    }
    
    return precode_list;
}

vector<struct precode_object*> create_expression(struct ast* node, string reg) {
    vector<struct precode_object*> precode_list;
    if ((node->value).compare("EMPTY") == 0) {
        precode_list.push_back(create_load(node->s_1, reg));
    } else {
        precode_list.push_back(create_load(node->s_1, reg));
        precode_list.push_back(create_load(node->s_2, "C"));

        struct variable* reg_1 = new_variable(variable_label(registry), reg, "", 0);
        struct variable* reg_2 = new_variable(variable_label(registry), "C", "", 0);
        
        if ((node->value).compare("+") == 0) {
            precode_list.push_back(new_precode_obj("ADD", reg_1, reg_2));
        } else if ((node->value).compare("-") == 0) {
            precode_list.push_back(new_precode_obj("SUB", reg_1, reg_2));
        } else if ((node->value).compare("*") == 0) {
            precode_list.push_back(new_precode_obj("L_MULT", reg_1, reg_2));
        } else if ((node->value).compare("/") == 0) {
            precode_list.push_back(new_precode_obj("L_DIV", reg_1, reg_2));
        } else if ((node->value).compare("%") == 0) {
            precode_list.push_back(new_precode_obj("L_MOD", reg_1, reg_2));
        }
    }
    return precode_list;
}

struct precode_object* create_load(struct ast* node, string reg) {
    struct variable* v_1 = create_variable(node);
    struct variable* v_2 = new_variable(variable_label(registry), reg, "", 0);
    
    return new_precode_obj("L_LOAD_VAR", v_1, v_2);
}

struct precode_object* create_store(struct ast* node, string reg) {
    struct variable* v_1 = create_variable(node);
    struct variable* v_2 = new_variable(variable_label(registry), reg, "", 0);
    
    return new_precode_obj("L_STORE_VAR", v_2, v_1);
}

struct variable* create_variable(struct ast* node) {
    if ((node->type).compare("NUM") == 0) {
        int n = node->s_1->number;
        return new_variable(variable_label(constant), "", "", node->s_1->number);
    } else {
        if ((node->s_1->type).compare("IDENTIFIER1") == 0) {
            return new_variable(variable_label(variable), node->s_1->s_1->value, "", 0);
        } else if ((node->s_1->type).compare("IDENTIFIER2") == 0) {
            return new_variable(variable_label(arr), node->s_1->value, node->s_1->s_2->value, 0);
        } else {
            return new_variable(variable_label(arr), node->s_1->value, "", node->s_1->s_2->number);
        }
    }
}

struct variable* get_new_label() {
    struct variable* new_label_id = new_variable(variable_label(label), "", "", label_iterator);
    label_iterator++;
    return new_label_id;
}


// ================== OTHERS =============

void print_precode_obj(struct precode_object* obj) {
    string labels[] = {"variable", "registry", "arr", "constant", "label"};

    cout << obj->label << " ";
    if (obj->var_1 != NULL) {
        cout << labels[obj->var_1->label] << "[";
        if (obj->var_1->label == 0 || obj->var_1->label == 1) {
            cout << obj->var_1->id_1 << "] ";
        } else if (obj->var_1->label == 2) {
            cout << obj->var_1->id_1 << "(" << obj->var_1->id_2 << ")] ";
        } else {
            cout << obj->var_1->value << "] ";
        }
    }
    if (obj->var_2 != NULL) {
        cout << labels[obj->var_2->label] << "[";
        if (obj->var_2->label == 0 || obj->var_2->label == 1) {
            cout << obj->var_2->id_1 << "] ";
        } else if (obj->var_2->label == 2) {
            cout << obj->var_2->id_1 << "(" << obj->var_2->id_2 << ")] ";
        } else {
            cout << obj->var_2->value << "] ";
        }
    }
    cout << endl;
}
