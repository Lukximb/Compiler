#ifndef PROGRAM_FUNCTIONS_H
#define PROGRAM_FUNCTIONS_H

#include "../precodes/function_handlers.h"
#include "../asm/asm.h"

#include <stdio.h>
#include <stdlib.h>
#include <vector>
#include <string>
#include <iostream>
#include <map>

using namespace std;

void handle_program(struct ast* root);

int semantic_analyse(struct ast* root);

void generate_var_to_map(string id);

void generate_arr_to_map(struct ast* node);

#endif