#include "symtab.h"

#include <string.h>
#include <stdlib.h>

sym_lst *lista = 0;

void insertLine(RefList **ref, int line)
{
	RefList *aux;

	if (!*ref)
	{
		*ref = malloc(sizeof(RefList));
		aux = *ref;
		aux->lineno = line;
		return;
	}

	aux = *ref;
	while (aux && aux->next)
	{
		aux = aux->next;
	}

	aux->next = malloc(sizeof(RefList));
	aux->next->lineno = line;
	aux->next->next = 0;
}

sym_lst *insert(char *id, int line)
{
	sym_lst *aux = lista;
	if (!aux)
	{
		lista = malloc(sizeof(sym_lst));
		aux = lista;
	}
	else
	{
		while (aux != NULL && aux->next != NULL && strcmp(aux->st_name, id) != 0)
			aux = aux->next;

		if (strcmp(aux->st_name, id) == 0)
		{
			insertLine(&aux->lines, line);
			return aux;
		}

		aux->next = malloc(sizeof(sym_lst));
		aux = aux->next;
	}

	memset(aux, 0, sizeof(sym_lst));
	insertLine(&aux->lines, line);
	aux->next = 0;
	strcpy(aux->st_name, id);
	return aux;
}
