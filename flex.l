%option noyywrap
%option yylineno
%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <string>
    #include <iostream>
    #include "bison.tab.h"
    using namespace std;

	void yyerror(char *s);
    int yylex();

	int lineno = 1;
%}

%x comment
WHITESPACE [ \t]
NUMBER [0-9]

%%

"[" 		{BEGIN(comment);}

<comment>{
    <<EOF>>	{yyerror("koniec pliku a nie zamkniety"); yyterminate();}
	"]"		{BEGIN(INITIAL);}
	.		;
	\n 		{lineno++;}
}

"+"			{return '+';}
"-"			{return '-';}
"*"			{return '*';}
"/"			{return '/';}
"%"			{return '%';}
"="			{return EQ;}
"!="		{return NEQ;}
"<"			{return LT;}
">"			{return GT;}
"<="		{return LTE;}
">="		{return GTE;}
":="		{return ASSIGN;}

DECLARE     {return DECLARE;}
IN          {return IN;}
END         {return END;}
IF          {return IF;}
THEN        {return THEN;}
ELSE        {return ELSE;}
ENDIF       {return ENDIF;}
WHILE       {return WHILE;}
DO          {return DO;}
ENDWHILE    {return ENDWHILE;}
ENDDO       {return ENDDO;}
FOR         {return FOR;}
FROM        {return FROM;}
TO          {return TO;}
DOWNTO      {return DOWNTO;}
WRITE       {return WRITE;}
READ        {return READ;}
ENDFOR      {return ENDFOR;}
s

";"			{return ';';}
":"         {return ':';}
"("			{return '(';}
")"			{return ')';}

[_a-z]+		{yylval.str = strdup(yytext); return ID;}
{NUMBER}+	{yylval.number = strtoull(yytext, NULL, 10); return NUM;}
[_a-zA-Z0-9]+	{yyerror("nierozpoznany napis"); yyterminate();}
{WHITESPACE}	;
\n 				{lineno++;}
.			{yyerror("nieznany znak"); yyterminate();}

%%
