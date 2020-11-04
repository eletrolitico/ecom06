#ifndef SYMTAB_H
#define SYMTAB_H

#define MAXTOKENLEN 32

typedef union Value
{
	int ival;
	double fval;
	char cval;
	char *sval;
} Value;

typedef struct RefList
{
	int lineno;
	struct RefList *next;
} RefList;

typedef struct sym_lst
{
	char st_name[MAXTOKENLEN];
	int st_size;
	RefList *lines;

	// to store value
	Value val;

	// type
	int st_type;

	/* register assignment stuff */
	int g_index;
	int reg_name;

	// pointer to next item in the list
	struct sym_lst *next;
} sym_lst;

sym_lst *insert(char *, int);

#endif