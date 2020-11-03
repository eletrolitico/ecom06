%{
#include <stdio.h>
#define YY_DECL int yylex()
#include "ghd.tab.h"

void extern yyerror(const char* s);
int yyCountLine = 1;

%}

digit         [0-9]
letter        [a-zA-Z]

%%
"begin"             {return BEGINPROG;}
"end"               {return ENDPROG;}
"="                 {return ASSIGNMENT;}
"=="                {return EQU;}
">"                 {return GREATER;}
">="                {return GREATEREQU;}
"<"                 {return LESS;}
"<="                {return LESSEQU;}
"!="                {return DIFFERENT;}
"and"               {return AND;}
"or"                {return OR;}
"xor"               {return XOR;}
"not"               {return NOT;}
"+"                 {return ADD;}
"-"                 {return SUB;}
"*"                 {return MUL;}
"/"                 {return DIV;}
"mod"               {return MOD;}
":"                 {return COLON;}
";"                 {return SEMICOLON;}
"("                 {return P_OPEN;}
")"                 {return P_CLOSE;}
"{"                 {return B_BLOCK;}
"}"                 {return E_BLOCK;}
"int"               {return T_INT;}
"char"              {return T_CHAR;}
"float"             {return T_FLOAT;}
"input"             {return INP;}
"output"            {return OUT;}
"if"                {return IF;}
"else"              {return ELSE;}
"while"             {return WHILE;}

{letter}({letter}|{digit})* {
                       yylval.ident = strdup(yytext);
                       return VARIABLE;}

"'"{letter}|{digit}"'"       {yylval.char_val = yytext[0];
                        return CHARACTER;}

-?{digit}+             { yylval.int_val = atoi(yytext);
                       return INTEGER;}

-?{digit}+\.{digit}+   { yylval.real_val = atof(yytext);
                         return REAL;}

[\n]                    {yyCountLine++;}
[ \t\r]                /* skip whitespace */
.                       { yyerror("character unrecognized"); }

%%

int yywrap(void){return 1;}
