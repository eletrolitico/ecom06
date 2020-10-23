%{
  #include <stdio.h>
  #include <math.h>
  extern int yylex (void);
  extern void yyerror (char const *);
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
%token MUL
%token DIV
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


%%
program: BEGINPROG statements ENDPROG;

statements: attribution | var | if | else | loop | input | output;

value: INTEGER | VARIABLE | CHARACTER | REAL;

ops: ADD | SUB | MUL | DIV;

exp: value | exp ops exp | P_OPEN exp P_CLOSE;

intVar: VARIABLE | INTEGER;
opMod: intVar MOD intVar;

tipo: T_INT | T_CHAR | T_FLOAT;

var: tipo VARIABLE SEMICOLON;

r_value: exp | logicOp | opMod;

attribution: VARIABLE ASSIGNMENT r_value SEMICOLON;

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

int main(){
    yyparse();
    return 0;
}