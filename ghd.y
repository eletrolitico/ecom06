%{
#include <stdlib.h> /* For malloc in symbol table */
#include <string.h> /* For strcmp in symbol table */
#include <stdio.h> /* For error messages */
#include "ST.h" /* The Symbol Table Module */
#define YYDEBUG 1 /* For debugging */
int errors = 0;
install(char *sym_name)
{ 
  symrec *s;
  s = getsym(sym_name);
  if (s == 0)
    s = putsym (sym_name);
  else { 
    errors++;
    printf( "%s is already defined\n", sym_name);
  }
}
context_check( char *sym_name )
{ 
  if (getsym(sym_name) == 0)
  printf( "%s is an undeclared identifier\n", sym_name);
}

extern int yylex();
extern int yyparse();
extern FILE* yyin;

extern int yyCountLine; 

void yyerror(const char* s);
%}

%union {
  int int_val;
  char char_val;
  float real_val;
  char* ident;
}

%token BEGINPROG
%token ENDPROG
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
%token AND
%token OR
%token XOR
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

%token UNKNOWN

%type<ident> tipo

%start program


%%
program: BEGINPROG statements ENDPROG;

statements: statement | statements statement;
statement: attribution | var | if | else | loop | input | output;

value: INTEGER | VARIABLE | CHARACTER | REAL;

ops: ADD | SUB | MUL | DIV;

exp: value | exp ops exp | P_OPEN exp P_CLOSE;

intVar: VARIABLE | INTEGER;
opMod: intVar MOD intVar;

tipo: T_INT {$$ = "int";} | T_CHAR {$$ = "char";} | T_FLOAT {$$ = "float";};

var: tipo VARIABLE SEMICOLON {printf("Var dec: type: %s, ident: %s\n", $1,$2);};

r_value: exp | logicOp | opMod;

attribution: VARIABLE ASSIGNMENT r_value SEMICOLON {printf("Var attrib: %s\n", $1);};

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


int main() {
	yyin = stdin;

	do {
		yyparse();
	} while(!feof(yyin));

  fprintf(stderr, "ACCEPTED!\n\n");

	return 0;
}

void yyerror(const char* s) {
	fprintf(stderr, "\nERROR ON LINE %d - error: %s\n", yyCountLine, s);
	exit(1);
}