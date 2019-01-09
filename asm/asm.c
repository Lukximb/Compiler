#include "asm.h"

// #include <string>

// using namespace std;
vector<string> asm_code;
int lines = 0;


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
            } else if (block->precode_list[i]->label.compare("ADD") == 0) {
                gen_add(block->precode_list[i]);
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
        vector<string> n = generate_const(line->var_1->value, line->var_2->id_1);
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
    labels[string(to_string(line->var_1->value))] = lines;
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
    asm_code.push_back("JUMP " + string(to_string(lines-3)));
    lines++;
    asm_code.push_back("COPY " + line->var_1->id_1 + " D");
    lines++;
}

void gen_add(struct precode_object* line) {
    asm_code.push_back("ADD " + line->var_1->id_1 + " " + line->var_2->id_1);
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
