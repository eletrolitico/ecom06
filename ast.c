#include "ast.h"

#include <stdio.h>
#include "ghd.tab.h"

extern FILE *yyout;

node *rootDecl;
node *rootStat;

char tmp[3][5] = {"int", "float", "char"};

void imprime(node *n)
{
    if (!n)
        return;
    imprime(n->esq);

    switch (n->token)
    {
    case ID:
        fprintf(yyout, "\t%s %s;\n", tmp[n->tipo], n->id);
        break;
    case ASSIGN:
        fprintf(yyout, "\t%s = ", n->id);
        imprime(n->lookahead);
        fprintf(yyout, ";\n");
        break;
    case ICONST:
        fprintf(yyout, "%d", n->val.ival);
        break;
    default:
        fprintf(yyout, "Esqueceu de implementar: %d", n->token);
        break;
    }

    imprime(n->dir);
}
