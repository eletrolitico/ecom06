%{
	#include "semantics.c"
	#include "symtab.c"
	#include "ast.h"
	#include "ast.c"
	#include "code_generation.c"
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
	extern FILE *yyin;
	extern FILE *yyout;
	extern int lineno;
	extern int yylex();
	void yyerror();
	
%}

/* YYSTYPE union */
%union{
	Value val;
	sym_lst *sym_item;
	// for declarations
	int data_type;
	int const_type;
}

/* token definition */
%token BEGINPROG ENDPROG
%token<val> T_CHAR T_INT T_FLOAT IF ELSE WHILE INP OUT
%token<val> ADDOP MULOP DIVOP MODOP OROP ANDOP XOROP NOTOP EQUOP RELOP
%token<val> P_OPEN P_CLOSE B_BLOCK E_BLOCK SEMICOLON ASSIGN REFER
%token <symtab_item> ID
%token <val> 	ICONST
%token <val>  FCONST
%token <val> 	CCONST
%token <val>  STRING

/* precedencies and associativities */
%right ASSIGN
%left OROP
%left ANDOP
%left EQUOP
%left RELOP
%left ADDOP
%left SUBOP
%left MULOP DIVOP
%right NOTOP INCR REFER MINUS
%left P_OPEN P_CLOSE B_BLOCK E_BLOCK

/* rule (non-terminal) definitions */
%type <node> program
%type <node> declarations declaration
%type <data_type> type
%type <node> constant
%type <node> expression
%type <node> statement assigment
%type <node> statements tail
%type <node> if else
%type <node> loop
%type <node> input
%type <node> output

%start program

%%

program: BEGINPROG
         declarations
         statements
         ENDPROG;

declarations: declarations declaration
			| declaration
;

declaration: type ID SEMICOLON;

type: T_INT   
	| T_CHAR  
	| T_FLOAT 
;

statements:
	statements statement
	| statement
;

statement:
	  if
	| loop
	| assigment
	| output
	| input
;

output: OUT P_OPEN expression P_CLOSE SEMICOLON;
input: INP P_OPEN ID P_CLOSE SEMICOLON;

if:	IF P_OPEN expression P_CLOSE tail else;

else:
	ELSE tail
	| 
;

loop: WHILE P_OPEN expression P_CLOSE tail;

tail: B_BLOCK statements E_BLOCK;

expression:
      expression ADDOP expression
    | expression SUBOP expression
	| expression MULOP expression
	| expression DIVOP expression
	| expression MODOP expression
	| expression OROP expression
	| expression ANDOP expression
	| expression XOROP expression
	| NOTOP expression
	| expression EQUOP expression
	| expression RELOP expression
	| P_OPEN expression P_CLOSE
	| ID
	| constant
	| ADDOP constant %prec MINUS
	
;

constant:
	ICONST   
	| FCONST 
	| CCONST;

assigment: ID ASSIGN expression SEMICOLON;


%%

void yyerror ()
{
  fprintf(stderr, "Syntax error at line %d\n", lineno);
  exit(1);
}

int main (int argc, char *argv[]){
	
	if(argc < 2){
		printf("Erro: nenhum arquivo de entrada");
		exit(1);
	}
	// parsing
	int flag;
	yyin = fopen(argv[1], "r");
	flag = yyparse();
	fclose(yyin);
	
	printf("Parsing finished!\n");
	
	
	return flag;
}
