#include "function_handlers.h"

// ============ PRECODE CONSTRUCTORS ==================

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
