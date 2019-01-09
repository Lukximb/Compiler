#ifndef FUNCTION_HANDLERS_H
#define FUNCTION_HANDLERS_H

#include "auxiliary_functions.h"

#include <stdio.h>
#include <stdlib.h>
#include <vector>
#include <string>
#include <iostream>
#include <map>

using namespace std;

struct precode_block* create_command(struct ast* node);

struct precode_block* create_commands(struct ast* node);

struct precode_block* create_assign(struct ast* node);

struct precode_block* create_ifelse(struct ast* node);

struct precode_block* create_if(struct ast* node);

struct precode_block* create_while(struct ast* node);

struct precode_block* create_dowhile(struct ast* node);

struct precode_block* create_forto(struct ast* node);

struct precode_block* create_fordownto(struct ast* node);

struct precode_block* create_read(struct ast* node);

struct precode_block* create_write(struct ast* node);

#endif