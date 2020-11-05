#ifndef AST_H
#define AST_H

typedef union
{
	int ival;
	float fval;
	char cval;
} Value;

typedef enum
{
	INT,
	FLOAT,
	CHAR,
} TipoVar;

typedef struct node
{
	int token;
	Value val;

	//para vars
	TipoVar tipo;
	char *id;

	struct node *esq, *dir, *lookahead, *lookahead1;
} node;

void imprime(node *n);

#endif