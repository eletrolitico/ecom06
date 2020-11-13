#include "ast.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ghd.tab.h"

extern FILE *yyout;
extern FILE *comout;

node *rootDecl;
node *rootStat;

list_t *lista;

int label = 0;

void getLabel(char *c)
{
    sprintf(c, "PK%d", label++);
}

char *getTipo(int n)
{
    switch (n)
    {
    case CHAR:
        return "CHAR";
    case INT:
        return "INT";
    case FLOAT:
        return "REAL";

    default:
        return "UNDEFINED";
    }
}

char laTmp[10];

void imprime(node *n)
{
    char msg[5], la1[10], la2[10];
    if (!n)
        return;
    imprime(n->esq);

    switch (n->token)
    {
    case 0:
        fprintf(yyout, "\n");
        break;
    case ID:
        fprintf(comout, "%s = DECLARACAO %s\n", n->id, getTipo(n->tipo));

        if (n->tipo == CHAR)
            fprintf(yyout, "%s:\tRESB\t1\n", n->id);
        else
            fprintf(yyout, "%s:\tRESD\t1\n", n->id);
        break;

    case ASSIGN:
        fprintf(comout, "COMANDO ATRIBUICAO %s = ", n->id);
        imprime(n->lookahead);
        fprintf(comout, "\n");

        if (n->tipo == FLOAT)
        {
            if (n->lookahead->tipo == FLOAT)
            {
                fprintf(yyout, "\tMOV\tEAX,[tempvar1]\n", n->id);
                fprintf(yyout, "\tMOV\t[%s],EAX\n", n->id);
            }
            else
            {
                fprintf(yyout, "\tMOV\t[tempvar1],EAX\n", n->id);
                fprintf(yyout, "\tFILD\tdword [tempvar1]\n", n->id);
                fprintf(yyout, "\tFSTP\tdword [tempvar1]\n", n->id);
                fprintf(yyout, "\tMOV\tEAX,[tempvar1]\n", n->id);
                fprintf(yyout, "\tMOV\t[%s],EAX\n", n->id);
            }
        }
        else
        {
            if (n->lookahead->tipo == FLOAT)
            {
                fprintf(yyout, "\tFLD\tdword [tempvar1]\n", n->id);
                if (n->tipo == INT)
                    fprintf(yyout, "\tFISTP\tdword [%s]\n", n->id);

                if (n->tipo == CHAR)
                    fprintf(yyout, "\tFISTP\tbyte [%s]\n", n->id);
            }
            else
            {
                if (n->tipo == INT)
                    fprintf(yyout, "\tMOV\t[%s],EAX\n", n->id);

                if (n->tipo == CHAR)
                    fprintf(yyout, "\tMOV\tbyte [%s],AL\n", n->id);
            }
        }
        break;
    case ICONST:
        fprintf(comout, "ICONST");
        if (n->reg == 'a')
            fprintf(yyout, "\tMOV\tEAX,%d\n", n->val.ival);
        else
            fprintf(yyout, "\tMOV\tEBX,%d\n", n->val.ival);
        break;

    case FCONST:
        fprintf(comout, "FCONST");
        if (n->reg == 'a')
            fprintf(yyout, "\tMOV\tdword [tempvar1],__float32__(%f)\n", n->val.fval);
        else
            fprintf(yyout, "\tMOV\tdword [tempvar2],__float32__(%f)\n", n->val.fval);
        break;

    case CCONST:
        fprintf(comout, "CCONST");
        if (n->reg == 'a')
            fprintf(yyout, "\tMOV\tAL,'%c'\n", n->val.cval);
        else
            fprintf(yyout, "\tMOV\tBL,'%c'\n", n->val.cval);
        break;

    case VAR:
        fprintf(comout, "VAR(%s)", n->id);

        if (n->tipo != FLOAT)
        {

            if (n->reg == 'a')
                fprintf(yyout, "\tMOV\tEAX,[%s]\n", n->id);
            else
                fprintf(yyout, "\tMOV\tEBX,[%s]\n", n->id);
        }
        else
        {
            if (n->reg == 'a')
            {

                fprintf(yyout, "\tMOV\tEAX,[%s]\n", n->id);
                fprintf(yyout, "\tMOV\t[tempvar1],EAX\n", n->id);
            }
            else
            {
                fprintf(yyout, "\tMOV\tEBX,[%s]\n", n->id);
                fprintf(yyout, "\tMOV\t[tempvar2],EBX\n", n->id);
            }
        }
        break;

    case EXPS:
        n->lookahead->reg = 'a';
        n->lookahead1->reg = 'b';

        if (n->hasParen)
            fprintf(comout, "(");

        imprime(n->lookahead);
        getOpCom(msg, n->op);
        fprintf(comout, " %s ", msg);
        imprime(n->lookahead1);

        if (n->hasParen)
            fprintf(comout, ")");

        if (((n->lookahead->tipo == FLOAT) || (n->lookahead1->tipo == FLOAT)) && (n->op == MOD)) //deu ruim
        {
            fprintf(stderr, "Nao pode mod com operandos nao inteiros");
            exit(1);
        }

        if (n->lookahead->tipo != FLOAT && n->lookahead1->tipo != FLOAT) // tudo int
        {
            n->tipo = INT;
            if (n->op == DIV || n->op == MOD)
            {
                fprintf(yyout, "\tMOV\tEDX,0\n", msg);
                fprintf(yyout, "\tIDIV\tEBX\n", msg);
            }
            else if (n->op == MUL)
            {
                fprintf(yyout, "\tIMUL\tEBX\n", msg);
            }
            else
            {
                getOp(msg, n->op);
                fprintf(yyout, "\t%s\tEAX,EBX\n", msg);
            }
            if (n->op == MOD)
                fprintf(yyout, "\tMOV\tEAX,EDX\n");

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

            fprintf(yyout, "\tFLD\tdword [tempvar1]\n");
            fprintf(yyout, "\tFILD\tdword [tempvar2]\n");
            fprintf(yyout, "\tFSTP\tdword [tempvar2]\n");
            fprintf(yyout, "\t%s\tdword [tempvar2]\n", msg);
            if (n->reg == 'a')
                fprintf(yyout, "\tFSTP\tdword [tempvar1]\n");
            else
                fprintf(yyout, "\tFSTP\tdword [tempvar2]\n");
        }
        else if (n->lookahead->tipo != FLOAT) // n é float
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
    case ROP:
        n->lookahead->reg = 'a';
        n->lookahead1->reg = 'b';

        if (n->hasParen)
            fprintf(comout, "(");

        imprime(n->lookahead);
        getOpCom(msg, n->op);
        fprintf(comout, " %s ", msg);
        imprime(n->lookahead1);

        if (n->hasParen)
            fprintf(comout, ")");

        getLabel(la1);
        getLabel(la2);
        n->tipo = INT;
        if (n->lookahead->tipo != FLOAT && n->lookahead1->tipo != FLOAT) // nenhum eh float
        {
            fprintf(yyout, "\tCMP\tEAX,EBX\n"); // compara
            getCmp(msg, n->op);
        }
        else
        {
            if (n->lookahead1->tipo != FLOAT) // a é float
            {
                fprintf(yyout, "\tMOV\t[tempvar2],EBX\n");
                fprintf(yyout, "\tFILD\tdword [tempvar2]\n");
                fprintf(yyout, "\tFLD\tdword [tempvar1]\n");
            }
            else if (n->lookahead->tipo != FLOAT) // b é float
            {
                fprintf(yyout, "\tFLD\tdword [tempvar2]\n");
                fprintf(yyout, "\tMOV\t[tempvar1],EAX\n");
                fprintf(yyout, "\tFILD\tdword [tempvar1]\n");
            }
            else // os 2 são float
            {
                fprintf(yyout, "\tFLD\tdword [tempvar2]\n");
                fprintf(yyout, "\tFLD\tdword [tempvar1]\n");
            }
            fprintf(yyout, "\tFCOMIP\n");
            fprintf(yyout, "\tFSTP\tST0\n");
            getFloatCmp(msg, n->op);
        }

        fprintf(yyout, "\t%s\t%s\n", msg, la1); // se deu certo pula pro la1

        if (n->reg == 'a')
            fprintf(yyout, "\tMOV\tEAX,0\n"); // se n pulou resposta eh 0
        else
            fprintf(yyout, "\tMOV\tEBX,0\n"); // se n pulou resposta eh 0

        fprintf(yyout, "\tJMP\t%s\n", la2); // pula pro final que eh la2

        if (n->reg == 'a')
            fprintf(yyout, "%s:\tMOV\tEAX,1\n", la1);
        else
            fprintf(yyout, "%s:\tMOV\tEBX,1\n", la1);

        fprintf(yyout, "%s:\n", la2);
        break;

    case LOP:
        n->lookahead->reg = 'a';
        n->lookahead1->reg = 'b';

        if (n->hasParen)
            fprintf(comout, "(");

        imprime(n->lookahead);
        getOpCom(msg, n->op);
        fprintf(comout, " %s ", msg);
        imprime(n->lookahead1);

        if (n->hasParen)
            fprintf(comout, ")");

        getLabel(la1);
        getLabel(la2);
        n->tipo = INT;
        if (n->lookahead->tipo == FLOAT)
            fprintf(yyout, "\tMOV\tEAX,[tempvar1]");
        if (n->lookahead1->tipo == FLOAT)
            fprintf(yyout, "\tMOV\tEBX,[tempvar2]");

        switch (n->op)
        {
        case AND:
            fprintf(yyout, "\tCMP\tEAX,0\n");
            fprintf(yyout, "\tJE\t%s\n", la1);
            fprintf(yyout, "\tCMP\tEBX,0\n");
            fprintf(yyout, "\tJE\t%s\n", la1);

            if (n->reg == 'a')
                fprintf(yyout, "\tMOV\tEAX,1\n");
            else
                fprintf(yyout, "\tMOV\tEBX,1\n");

            fprintf(yyout, "\tJMP\t%s\n", la2);

            if (n->reg == 'a')
                fprintf(yyout, "%s:\tMOV\tEAX,0\n", la1);
            else
                fprintf(yyout, "%s:\tMOV\tEBX,0\n", la1);
            fprintf(yyout, "%s:", la2);
            break;
        case OR:
            fprintf(yyout, "\tCMP\tEAX,1\n");
            fprintf(yyout, "\tJE\t%s\n", la1);
            fprintf(yyout, "\tCMP\tEBX,1\n");
            fprintf(yyout, "\tJE\t%s\n", la1);

            if (n->reg == 'a')
                fprintf(yyout, "\tMOV\tEAX,0\n");
            else
                fprintf(yyout, "\tMOV\tEBX,0\n");

            fprintf(yyout, "\tJMP\t%s\n", la2);

            if (n->reg == 'a')
                fprintf(yyout, "%s:\tMOV\tEAX,1\n", la1);
            else
                fprintf(yyout, "%s:\tMOV\tEBX,1\n", la1);
            fprintf(yyout, "%s:", la2);
            break;
        case XOR:
            fprintf(yyout, "\tCMP\tEAX,EBX\n");
            fprintf(yyout, "\tJE\t%s\n", la1);

            if (n->reg == 'a')
                fprintf(yyout, "\tMOV\tEAX,1\n");
            else
                fprintf(yyout, "\tMOV\tEBX,1\n");

            fprintf(yyout, "\tJMP\t%s\n", la2);

            if (n->reg == 'a')
                fprintf(yyout, "%s:\tMOV\tEAX,0\n", la1);
            else
                fprintf(yyout, "%s:\tMOV\tEBX,0\n", la1);
            fprintf(yyout, "%s:", la2);
            break;
        }

        break;
    case NOT:
        n->lookahead->reg = 'a';
        fprintf(comout, "not ");
        imprime(n->lookahead);

        getLabel(la1);
        getLabel(la2);
        n->tipo = INT;
        if (n->lookahead->tipo == FLOAT)
            fprintf(yyout, "\tMOV\tEAX,[tempvar1]\n");
        fprintf(yyout, "\tCMP\tEAX,0\n");
        fprintf(yyout, "\tJE\t%s\n", la1);
        fprintf(yyout, "\tMOV\tEAX,0\n");
        fprintf(yyout, "\tJMP\t%s\n", la2);
        fprintf(yyout, "%s:\tMOV\tEAX,1\n", la1);
        fprintf(yyout, "%s:\n", la2);

        break;
    case OUT:
        fprintf(comout, "COMANDO SAIDA(");
        imprime(n->lookahead);
        fprintf(comout, ")\n");
        switch (n->lookahead->tipo)
        {
        case INT:
            fprintf(yyout, "\tPUSH\tEAX\n");
            fprintf(yyout, "\tPUSH\tintFmt\n");
            fprintf(yyout, "\tCALL\tprintf\n");
            fprintf(yyout, "\tADD\tESP,8\n");
            break;
        case CHAR:
            fprintf(yyout, "\tPUSH\tEAX\n");
            fprintf(yyout, "\tPUSH\tcharFmt\n");
            fprintf(yyout, "\tCALL\tprintf\n");
            fprintf(yyout, "\tADD\tESP,8\n");
            break;
        case FLOAT:
            fprintf(yyout, "\tSUB\tESP,8\n");
            fprintf(yyout, "\tFLD\tdword [tempvar1]\n");
            fprintf(yyout, "\tFSTP\tqword [ESP]\n");
            fprintf(yyout, "\tPUSH\tfloatFmt\n");
            fprintf(yyout, "\tCALL\tprintf\n");
            fprintf(yyout, "\tADD\tESP,12\n");
            break;

        default:
            break;
        }
        break;
    case INP:
        fprintf(comout, "COMANDO ENTRADA(VAR(%s))\n", n->id);

        switch (n->tipo)
        {
        case INT:
            fprintf(yyout, "\tPUSH\t%s\n", n->id);
            fprintf(yyout, "\tPUSH\tintRd\n");
            fprintf(yyout, "\tCALL\tscanf\n");
            fprintf(yyout, "\tADD\tESP,8\n");
            break;
        case CHAR:
            fprintf(yyout, "\tPUSH\t%s\n", n->id);
            fprintf(yyout, "\tPUSH\tcharRd\n");
            fprintf(yyout, "\tCALL\tscanf\n");
            fprintf(yyout, "\tADD\tESP,8\n");
            break;
        case FLOAT:
            fprintf(yyout, "\tPUSH\t%s\n", n->id);
            fprintf(yyout, "\tPUSH\tfloatRd\n");
            fprintf(yyout, "\tCALL\tscanf\n");
            fprintf(yyout, "\tADD\tESP,8\n");
            break;

        default:
            break;
        }
        break;
    case NEXP:
        fprintf(comout, "-");
        if (n->lookahead->token == ICONST)
        {
            if (n->reg == 'a')
                fprintf(yyout, "\tMOV\tEAX,-%d\n", n->lookahead->val.ival);
            else
                fprintf(yyout, "\tMOV\tEBX,-%d\n", n->lookahead->val.ival);
            break;
        }
        else if (n->lookahead->token == CCONST)
        {
            if (n->reg == 'a')
                fprintf(yyout, "\tMOV\tAL,-'%c'\n", n->lookahead->val.cval);
            else
                fprintf(yyout, "\tMOV\tBL,-'%c'\n", n->lookahead->val.cval);
            break;
        }
        else
        {
            n->lookahead->reg = n->reg;
            imprime(n->lookahead);
            n->tipo = n->lookahead->tipo;

            if (n->lookahead->tipo == FLOAT)
            {
                if (n->reg == 'a')
                    fprintf(yyout, "\tXOR\tdword [tempvar1],0x80000000\n");

                else
                    fprintf(yyout, "\tXOR\tdword [tempvar2],0x80000000\n");
            }
            else
            {
                if (n->reg == 'a')
                    fprintf(yyout, "\tNEGL\tEAX\n");

                else
                    fprintf(yyout, "\tNEGL\tEBX\n");
            }
            break;
        }
        break;
    case IF:
        fprintf(comout, "COMANDO CONDICIONAL\n");

        n->lookahead->reg = 'a';
        imprime(n->lookahead);
        getLabel(la1);
        if (n->lookahead->tipo == FLOAT)
            fprintf(yyout, "\tMOV\tEAX,[tempvar1]\n");

        fprintf(yyout, "\tCMP\tEAX,0\n");
        fprintf(yyout, "\tJE\t%s\n", la1);
        imprime(n->lookahead1);
        if (n->dir != NULL && n->dir->token == ELSE)
        {
            getLabel(la2);
            fprintf(yyout, "\tJMP\t%s\n", la2);
            strcpy(laTmp, la2);
        }
        fprintf(yyout, "%s:\n", la1);
        fprintf(comout, "FIM CONDICIONAL\n");
        break;
    case ELSE:
        fprintf(comout, "ELSE\n");
        imprime(n->lookahead);
        fprintf(yyout, "%s:\n", laTmp);
        fprintf(comout, "FIM ELSE\n");
        break;
    case WHILE:

        n->lookahead->reg = 'a';
        getLabel(la1);
        getLabel(la2);

        fprintf(yyout, "%s:\n", la1);
        fprintf(comout, "COMANDO REPETICAO(");
        imprime(n->lookahead);
        fprintf(comout, ")\n");

        if (n->lookahead->tipo == FLOAT)
            fprintf(yyout, "\tMOV\tEAX,[tempvar1]\n");

        fprintf(yyout, "\tCMP\tEAX,0\n");
        fprintf(yyout, "\tJE\t%s\n", la2);

        imprime(n->lookahead1);
        fprintf(yyout, "\tJMP\t%s\n", la1);

        fprintf(yyout, "%s:\n", la2);
        fprintf(comout, "FIM REPETICAO\n");

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
        printf("Erro, getop de %d", op);
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
        printf("Erro, getfloatop de %d", op);
        strcpy(msg, "!ERROR!");
        return;
    }
}

void getCmp(char *msg, int op)
{
    switch (op)
    {
    case EQU:
        strcpy(msg, "JE");
        return;
    case DIF:
        strcpy(msg, "JNE");
        return;
    case GRT:
        strcpy(msg, "JG");
        return;
    case GEQ:
        strcpy(msg, "JGE");
        return;
    case LES:
        strcpy(msg, "JL");
        return;
    case LEQ:
        strcpy(msg, "JLE");
        return;

    default:
        printf("Erro, getcmp de %d", op);
        strcpy(msg, "!ERROR!");
        return;
    }
}

void getFloatCmp(char *msg, int op)
{
    switch (op)
    {
    case EQU:
        strcpy(msg, "JE");
        return;
    case DIF:
        strcpy(msg, "JNE");
        return;
    case GRT:
        strcpy(msg, "JA");
        return;
    case GEQ:
        strcpy(msg, "JAE");
        return;
    case LES:
        strcpy(msg, "JB");
        return;
    case LEQ:
        strcpy(msg, "JBE");
        return;

    default:
        printf("Erro, getFloatCmp de %d", op);
        strcpy(msg, "!ERROR!");
        return;
    }
}

void getOpCom(char *msg, int op)
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
        strcpy(msg, "MUL");
        return;
    case DIV:
        strcpy(msg, "DIV");
        return;
    case AND:
        strcpy(msg, "AND");
        return;
    case OR:
        strcpy(msg, "OR");
        return;
    case XOR:
        strcpy(msg, "XOR");
        return;
    case EQU:
        strcpy(msg, "EQU");
        return;
    case DIF:
        strcpy(msg, "DIF");
        return;
    case GRT:
        strcpy(msg, "GRT");
        return;
    case GEQ:
        strcpy(msg, "GEQ");
        return;
    case LES:
        strcpy(msg, "LES");
        return;
    case LEQ:
        strcpy(msg, "LEQ");
        return;
    case MOD:
        strcpy(msg, "MOD");
        return;

    default:
        printf("Erro, getopcom de %d", op);
        strcpy(msg, "!ERROR!");
        return;
    }
}
