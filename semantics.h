#ifndef SEMANTICS_H
#define SEMANTICS_H

/* token types */
#define UNDEF 0
#define INT_TYPE 1
#define REAL_TYPE 2
#define CHAR_TYPE 3
#define STR_TYPE 4
#define ARRAY_TYPE 5
#define POINTER_TYPE 6
#define FUNCTION_TYPE 7
#define VOID_TYPE 8

/* operator types */
#define NONE 0      // to check types only - assignment, parameter
#define ARITHM_OP 1 // ADDOP, SUBOP, MULOP, DIVOP (+, -, *, /)
#define BOOL_OP 3   // OROP, ANDOP (||, &&)
#define NOT_OP 4    // NOTOP (!)
#define REL_OP 5    // RELOP (>, <, >=, <=)
#define EQU_OP 6    // EQUOP (==, !=)

#endif