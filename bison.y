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
        int memory_index;
    };

    enum variable_label {
        variable = 0,
        registry = 1,
        arr = 2,
        constant = 3,
        label = 4,
        iterator = 5
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
        int end,
        int memory_index
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
    map<string, struct array_object*> arrays;   
    map<string, int> labels;                            // all declared arrays
    string registries[8] = {"A", "B", "C", "D", "E", "F", "G", "H"};        // all available registries

    vector<string> asm_code;

    int label_iterator = 0;
    int iter_iterator = 0;

    int memory_counter = 0;

    int lines = 0;

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
    struct precode_block* get_new_iter(string name, struct ast* node);

    void print_precode_obj(struct precode_object* obj);
    void generate_var_to_map(string id);
    void generate_arr_to_map(struct ast* node);

    void translate(struct precode_block* block);
    vector<string> generate_const(int number, string reg);
    vector<string> generate_mult_const(int number, string reg);
    void print_generate_const(vector<string> vec);
    void gen_load(struct precode_object* line);
    void gen_store(struct precode_object* line);
    void gen_jzero_2(struct precode_object* line);
    void gen_sub(struct precode_object* line);

    void gen_get(struct precode_object* line);
    void gen_put(struct precode_object* line);
    void gen_label(struct precode_object* line);
    void gen_jzero(struct precode_object* line);
    void gen_jump(struct precode_object* line);
    void gen_div(struct precode_object* line);
    void gen_mull(struct precode_object* line);
    void gen_mod(struct precode_object* line);
    void gen_copy(struct precode_object* line);

    void swap_labels();
    void print_asm();
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
        int end,
        int memory_index) {
    struct array_object* arr = (struct array_object*)malloc(sizeof(struct array_object));
    
    if (!arr) {
        cout << "ERR: arr out of space" << endl;
        yyerror("Err: out of space\n");
        exit(1);
    }
    arr->id = id;
    arr->start = start;
    arr->end = end;
    arr->memory_index = memory_index;

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
    struct precode_block* block_copy = block;
    // cout << "handle program" << endl;

    // DONE
    // while (NULL != block) {
    //     cout << "=== block ===" << endl;
    //     for (int i = 0; i < block->precode_list.size(); i++) {
    //         print_precode_obj(block->precode_list[i]);
    //     }
    //     block = block->next;
    // }
    // DONE

    translate(block_copy);
}

int semantic_analyse(struct ast* root) {
    struct ast* next_node = root;
    while ((next_node->value).compare("NULL") != 0) {
        if ((next_node->value).compare("DECVAR") == 0) {
            generate_var_to_map(next_node->s_2->value);
        }
        next_node = next_node->s_1;
    }

    next_node = root;
    while ((next_node->value).compare("NULL") != 0) {
        if ((next_node->value).compare("DECARR") == 0) {
            generate_arr_to_map(next_node);
        }
        next_node = next_node->s_1;
    }
    return 1;
}

void generate_var_to_map(string id) {
    if (variables.find(id) != variables.end()) {
        cout << "Declaration error" << endl << "     Variable " << id << " was already declared" << endl;
        exit(1);
    }
    
    variables[id] = memory_counter;
    memory_counter++;
}

void generate_arr_to_map(struct ast* node) {
    int v_1 = node->s_3->number;
    int v_2 = node->s_4->number;
    string name = node->s_2->value;

    if (arrays.find(name) != arrays.end()) {
        cout << "Declaration error" << endl << "     Array " << name << " was already declared" << endl;
        exit(1);
    }     

    if (v_1 > v_2) {
        printf("Declaration error\n     Cannot generate array in range %d:%d\n", v_1, v_2);
        exit(1);
    }

    struct array_object* arr = new_array_obj(name, v_1, v_2, memory_counter);
    memory_counter += v_2 - v_1 + 1;
    arrays[name] = arr;
}


// ============ PRECODE CONSTRUCTORS ==================

struct precode_block* create_assign(struct ast* node) {
    string reg = "B";
    vector<struct precode_object*> precode_list = create_expression(node->s_2, reg);
    precode_list.push_back(create_store(node, reg));

    return new_precode_block(NULL, NULL, precode_list, precode_list.size());
}

struct precode_block* create_ifelse(struct ast* node) {
    struct variable* label_else = get_new_label();

    vector<struct precode_object*> cond = create_condition(node->s_1, label_else);
    struct precode_block* commands_1 = create_commands(node->s_2);
    struct precode_block* commands_2 = create_commands(node->s_3);

    struct precode_block* cond_block = new_precode_block(NULL, NULL, cond, cond.size());

    cond_block->next = commands_1;
    commands_1->previous = cond_block;
    
    struct precode_block* current_command = cond_block;
    while (current_command->next != NULL) {
        current_command = current_command->next;
    }

    (current_command->precode_list).push_back(new_precode_obj("LABEL", label_else, NULL));
    current_command->length++;

    current_command->next = commands_2;
    commands_2->previous = current_command;

    return cond_block;
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
    struct variable* label_while = get_new_label();
    struct variable* label_end = get_new_label();
    vector<struct precode_object*> cond = create_condition(node->s_1, label_end);
    struct precode_block* commands = create_commands(node->s_2);

    struct precode_block* cond_block = new_precode_block(NULL, NULL, cond, cond.size());

    vector<struct precode_object*>::iterator it;
    it = (cond_block->precode_list).begin();

    (cond_block->precode_list).insert(it, new_precode_obj("LABEL", label_while, NULL));
    (cond_block->length)++;

    cond_block->next = commands;
    commands->previous = cond_block;
    
    struct precode_block* current_command = cond_block;
    while (current_command->next != NULL) {
        current_command = current_command->next;
    }

    (current_command->precode_list).push_back(new_precode_obj("JUMP", label_while, NULL));
    (current_command->precode_list).push_back(new_precode_obj("LABEL", label_end, NULL));
    current_command->length++;

    return cond_block;
}

struct precode_block* create_dowhile(struct ast* node) {
    struct variable* label_while = get_new_label();
    struct variable* label_end = get_new_label();
    vector<struct precode_object*> cond = create_condition(node->s_2, label_end);
    struct precode_block* commands = create_commands(node->s_1);

    struct precode_block* cond_block = new_precode_block(NULL, NULL, cond, cond.size());

    vector<struct precode_object*>::iterator it;
    it = (commands->precode_list).begin();

    (commands->precode_list).insert(it, new_precode_obj("LABEL", label_while, NULL));
    (commands->length)++;

    struct precode_block* current_command = commands;
    while (current_command->next != NULL) {
        current_command = current_command->next;
    }

    cond_block->previous = current_command;
    current_command->next = cond_block;

    (cond_block->precode_list).push_back(new_precode_obj("JUMP", label_while, NULL));
    (cond_block->precode_list).push_back(new_precode_obj("LABEL", label_end, NULL));
    cond_block->length += 2;

    return commands;
}

struct precode_block* create_forto(struct ast* node) {
    struct variable* label_for = get_new_label();
    struct variable* label_end = get_new_label();

    struct precode_block* iter_block = get_new_iter(node->s_1->value, node->s_2);

    (iter_block->precode_list).push_back(new_precode_obj("LABEL", label_for, NULL));
    (iter_block->length)++;

    // GENERATE CONDITION
    vector<struct precode_object*> cond;

    struct variable* reg_b = new_variable(variable_label(registry), "B", "", 0);
    struct variable* reg_c = new_variable(variable_label(registry), "C", "", 0);
    struct variable* iter = new_variable(variable_label(variable), node->s_1->value, "", 0);
    
    cond.push_back(new_precode_obj("L_LOAD_VAR", iter, reg_c));
    cond.push_back(create_load(node->s_3, "B"));
    cond.push_back(new_precode_obj("SUB", reg_b, reg_c));
    cond.push_back(new_precode_obj("JZERO", reg_b, label_end));

    struct precode_block* cond_block = new_precode_block(NULL, NULL, cond, cond.size());
    // END CONDITION

    struct precode_block* commands = create_commands(node->s_4);

    iter_block->next = cond_block;
    cond_block->previous = iter_block;

    cond_block->next = commands;
    commands->previous = cond_block;
    
    struct precode_block* current_command = commands;
    while (current_command->next != NULL) {
        current_command = current_command->next;
    }

    // DECREMENT ITERATOR
    (current_command->precode_list).push_back(new_precode_obj("L_LOAD_VAR", iter, reg_b));
    (current_command->precode_list).push_back(new_precode_obj("INC", reg_b, NULL));
    (current_command->precode_list).push_back(new_precode_obj("L_STORE_VAR", reg_b, iter));
    // END DECREMENT

    (current_command->precode_list).push_back(new_precode_obj("JUMP", label_for, NULL));
    (current_command->precode_list).push_back(new_precode_obj("LABEL", label_end, NULL));
    (current_command->length) += 5;

    return iter_block;
}

struct precode_block* create_fordownto(struct ast* node) {
    struct variable* label_for = get_new_label();
    struct variable* label_end = get_new_label();

    struct precode_block* iter_block = get_new_iter(node->s_1->value, node->s_2);

    (iter_block->precode_list).push_back(new_precode_obj("LABEL", label_for, NULL));
    (iter_block->length)++;

    // GENERATE CONDITION
    vector<struct precode_object*> cond;

    struct variable* reg_b = new_variable(variable_label(registry), "B", "", 0);
    struct variable* reg_c = new_variable(variable_label(registry), "C", "", 0);
    struct variable* iter = new_variable(variable_label(variable), node->s_1->value, "", 0);
    
    cond.push_back(new_precode_obj("L_LOAD_VAR", iter, reg_c));
    cond.push_back(create_load(node->s_3, "B"));
    cond.push_back(new_precode_obj("SUB", reg_c, reg_b));
    cond.push_back(new_precode_obj("JZERO", reg_c, label_end));

    struct precode_block* cond_block = new_precode_block(NULL, NULL, cond, cond.size());
    // END CONDITION

    struct precode_block* commands = create_commands(node->s_4);

    iter_block->next = cond_block;
    cond_block->previous = iter_block;

    cond_block->next = commands;
    commands->previous = cond_block;
    
    struct precode_block* current_command = commands;
    while (current_command->next != NULL) {
        current_command = current_command->next;
    }

    // DECREMENT ITERATOR
    (current_command->precode_list).push_back(new_precode_obj("L_LOAD_VAR", iter, reg_b));
    (current_command->precode_list).push_back(new_precode_obj("DEC", reg_b, NULL));
    (current_command->precode_list).push_back(new_precode_obj("L_STORE_VAR", reg_b, iter));
    // END DECREMENT

    (current_command->precode_list).push_back(new_precode_obj("JUMP", label_for, NULL));
    (current_command->precode_list).push_back(new_precode_obj("LABEL", label_end, NULL));
    (current_command->length) += 5;

    return iter_block;
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
    } else if ((node->value).compare("!=") == 0) { 
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
            return new_variable(variable_label(arr), node->s_1->s_1->value, node->s_1->s_2->value, 0);
        } else {
            return new_variable(variable_label(arr), node->s_1->s_1->value, "", node->s_1->s_2->number);
        }
    }
}

struct variable* get_new_label() {
    struct variable* new_label_id = new_variable(variable_label(label), "", "", label_iterator);
    label_iterator++;
    return new_label_id;
}

struct precode_block* get_new_iter(string name, struct ast* node) {
    vector<struct precode_object*> precode_list;
    variables[name] = iter_iterator;

    precode_list.push_back(create_load(node, "B"));

    struct variable* v = new_variable(variable_label(variable), name, "", iter_iterator);
    struct variable* reg_b = new_variable(variable_label(registry), "B", "", 0);
    
    precode_list.push_back(new_precode_obj("L_STORE_VAR", reg_b, v));

    iter_iterator++;
    return new_precode_block(NULL, NULL, precode_list, precode_list.size());
}


// ================== OTHERS =============

void print_precode_obj(struct precode_object* obj) {
    string labels[] = {"variable", "registry", "arr", "constant", "label", "iterator"};

    cout << obj->label << " ";
    if (obj->var_1 != NULL) {
        cout << labels[obj->var_1->label] << "[";
        if (obj->var_1->label == 0 || obj->var_1->label == 1 || obj->var_1->label == 5) {
            cout << obj->var_1->id_1 << "] ";
        } else if (obj->var_1->label == 2) {
            if ((obj->var_1->id_2).compare("") == 0) {
                cout << obj->var_1->id_1 << "(" << obj->var_1->value << ")] ";
            } else {
                cout << obj->var_1->id_1 << "(" << obj->var_1->id_2 << ")] ";
            }
        } else {
            cout << obj->var_1->value << "] ";
        }
    }
    if (obj->var_2 != NULL) {
        cout << labels[obj->var_2->label] << "[";
        if (obj->var_2->label == 0 || obj->var_2->label == 1 || obj->var_1->label == 5) {
            cout << obj->var_2->id_1 << "] ";
        } else if (obj->var_2->label == 2) {
            if ((obj->var_1->id_2).compare("") == 0) {
                cout << obj->var_1->id_1 << "(" << obj->var_1->value << ")] ";
            } else {
                cout << obj->var_1->id_1 << "(" << obj->var_1->id_2 << ")] ";
            }
        } else {
            cout << obj->var_2->value << "] ";
        }
    }
    cout << endl;
}


void translate(struct precode_block* block) {
    // cout << endl << "#########################" << endl;
    while (block != NULL) {
        for (int i = 0; i < block->precode_list.size(); i++) {
            if (block->precode_list[i]->label.compare("L_LOAD_VAR") == 0) {
                gen_load(block->precode_list[i]);
            } else if (block->precode_list[i]->label.compare("L_STORE_VAR") == 0) {
                gen_store(block->precode_list[i]);
            } else if (block->precode_list[i]->label.compare("JZERO_2") == 0) {
                gen_jzero_2(block->precode_list[i]);
            } else if (block->precode_list[i]->label.compare("SUB") == 0) {
                gen_sub(block->precode_list[i]);
            } else if (block->precode_list[i]->label.compare("GET") == 0) {
                gen_get(block->precode_list[i]);
            } else if (block->precode_list[i]->label.compare("PUT") == 0) {
                gen_put(block->precode_list[i]);
            } else if (block->precode_list[i]->label.compare("LABEL") == 0) {
                gen_label(block->precode_list[i]);
            } else if (block->precode_list[i]->label.compare("JZERO") == 0) {
                gen_jzero(block->precode_list[i]);
            } else if (block->precode_list[i]->label.compare("JUMP") == 0) {
                gen_jump(block->precode_list[i]);
            } else if (block->precode_list[i]->label.compare("L_DIV") == 0) {
                gen_div(block->precode_list[i]);
            } else if (block->precode_list[i]->label.compare("L_MULT") == 0) {
                gen_mull(block->precode_list[i]);
            } else if (block->precode_list[i]->label.compare("L_MOD") == 0) {
                gen_mod(block->precode_list[i]);
            } else if (block->precode_list[i]->label.compare("COPY") == 0) {
                gen_copy(block->precode_list[i]);
            } else {
                // print_precode_obj(block->precode_list[i]);
            }
        }
        block = block->next;
    }
    // print_asm();
    swap_labels();
    print_asm();
}

vector<string> generate_const(int number, string reg) {
    vector<string> queue;
    // queue.push_back("INC " + reg + " " + reg);
    while (number > 0) {
        if (number % 2 == 0) {
            number /= 2;
            queue.push_back("ADD " + reg + " " + reg);
        } else {
            number--;
            queue.push_back("INC " + reg);
        }
    }
    queue.push_back("SUB " + reg + " " + reg);
    return queue;
}

vector<string> generate_mult_const(int number, string reg) {
    vector<string> queue;
    while (number > 1) {
        if (number % 2 == 0) {
            number /= 2;
            queue.push_back("ADD " + reg + " " + reg);
        } else {
            number--;
            queue.push_back("ADD " + reg + " F");
        }
    }
    queue.push_back("COPY F " + reg);
    return queue;
}

void gen_jzero_2(struct precode_object* line) {
    asm_code.push_back("JZERO " + line->var_1->id_1 + " " + string(to_string(lines+2)));
    lines++;
}

void gen_sub(struct precode_object* line) {
    asm_code.push_back("SUB " + line->var_1->id_1 + " " + line->var_2->id_1);
    lines++;
}

void gen_load(struct precode_object* line) {
    if (line->var_1->label == 0 || line->var_1->label == 5) {
        int n = variables[line->var_1->id_1];
        vector<string> gen_n = generate_const(n, "A");
        print_generate_const(gen_n);
        asm_code.push_back("LOAD " + line->var_2->id_1);
        lines++;
    } else if (line->var_1->label == 2) {
        struct array_object* arr = arrays[line->var_1->id_1];
        if ((line->var_1->id_2).compare("") == 0) {
            int n = line->var_1->value - arr->start;
            vector<string> gen_n = generate_const(n, "A");
            print_generate_const(gen_n);
            asm_code.push_back("LOAD " + line->var_2->id_1);
            lines++;
        } else {
            int a_ind = variables[line->var_1->id_2];
            vector<string> gen_n = generate_const(a_ind, "A");
            vector<string> a_from = generate_const(arr->start, "B");
            print_generate_const(gen_n);
            asm_code.push_back("LOAD " + line->var_2->id_1);
            lines++;
            print_generate_const(a_from);
            asm_code.push_back("SUB A " + line->var_2->id_1);
            asm_code.push_back("LOAD " + line->var_2->id_1);
            lines += 2;
        }
    } else if (line->var_1->label == 3) {
        vector<string> n = generate_const(line->var_1->value, "B");
        print_generate_const(n);
    }
}

void gen_store(struct precode_object* line) {
    if (line->var_2->label == 0 || line->var_2->label == 5) {
        int n = variables[line->var_2->id_1];
        vector<string> gen_n = generate_const(n, "A");

        print_generate_const(gen_n);
        asm_code.push_back("STORE " + line->var_1->id_1);
        lines++;
    } else if (line->var_2->label == 2) {
        struct array_object* arr = arrays[line->var_2->id_1];
        if ((line->var_2->id_2).compare("") == 0) {
            int n = line->var_2->value - arr->start;
            vector<string> gen_n = generate_const(n, "A");
 
            print_generate_const(gen_n);
            asm_code.push_back("STORE " + line->var_1->id_1);
            lines++;
        } else {
            int a_ind = variables[line->var_2->id_2];
            vector<string> gen_n = generate_const(a_ind, "A");
            vector<string> a_from = generate_const(arr->start, "B");

            print_generate_const(gen_n);
            asm_code.push_back("STORE " + line->var_1->id_1);
            lines++;
 
            print_generate_const(a_from);
            asm_code.push_back("SUB A " + line->var_1->id_1);
            asm_code.push_back("STORE " + line->var_1->id_1);
            lines += 2;
        }
    } 
}

void print_generate_const(vector<string> vec) {
    for (int i = vec.size()-1; i >= 0; i--) {
        asm_code.push_back(vec[i]);
        lines++;
    }
}

void gen_get(struct precode_object* line) {
    asm_code.push_back("GET " + line->var_1->id_1);
    lines++;
}

void gen_put(struct precode_object* line) {
    asm_code.push_back("PUT " + line->var_1->id_1);
    lines++;
}

void gen_label(struct precode_object* line) {
    labels[string(to_string(line->var_1->value))] = lines+1;
}

void gen_jzero(struct precode_object* line) {
    asm_code.push_back("QZ " + line->var_1->id_1 + " " + string(to_string(line->var_2->value)));
    lines++;
}

void gen_jump(struct precode_object* line) {
    asm_code.push_back("Q  " + string(to_string(line->var_1->value)));
    lines++;
}

void gen_copy(struct precode_object* line) {
    asm_code.push_back("COPY " + line->var_1->id_1 + " " + line->var_2->id_1);
    lines++;
}

void gen_div(struct precode_object* line) {
    asm_code.push_back("SUB D D");
    lines++;
    asm_code.push_back("SUB " + line->var_1->id_1 + " " + line->var_2->id_1);
    lines++;
    asm_code.push_back("JZERO "  + line->var_1->id_1 + " " + string(to_string(lines+3)));
    lines++;
    asm_code.push_back("INC D");
    lines++;
    asm_code.push_back("JUMP " + string(to_string(lines-3)));
    lines++;
    asm_code.push_back("COPY " + line->var_1->id_1 + " D");
    lines++;
}

void gen_mull(struct precode_object* line) {
    asm_code.push_back("COPY " + line->var_1->id_1 + " " + line->var_2->id_1);
    lines++;
    asm_code.push_back("SUB " + line->var_1->id_1 + " " + line->var_1->id_1);
    lines++;
    asm_code.push_back("JODD " + line->var_2->id_1 + " " + string(to_string(lines+2)));
    lines++;
    asm_code.push_back("ADD " + line->var_1->id_1 + " D");
    lines++;
    asm_code.push_back("ADD D D");
    lines++;
    asm_code.push_back("HALF " + line->var_2->id_1);
    lines++;
    asm_code.push_back("ADD " + line->var_1->id_1 + " D");
    lines++;
    asm_code.push_back("JZERO " + line->var_2->id_1 + " " + string(to_string(lines+2)));
    lines++;
    asm_code.push_back("JUMP " + string(to_string(lines-6)));
    lines++;
}

void gen_mod(struct precode_object* line) {
    asm_code.push_back("SUB " + line->var_1->id_1 + " " + line->var_2->id_1);
    lines++;
    asm_code.push_back("COPY D " + line->var_1->id_1);
    lines++;
    asm_code.push_back("JZERO "  + line->var_1->id_1 + " " + string(to_string(lines+3)));
    lines++;
    asm_code.push_back("JUMP " + (lines-3));
    lines++;
    asm_code.push_back("COPY " + line->var_1->id_1 + " D");
    lines++;
}

void swap_labels() {
    for (int i = 0; i < asm_code.size(); i++) {
        if (asm_code[i].at(0) ==  'Q') {
            string a;
            if (asm_code[i].at(1) == 'Z') {
                string label = asm_code[i].substr(5, asm_code[i].size());
                a = "JZERO ";
                a += asm_code[i].at(3);
                a += " ";
                a += string(to_string(labels[label]));

                asm_code[i] = a;
            } else {
                string label = asm_code[i].substr(3, asm_code[i].size());
                string a = "JUMP ";
                a += string(to_string(labels[label]));
                asm_code[i] = a;
            }
        }
    }
    asm_code.push_back("HALT");
}

void print_asm() {
    // cout <<endl << "..............." << endl;
    for (int i = 0; i < asm_code.size(); i++) {
        cout << asm_code[i] << endl;
    }
}
