#ifndef ASM_H
#define ASM_H

#include "../structures/struct.h"
#include "../precodes/auxiliary_functions.h"

#include <stdio.h>
#include <stdlib.h>
#include <vector>
#include <string>
#include <iostream>
#include <map>

using namespace std;

extern vector<string> asm_code;
extern int lines;
 

void translate(struct precode_block* block);

vector<string> generate_const(int number, string reg);

void gen_jzero_2(struct precode_object* line);

void gen_sub(struct precode_object* line);

void gen_add(struct precode_object* line);

void gen_load(struct precode_object* line);

void gen_store(struct precode_object* line);

void print_generate_const(vector<string> vec);

void gen_get(struct precode_object* line);

void gen_put(struct precode_object* line);

void gen_label(struct precode_object* line);

void gen_jzero(struct precode_object* line);

void gen_jump(struct precode_object* line);

void gen_copy(struct precode_object* line);

void gen_div(struct precode_object* line);

void gen_mull(struct precode_object* line);

void gen_mod(struct precode_object* line);

void gen_inc(struct precode_object* line);

void gen_dec(struct precode_object* line);

void swap_labels();

void print_asm();

#endif
