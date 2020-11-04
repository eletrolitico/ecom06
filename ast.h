#ifndef AST_H
#define AST_H

typedef enum Arithm_op
{
	ADD,
	SUB,
	MUL,
	DIV,
	MOD,
} Arithm_op;

typedef enum Bool_op
{
	OR,
	AND,
	XOR,
	NOT
} Bool_op;

typedef enum Rel_op
{
	GREATER,
	LESS,
	GREATER_EQUAL,
	LESS_EQUAL
} Rel_op;

typedef enum Equ_op
{
	EQUAL,
	NOT_EQUAL
} Equ_op;

#endif