%option noyywrap

%{
    #include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
	#include "ast.h"
	#include "ghd.tab.h"
	extern FILE *yyin;
	extern FILE *yyout;
	extern FILE *tokout;

	int lineno = 1; 
	void yyerror(char *msg);
%}

letter 		[a-zA-Z]
digit 		[0-9]
alnum 		{letter}|{digit}
print		[ -~]

ID 			{letter}+{alnum}*
ICONST		"0"|[0-9]{digit}*
FCONST		"0"|{digit}*"."{digit}+
CCONST		(\'{print}\')|(\'\\[nftrbv]\')

%%
"begin"             {fprintf(tokout,"BEGINPROG ");return BEGINPROG;}
"end"               {fprintf(tokout,"ENDPROG ");return ENDPROG;}

"+"					{ fprintf(tokout,"ADD ");return ADD; }
"-"					{ fprintf(tokout,"SUB ");return SUB; }
"*"					{ fprintf(tokout,"MUL ");return MUL; }
"/"					{ fprintf(tokout,"DIV ");return DIV; }
"mod"               { fprintf(tokout,"MOD ");return MOD; }
"or"				{ fprintf(tokout,"OR ");return OR;  }
"and"				{ fprintf(tokout,"AND ");return AND; }
"xor"				{ fprintf(tokout,"XOR ");return XOR; }
"not"				{ fprintf(tokout,"NOT ");return NOT; }
"=="				{ fprintf(tokout,"EQU ");return EQU; }
"!="				{ fprintf(tokout,"DIF ");return DIF; }
">"					{ fprintf(tokout,"GRT ");return GRT; }
"<"					{ fprintf(tokout,"LES ");return LES; }
">="				{ fprintf(tokout,"GEQ ");return GEQ; }
"<="				{ fprintf(tokout,"LEQ ");return LEQ; }

"="                 { fprintf(tokout,"ASSIGN ");return ASSIGN;}
";"                 { fprintf(tokout,"SEMICOLON ");return SEMICOLON;}
"("                 { fprintf(tokout,"P_OPEN ");return P_OPEN;}
")"                 { fprintf(tokout,"P_CLOSE ");return P_CLOSE;}
"{"                 { fprintf(tokout,"B_BLOCK ");return B_BLOCK;}
"}"                 { fprintf(tokout,"E_BLOCK ");return E_BLOCK;}
"int"               { fprintf(tokout,"T_INT ");return T_INT;}
"char"              { fprintf(tokout,"T_CHAR ");return T_CHAR;}
"float"             { fprintf(tokout,"T_FLOAT ");return T_FLOAT;}
"input"             { fprintf(tokout,"INP ");return INP;}
"output"            { fprintf(tokout,"OUT ");return OUT;}
"if"                { fprintf(tokout,"IF ");return IF;}
"else"              { fprintf(tokout,"ELSE ");return ELSE;}
"while"             { fprintf(tokout,"WHILE ");return WHILE;}

{ID} 			{
					yylval.id = strdup(yytext);
					fprintf(tokout,"ID ");
					return ID;
				}
{ICONST} 		{ fprintf(tokout,"ICONST ");yylval.val.ival = atoi(yytext); return ICONST; }
{FCONST} 		{ fprintf(tokout,"FCONST ");yylval.val.fval = atof(yytext); return FCONST; }
{CCONST} 		{ fprintf(tokout,"CCONST ");yylval.val.cval = yytext[1];    return CCONST; }

"\n"                    {fprintf(tokout,"\n");lineno++;}
[ \t\r\f]+              /* skip whitespace */
.                       { 
							strcat(yytext, " lexical error: unrecognized character");
							yyerror(yytext);
						}

%%
