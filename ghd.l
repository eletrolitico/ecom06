%option noyywrap

%{
    #include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
	#include "ast.h"
	#include "ghd.tab.h"
	extern FILE *yyin;
	extern FILE *yyout;
	
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
"begin"             {return BEGINPROG;}
"end"               {return ENDPROG;}

"+"					{ return ADD; }
"-"					{ return SUB; }
"*"					{ return MUL; }
"/"					{ return DIV; }
"mod"               { return MOD; }
"or"				{ return OR;  }
"and"				{ return AND; }
"xor"				{ return XOR; }
"not"				{ return NOT; }
"=="				{ return EQU; }
"!="				{ return DIF; }
">"					{ return GRT; }
"<"					{ return LES; }
">="				{ return GEQ; }
"<="				{ return LEQ; }

"="                 {return ASSIGN;}
";"                 {return SEMICOLON;}
"("                 {return P_OPEN;}
")"                 {return P_CLOSE;}
"{"                 {return B_BLOCK;}
"}"                 {return E_BLOCK;}
"int"               {return T_INT;}
"char"              {return T_CHAR;}
"float"             {return T_FLOAT;}
"input"             {return INP;}
"output"            {return OUT;}
"if"                {return IF;}
"else"              {return ELSE;}
"while"             {return WHILE;}

{ID} 			{
					yylval.id = strdup(yytext);
					return ID;
				}
{ICONST} 		{ yylval.val.ival = atoi(yytext); return ICONST; }
{FCONST} 		{ yylval.val.fval = atof(yytext); return FCONST; }
{CCONST} 		{ yylval.val.cval = yytext[1];    return CCONST; }

"\n"                    {lineno++;}
[ \t\r\f]+              /* skip whitespace */
.                       { 
							strcat(yytext, " lexical error: unrecognized character");
							yyerror(yytext);
						}

%%
