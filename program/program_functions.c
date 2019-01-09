#include "program_functions.h"

void handle_program(struct ast* root) {
    int result = semantic_analyse(root);
    if (result != 1) {
        cout << "Semantic Error" << endl;
        return;
    }
    struct precode_block* block = create_commands(root->s_2);
    struct precode_block* block_copy = block;

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