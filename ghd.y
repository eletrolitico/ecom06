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
	
	// for else ifs
	void add_elseif(AST_Node *elsif);
	AST_Node **elsifs;
	int elseif_count = 0;
%}

/* YYSTYPE union */
%union{
	// different types of values
	Value val;   
	
	// structures
	list_t* symtab_item;
	AST_Node* node;
	
	// for declarations
	int data_type;
	int const_type;
	
	// for parameters
	Param par;
}

/* token definition */
%token BEGINPROG ENDPROG
%token<val> T_CHAR T_INT T_FLOAT IF ELSE WHILE INP OUT
%token<val> ADDOP MULOP DIVOP MODOP OROP ANDOP XOROP NOTOP EQUOP RELOP
%token<val> P_OPEN P_CLOSE B_BLOCK E_BLOCK LBRACE RBRACE SEMI COMMA ASSIGN REFER
%token <symtab_item> ID
%token <val> 	ICONST
%token <val>  FCONST
%token <val> 	CCONST
%token <val>  STRING

/* precedencies and associativities */
%left COMMA
%right ASSIGN
%left OROP
%left ANDOP
%left EQUOP
%left RELOP
%left ADDOP
%left MULOP DIVOP
%right NOTOP INCR REFER MINUS
%left P_OPEN P_CLOSE B_BLOCK E_BLOCK

/* rule (non-terminal) definitions */
%type <node> program
%type <node> declarations declaration
%type <data_type> type
%type <symtab_item> init
%type <node> constant
%type <node> expression var_ref
%type <node> statement assigment
%type <node> statements tail
%type <node> if_statement else_if optional_else
%type <node> while_statement
%type <node> input
%type <node> output

%start program

%%

program: BEGINPROG 
         declarations { main_decl_tree = $2; ast_traversal($2); } 
         statements   { main_func_tree = $4; ast_traversal($4); }
         ENDPROG;

/* declarations */
declarations: 
	declarations declaration
	{
		AST_Node_Declarations *temp = (AST_Node_Declarations*) $1;
		$$ = new_declarations_node(temp->declarations, temp->declaration_count, $2);
	}
	| declaration
	{
		$$ = new_declarations_node(NULL, 0, $1);
	}
;

declaration: type { declare = 1; } ID  { declare = 0; } SEMI
{
		$$ = new_ast_decl_node($1, $3);
};

type: T_INT  		{ $$ = INT_TYPE;   }
	| T_CHAR 		{ $$ = CHAR_TYPE;  }
	| T_FLOAT 	{ $$ = REAL_TYPE;  }
;

init : ID ASSIGN constant
{ 
	AST_Node_Const *temp = (AST_Node_Const*) $3;
	$1->val = temp->val;
	$1->st_type = temp->const_type;
	$$ = $1;
}
;

values: values COMMA constant 
	{
		AST_Node_Const *temp = (AST_Node_Const*) $3;
		add_to_vals(temp->val);
	}
	| constant
	{
		AST_Node_Const *temp = (AST_Node_Const*) $1;
		add_to_vals(temp->val);
	}
;

/* statements */
statements:
	statements statement
	{
		AST_Node_Statements *temp = (AST_Node_Statements*) $1;
		$$ = new_statements_node(temp->statements, temp->statement_count, $2);
	}
	| statement
	{
		$$ = new_statements_node(NULL, 0, $1);
	}
;

statement:
	if_statement
	{ 
		$$ = $1; /* just pass information */
	}
	| while_statement
	{
		$$ = $1; /* just pass information */
	}
	| assigment SEMI
	{
		$$ = $1; /* just pass information */
	}
  | output
  {
		$$ = $1; /* just pass information */
  }
  | input
  {
		$$ = $1; /* just pass information */
  }
;

output: OUT P_OPEN expression P_CLOSE SEMI;
input: INP P_OPEN ID P_CLOSE SEMI;

if_statement:
	IF P_OPEN expression P_CLOSE tail else_if optional_else
	{
		$$ = new_ast_if_node($3, $5, elsifs, elseif_count, $7);
		elseif_count = 0;
		elsifs = NULL;
	}
	| IF P_OPEN expression P_CLOSE tail optional_else
	{
		$$ = new_ast_if_node($3, $5, NULL, 0, $6);
	}
;

else_if:
	else_if ELSE IF P_OPEN expression P_CLOSE tail
	{
		AST_Node *temp = new_ast_elsif_node($5, $7);
		add_elseif(temp);
	}
	| ELSE IF P_OPEN expression P_CLOSE tail
	{
		AST_Node *temp = new_ast_elsif_node($4, $6);
		add_elseif(temp);
	}
;

optional_else:
	ELSE tail
	{
		/* else exists */
		$$ = $2;
	}
	| /* empty */
	{
		/* no else */
		$$ = NULL;
	}
;

while_statement: WHILE P_OPEN expression P_CLOSE tail
{
	$$ = new_ast_while_node($3, $5);
}
;

tail: LBRACE statements RBRACE
{ 
	$$ = $2; /* just pass information */
}
;

expression:
    expression ADDOP expression
	{ 
	    $$ = new_ast_arithm_node($2.ival, $1, $3);
	}
	| expression MULOP expression
	{
	    $$ = new_ast_arithm_node(MUL, $1, $3);
	}
	| expression DIVOP expression
	{
		$$ = new_ast_arithm_node(DIV, $1, $3);
	}
	| expression OROP expression
	{
		$$ = new_ast_bool_node(OR, $1, $3);
	}
	| expression ANDOP expression
	{
		$$ = new_ast_bool_node(AND, $1, $3);
	}
	| NOTOP expression
	{
	    $$ = new_ast_bool_node(NOT, $2, NULL);
	}
	| expression EQUOP expression
	{
		$$ = new_ast_equ_node($2.ival, $1, $3);
	}
	| expression RELOP expression
	{
		$$ = new_ast_rel_node($2.ival, $1, $3);
	}
	| P_OPEN expression P_CLOSE
	{
		$$ = $2; /* just pass information */
	}
	| var_ref
	{ 
		$$ = $1; /* just pass information */
	}
	| constant
	{
		$$ = $1; /* no sign */
	}
	| ADDOP constant %prec MINUS
	{
		/* plus sign error */
		if($1.ival == ADD){
			fprintf(stderr, "Error having plus as a sign!\n");
			exit(1);
		}
		else{
			AST_Node_Const *temp = (AST_Node_Const*) $2;
		
			/* inverse value depending on the constant type */
			switch(temp->const_type){
				case INT_TYPE:
					temp->val.ival *= -1;
					break;
				case REAL_TYPE:
					temp->val.fval *= -1;
					break;
				case CHAR_TYPE:
					/* sign before T_char error */
					fprintf(stderr, "Error having sign before T_character constant!\n");
					exit(1);
					break;
			}
			
			$$ = (AST_Node*) temp;
		}
	}
;

constant:
	ICONST   { $$ = new_ast_const_node(INT_TYPE, $1);  }
	| FCONST { $$ = new_ast_const_node(REAL_TYPE, $1); }
	| CCONST { $$ = new_ast_const_node(CHAR_TYPE, $1); }
;

assigment: var_ref ASSIGN expression
{
	AST_Node_Ref *temp = (AST_Node_Ref*) $1;
	$$ = new_ast_assign_node(temp->entry, temp->ref, $3);
	
	/* find datatypes */
	int type1 = get_type(temp->entry->st_name);
	int type2 = expression_data_type($3);
	
	/* the last function will give us information about revisits */
	
	/* contains revisit => add assignment-check to revisit queue */
	if(cont_revisit == 1){	
		/* search if entry exists */
		revisit_queue *q = search_queue(temp->entry->st_name);
		if(q == NULL){
			add_to_queue(temp->entry, temp->entry->st_name, ASSIGN_CHECK);
			q = search_queue(temp->entry->st_name);	
		}
		
		/* setup structures */
		if(q->num_of_assigns == 0){ /* first node */
			q->nodes = (void**) malloc(sizeof(void*));
		}
		else{ /* general case */
			q->nodes = (void**) realloc(q->nodes, (q->num_of_assigns + 1) * sizeof(void*));
		}
		
		/* add info of assignment */
		q->nodes[q->num_of_assigns] = (void*) $3;
		
		/* increment number of assignments */
		q->num_of_assigns++;
		
		/* reset revisit flag */
		cont_revisit = 0;
		
		printf("Assignment revisit for %s at line %d\n", temp->entry->st_name, lineno);
	}
	else{ /* no revisit */
		/* check assignment semantics */
		get_result_type(
			type1,       /*  variable datatype  */
			type2,       /* expression datatype */
			NONE  /* checking compatibility only (no operator) */
		);
	}
}
;

var_ref: ID
	{
		$$ = new_ast_ref_node($1, 0); /* no reference */
	}
;

%%

void yyerror ()
{
  fprintf(stderr, "Syntax error at line %d\n", lineno);
  exit(1);
}

void add_elseif(AST_Node *elsif){
	// first entry
	if(elseif_count == 0){
		elseif_count = 1;
		elsifs = (AST_Node **) malloc(1 * sizeof(AST_Node));
		elsifs[0] = elsif;
	}
	// general case
	else{
		elseif_count++;
		elsifs = (AST_Node **) realloc(elsifs, elseif_count * sizeof(AST_Node));
		elsifs[elseif_count - 1] = elsif;
	}
}

int main (int argc, char *argv[]){
	
	// initialize symbol table
	init_hash_table();
	
	// initialize revisit queue
	queue = NULL;
	
	// parsing
	int flag;
	yyin = fopen(argv[1], "r");
	flag = yyparse();
	fclose(yyin);
	
	printf("Parsing finished!\n");
	
	/* remove print from revisit queue */
	revisit_queue *q = search_prev_queue("print");
	if(q == NULL){ /* special case: first entry */
		if(queue != NULL){ /* check if queue not empty */
			queue = queue->next;
		}
	}
	else{
		q->next = q->next->next;
	}
	
	/* perform the remaining checks (assignments) */
	if(queue != NULL){
		revisit_queue *cur;
		cur = queue;
		while(cur != NULL){
			if(cur->revisit_type == ASSIGN_CHECK){
				revisit(cur->st_name);
			}
			cur = cur->next;
		}
	}
	
	/* if still not empty => warning */
	if(queue != NULL){
		printf("Warning! Something in the revisit queue has not been checked yet!\n");
	}
	
	/* declare function type of "print" */
	func_declare("print", VOID_TYPE, 1, NULL);
	
	// symbol table dump
	yyout = fopen("symtab_dump.out", "w");
	symtab_dump(yyout);
	fclose(yyout);
	
	// revisit queue dump
	yyout = fopen("revisit_dump.out", "w");
	revisit_dump(yyout);
	fclose(yyout);
	
	// code generation
	printf("\nGenerating code...\n");
	generate_code();
	
	return flag;
}
