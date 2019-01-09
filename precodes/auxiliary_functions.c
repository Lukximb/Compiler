#import "auxiliary_functions.h"

int label_iterator = 0;
int iter_iterator = 0;
int memory_counter = 0;

map<string, int> variables;                                             // all declared variables
map<string, struct array_object*> arrays;   
map<string, int> labels; 

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