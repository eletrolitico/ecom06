#include <stdio.h>
#include "lex.yy.c"

FILE *yyin;
FILE *out;

int main()
{
    yyin = stdin;
    out = stdout;

    fprintf(out, ".data\n");
    do
    {
        yyparse();
    } while (!feof(yyin));

    fprintf(stderr, "ACCEPTED!\n\n");

    return 0;
}