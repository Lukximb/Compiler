#ifndef STRUCT_H
#define STRUCT_H

#include <stdio.h>
#include <stdlib.h>
#include <vector>
#include <string>
#include <iostream>

using namespace std;

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

#endif
