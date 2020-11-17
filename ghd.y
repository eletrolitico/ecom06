%{
	#include "ast.h"
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
	extern FILE *yyin;
	extern FILE *yyout;
	FILE *tokout;
	FILE *comout;
	extern int lineno;
	extern int yylex();

	char *idTemp;

	extern node *rootDecl;
	extern node *rootStat;

	void yyerror(char *msg);
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
%token P_OPEN P_CLOSE B_BLOCK E_BLOCK SEMICOLON ASSIGN
%token ID
%token ICONST FCONST CCONST

%token EXP VAR TAIL EXPS LOP ROP NEXP

/* precedencies and associativities */
%right ASSIGN
%left OR
%left AND
%left EQU
%left ADD
%left SUB
%left MUL DIV
%right NOT
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
%type <ival> ops lOps relOps

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
		insert(yylval.id,$1);
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
		$3->reg = 'a';
		$$->lookahead = $3;
		$$->tipo = $3->tipo;
		$$->esq = NULL;
		$$->dir = NULL;
	}
;
input: INP P_OPEN ID P_CLOSE SEMICOLON
	{
		$$ = (node*)malloc(sizeof(node));
		$$->token = INP;
		$$->id = yylval.id;
		$$->tipo = lookup(yylval.id);
		$$->esq = NULL;
		$$->dir = NULL;
	}
;

if:	IF P_OPEN expression P_CLOSE tail else
{
	$$ = (node*)malloc(sizeof(node));
	$$->token = IF;
	$$->lookahead = $3;
	$$->lookahead1 = $5;
	$$->esq = NULL;
	$$->dir = $6;
}
;

else:
	ELSE tail
	{
		$$ = (node*)malloc(sizeof(node));
		$$->token = ELSE;
		$$->lookahead = $2;
		$$->esq = NULL;
		$$->dir = NULL;
	}
	|
	{
		$$ = NULL;
	}
;

loop: WHILE P_OPEN expression P_CLOSE tail
	{
		$$ = (node*)malloc(sizeof(node));
		$$->token = WHILE;
		$$->lookahead = $3;
		$$->lookahead1 = $5;
		$$->esq = NULL;
		$$->dir = NULL;
	}
;

tail: B_BLOCK statements E_BLOCK
{
	$$ = $2;
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
;

relOps:
	EQU
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

expression:
	expression ops expression 
	{
		$$ = (node*)malloc(sizeof(node));
		$$->token = EXPS;
		$$->op = $2;
		$$->lookahead = $1;
		$$->lookahead1 = $3;
		$$->esq = NULL;
		$$->dir = NULL;
	}
	|
	expression relOps expression 
	{
		$$ = (node*)malloc(sizeof(node));
		$$->token = ROP;
		$$->op = $2;
		$$->lookahead = $1;
		$$->lookahead1 = $3;
		$$->esq = NULL;
		$$->dir = NULL;
	}
	|
	expression lOps expression 
	{
		$$ = (node*)malloc(sizeof(node));
		$$->token = LOP;
		$$->op = $2;
		$$->lookahead = $1;
		$$->lookahead1 = $3;
		$$->esq = NULL;
		$$->dir = NULL;
	}
	| P_OPEN expression P_CLOSE
	{
		$$ = $2;
		$$->hasParen = 1;
	}
	| SUB expression
	{
		$$ = (node*)malloc(sizeof(node));
		$$->token = NEXP;
		$$->lookahead = $2;
		$$->esq = NULL;
		$$->dir = NULL;
	}
	| NOT expression
	{
		$$ = (node*)malloc(sizeof(node));
		$$->token = NOT;
		$$->lookahead = $2;
		$$->esq = NULL;
		$$->dir = NULL;
	}
	| ID
	{
		$$ = (node*)malloc(sizeof(node));
		$$->token = VAR;
		$$->id = yylval.id;
		$$->tipo = lookup(yylval.id);
		$$->esq = NULL;
		$$->dir = NULL;
	}
	| constant
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
		$$->tipo = INT;
		$$->esq = NULL;
		$$->dir = NULL;
	}
	| FCONST 
	{
		$$ = (node*)malloc(sizeof(node));
		$$->token = FCONST;
		$$->val = yylval.val;
		$$->tipo = FLOAT;
		$$->esq = NULL;
		$$->dir = NULL;
	}
	| CCONST
	{
		$$ = (node*)malloc(sizeof(node));
		$$->token = CCONST;
		$$->val = yylval.val;
		$$->tipo = CHAR;
		$$->esq = NULL;
		$$->dir = NULL;
	}
;

assigment: ID {idTemp = yylval.id;} ASSIGN expression SEMICOLON
	{
		$$ = (node*)malloc(sizeof(node));
		$$->token = ASSIGN;
		$$->id = idTemp;
		$$->tipo = lookup(idTemp);
		$4->reg = 'a';
		$$->lookahead = $4;
		$$->esq = NULL;
		$$->dir = NULL;
	}
;


%%

void yyerror (char *msg)
{
  fprintf(stderr, "%s: error at line %d\n", msg, lineno);
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
	char *msg = strdup(argv[1]);
	tokout = fopen(strcat(argv[1],"-tokens"),"w");

	flag = yyparse();
	fclose(yyin);
	fclose(tokout);
	
	printf("Parsing finished!\n");

	comout = fopen(strcat(msg,"-comandos"),"w");
	yyout = fopen("out.s","w");

	fprintf(yyout,"\tglobal\tmain\n");
	fprintf(yyout,"\textern\tprintf\n");
	fprintf(yyout,"\textern\tscanf\n");
	fprintf(yyout,"\nsection .data\n");
	fprintf(yyout,"intFmt\tdb\t\"%%d\",10,0\n");
	fprintf(yyout,"charFmt\tdb\t\"%%c\",10,0\n");
	fprintf(yyout,"floatFmt\tdb\t\"%%f\",10,0\n");
	fprintf(yyout,"intRd\tdb\t\"%%d\",0\n");
	fprintf(yyout,"charRd\tdb\t\"%%c\",0\n");
	fprintf(yyout,"floatRd\tdb\t\"%%f\",0\n");
	fprintf(yyout,"\nsection .bss\n");
	fprintf(yyout,"tempvar1:\tRESD\t1\n");
	fprintf(yyout,"tempvar2:\tRESD\t1\n\n");

	imprime(rootDecl);

	fprintf(yyout,"\nsection .text\nmain:\n");

	fprintf(yyout,"\tPUSH\tEBP\n");
	fprintf(yyout,"\tMOV\tEBP,ESP\n\n");

	imprime(rootStat);

	fprintf(yyout,"\n\tMOV\tEBX,0\n");
	fprintf(yyout,"\tMOV\tEAX,1\n");
	fprintf(yyout,"\tINT\t0x80\n");
	
	fclose(comout);
	fclose(yyout);

	if(flag != 0)
		return flag;

	flag = system("nasm -f elf32 -g -F dwarf out.s");

	if(flag != 0){
		printf("Erro do nasm\n");
		return flag;
	}

	flag = system("gcc -m32 out.o -o out");

	if(flag != 0){
		printf("Erro do gcc\n");
		return flag;
	}
}
