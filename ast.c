#include "ast.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ghd.tab.h"

extern FILE *yyout;

node *rootDecl;
node *rootStat;

list_t *lista;

void imprime(node *n)
{
    if (!n)
        return;
    imprime(n->esq);

    switch (n->token)
    {
    case 0:
        break;
    case ID:
        if (n->tipo == CHAR)
            fprintf(yyout, "%s:\tRESB\t1\n", n->id);
        else
            fprintf(yyout, "%s:\tRESD\t1\n", n->id);
        break;

    case ASSIGN:
        imprime(n->lookahead);
        if (n->tipo != FLOAT)
            fprintf(yyout, "\tMOV\t[%s],EAX\n", n->id);
        else
        {
            fprintf(yyout, "\tMOV\tEAX,[tempvar1]\n", n->id);
            fprintf(yyout, "\tMOV\t[%s],EAX\n", n->id);
        }
        break;
    case ICONST:
        if (n->reg == 'a')
            fprintf(yyout, "\tMOV\tEAX,$%d\n", n->val.ival);
        else
            fprintf(yyout, "\tMOV\tEBX,$%d\n", n->val.ival);
        break;

    case FCONST:
        if (n->reg == 'a')
            fprintf(yyout, "\tMOV\tdword [tempvar1],__float32__(%f)\n", n->val.fval);
        else
            fprintf(yyout, "\tMOV\tdword [tempvar2],__float32__(%f)\n", n->val.fval);
        break;

    case CCONST:
        if (n->reg == 'a')
            fprintf(yyout, "\tMOVZX\tEAX,byte '%c'\n", n->val.cval);
        else
            fprintf(yyout, "\tMOVZX\tEBX,byte '%c'\n", n->val.cval);
        break;

    case VAR:
        if (n->reg == 'a')
            fprintf(yyout, "\tMOV\tEAX,[%s]\n", n->id);
        else
            fprintf(yyout, "\tMOV\tEBX,[%s]\n", n->id);
        break;

    case EXPS:
        n->lookahead->reg = 'a';
        n->lookahead1->reg = 'b';
        imprime(n->lookahead);
        imprime(n->lookahead1);
        char msg[5];

        if (n->lookahead->tipo != FLOAT && n->lookahead1->tipo != FLOAT)
        {
            n->tipo = INT;
            getOp(msg, n->op);
            fprintf(yyout, "\t%s\tEAX,EBX\n", msg);
            if (n->reg == 'b')
                fprintf(yyout, "\tMOV\tEBX,EAX\n");
        }
        else if (n->lookahead1->tipo != FLOAT) // a é float
        {
            n->tipo = FLOAT;
            getFloatOp(msg, n->op);
            if (n->lookahead1->reg == 'a')
                fprintf(yyout, "\tMOV\t[tempvar2],EAX\n");
            else
                fprintf(yyout, "\tMOV\t[tempvar2],EBX\n");
            fprintf(yyout, "\tFILD\tdword [tempvar2]\n");
            fprintf(yyout, "\t%s\tdword [tempvar1]\n", msg);
            if (n->reg == 'a')
                fprintf(yyout, "\tFSTP\tdword [tempvar1]\n");
            else
                fprintf(yyout, "\tFSTP\tdword [tempvar2]\n");
        }
        else if (n->lookahead->tipo != FLOAT) // b é float
        {
            n->tipo = FLOAT;
            getFloatOp(msg, n->op);
            fprintf(yyout, "\tMOV\t[tempvar1],EAX\n");
            fprintf(yyout, "\tFILD\tdword [tempvar1]\n");
            fprintf(yyout, "\t%s\tdword [tempvar2]\n", msg);
            if (n->reg == 'a')
                fprintf(yyout, "\tFSTP\tdword [tempvar1]\n");
            else
                fprintf(yyout, "\tFSTP\tdword [tempvar2]\n");
        }
        else // os 2 são float
        {
            n->tipo = FLOAT;
            getFloatOp(msg, n->op);
            fprintf(yyout, "\tFLD\tdword [tempvar1]\n");
            fprintf(yyout, "\t%s\tdword [tempvar2]\n", msg);
            if (n->reg == 'a')
                fprintf(yyout, "\tFSTP\tdword [tempvar1]\n");
            else
                fprintf(yyout, "\tFSTP\tdword [tempvar2]\n");
        }

        break;

    default:
        fprintf(yyout, "Esqueceu de implementar: %d", n->token);
        break;
    }

    imprime(n->dir);
}

void insert(char *id, TipoVar t)
{
    list_t *aux = lista, *ant = NULL;

    while (aux != NULL)
    {
        ant = aux;
        aux = aux->prox;
    }

    if (!ant)
    {
        lista = (list_t *)malloc(sizeof(list_t));
        lista->id = strdup(id);
        lista->tipo = t;
        lista->prox = NULL;
        return;
    }
    aux = (list_t *)malloc(sizeof(list_t));
    aux->id = strdup(id);
    aux->tipo = t;
    aux->prox = NULL;

    ant->prox = aux;
}

TipoVar lookup(char *id)
{
    list_t *aux = lista;

    while (aux != NULL && strcmp(aux->id, id) != 0)
        aux = aux->prox;

    if (!aux)
        return -1;

    return aux->tipo;
}

void getOp(char *msg, int op)
{
    switch (op)
    {
    case ADD:
        strcpy(msg, "ADD");
        return;
    case SUB:
        strcpy(msg, "SUB");
        return;
    case MUL:
        strcpy(msg, "IMUL");
        return;
    case DIV:
        strcpy(msg, "IDIV");
        return;

    default:
        strcpy(msg, "!ERROR!");
        return;
    }
}

void getFloatOp(char *msg, int op)
{
    switch (op)
    {
    case ADD:
        strcpy(msg, "FADD");
        return;
    case SUB:
        strcpy(msg, "FSUB");
        return;
    case MUL:
        strcpy(msg, "FMUL");
        return;
    case DIV:
        strcpy(msg, "FDIV");
        return;

    default:
        strcpy(msg, "!ERROR!");
        return;
    }
}
