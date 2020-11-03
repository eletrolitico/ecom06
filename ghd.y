%{
#include <stdlib.h> /* For malloc in symbol table */
#include <string.h> /* For strcmp in symbol table */
#include <stdio.h> /* For error messages */
#include "ST.h" /* The Symbol Table Module */
#define YYDEBUG 1 /* For debugging */
int errors = 0;

extern int yylex();
extern int yyparse();
extern FILE* yyin;
extern FILE *out;

extern int yyCountLine; 

void yyerror(const char* s);
%}

%union {
  int int_val;
  char char_val;
  float real_val;
  char* ident;
}

%token BEGINPROG ENDPROG
%token <char_val> CHARACTER
%token <int_val>  INTEGER
%token <real_val> REAL
%token <ident>    VARIABLE
%token ASSIGNMENT
%token EQU
%token GREATER
%token GREATEREQU
%token LESS
%token LESSEQU
%token DIFFERENT
%token OR XOR
%token AND
%right AND
%token NOT
%token ADD
%token SUB
%left ADD SUB
%token MUL
%token DIV
%right MUL DIV
%token MOD
%token COLON
%token SEMICOLON
%token P_OPEN
%token P_CLOSE
%token B_BLOCK
%token E_BLOCK
%token T_INT
%token T_CHAR
%token T_FLOAT
%token INP
%token OUT
%token IF
%token ELSE
%token WHILE

%type<ident> tipo

%start program


%%
program: BEGINPROG declarations statements ENDPROG;

declarations: var | declarations var;
var: tipo VARIABLE SEMICOLON;

statements: statement | statements statement;
statement: attribution  | if | else | loop | input | output;

value: INTEGER | VARIABLE | CHARACTER | REAL;

ops: ADD | SUB | MUL | DIV;

exp: value | exp ops exp | P_OPEN exp P_CLOSE;

intVar: VARIABLE | INTEGER;
opMod: intVar MOD intVar;

tipo: T_INT {$$ = "int";} | T_CHAR {$$ = "char";} | T_FLOAT {$$ = "float";};


r_value: exp | logicOp | opMod;

attribution: VARIABLE ASSIGNMENT r_value SEMICOLON {fprintf(out,"Var attrib: %s\n", $1);};

output: OUT P_OPEN r_value P_CLOSE SEMICOLON;
input: INP P_OPEN VARIABLE P_CLOSE SEMICOLON;

operators: AND | XOR | OR;
varNot: NOT exp | exp;

relOps: EQU | GREATER | GREATEREQU | LESS | LESSEQU | DIFFERENT;
compOp: exp relOps exp;

logicOp: varNot | compOp | logicOp operators logicOp;

if: IF P_OPEN logicOp P_CLOSE B_BLOCK statements E_BLOCK;
else: if ELSE B_BLOCK statements E_BLOCK;

loop: WHILE P_OPEN logicOp P_CLOSE B_BLOCK statements E_BLOCK;

%%


void yyerror(const char* s) {
	fprintf(stderr, "\nERROR ON LINE %d - error: %s\n", yyCountLine, s);
	exit(1);
}