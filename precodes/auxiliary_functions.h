#ifndef AUXILIARY_FUCTIONS_H
#define AUXILIARY_FUCTIONS_H

#include "../structures/struct.h"

#include <stdio.h>
#include <stdlib.h>
#include <vector>
#include <string>
#include <iostream>
#include <map>

using namespace std;

extern int label_iterator;
extern int iter_iterator;
extern int memory_counter;

extern map<string, int> variables;                                             // all declared variables
extern map<string, struct array_object*> arrays;   
extern map<string, int> labels;


vector<struct precode_object*> create_condition(struct ast* node, struct variable* label);

vector<struct precode_object*> create_expression(struct ast* node, string reg);

struct precode_object* create_load(struct ast* node, string reg);

struct precode_object* create_store(struct ast* node, string reg);

struct variable* create_variable(struct ast* node);

struct variable* get_new_label();

struct precode_block* get_new_iter(string name, struct ast* node);

void print_precode_obj(struct precode_object* obj);

#endif