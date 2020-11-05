%{
	#include "ast.h"
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
	extern FILE *yyin;
	extern FILE *yyout;
	extern int lineno;
	extern int yylex();

	char *idTemp;

	extern node *rootDecl;
	extern node *rootStat;

	void yyerror();
%}

/* YYSTYPE union */
%union{
	Value val;
	char *id;
	node *node;
	int ival;
}

/* token definition */
%token BEGINPROG ENDPROG
%token T_CHAR T_INT T_FLOAT IF ELSE WHILE INP OUT
%token ADD MUL DIV MOD
%token OR AND XOR NOT
%token EQU DIF GRT LES GEQ LEQ
%token P_OPEN P_CLOSE B_BLOCK E_BLOCK SEMICOLON ASSIGN REFER
%token ID
%token ICONST FCONST CCONST

%token EXP VAR TAIL

/* precedencies and associativities */
%right ASSIGN
%left OR
%left AND
%left EQU
%left REL
%left ADD
%left SUB
%left MUL DIV
%right NOT MINUS
%left P_OPEN P_CLOSE B_BLOCK E_BLOCK

/* rule (non-terminal) definitions */
%type <node> program
%type <node> declarations declaration
%type <ival> type
%type <node> constant
%type <node> expression
%type <node> statement assigment
%type <node> statements tail
%type <node> if else
%type <node> loop
%type <node> input
%type <node> output
%type <node> logicOp
%type <ival> ops lOps

%start program

%%

program: BEGINPROG declarations statements ENDPROG
		 {
			 rootDecl = $2;
			 rootStat = $3;
		 }
;

declarations: 
	declarations declaration
	{
		$$ = (node*)malloc(sizeof(node));
		$$->token = 0;
		$$->esq = $1;
		$$->dir = $2;
	}
	| declaration
	{
		$$ = $1;
	}
	|
	{
		$$ = NULL;
	}
;

declaration: type ID SEMICOLON
	{
		$$ = (node*)malloc(sizeof(node));
		$$->token = ID;
		$$->tipo = $1;
		$$->id = yylval.id;
		$$->esq = NULL;
		$$->dir = NULL;
	}
;

type: 
	T_INT
	{
		$$ = INT;
	}   
	| T_CHAR
	{
		$$ = CHAR;
	}  
	| T_FLOAT
	{
		$$ = FLOAT;
	} 
;

statements:
	statements statement
	{
		$$ = (node*)malloc(sizeof(node));
		$$->token = 0;
		$$->esq = $1;
		$$->dir = $2;
	}
	| statement
	{
		$$ = $1;
	}
	|
	{
		$$ = NULL;
	}
;

statement:
	if
	{
		$$ = $1;
	}
	| loop
	{
		$$ = $1;
	}
	| assigment
	{
		$$ = $1;
	}
	| output
	{
		$$ = $1;
	}
	| input
	{
		$$ = $1;
	}
;

output: OUT P_OPEN expression P_CLOSE SEMICOLON
	{
		$$ = (node*)malloc(sizeof(node));
		$$->token = OUT;
		$$->lookahead = $3;
		$$->esq = NULL;
		$$->dir = NULL;
	}
;
input: INP P_OPEN ID P_CLOSE SEMICOLON
	{
		$$ = (node*)malloc(sizeof(node));
		$$->token = INP;
		$$->id = yylval.id;
		$$->esq = NULL;
		$$->dir = NULL;
	}
;

if:	IF P_OPEN logicOp P_CLOSE tail else
{
	$$ = (node*)malloc(sizeof(node));
	$$->token = IF;
	$$->lookahead = $3;
	$$->lookahead1 = $5;
	$$->esq = $6;
	$$->dir = NULL;
}
;

else:
	ELSE tail
	{
		$$ = (node*)malloc(sizeof(node));
		$$->token = ELSE;
		$$->esq = $2;
		$$->dir = NULL;
	}
	|
	{
		$$ = NULL;
	}
;

loop: WHILE P_OPEN logicOp P_CLOSE tail
	{
		$$ = (node*)malloc(sizeof(node));
		$$->token = WHILE;
		$$->lookahead = $3;
		$$->esq = $5;
		$$->dir = NULL;
	}
;

tail: B_BLOCK statements E_BLOCK
{
	$$ = (node*)malloc(sizeof(node));
	$$->token = TAIL;
	$$->lookahead = $2;
	$$->esq = NULL;
	$$->dir = NULL;
}
;

ops:
	ADD
	{
		$$ = ADD;
	}
	|SUB
	{
		$$ = SUB;
	}
	|MUL
	{
		$$ = MUL;
	}
	|DIV
	{
		$$ = DIV;
	}
	|MOD
	{
		$$ = MOD;
	}
;

expression:
	expression ops expression 
	{
		$$ = (node*)malloc(sizeof(node));
		$$->token = $2;
		$$->esq = $1;
		$$->dir = $3;
	}
	| P_OPEN expression P_CLOSE
	{
		$$ = (node*)malloc(sizeof(node));
		$$->token = EXP;
		$$->esq = $2;
		$$->dir = NULL;
	}
	| ID
	{
		$$ = (node*)malloc(sizeof(node));
		$$->token = VAR;
		$$->esq = NULL;
		$$->dir = NULL;
	}
	| constant
	{
		$$ = $1;
	}
;

lOps:
	OR
	{
		$$ = OR;
	}
	|AND
	{
		$$ = AND;
	}
	|XOR
	{
		$$ = XOR;
	}
	|EQU
	{
		$$ = EQU;
	}
	|DIF
	{
		$$ = DIF;
	}
	|GRT
	{
		$$ = GRT;
	}
	|LES
	{
		$$ = LES;
	}
	|GEQ
	{
		$$ = GEQ;
	}
	|LEQ
	{
		$$ = LEQ;
	}
;

logicOp:
	logicOp lOps logicOp
	{
		$$ = (node*)malloc(sizeof(node));
		$$->token = $2;
		$$->esq = $1;
		$$->dir = $3;
	}
	|NOT logicOp
	{
		$$ = (node*)malloc(sizeof(node));
		$$->token = NOT;
		$$->esq = $2;
		$$->dir = NULL;
	}
	|expression
	{
		$$ = $1;
	}
;

constant:
	ICONST
	{
		$$ = (node*)malloc(sizeof(node));
		$$->token = ICONST;
		$$->val = yylval.val;
		$$->esq = NULL;
		$$->dir = NULL;
	}
	| FCONST 
	{
		$$ = (node*)malloc(sizeof(node));
		$$->token = FCONST;
		$$->val = yylval.val;
		$$->esq = NULL;
		$$->dir = NULL;
	}
	| CCONST
	{
		$$ = (node*)malloc(sizeof(node));
		$$->token = CCONST;
		$$->val = yylval.val;
		$$->esq = NULL;
		$$->dir = NULL;
	}
;

assigment: ID {idTemp = yylval.id;} ASSIGN expression SEMICOLON
	{
		$$ = (node*)malloc(sizeof(node));
		$$->token = ASSIGN;
		$$->id = idTemp;
		$$->lookahead = $4;
		$$->esq = NULL;
		$$->dir = NULL;
	}
;


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

	fprintf(yyout,"#include <iostream>\n\nint main()\n{\n");
	imprime(rootDecl);
	imprime(rootStat);
	fprintf(yyout,"\treturn 0;\n}\n");

	
	
	return flag;
}
