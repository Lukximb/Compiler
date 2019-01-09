#include "struct.h"

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
        // yyerror("Err: out of space\n");
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
        // yyerror("Err: out of space\n");
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
        // yyerror("Err: out of space\n");
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
        // yyerror("Err: code out of space\n");
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
        // yyerror("Err: block out of space\n");
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
        // yyerror("Err: block out of space\n");
        exit(1);
    }
    block->previous = previous;
    block->next = next;
    block->length = length;

    return block;
}
