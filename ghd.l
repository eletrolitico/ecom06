%option noyywrap

%{
    #include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
	#include "symtab.h"
	#include "semantics.h"
	#include "ast.h"
	#include "ghd.tab.h"
	extern FILE *yyin;
	extern FILE *yyout;
	
	int lineno = 1; // initialize to 1
	void ret_print(char *token_type);
	void yyerror();
%}

letter 		[a-zA-Z]
digit 		[0-9]
alnum 		{letter}|{digit}
print		[ -~]

ID 			{letter}+{alnum}*
ICONST		"0"|[0-9]{digit}*
FCONST		"0"|{digit}*"."{digit}+
CCONST		(\'{print}\')|(\'\\[nftrbv]\')
STRING		\"{print}*\"

%%
"begin"             {return BEGINPROG;}
"end"               {return ENDPROG;}

"+"					{ yylval.val.ival = ADD; return ADDOP; }
"-"					{ yylval.val.ival = SUB; return ADDOP; }
"*"					{ return MULOP; }
"/"					{ return DIVOP; }
"mod"               {return MODOP;}
"or"				{ return OROP; }
"and"				{ return ANDOP; }
"xor"				{ return XOROP; }
"not"				{ return NOTOP; }
"=="				{ yylval.val.ival = EQUAL; return EQUOP; }
"!="				{ yylval.val.ival = NOT_EQUAL; return EQUOP; }
">"					{ yylval.val.ival = GREATER; return RELOP; }
"<"					{ yylval.val.ival = LESS; return RELOP; }
">="				{ yylval.val.ival = GREATER_EQUAL; return RELOP; }
"<="				{ yylval.val.ival = LESS_EQUAL; return RELOP; }

"="                 {return ASSIGN;}
";"                 {return SEMI;}
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
					insert(yytext, strlen(yytext), UNDEF, lineno);
					yylval.symtab_item = lookup(yytext);
					return ID;
				}
{ICONST} 		{ yylval.val.ival = atoi(yytext); return ICONST; }
{FCONST} 		{ yylval.val.fval = atof(yytext); return FCONST; }
{CCONST} 		{ yylval.val.cval = yytext[1];    return CCONST; }
{STRING} 		{ 
				  add_to_str_messages(yytext);
				  yylval.val.sval = malloc(yyleng * sizeof(char));
				  strcpy(yylval.val.sval, yytext);  return STRING;
				}

"\n"                    {lineno++;}
[ \t\r\f]+              /* skip whitespace */
.                       { yyerror("character unrecognized"); }

%%