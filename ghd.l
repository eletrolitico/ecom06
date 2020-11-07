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
"begin"             {fprintf(tokout,"BEGINPROG\n");return BEGINPROG;}
"end"               {fprintf(tokout,"ENDPROG\n");return ENDPROG;}

"+"					{ fprintf(tokout,"ADD\n");return ADD; }
"-"					{ fprintf(tokout,"SUB\n");return SUB; }
"*"					{ fprintf(tokout,"MUL\n");return MUL; }
"/"					{ fprintf(tokout,"DIV\n");return DIV; }
"mod"               { fprintf(tokout,"MOD\n");return MOD; }
"or"				{ fprintf(tokout,"OR\n");return OR;  }
"and"				{ fprintf(tokout,"AND\n");return AND; }
"xor"				{ fprintf(tokout,"XOR\n");return XOR; }
"not"				{ fprintf(tokout,"NOT\n");return NOT; }
"=="				{ fprintf(tokout,"EQU\n");return EQU; }
"!="				{ fprintf(tokout,"DIF\n");return DIF; }
">"					{ fprintf(tokout,"GRT\n");return GRT; }
"<"					{ fprintf(tokout,"LES\n");return LES; }
">="				{ fprintf(tokout,"GEQ\n");return GEQ; }
"<="				{ fprintf(tokout,"LEQ\n");return LEQ; }

"="                 { fprintf(tokout,"ASSIGN\n");return ASSIGN;}
";"                 { fprintf(tokout,"SEMICOLON\n");return SEMICOLON;}
"("                 { fprintf(tokout,"P_OPEN\n");return P_OPEN;}
")"                 { fprintf(tokout,"P_CLOSE\n");return P_CLOSE;}
"{"                 { fprintf(tokout,"B_BLOCK\n");return B_BLOCK;}
"}"                 { fprintf(tokout,"E_BLOCK\n");return E_BLOCK;}
"int"               { fprintf(tokout,"T_INT\n");return T_INT;}
"char"              { fprintf(tokout,"T_CHAR\n");return T_CHAR;}
"float"             { fprintf(tokout,"T_FLOAT\n");return T_FLOAT;}
"input"             { fprintf(tokout,"INP\n");return INP;}
"output"            { fprintf(tokout,"OUT\n");return OUT;}
"if"                { fprintf(tokout,"IF\n");return IF;}
"else"              { fprintf(tokout,"ELSE\n");return ELSE;}
"while"             { fprintf(tokout,"WHILE\n");return WHILE;}

{ID} 			{
					yylval.id = strdup(yytext);
					fprintf(tokout,"ID\n");
					return ID;
				}
{ICONST} 		{ fprintf(tokout,"ICONST\n");yylval.val.ival = atoi(yytext); return ICONST; }
{FCONST} 		{ fprintf(tokout,"FCONST\n");yylval.val.fval = atof(yytext); return FCONST; }
{CCONST} 		{ fprintf(tokout,"CCONST\n");yylval.val.cval = yytext[1];    return CCONST; }

"\n"                    {lineno++;}
[ \t\r\f]+              /* skip whitespace */
.                       { 
							strcat(yytext, " lexical error: unrecognized character");
							yyerror(yytext);
						}

%%
