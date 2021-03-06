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

	// uso de registro
	char reg;
	char hasParen;

	//operacao
	int op;

	struct node *esq, *dir, *lookahead, *lookahead1;
} node;

typedef struct list_t
{
	char *id;
	TipoVar tipo;

	struct list_t *prox;
} list_t;

void imprime(node *n);
void insert(char *id, TipoVar t);
void getOp(char *msg, int op);
void getFloatOp(char *msg, int op);
void getCmp(char *msg, int op);
void getFloatCmp(char *msg, int op);
void getLop(char *msg, int op);
void getOpCom(char *msg, int op);
TipoVar lookup(char *id);

#endif